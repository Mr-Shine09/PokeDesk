import Foundation

/// A monotonic instant, in seconds since an arbitrary origin.
///
/// Wall-clock timestamps arrive inside `EventEnvelope` and are used only to
/// order events *within* one session. Expiry and reaction windows use this type
/// instead, so laptop sleep, a time-zone change, or an NTP correction cannot
/// retire a live session or freeze a reaction on screen.
public struct Uptime: Comparable, Hashable, Sendable {
    public let seconds: TimeInterval

    public init(seconds: TimeInterval) {
        self.seconds = seconds
    }

    public func advanced(by interval: TimeInterval) -> Uptime {
        Uptime(seconds: seconds + interval)
    }

    public static func < (lhs: Uptime, rhs: Uptime) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

/// What one session is currently doing, independent of every other session.
public enum SessionActivity: String, CaseIterable, Sendable {
    /// The session exists but has not claimed any work.
    case idle
    case working
    case waiting
    case completed
    case failed
    /// Ended; retained only until the grace period elapses.
    case stopped
}

/// A bounded reaction that plays after a turn ends.
public struct SessionReaction: Equatable, Sendable {
    public enum Kind: String, Sendable {
        case success
        case failure
    }

    public let kind: Kind
    public let expiresAt: Uptime
}

/// Identity of a session. The provider is part of the key because opaque
/// per-provider IDs share no namespace and may collide.
public struct SessionKey: Hashable, Sendable {
    public let provider: EventProvider
    public let sessionID: SessionID

    public init(provider: EventProvider, sessionID: SessionID) {
        self.provider = provider
        self.sessionID = sessionID
    }
}

/// One tracked agent session.
///
/// Like `EventEnvelope`, this type is part of the privacy boundary: it holds no
/// field that could carry prompt text, paths, or tool data.
public struct AgentSession: Equatable, Sendable {
    public let key: SessionKey
    public var activity: SessionActivity
    /// Newest accepted `occurredAt`. Ordering only; never used for expiry.
    public var lastEventAt: Date
    /// Monotonic arrival of the newest accepted event. Drives expiry.
    public var lastSeen: Uptime
    public var reaction: SessionReaction?
    /// Where this session is being driven from, when its helper could tell.
    ///
    /// Set from the first event that creates the session and refreshed by later
    /// ones, because a surface is a property of the session rather than of any
    /// single event — and a hook that could not determine it must not erase what
    /// an earlier one established. `nil` means unknown, which is the ordinary
    /// case for every provider except Codex.
    public var surface: EventSurface?
    /// Whether the *current* turn has run a tool.
    ///
    /// This is what separates an agent run from a conversation inside a single
    /// desktop app. The ChatGPT app hosts both, from one binary and one bundle,
    /// so their hook events are identical except for this: an agent touches
    /// tools and a chat does not.
    ///
    /// **Turn-scoped, not session-scoped.** It clears when a new prompt starts a
    /// turn, because one conversation legitimately alternates between asking a
    /// question and asking for work, and a sticky flag would leave the pet
    /// typing at a chat for the rest of the session.
    public var hasRunToolsThisTurn: Bool = false

    public var provider: EventProvider { key.provider }
    public var sessionID: SessionID { key.sessionID }
}

public struct SessionRegistryLimits: Equatable, Sendable {
    /// A session with no event for this long is treated as offline.
    public var heartbeatTimeout: TimeInterval
    /// The same, for a session that is waiting on the user.
    ///
    /// Deliberately far longer than `heartbeatTimeout`, because a waiting
    /// session is the one case where silence is *evidence the session is still
    /// there* rather than evidence it is gone: the agent is blocked on a human,
    /// so by definition it sends nothing until the human answers. Under the
    /// ordinary timeout the mascot gave up after two minutes and strolled away
    /// while a permission prompt was still on screen — observed in a real Claude
    /// Code session on 2026-08-09.
    ///
    /// It is not infinite on purpose. An agent killed while waiting leaves a
    /// session nothing will ever update, and showing `waiting` forever would
    /// assert something false about the machine's state. Half an hour is far
    /// past any realistic human response time and still bounds that lie.
    public var waitingTimeout: TimeInterval
    /// How long a `stopped` session is retained before removal.
    public var stoppedGracePeriod: TimeInterval
    public var successReaction: TimeInterval
    public var failureReaction: TimeInterval
    /// Ceiling on tracked sessions so a looping or hostile helper cannot grow
    /// the registry without bound. The least recently seen session is evicted.
    public var maximumSessions: Int

    public init(
        heartbeatTimeout: TimeInterval = 120,
        waitingTimeout: TimeInterval = 1800,
        stoppedGracePeriod: TimeInterval = 5,
        successReaction: TimeInterval = 3,
        failureReaction: TimeInterval = 4,
        maximumSessions: Int = 64
    ) {
        self.heartbeatTimeout = heartbeatTimeout
        self.waitingTimeout = waitingTimeout
        self.stoppedGracePeriod = stoppedGracePeriod
        self.successReaction = successReaction
        self.failureReaction = failureReaction
        self.maximumSessions = maximumSessions
    }
}

/// Why an event did not change the registry.
public enum IngestOutcome: Equatable, Sendable {
    case accepted
    /// Older than the newest event already accepted for that session.
    case ignoredStale
    /// `heartbeat` and `stopped` refer to a session rather than asserting one,
    /// so they cannot conjure a session the registry never saw start.
    case ignoredUnknownSession
}

/// Per-session state with heartbeat expiry, on an injected monotonic clock.
///
/// A value type on purpose: every transition is a pure function of the previous
/// registry, one envelope, and one `Uptime`, which is what makes the ordering,
/// expiry, and reaction fixtures deterministic.
public struct SessionRegistry: Equatable, Sendable {
    public let limits: SessionRegistryLimits
    private var storage: [SessionKey: AgentSession] = [:]

    public init(limits: SessionRegistryLimits = SessionRegistryLimits()) {
        self.limits = limits
    }

    @discardableResult
    public mutating func ingest(_ envelope: EventEnvelope, at uptime: Uptime) -> IngestOutcome {
        purgeExpired(at: uptime)

        let key = SessionKey(provider: envelope.provider, sessionID: envelope.sessionID)
        let existing = storage[key]

        if let existing, envelope.occurredAt < existing.lastEventAt {
            return .ignoredStale
        }

        guard var session = existing ?? Self.session(startedBy: envelope, at: uptime) else {
            return .ignoredUnknownSession
        }

        session.lastEventAt = envelope.occurredAt
        session.lastSeen = uptime
        // Refreshed, never cleared. A later hook that could not work out its
        // surface says nothing about the session's origin, and letting it write
        // `nil` would flip a chat turn back to the terminal pose mid-turn.
        if let surface = envelope.surface {
            session.surface = surface
        }

        switch envelope.event {
        case .started:
            session.activity = .idle
            session.reaction = nil
        case .active:
            session.activity = .working
            session.reaction = nil
            // `.tool` marks tool traffic; a bare `active` is a prompt starting a
            // new turn, which is where the flag resets.
            session.hasRunToolsThisTurn = envelope.detail == .tool
        case .waiting:
            session.activity = .waiting
            session.reaction = nil
        case .completed:
            session.activity = .completed
            session.reaction = SessionReaction(
                kind: .success,
                expiresAt: uptime.advanced(by: limits.successReaction)
            )
        case .failed:
            session.activity = .failed
            session.reaction = SessionReaction(
                kind: .failure,
                expiresAt: uptime.advanced(by: limits.failureReaction)
            )
        case .stopped:
            // A pending reaction survives session end so a completed turn still
            // gets its bounded success or failure animation.
            session.activity = .stopped
        case .heartbeat:
            // Refresh only. A heartbeat means "work continues", never "work
            // began", so it must not promote an idle session to working.
            break
        }

        storage[key] = session
        evictOldestIfOverCapacity()
        return .accepted
    }

    /// Live sessions at `uptime`, ordered deterministically.
    public func sessions(at uptime: Uptime) -> [AgentSession] {
        storage.values
            .filter { !Self.isExpired($0, at: uptime, limits: limits) }
            .sorted { lhs, rhs in
                lhs.provider.rawValue == rhs.provider.rawValue
                    ? lhs.sessionID.rawValue < rhs.sessionID.rawValue
                    : lhs.provider.rawValue < rhs.provider.rawValue
            }
    }

    public func session(for key: SessionKey, at uptime: Uptime) -> AgentSession? {
        guard let session = storage[key], !Self.isExpired(session, at: uptime, limits: limits) else {
            return nil
        }
        return session
    }

    /// Drops expired and stopped sessions from storage.
    ///
    /// `sessions(at:)` already hides them, so this only reclaims memory — but it
    /// is also the required reconciliation step after wake, when a large
    /// monotonic jump may have retired everything at once.
    public mutating func reconcile(at uptime: Uptime) {
        purgeExpired(at: uptime)
    }

    public var trackedSessionCount: Int { storage.count }

    // MARK: - Private

    /// Only events that assert a state may create a session.
    private static func session(startedBy envelope: EventEnvelope, at uptime: Uptime) -> AgentSession? {
        switch envelope.event {
        case .heartbeat, .stopped:
            return nil
        case .started, .active, .waiting, .completed, .failed:
            return AgentSession(
                key: SessionKey(provider: envelope.provider, sessionID: envelope.sessionID),
                activity: .idle,
                lastEventAt: envelope.occurredAt,
                lastSeen: uptime,
                reaction: nil,
                surface: envelope.surface
            )
        }
    }

    /// A session never expires while its reaction is still playing, so a bounded
    /// success or failure animation cannot be cut short by either deadline.
    private static func isExpired(
        _ session: AgentSession,
        at uptime: Uptime,
        limits: SessionRegistryLimits
    ) -> Bool {
        if let reaction = session.reaction, uptime <= reaction.expiresAt {
            return false
        }
        let deadline: TimeInterval
        switch session.activity {
        case .stopped:
            deadline = limits.stoppedGracePeriod
        case .waiting:
            // A blocked agent sends nothing while it waits, so quiet is the
            // expected condition here rather than a sign of death.
            deadline = limits.waitingTimeout
        case .idle, .working, .completed, .failed:
            deadline = limits.heartbeatTimeout
        }
        return uptime > session.lastSeen.advanced(by: deadline)
    }

    private mutating func purgeExpired(at uptime: Uptime) {
        storage = storage.filter { !Self.isExpired($0.value, at: uptime, limits: limits) }
    }

    private mutating func evictOldestIfOverCapacity() {
        while storage.count > limits.maximumSessions {
            guard let oldest = storage.min(by: { $0.value.lastSeen < $1.value.lastSeen })?.key else {
                return
            }
            storage.removeValue(forKey: oldest)
        }
    }
}
