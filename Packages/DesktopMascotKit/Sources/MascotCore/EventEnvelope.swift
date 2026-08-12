import Foundation

/// Providers whose documented lifecycle hooks may drive mascot state.
public enum EventProvider: String, CaseIterable, Codable, Sendable {
    case claudeCode = "claude-code"
    case codex
}

/// The complete normalized lifecycle vocabulary. Anything outside this set fails closed.
public enum AgentEvent: String, CaseIterable, Codable, Sendable {
    case started
    case active
    case waiting
    case completed
    case failed
    case stopped
    case heartbeat
}

/// Coarse, non-identifying context for an event.
///
/// Unknown values are discarded rather than rejected: `detail` only refines a
/// reaction, so a provider adding vocabulary must not invalidate the `event`
/// that actually drives state.
public enum EventDetail: String, CaseIterable, Codable, Sendable {
    case tool
    case permission
    case input
    case network
    case timeout
    case cancelled
}

/// Where an agent turn is being driven from.
///
/// **This widens the envelope, which is a product decision and is recorded as
/// one** (owner, 2026-08-11). It exists because one provider now covers two
/// completely different experiences: the ChatGPT desktop app *is* the Codex app,
/// so a conversational chat turn and a terminal agent run arrive as byte-identical
/// hook events, and the owner wants them to look different — a chat should think,
/// an agent run should sit at its computer.
///
/// **What this is not.** It is a two-value enum, decided inside the hook helper
/// by looking at that process's own parent chain. No path, no command line, no
/// process name, and no bundle identifier ever leaves the helper; the app learns
/// only which of these two words applied. Unknown values decode to `nil` — like
/// `EventDetail`, an unrecognized surface must not invalidate the `event` that
/// actually drives state.
public enum EventSurface: String, CaseIterable, Codable, Sendable {
    /// Driven from a desktop app's chat interface — today, a turn in the ChatGPT
    /// app, which is the Codex app wearing a conversation.
    case desktopChat = "desktop-chat"
    /// Everything else, and the default for anything unrecognized.
    ///
    /// **It names the ordinary case rather than asserting that a TTY exists.**
    /// Claude Code hosted inside the Claude desktop app reports `commandLine`
    /// too, and that is deliberate: it is agent work and must keep sitting at its
    /// computer. Only an interface a person *converses* with belongs in the other
    /// case, so defaulting here is what makes an unknown origin behave exactly as
    /// Dock Pet did before surfaces existed.
    case commandLine = "command-line"
}

/// An opaque per-session identifier.
///
/// The allowed character set deliberately excludes path separators, spaces,
/// colons, and every other character needed to express a file path, URL, or
/// prose, so a session ID cannot structurally carry private content.
public struct SessionID: Hashable, Sendable, CustomStringConvertible {
    public static let maximumLength = 128

    private static let allowedCharacters = Set(
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_."
    )

    public let rawValue: String

    public init?(_ rawValue: String) {
        guard (1 ... Self.maximumLength).contains(rawValue.count) else { return nil }
        guard rawValue.allSatisfy(Self.allowedCharacters.contains) else { return nil }
        self.rawValue = rawValue
    }

    public var description: String { rawValue }
}

/// The only shape of agent information the app retains.
///
/// This type is the privacy boundary: it has no field for prompt text,
/// assistant text, transcript paths, code, tool arguments or output, file
/// paths, working directories, repository names, usernames, or tokens.
/// Adding such a field is a product decision, not an implementation detail.
///
/// `surface` was added on 2026-08-11 by exactly such a decision; see
/// `EventSurface` for what it carries and what it deliberately does not.
public struct EventEnvelope: Equatable, Sendable {
    public static let currentVersion = 1

    public let version: Int
    public let provider: EventProvider
    public let sessionID: SessionID
    public let event: AgentEvent
    public let occurredAt: Date
    public let detail: EventDetail?
    public let surface: EventSurface?

    public init(
        version: Int = EventEnvelope.currentVersion,
        provider: EventProvider,
        sessionID: SessionID,
        event: AgentEvent,
        occurredAt: Date,
        detail: EventDetail? = nil,
        surface: EventSurface? = nil
    ) {
        self.version = version
        self.provider = provider
        self.sessionID = sessionID
        self.event = event
        self.occurredAt = occurredAt
        self.detail = detail
        self.surface = surface
    }
}
