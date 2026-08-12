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
    /// One chat application, its mascot, and the accessibility string that marks
    /// a response as being produced.
    ///
    /// **`streamingMarker` is `nil` until someone has actually seen the marker in
    /// that app's accessibility tree.** A `nil` marker means the app can be
    /// probed but is not watched: no guess, no plausible-looking constant that
    /// silently matches nothing. This is the type-level version of the rule the
    /// project learned the expensive way — the Claude marker was *discovered* by
    /// a probe, not predicted, and Chromium's lazily built tree meant nobody
    /// could have known it existed without asking.
    public struct Descriptor: Equatable, Sendable {
        public let bundleIdentifier: String
        public let displayName: String
        public let provider: EventProvider
        public let streamingMarker: String?
        /// An optional second condition on the element carrying the marker.
        /// Claude's marker sits on an `AXDocumentArticle`, and requiring both
        /// keeps the match specific; an app whose marker needs no such
        /// qualifier leaves this `nil`.
        public let streamingSubrole: String?

        public init(
            bundleIdentifier: String,
            displayName: String,
            provider: EventProvider,
            streamingMarker: String?,
            streamingSubrole: String? = nil
        ) {
            self.bundleIdentifier = bundleIdentifier
            self.displayName = displayName
            self.provider = provider
            self.streamingMarker = streamingMarker
            self.streamingSubrole = streamingSubrole
        }

        /// Whether this app can drive a mascot, as opposed to only being probed.
        public var isWatchable: Bool { streamingMarker != nil }
    }

    /// ChatGPT's desktop app really does ship as `com.openai.codex`, verified on
    /// the owner's machine 2026-08-11. It looks like a mistake and is not one —
    /// do not "correct" it to `com.openai.chatgpt`, which matches nothing.
    ///
    /// The mapping follows the wardrobe rule: the Claude app drives the Claude
    /// mascot, which wears orange, and the ChatGPT app drives the Codex mascot,
    /// which wears navy.
    public static let all: [Descriptor] = [
        Descriptor(
            bundleIdentifier: "com.anthropic.claudefordesktop",
            displayName: "Claude",
            provider: .claudeCode,
            // Found by probe and verified on screen 2026-08-11: an element with
            // subrole `AXDocumentArticle` carries this description while its
            // message streams, and reads `Message N of N` once it lands.
            streamingMarker: "Currently streaming message",
            streamingSubrole: "AXDocumentArticle"
        ),
        Descriptor(
            bundleIdentifier: "com.openai.codex",
            displayName: "ChatGPT",
            provider: .codex,
            // **Deliberately never watched, and this is not a gap.** The
            // identifier is not a mislabel: the ChatGPT desktop app *is* the
            // Codex app, so its turns fire the installed Codex hooks — observed
            // 2026-08-11 driving the navy mascot to its computer on an agentic
            // turn and on a plain conversational one alike. Hooks report the
            // real lifecycle (working, success, and failure); an accessibility
            // marker could only ever report "probably thinking", and `working`
            // outranks chat-ideating, so the pose would never even be seen.
            //
            // It stays listed so the probe can target it and so this reasoning
            // has somewhere to live. Do not "finish" it by capturing a marker.
            streamingMarker: nil
        ),
    ]

    public static var identifiers: [String: EventProvider] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.bundleIdentifier, $0.provider) })
    }

    /// The apps that can currently drive a mascot.
    public static var watchable: [Descriptor] { all.filter(\.isWatchable) }

    public static func descriptor(forBundleIdentifier identifier: String?) -> Descriptor? {
        guard let identifier else { return nil }
        return all.first { $0.bundleIdentifier == identifier }
    }

    /// The mascot that should react to this application, or `nil` for the
    /// overwhelming majority of apps, which are none of Dock Pet's business.
    public static func provider(forBundleIdentifier identifier: String?) -> EventProvider? {
        descriptor(forBundleIdentifier: identifier)?.provider
    }
}
