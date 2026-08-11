import Foundation
import MascotCore

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
        /// The pre-2026-08-11 app-wide roaming key. Read only, as the default
        /// for a provider that has not been set individually.
        static let roaming = "com.mrshine09.desktopmascot.roaming"
        static func roaming(for provider: EventProvider) -> String {
            "\(roaming).\(provider.rawValue)"
        }
        static let reactionSoundsMuted = "com.mrshine09.desktopmascot.reactionSoundsMuted"
        static let chatAppsDriveIdeating = "com.mrshine09.desktopmascot.chatAppsDriveIdeating"
        static let sleepScheduleEnabled = "com.mrshine09.desktopmascot.sleepScheduleEnabled"
        static let sleepStartHour = "com.mrshine09.desktopmascot.sleepStartHour"
        static let sleepEndHour = "com.mrshine09.desktopmascot.sleepEndHour"
        // The `desktopmascot` prefix is stale — the bundle identifier became
        // `dockpet` on 2026-08-05 — but it is matched deliberately. These are
        // arbitrary strings inside the app's own defaults domain, where the
        // prefix carries no meaning at all, and one consistent namespace is
        // worth more than a half-migrated one. Do not rename the existing two:
        // that resets every user's saved choice, which is why `reactionSounds`
        // is still called that.
    }

    /// `UserDefaults.standard` is read through a computed property rather than
    /// held in a `static let`: under strict concurrency it is not `Sendable`, and
    /// storing it would make this enum's state shared mutable state. Fetching it
    /// per access is free and keeps the type stateless.
    private static var defaults: UserDefaults { .standard }

    /// Whether one provider's mascot strolls or holds its position.
    ///
    /// Per mascot since 2026-08-11 (owner decision, after reporting that
    /// switching one pet to Stay in One Place stopped both). Each provider gets
    /// its own key, suffixed with the provider's raw value.
    ///
    /// The old app-wide `Key.roaming` is still **read** as the default for a
    /// provider that has no key of its own, so anyone who had already switched
    /// roaming off keeps that choice for both mascots on first launch after the
    /// upgrade. It is deliberately never written again — writing both would make
    /// two sources of truth for the same question. Do not delete the fallback to
    /// "tidy up": it is a one-way migration that costs one `object(forKey:)` and
    /// silently resets a saved choice if removed.
    static func roaming(for provider: EventProvider) -> Bool {
        let inherited = defaults.object(forKey: Key.roaming) as? Bool ?? true
        return defaults.object(forKey: Key.roaming(for: provider)) as? Bool ?? inherited
    }

    static func setRoaming(_ roaming: Bool, for provider: EventProvider) {
        defaults.set(roaming, forKey: Key.roaming(for: provider))
    }

    /// Whether a frontmost Claude or ChatGPT desktop app puts its mascot into
    /// the Thinker pose. Defaults to `true`, because it is the feature the owner
    /// asked for; the menu switch exists so it can be turned off without
    /// hunting through defaults.
    /// Defaults to **off**, changed from on when the feature grew teeth.
    ///
    /// It was on by default while it read nothing but the frontmost app's
    /// bundle identifier. It now needs Accessibility permission, and a feature
    /// that wants a powerful system permission has to be asked for rather than
    /// arrive switched on — particularly in an app whose selling point is that
    /// it cannot learn anything about you. It is also unproven on screen, and
    /// an unproven default is how a whole install looks broken.
    static var chatAppsDriveIdeating: Bool {
        get {
            defaults.object(forKey: Key.chatAppsDriveIdeating) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: Key.chatAppsDriveIdeating)
        }
    }

    /// Whether every cue is silenced — reactions and transitions alike.
    /// Defaults to `false`, so the cues work on first launch without hunting for
    /// a switch, but the choice to silence them persists, because being
    /// re-surprised by a sound you already turned off is the worse failure of
    /// the two.
    ///
    /// The stored key still says `reactionSounds`. It was named before summon
    /// and dismiss had cues, and renaming it would silently reset the choice of
    /// anyone who had already turned sound off.
    static var soundsMuted: Bool {
        get {
            defaults.bool(forKey: Key.reactionSoundsMuted)
        }
        set {
            defaults.set(newValue, forKey: Key.reactionSoundsMuted)
        }
    }

    /// The nightly sleep window, or `nil` when the user has switched scheduled
    /// sleep off. Defaults to the documented 23:00–06:00 on a fresh install.
    ///
    /// Stored as three keys rather than one encoded value so a partially written
    /// or hand-edited domain degrades to the default instead of failing to
    /// decode. `SleepWindow` clamps the hours, so a value outside `0 ... 23`
    /// cannot reach the reducer.
    static var sleepWindow: SleepWindow? {
        get {
            let enabled = defaults.object(forKey: Key.sleepScheduleEnabled) as? Bool ?? true
            guard enabled else { return nil }
            return SleepWindow(
                startHour: defaults.object(forKey: Key.sleepStartHour) as? Int ?? 23,
                endHour: defaults.object(forKey: Key.sleepEndHour) as? Int ?? 6
            )
        }
        set {
            defaults.set(newValue != nil, forKey: Key.sleepScheduleEnabled)
            // The hours are kept when sleep is switched off, so turning it back
            // on restores the schedule the user chose rather than the default.
            if let newValue {
                defaults.set(newValue.startHour, forKey: Key.sleepStartHour)
                defaults.set(newValue.endHour, forKey: Key.sleepEndHour)
            }
        }
    }

    /// The hours to show while sleep is switched off, so the menu can present
    /// the schedule that would resume rather than blanks.
    static var lastSleepHours: (start: Int, end: Int) {
        (
            defaults.object(forKey: Key.sleepStartHour) as? Int ?? 23,
            defaults.object(forKey: Key.sleepEndHour) as? Int ?? 6
        )
    }
}
