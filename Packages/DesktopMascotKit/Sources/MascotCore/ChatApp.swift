import Foundation

/// Which first-party chat apps are in front, if any.
///
/// This is the one signal Dock Pet takes from outside a provider hook.
///
/// **It began as the frontmost application's bundle identifier and is no longer
/// only that.** Frontmost alone cannot see a response begin or end, so it
/// produced a Thinker pose that ran continuously while the user read and typed
/// — the owner watched it and called it awkward, correctly. Since 2026-08-11
/// the app also reads **one attribute on one accessibility element** of the
/// Claude window to tell whether a response is being produced; see
/// `ChatActivityWatcher` for exactly what is read and the founding promise that
/// was reversed to allow it. Nothing about conversation content is read, kept,
/// or sent either way.
///
/// Browser tabs are out of scope on purpose, not for want of trying. Detecting
/// `claude.ai` or `chatgpt.com` in Chrome means reading the active tab's URL,
/// which is the user's browsing history — the line this project has refused to
/// cross since the first session. The cost is honest partial coverage: the
/// desktop apps drive the pet, the web ones do not, and `README.md` says so.
///
/// Owner decision, 2026-08-11, after observing that a long session in the
/// Claude or ChatGPT desktop app left the mascot strolling as though nothing
/// were happening.
public struct ChatPresence: Equatable, Sendable {
    /// What a chat app is doing, as far as its accessibility tree admits.
    ///
    /// **`open` deliberately produces no animation.** Until 2026-08-11 a
    /// frontmost chat app alone drove the Thinker pose, and the owner's verdict
    /// on watching it was that it looked "awkward and unsync" — because it was:
    /// the pet thought continuously while a human read, typed, and scrolled.
    /// Being in front is context for the other two cases, not evidence of
    /// thought.
    public enum Activity: Equatable, Sendable {
        /// The app is frontmost and quiet. No response is being produced.
        case open
        /// A response is being produced right now — the model is thinking, or
        /// its answer is streaming out. One state, because the user asked for
        /// one: the pose runs from the moment they press Enter until the last
        /// word lands.
        case generating
        /// A response finished moments ago. Held briefly by the watcher so the
        /// reducer can stay a pure function of its inputs with no timers of its
        /// own, exactly as it does for hook-driven reactions.
        case completed
    }

    /// What each provider's chat app is doing. Absent means "not running, not in
    /// front, or nothing to say".
    public var activities: [EventProvider: Activity]

    public static let none = ChatPresence()

    public init(activities: [EventProvider: Activity] = [:]) {
        self.activities = activities
    }

    public func providers(doing activity: Activity) -> Set<EventProvider> {
        Set(activities.filter { $0.value == activity }.keys)
    }
}

/// Maps a frontmost application to the mascot that should react to it.
///
/// A fixed allowlist rather than a pattern: "any app with `claude` in its
/// identifier" would match this project's own builds, unrelated software, and
/// anything a user renames, and an allowlist is auditable by reading it.
public enum ChatApp {
    /// ChatGPT's desktop app really does ship as `com.openai.codex`, verified on
    /// the owner's machine 2026-08-11. It looks like a mistake and is not one —
    /// do not "correct" it to `com.openai.chatgpt`, which matches nothing.
    ///
    /// The mapping follows the wardrobe rule: the Claude app drives the Claude
    /// mascot, which wears orange, and the ChatGPT app drives the Codex mascot,
    /// which wears navy.
    public static let identifiers: [String: EventProvider] = [
        "com.anthropic.claudefordesktop": .claudeCode,
        "com.openai.codex": .codex,
    ]

    /// The mascot that should react to this application, or `nil` for the
    /// overwhelming majority of apps, which are none of Dock Pet's business.
    public static func provider(forBundleIdentifier identifier: String?) -> EventProvider? {
        guard let identifier else { return nil }
        return identifiers[identifier]
    }
}
