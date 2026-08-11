import Foundation

/// Which first-party chat apps are in front, if any.
///
/// This is the one signal Dock Pet takes from outside a provider hook, and it
/// is deliberately the weakest thing that could work: the **bundle identifier
/// of the frontmost application**, compared against a fixed allowlist. No
/// window titles, no accessibility tree, no screen contents, no browser tabs,
/// nothing typed. The app learns "a chat app is in front" and nothing else, and
/// like everything else here it is never stored and never leaves the machine.
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
    /// The providers whose chat app is currently frontmost. Empty is the
    /// ordinary case.
    public var providers: Set<EventProvider>

    public static let none = ChatPresence()

    public init(providers: Set<EventProvider> = []) {
        self.providers = providers
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
