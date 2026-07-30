import Foundation

public struct PortalSummonFrame: Equatable, Sendable {
    public let progress: Double
    public let portalOpenness: Double
    public let petReveal: Double
    public let isComplete: Bool

    public static let resting = PortalSummonFrame(
        progress: 1,
        portalOpenness: 0,
        petReveal: 1,
        isComplete: true
    )

    public init(progress: Double, portalOpenness: Double, petReveal: Double, isComplete: Bool) {
        self.progress = progress
        self.portalOpenness = portalOpenness
        self.petReveal = petReveal
        self.isComplete = isComplete
    }
}

public struct PortalSummonTimeline: Sendable {
    public let duration: TimeInterval

    public init(duration: TimeInterval = 1.25) {
        self.duration = max(0.01, duration)
    }

    public func frame(at elapsed: TimeInterval) -> PortalSummonFrame {
        let progress = clamp(elapsed / duration)
        let opening = smoothstep(clamp(progress / 0.22))
        let closing = 1 - smoothstep(clamp((progress - 0.78) / 0.22))
        let portalOpenness = min(opening, closing)
        let petReveal = smoothstep(clamp((progress - 0.14) / 0.62))

        return PortalSummonFrame(
            progress: progress,
            portalOpenness: portalOpenness,
            petReveal: petReveal,
            isComplete: elapsed >= duration
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    private func smoothstep(_ value: Double) -> Double {
        value * value * (3 - 2 * value)
    }
}
