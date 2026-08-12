import AppKit
import MascotAnimation
import MascotCore
import MascotWindow

/// Plays whatever `MascotVisibleState` says, plus the two things that are not
/// agent state at all: the summon transition and a direct drag.
///
/// The reduced state is the single source of truth for which row plays, manual
/// pause and ideating included — those reach here as `.paused` and `.ideating`
/// through the reducer's overrides, not as separate flags. `isRoaming` stays
/// separate because it is about *placement*, not about what the agent is doing.
@MainActor
final class AmbientAnimationController {
    var onSummonCompleted: (() -> Void)?
    /// Fires when a state reaches the screen, after the selector's dwell — not
    /// when it is reduced. Anything that accompanies an animation (today, the
    /// reaction cues) hangs off this so it stays in step with the frames.
    var onStateAppeared: ((MascotState) -> Void)?

    private enum Phase {
        case walking(direction: CGFloat, until: TimeInterval)
        /// An ambient pause between walks. `.infinity` means roaming is off.
        case resting(until: TimeInterval)
        /// Holding one state's row in place.
        case stationary
    }

    private let atlas: SpriteAtlas
    private let previewModel: MascotPreviewModel
    private let windowCoordinator: WindowCoordinator
    private let summonTimeline = PortalSummonTimeline()
    private var selector = AnimationSelector()
    private var frameCache: [String: [NSImage]] = [:]
    private var timer: Timer?
    private var summonStartedAt: TimeInterval?
    private var phase: Phase = .resting(until: 0)
    private var currentState = "offline"
    private var frameIndex = 0
    private var nextFrameTime: TimeInterval = 0
    private var previousTickTime: TimeInterval = 0
    private var lastWalkingDirection: CGFloat = 0
    private var isDragging = false
    private(set) var isVisible = false
    private(set) var isRoaming = true

    /// The state actually on screen, which lags the reduced state by at most the
    /// selector's dwell.
    private(set) var displayedState: MascotState = .offline

    private var plan: AnimationPlan { AnimationSelector.plan(for: displayedState) }

    init(atlas: SpriteAtlas, previewModel: MascotPreviewModel, windowCoordinator: WindowCoordinator) throws {
        self.atlas = atlas
        self.previewModel = previewModel
        self.windowCoordinator = windowCoordinator
        // Every declared row is cached, rather than a hand-listed subset: the
        // reduced state can now select any of them, and a missing row would show
        // up as a silently frozen pet.
        for row in atlas.contract.rows {
            frameCache[row.state] = try (0 ..< row.frames).map { try atlas.frame(state: row.state, index: $0) }
        }
        beginWalking(at: ProcessInfo.processInfo.systemUptime)
    }

    /// The only way agent state enters the animation.
    func setVisibleState(_ state: MascotState) {
        let now = ProcessInfo.processInfo.systemUptime
        adopt(selector.update(to: state, at: Uptime(seconds: now)), at: now)
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

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        let now = ProcessInfo.processInfo.systemUptime
        // Roaming only governs the strolling states. A working or waiting pet is
        // stationary either way, so toggling this must not yank it into a walk.
        if plan.isAmbient {
            if roaming {
                // Resuming roaming must not yank a dropped pet back down to the
                // lane; it only recovers placement for one that never moved.
                if !windowCoordinator.hasManualPlacement {
                    windowCoordinator.reposition()
                }
                beginWalking(at: now)
            } else {
                beginResting(at: now, duration: .infinity)
            }
        }
        if isVisible, displayedState != .paused { startTimer() }
    }

    func userDidBeginDrag() {
        finishSummon()
        isDragging = true
        currentState = "hanging"
        frameIndex = 0
        nextFrameTime = 0
        startTimer()
    }

    /// Resumes whatever the mascot was doing, from wherever it was dropped.
    ///
    /// Owner decision, 2026-07-30: a drop used to force `setRoaming(false)`, so
    /// the pet stopped where it was released and — with no agent connected —
    /// held the `offline` row's dozing Z-trail indefinitely. That read as the
    /// mascot breaking rather than as a manual placement. Dragging is now a
    /// placement gesture only: it moves the pet, it does not switch roaming off.
    ///
    /// The dropped height is kept, so the pet roams along X wherever it landed
    /// rather than falling back to the bottom lane. The owner asked for this
    /// after seeing the lane-snapping version and accepted that it means the
    /// mascot can walk through open air. Reposition returns it to the lane.
    func userDidEndDrag() {
        isDragging = false
        windowCoordinator.settleAfterDrop()
        let now = ProcessInfo.processInfo.systemUptime

        if displayedState == .paused {
            show(state: "paused", frame: 0)
            stopTimer()
            return
        }

        if plan.isAmbient {
            if isRoaming {
                beginWalking(at: now)
            } else {
                beginResting(at: now, duration: .infinity)
            }
        } else {
            phase = .stationary
            currentState = plan.restingRow
            frameIndex = 0
            nextFrameTime = 0
        }
        startTimer()
    }

    // MARK: - State adoption

    /// Reconfigures playback when the displayed state actually changes.
    private func adopt(_ state: MascotState, at now: TimeInterval) {
        guard state != displayedState else { return }
        displayedState = state
        onStateAppeared?(state)

        if state == .paused {
            show(state: "paused", frame: 0)
            stopTimer()
            return
        }

        switch AnimationSelector.plan(for: state) {
        case .ambient:
            if isRoaming {
                beginWalking(at: now)
            } else {
                beginResting(at: now, duration: .infinity)
            }
        case .stationary(let row):
            phase = .stationary
            currentState = row
            frameIndex = 0
            nextFrameTime = 0
        }

        if isVisible { startTimer() }
    }

    // MARK: - Timing

    private func startTimer(resetPhase: Bool = false) {
        guard isVisible else { return }
        guard displayedState != .paused || isDragging || summonStartedAt != nil else { return }
        if resetPhase, summonStartedAt == nil, plan.isAmbient {
            beginWalking(at: ProcessInfo.processInfo.systemUptime)
        }
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

        // Direct interaction outranks every agent state.
        if isDragging {
            advanceFrames(state: "hanging", now: now)
            return
        }

        // Commits a state the dwell was holding back; inert when none is pending.
        adopt(selector.tick(at: Uptime(seconds: now)), at: now)
        guard displayedState != .paused else { return }

        switch phase {
        case .stationary:
            advanceFrames(state: plan.restingRow, now: now)
        case let .walking(direction, until):
            if !isRoaming {
                beginResting(at: now, duration: .infinity)
                return
            }
            if now >= until {
                beginResting(at: now, duration: Double.random(in: 2.5 ... 5.0))
                return
            }
            let visibleDirection = move(direction: direction, elapsed: elapsed, now: now)
            advanceFrames(state: visibleDirection > 0 ? "walk-right" : "walk-left", now: now)
        case let .resting(until):
            advanceFrames(state: plan.restingRow, now: now)
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
        let backingScale = windowCoordinator.placementBackingScaleFactor
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

        if displayedState == .paused {
            show(state: "paused", frame: 0)
        } else if plan.isAmbient, isRoaming {
            beginWalking(at: now)
            show(state: currentState, frame: 0)
        } else if plan.isAmbient {
            beginResting(at: now, duration: .infinity)
            show(state: plan.restingRow, frame: 0)
        } else {
            phase = .stationary
            currentState = plan.restingRow
            show(state: currentState, frame: 0)
        }
        startTimer()
    }

    private func finishSummon() {
        summonStartedAt = nil
        previewModel.isSummoning = false
        previewModel.summonFrame = .resting
    }

    private func resumeAfterSummon(at now: TimeInterval) {
        if displayedState == .paused {
            show(state: "paused", frame: 0)
            stopTimer()
        } else if plan.isAmbient {
            if isRoaming {
                beginWalking(at: now)
            } else {
                beginResting(at: now, duration: .infinity)
            }
        } else {
            phase = .stationary
            currentState = plan.restingRow
            frameIndex = 0
            nextFrameTime = 0
        }
    }

    private func beginResting(at now: TimeInterval, duration: TimeInterval) {
        phase = .resting(until: now + duration)
        currentState = plan.restingRow
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
