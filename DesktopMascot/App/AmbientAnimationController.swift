import AppKit
import MascotAnimation
import MascotWindow

@MainActor
final class AmbientAnimationController {
    var onSummonCompleted: (() -> Void)?

    private enum Phase {
        case walking(direction: CGFloat, until: TimeInterval)
        case offline(until: TimeInterval)
    }

    private let atlas: SpriteAtlas
    private let previewModel: MascotPreviewModel
    private let windowCoordinator: WindowCoordinator
    private let summonTimeline = PortalSummonTimeline()
    private var frameCache: [String: [NSImage]] = [:]
    private var timer: Timer?
    private var summonStartedAt: TimeInterval?
    private var phase: Phase = .offline(until: 0)
    private var currentState = "offline"
    private var frameIndex = 0
    private var nextFrameTime: TimeInterval = 0
    private var previousTickTime: TimeInterval = 0
    private var lastWalkingDirection: CGFloat = 0
    private var isDragging = false
    private(set) var isVisible = false
    private(set) var isPaused = false
    private(set) var isIdeating = false
    private(set) var isRoaming = true

    init(atlas: SpriteAtlas, previewModel: MascotPreviewModel, windowCoordinator: WindowCoordinator) throws {
        self.atlas = atlas
        self.previewModel = previewModel
        self.windowCoordinator = windowCoordinator
        for state in ["offline", "walk-right", "walk-left", "hanging", "paused", "ideating"] {
            guard let row = atlas.contract.row(named: state) else { continue }
            frameCache[state] = try (0 ..< row.frames).map { try atlas.frame(state: state, index: $0) }
        }
        beginWalking(at: ProcessInfo.processInfo.systemUptime)
    }

    func setVisible(_ visible: Bool) {
        isVisible = visible
        if visible {
            beginSummon(at: ProcessInfo.processInfo.systemUptime)
        } else {
            summonStartedAt = nil
            previewModel.isSummoning = false
            previewModel.summonFrame = .resting
            stopTimer()
        }
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused {
            if summonStartedAt == nil {
                show(state: "paused", frame: 0)
                stopTimer()
            }
        } else if isVisible {
            startTimer(resetPhase: summonStartedAt == nil)
        }
    }

    func setIdeating(_ ideating: Bool) {
        isIdeating = ideating
        if ideating {
            currentState = "ideating"
            frameIndex = 0
            nextFrameTime = 0
        } else {
            beginWalking(at: ProcessInfo.processInfo.systemUptime)
        }
        if isVisible, !isPaused { startTimer() }
    }

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        if roaming {
            windowCoordinator.reposition()
            beginWalking(at: ProcessInfo.processInfo.systemUptime)
        } else {
            beginOffline(at: ProcessInfo.processInfo.systemUptime, duration: .infinity)
        }
        if isVisible, !isPaused { startTimer() }
    }

    func userDidBeginDrag() {
        finishSummon()
        isDragging = true
        currentState = "hanging"
        frameIndex = 0
        nextFrameTime = 0
        startTimer()
    }

    func userDidEndDrag() {
        isDragging = false
        setRoaming(false)
        if isPaused {
            show(state: "paused", frame: 0)
            stopTimer()
        }
    }

    private func startTimer(resetPhase: Bool = false) {
        guard isVisible, !isPaused || isDragging || summonStartedAt != nil else { return }
        if resetPhase, summonStartedAt == nil { beginWalking(at: ProcessInfo.processInfo.systemUptime) }
        guard timer == nil else { return }
        previousTickTime = ProcessInfo.processInfo.systemUptime
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        tick()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = ProcessInfo.processInfo.systemUptime
        let elapsed = min(0.2, max(0, now - previousTickTime))
        previousTickTime = now

        if let summonStartedAt {
            let frame = summonTimeline.frame(at: now - summonStartedAt)
            previewModel.summonFrame = frame
            if frame.isComplete {
                finishSummon()
                resumeAfterSummon(at: now)
                onSummonCompleted?()
            }
            return
        }

        if isDragging {
            advanceFrames(state: "hanging", now: now)
            return
        }

        if isIdeating {
            advanceFrames(state: "ideating", now: now)
            return
        }

        switch phase {
        case let .walking(direction, until):
            if !isRoaming {
                beginOffline(at: now, duration: .infinity)
                return
            }
            if now >= until {
                beginOffline(at: now, duration: Double.random(in: 2.5 ... 5.0))
                return
            }
            let visibleDirection = move(direction: direction, elapsed: elapsed, now: now)
            advanceFrames(state: visibleDirection > 0 ? "walk-right" : "walk-left", now: now)
        case let .offline(until):
            advanceFrames(state: "offline", now: now)
            if isRoaming, now >= until {
                beginWalking(at: now)
            }
        }
    }

    private func move(direction: CGFloat, elapsed: TimeInterval, now: TimeInterval) -> CGFloat {
        guard let bounds = windowCoordinator.horizontalMovementBounds() else { return direction }
        var visibleDirection = direction
        var nextX = windowCoordinator.panel.frame.minX + direction * CGFloat(elapsed) * 24
        if nextX <= bounds.lowerBound || nextX >= bounds.upperBound {
            nextX = min(max(nextX, bounds.lowerBound), bounds.upperBound)
            let reversed = -direction
            phase = .walking(direction: reversed, until: now + Double.random(in: 6 ... 11))
            lastWalkingDirection = reversed
            visibleDirection = reversed
        }
        let backingScale = windowCoordinator.panel.screen?.backingScaleFactor ?? 2
        nextX = (nextX * backingScale).rounded() / backingScale
        windowCoordinator.setHorizontalPosition(nextX)
        return visibleDirection
    }

    private func beginWalking(at now: TimeInterval) {
        let bounds = windowCoordinator.horizontalMovementBounds()
        let direction: CGFloat
        if let bounds, windowCoordinator.panel.frame.minX <= bounds.lowerBound + 1 {
            direction = 1
        } else if let bounds, windowCoordinator.panel.frame.minX >= bounds.upperBound - 1 {
            direction = -1
        } else if lastWalkingDirection == 0 {
            let midpoint = bounds.map { ($0.lowerBound + $0.upperBound) / 2 } ?? 0
            direction = windowCoordinator.panel.frame.midX >= midpoint ? -1 : 1
        } else {
            direction = -lastWalkingDirection
        }
        lastWalkingDirection = direction
        phase = .walking(direction: direction, until: now + Double.random(in: 7 ... 13))
        currentState = direction > 0 ? "walk-right" : "walk-left"
        frameIndex = 0
        nextFrameTime = 0
    }

    private func beginSummon(at now: TimeInterval) {
        previewModel.usesReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        previewModel.isSummoning = true
        previewModel.summonFrame = summonTimeline.frame(at: 0)
        summonStartedAt = now

        if isPaused {
            show(state: "paused", frame: 0)
        } else if isIdeating {
            show(state: "ideating", frame: 0)
        } else if isRoaming {
            beginWalking(at: now)
            show(state: currentState, frame: 0)
        } else {
            beginOffline(at: now, duration: .infinity)
            show(state: "offline", frame: 0)
        }
        startTimer()
    }

    private func finishSummon() {
        summonStartedAt = nil
        previewModel.isSummoning = false
        previewModel.summonFrame = .resting
    }

    private func resumeAfterSummon(at now: TimeInterval) {
        if isPaused {
            show(state: "paused", frame: 0)
            stopTimer()
        } else if isIdeating {
            currentState = "ideating"
            frameIndex = 0
            nextFrameTime = 0
        } else if isRoaming {
            beginWalking(at: now)
        } else {
            beginOffline(at: now, duration: .infinity)
        }
    }

    private func beginOffline(at now: TimeInterval, duration: TimeInterval) {
        phase = .offline(until: now + duration)
        currentState = "offline"
        frameIndex = 0
        nextFrameTime = 0
    }

    private func advanceFrames(state: String, now: TimeInterval) {
        guard let frames = frameCache[state], !frames.isEmpty else { return }
        if currentState != state {
            currentState = state
            frameIndex = 0
            nextFrameTime = 0
        }
        if now >= nextFrameTime {
            show(state: state, frame: frameIndex)
            let duration = frameDuration(state: state, index: frameIndex)
            frameIndex = (frameIndex + 1) % frames.count
            nextFrameTime = now + duration
        }
    }

    private func show(state: String, frame: Int) {
        guard let frames = frameCache[state], frames.indices.contains(frame) else { return }
        previewModel.image = frames[frame]
    }

    private func frameDuration(state: String, index: Int) -> TimeInterval {
        guard
            let row = atlas.contract.row(named: state),
            row.durationsMS.indices.contains(index)
        else { return 0.15 }
        switch row.durationsMS[index] {
        case let .milliseconds(value): return Double(value) / 1_000
        case .hold: return 0.5
        }
    }
}
