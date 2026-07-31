import Foundation

/// The only things Dock Pet remembers between launches.
///
/// Deliberately tiny, and deliberately not a general settings store. Everything
/// here is a coarse user choice about presentation. Nothing derived from an
/// agent is persisted — no session, no provider, no event, no counter — because
/// the moment agent history is written to disk, "Dock Pet keeps no record of
/// your work" stops being true.
///
/// Two things that might look like settings are excluded on purpose:
/// - **Visibility.** The mascot is summoned deliberately, so every launch starts
///   unsummoned regardless of how the last one ended.
/// - **Preview state.** It is a testing mode; restoring it would leave the pet
///   stuck in a fabricated state with no memory of having asked for it.
enum Preferences {
    private enum Key {
        static let roaming = "com.mrshine09.desktopmascot.roaming"
        static let reactionSoundsMuted = "com.mrshine09.desktopmascot.reactionSoundsMuted"
    }

    /// `UserDefaults.standard` is read through a computed property rather than
    /// held in a `static let`: under strict concurrency it is not `Sendable`, and
    /// storing it would make this enum's state shared mutable state. Fetching it
    /// per access is free and keeps the type stateless.
    private static var defaults: UserDefaults { .standard }

    /// Whether the mascot strolls or holds its position. Defaults to `true` so a
    /// first launch behaves as the owner approved.
    static var roaming: Bool {
        get {
            defaults.object(forKey: Key.roaming) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Key.roaming)
        }
    }

    /// Whether the success/failure cues are silenced. Defaults to `false`, so
    /// the cues work on first launch without hunting for a switch — but the
    /// choice to silence them persists, because being re-surprised by a sound
    /// you already turned off is the worse failure of the two.
    static var reactionSoundsMuted: Bool {
        get {
            defaults.bool(forKey: Key.reactionSoundsMuted)
        }
        set {
            defaults.set(newValue, forKey: Key.reactionSoundsMuted)
        }
    }
}
