import Foundation

public struct PoofDismissFrame: Equatable, Sendable {
    public let progress: Double
    /// How far the smoke cloud has billowed out, `0` before the poof.
    public let smokeExpansion: Double
    public let smokeOpacity: Double
    /// `1` while the mascot is still forming the seal, falling to `0` inside the
    /// smoke.
    public let petReveal: Double
    public let isComplete: Bool

    public static let resting = PoofDismissFrame(
        progress: 0,
        smokeExpansion: 0,
        smokeOpacity: 0,
        petReveal: 1,
        isComplete: true
    )

    public init(
        progress: Double,
        smokeExpansion: Double,
        smokeOpacity: Double,
        petReveal: Double,
        isComplete: Bool
    ) {
        self.progress = progress
        self.smokeExpansion = smokeExpansion
        self.smokeOpacity = smokeOpacity
        self.petReveal = petReveal
        self.isComplete = isComplete
    }
}

/// The dismiss counterpart to `PortalSummonTimeline`: the mascot forms a ninja
/// hand seal, a smoke cloud bursts, and it is gone when the smoke clears.
///
/// The seal itself is not driven from here. The `hand-sign` atlas row plays on
/// its own declared durations, which sum to 350ms of movement before an
/// indefinite hold; `poofStart` is set later than that so the seal is always
/// finished and held by the time the smoke covers it. Changing either side means
/// re-checking the other.
public struct PoofDismissTimeline: Sendable {
    public static let defaultDuration: TimeInterval = 1.1
    /// Reduce Motion gets a short stationary fade instead — no seal, no smoke —
    /// matching how the summon transition degrades.
    public static let reducedMotionDuration: TimeInterval = 0.3

    /// Fraction of the run at which the smoke bursts.
    private static let poofStart = 0.40

    public let duration: TimeInterval
    public let usesReducedMotion: Bool

    /// Whether the `hand-sign` row should play. False under Reduce Motion, where
    /// the pet simply fades where it stands.
    public var playsSeal: Bool { !usesReducedMotion }

    public init(
        duration: TimeInterval = PoofDismissTimeline.defaultDuration,
        usesReducedMotion: Bool = false
    ) {
        self.duration = max(0.01, duration)
        self.usesReducedMotion = usesReducedMotion
    }

    public static func reducedMotion() -> PoofDismissTimeline {
        PoofDismissTimeline(duration: reducedMotionDuration, usesReducedMotion: true)
    }

    public func frame(at elapsed: TimeInterval) -> PoofDismissFrame {
        let progress = clamp(elapsed / duration)
        let isComplete = elapsed >= duration

        guard !usesReducedMotion else {
            return PoofDismissFrame(
                progress: progress,
                smokeExpansion: 0,
                smokeOpacity: 0,
                petReveal: 1 - smoothstep(progress),
                isComplete: isComplete
            )
        }

        let poofed = clamp((progress - Self.poofStart) / (1 - Self.poofStart))
        // The burst is near-instant and the drift is slow, so the cloud reads as
        // smoke rather than as a growing circle.
        let smokeExpansion = 1 - pow(1 - poofed, 3)
        let smokeOpacity = min(
            smoothstep(clamp((progress - Self.poofStart) / 0.06)),
            1 - smoothstep(clamp((progress - 0.62) / 0.38))
        )
        // The pet disappears while the smoke is at full opacity, so it is never
        // seen fading in the open.
        let petReveal = 1 - smoothstep(clamp((progress - Self.poofStart - 0.02) / 0.10))

        return PoofDismissFrame(
            progress: progress,
            smokeExpansion: smokeExpansion,
            smokeOpacity: smokeOpacity,
            petReveal: petReveal,
            isComplete: isComplete
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    private func smoothstep(_ value: Double) -> Double {
        value * value * (3 - 2 * value)
    }
}
