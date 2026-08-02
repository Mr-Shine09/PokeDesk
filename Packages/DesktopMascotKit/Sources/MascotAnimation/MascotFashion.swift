import MascotCore

/// Provider-specific wardrobe applied to the otherwise identical mascot.
///
/// Until 2026-08-01 this was a *selection*: one mascot was on screen and its
/// outfit was derived from whichever providers contributed to the single
/// reduced state. The owner replaced that with one mascot per provider, so a
/// wardrobe is now a fixed property of a mascot rather than something computed
/// from state. Claude Code wears the orange/sunglasses outfit and Codex wears
/// the original navy one — note that this is the reverse of the mapping used
/// before that date, and that `mascot-atlas-codex@2x.png` consequently holds
/// the *Claude* wardrobe. The filename is stale, not the mapping.
public enum MascotFashion: String, CaseIterable, Sendable {
    /// The original navy/white outfit.
    case classic
    /// The orange/white top with dark sunglasses.
    case orange

    /// The wardrobe worn by the given provider's mascot.
    public static func worn(by provider: EventProvider) -> MascotFashion {
        switch provider {
        case .claudeCode: .orange
        case .codex: .classic
        }
    }
}
