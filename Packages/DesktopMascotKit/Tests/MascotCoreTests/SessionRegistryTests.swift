import Foundation
import MascotCore
import Testing

private let wallClock = ISO8601DateFormatter().date(from: "2026-07-29T18:00:00Z")!
private let boot = Uptime(seconds: 1_000)

private func event(
    _ agentEvent: AgentEvent,
    provider: EventProvider = .claudeCode,
    session: String = "session-a",
    offset: TimeInterval = 0,
    detail: EventDetail? = nil
) -> EventEnvelope {
    EventEnvelope(
        provider: provider,
        sessionID: SessionID(session)!,
        event: agentEvent,
        occurredAt: wallClock.addingTimeInterval(offset),
        detail: detail
    )
}

private func key(_ provider: EventProvider = .claudeCode, _ session: String = "session-a") -> SessionKey {
    SessionKey(provider: provider, sessionID: SessionID(session)!)
}

// MARK: - Event to activity mapping

@Test func startedCreatesAnIdleSessionThatClaimsNoWork() {
    var registry = SessionRegistry()

    #expect(registry.ingest(event(.started), at: boot) == .accepted)
    #expect(registry.session(for: key(), at: boot)?.activity == .idle)
}

@Test func activePromotesTheSessionToWorking() {
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.active, offset: 1), at: boot.advanced(by: 1))

    #expect(registry.session(for: key(), at: boot.advanced(by: 1))?.activity == .working)
}

@Test func heartbeatRefreshesExpiryWithoutClaimingWork() {
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.heartbeat, offset: 100), at: boot.advanced(by: 100))

    let session = registry.session(for: key(), at: boot.advanced(by: 100))
    #expect(session?.activity == .idle)
    #expect(session?.lastSeen == boot.advanced(by: 100))
}

@Test func heartbeatAndStoppedCannotCreateAnUnknownSession() {
    var registry = SessionRegistry()

    #expect(registry.ingest(event(.heartbeat), at: boot) == .ignoredUnknownSession)
    #expect(registry.ingest(event(.stopped), at: boot) == .ignoredUnknownSession)
    #expect(registry.trackedSessionCount == 0)
}

@Test func everyStateAssertingEventCanCreateASession() {
    for agentEvent in [AgentEvent.started, .active, .waiting, .completed, .failed] {
        var registry = SessionRegistry()
        #expect(registry.ingest(event(agentEvent), at: boot) == .accepted)
        #expect(registry.trackedSessionCount == 1)
    }
}

// MARK: - Idempotence and ordering

@Test func duplicateEventsAreIdempotent() {
    var registry = SessionRegistry()
    registry.ingest(event(.active), at: boot)
    let afterFirst = registry

    registry.ingest(event(.active), at: boot)

    #expect(registry == afterFirst)
}

@Test func reorderedOlderEventsDoNotOverwriteNewerState() {
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.active, offset: 10), at: boot.advanced(by: 10))

    // A late-arriving PreToolUse-style waiting event stamped before the prompt.
    #expect(registry.ingest(event(.waiting, offset: 5), at: boot.advanced(by: 11)) == .ignoredStale)

    let session = registry.session(for: key(), at: boot.advanced(by: 11))
    #expect(session?.activity == .working)
    #expect(session?.lastSeen == boot.advanced(by: 10))
}

@Test func eventsSharingATimestampAreAcceptedInArrivalOrder() {
    var registry = SessionRegistry()
    registry.ingest(event(.active), at: boot)
    #expect(registry.ingest(event(.waiting), at: boot) == .accepted)

    #expect(registry.session(for: key(), at: boot)?.activity == .waiting)
}

@Test func identicalSessionIDsFromDifferentProvidersAreDistinctSessions() {
    var registry = SessionRegistry()
    registry.ingest(event(.active, provider: .claudeCode, session: "shared-id"), at: boot)
    registry.ingest(event(.waiting, provider: .codex, session: "shared-id"), at: boot)

    #expect(registry.trackedSessionCount == 2)
    #expect(registry.session(for: key(.claudeCode, "shared-id"), at: boot)?.activity == .working)
    #expect(registry.session(for: key(.codex, "shared-id"), at: boot)?.activity == .waiting)
}

@Test func snapshotOrderIsDeterministic() {
    var registry = SessionRegistry()
    registry.ingest(event(.active, provider: .codex, session: "zulu"), at: boot)
    registry.ingest(event(.active, provider: .claudeCode, session: "bravo"), at: boot)
    registry.ingest(event(.active, provider: .claudeCode, session: "alpha"), at: boot)

    let ordered = registry.sessions(at: boot).map { "\($0.provider.rawValue)/\($0.sessionID.rawValue)" }
    #expect(ordered == ["claude-code/alpha", "claude-code/bravo", "codex/zulu"])
}

// MARK: - Waiting persistence

@Test func waitingPersistsUntilTheSessionItselfMovesOn() {
    var registry = SessionRegistry()
    registry.ingest(event(.waiting), at: boot)

    // Heartbeats keep arriving while the permission prompt is unanswered.
    registry.ingest(event(.heartbeat, offset: 30), at: boot.advanced(by: 30))
    #expect(registry.session(for: key(), at: boot.advanced(by: 30))?.activity == .waiting)

    for (agentEvent, expected) in [
        (AgentEvent.active, SessionActivity.working),
        (.completed, .completed),
        (.failed, .failed),
        (.stopped, .stopped)
    ] {
        var scoped = SessionRegistry()
        scoped.ingest(event(.waiting), at: boot)
        scoped.ingest(event(agentEvent, offset: 60), at: boot.advanced(by: 60))
        #expect(scoped.session(for: key(), at: boot.advanced(by: 60))?.activity == expected)
    }
}

// MARK: - Heartbeat expiry

@Test func aSessionExpiresAfterTheHeartbeatTimeout() {
    var registry = SessionRegistry()
    registry.ingest(event(.active), at: boot)

    #expect(registry.sessions(at: boot.advanced(by: 120)).count == 1)
    #expect(registry.sessions(at: boot.advanced(by: 120.001)).isEmpty)
}

@Test func heartbeatsBeforeTheTimeoutKeepTheSessionAlive() {
    var registry = SessionRegistry()
    registry.ingest(event(.active), at: boot)

    var offset: TimeInterval = 0
    for step in 1 ... 5 {
        offset = TimeInterval(step) * 100
        registry.ingest(event(.heartbeat, offset: offset), at: boot.advanced(by: offset))
    }

    #expect(registry.sessions(at: boot.advanced(by: offset + 119)).count == 1)
    #expect(registry.sessions(at: boot.advanced(by: offset + 121)).isEmpty)
}

// MARK: - Waiting outlives the ordinary heartbeat timeout

@Test func aWaitingSessionSurvivesLongPastTheHeartbeatTimeout() {
    // Regression, observed in a real Claude Code session on 2026-08-09: a
    // permission prompt was still on screen and the mascot strolled away.
    // A blocked agent sends nothing while it waits, so the ordinary quiet-means-
    // gone rule retired the very session that was most certainly alive.
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.waiting, offset: 1), at: boot.advanced(by: 1))

    // Well past the 120 s heartbeat timeout, with no further events at all.
    let sessions = registry.sessions(at: boot.advanced(by: 600))
    #expect(sessions.count == 1)
    #expect(sessions.first?.activity == .waiting)
}

@Test func aWaitingSessionIsStillEventuallyExpired() {
    // Not infinite on purpose: an agent killed mid-prompt must not leave the
    // mascot asserting `waiting` for the rest of the login session.
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.waiting, offset: 1), at: boot.advanced(by: 1))

    #expect(registry.sessions(at: boot.advanced(by: 1 + 1_799)).count == 1)
    #expect(registry.sessions(at: boot.advanced(by: 1 + 1_801)).isEmpty)
}

@Test func leavingWaitingRestoresTheOrdinaryHeartbeatTimeout() {
    // The longer deadline is a property of the current activity, not a lasting
    // exemption the session keeps once the user has answered.
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.waiting, offset: 1), at: boot.advanced(by: 1))
    registry.ingest(event(.active, offset: 2), at: boot.advanced(by: 2))

    #expect(registry.sessions(at: boot.advanced(by: 2 + 119)).count == 1)
    #expect(registry.sessions(at: boot.advanced(by: 2 + 121)).isEmpty)
}

@Test func reconcileRemovesExpiredSessionsFromStorage() {
    var registry = SessionRegistry()
    registry.ingest(event(.active), at: boot)
    #expect(registry.trackedSessionCount == 1)

    // A long laptop sleep jumps the monotonic clock well past every deadline.
    registry.reconcile(at: boot.advanced(by: 100_000))
    #expect(registry.trackedSessionCount == 0)
}

@Test func aStoppedSessionIsPurgedAfterTheGracePeriod() {
    var registry = SessionRegistry()
    registry.ingest(event(.started), at: boot)
    registry.ingest(event(.stopped, offset: 1), at: boot.advanced(by: 1))

    #expect(registry.sessions(at: boot.advanced(by: 5)).count == 1)
    #expect(registry.sessions(at: boot.advanced(by: 6.001)).isEmpty)
}

@Test func registryEvictsTheLeastRecentlySeenSessionAtCapacity() {
    var registry = SessionRegistry(limits: SessionRegistryLimits(maximumSessions: 2))
    registry.ingest(event(.active, session: "oldest"), at: boot)
    registry.ingest(event(.active, session: "middle"), at: boot.advanced(by: 1))
    registry.ingest(event(.active, session: "newest"), at: boot.advanced(by: 2))

    let live = registry.sessions(at: boot.advanced(by: 2)).map(\.sessionID.rawValue)
    #expect(live == ["middle", "newest"])
}

// MARK: - Bounded reactions

@Test func theSuccessReactionLastsThreeSeconds() {
    var registry = SessionRegistry()
    registry.ingest(event(.completed), at: boot)

    let reaction = registry.session(for: key(), at: boot)?.reaction
    #expect(reaction?.kind == .success)
    #expect(reaction?.expiresAt == boot.advanced(by: 3))
}

@Test func theFailureReactionLastsFourSeconds() {
    var registry = SessionRegistry()
    registry.ingest(event(.failed, detail: .network), at: boot)

    let reaction = registry.session(for: key(), at: boot)?.reaction
    #expect(reaction?.kind == .failure)
    #expect(reaction?.expiresAt == boot.advanced(by: 4))
}

@Test func aPendingReactionSurvivesSessionEndAndTheGracePeriod() {
    var registry = SessionRegistry(limits: SessionRegistryLimits(stoppedGracePeriod: 0))
    registry.ingest(event(.failed), at: boot)
    registry.ingest(event(.stopped, offset: 1), at: boot.advanced(by: 1))

    // Grace alone would have dropped the session immediately; the reaction holds it.
    #expect(registry.sessions(at: boot.advanced(by: 3)).first?.reaction?.kind == .failure)
    #expect(registry.sessions(at: boot.advanced(by: 5)).isEmpty)
}

@Test func aNewTurnClearsTheOutgoingReaction() {
    var registry = SessionRegistry()
    registry.ingest(event(.completed), at: boot)
    registry.ingest(event(.active, offset: 1), at: boot.advanced(by: 1))

    #expect(registry.session(for: key(), at: boot.advanced(by: 1))?.reaction == nil)
}
