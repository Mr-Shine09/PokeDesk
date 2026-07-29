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
public struct EventEnvelope: Equatable, Sendable {
    public static let currentVersion = 1

    public let version: Int
    public let provider: EventProvider
    public let sessionID: SessionID
    public let event: AgentEvent
    public let occurredAt: Date
    public let detail: EventDetail?

    public init(
        version: Int = EventEnvelope.currentVersion,
        provider: EventProvider,
        sessionID: SessionID,
        event: AgentEvent,
        occurredAt: Date,
        detail: EventDetail? = nil
    ) {
        self.version = version
        self.provider = provider
        self.sessionID = sessionID
        self.event = event
        self.occurredAt = occurredAt
        self.detail = detail
    }
}
