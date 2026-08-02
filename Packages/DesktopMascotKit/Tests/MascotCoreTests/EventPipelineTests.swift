import Foundation
import MascotCore
import Testing

private let wallClock = ISO8601DateFormatter().date(from: "2026-07-30T14:00:00Z")!
private let boot = Uptime(seconds: 5_000)

/// Fixed so the sleep window never depends on the machine's local time zone.
private let daytimeReducer = MascotStateReducer(
    sleepWindow: SleepWindow(startHour: 23, endHour: 6),
    calendar: {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
)

private func pipeline() -> EventPipeline {
    EventPipeline(reducer: daytimeReducer)
}

private func event(
    _ agentEvent: AgentEvent,
    provider: EventProvider = .claudeCode,
    session: String = "session-a",
    offset: TimeInterval = 0
) -> EventEnvelope {
    EventEnvelope(
        provider: provider,
        sessionID: SessionID(session)!,
        event: agentEvent,
        occurredAt: wallClock.addingTimeInterval(offset)
    )
}

// MARK: - Reduced state

@Test func aFreshPipelineIsOfflineWithNoTraffic() {
    let pipeline = pipeline()

    #expect(pipeline.visibleState == MascotVisibleState(state: .offline))
    #expect(pipeline.diagnostics.hasObservedTraffic == false)
    #expect(pipeline.diagnostics.trackedSessions == 0)
}

@Test func anAcceptedActiveEventDrivesVisibleStateToWorking() {
    var pipeline = pipeline()

    #expect(pipeline.ingest(event(.active), now: wallClock, uptime: boot) == .accepted)
    #expect(pipeline.visibleState == MascotVisibleState(state: .working, providers: [.claudeCode]))
    #expect(pipeline.diagnostics.acceptedEvents == 1)
    #expect(pipeline.diagnostics.trackedSessions == 1)
    #expect(pipeline.diagnostics.lastAcceptedAt == wallClock)
}

@Test func manualPauseOutranksAWorkingSessionWithoutDiscardingIt() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active), now: wallClock, uptime: boot)

    pipeline.refresh(
        overrides: ManualOverrides(isPaused: true),
        now: wallClock,
        uptime: boot.advanced(by: 1)
    )

    #expect(pipeline.visibleState.state == .paused)
    #expect(pipeline.diagnostics.trackedSessions == 1)

    pipeline.refresh(now: wallClock, uptime: boot.advanced(by: 2))
    #expect(pipeline.visibleState.state == .working)
}

@Test func refreshAloneRetiresASilentSessionToOffline() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active), now: wallClock, uptime: boot)

    let afterTimeout = boot.advanced(by: 121)
    pipeline.refresh(now: wallClock.addingTimeInterval(121), uptime: afterTimeout)

    #expect(pipeline.visibleState.state == .offline)
    #expect(pipeline.diagnostics.trackedSessions == 0)
    // The event was still genuinely accepted; expiry is not a rejection.
    #expect(pipeline.diagnostics.acceptedEvents == 1)
}

@Test func aSuccessReactionExpiresOnRefreshWithoutANewEvent() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active), now: wallClock, uptime: boot)
    pipeline.ingest(event(.completed, offset: 1), now: wallClock.addingTimeInterval(1), uptime: boot.advanced(by: 1))

    #expect(pipeline.visibleState.state == .success)

    pipeline.refresh(now: wallClock.addingTimeInterval(6), uptime: boot.advanced(by: 6))
    #expect(pipeline.visibleState.state == .idle)
}

// MARK: - Diagnostics counters

@Test func staleAndUnknownSessionEventsAreCountedSeparatelyFromAccepted() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active, offset: 10), now: wallClock, uptime: boot)

    #expect(pipeline.ingest(event(.active, offset: 1), now: wallClock, uptime: boot) == .ignoredStale)
    #expect(
        pipeline.ingest(event(.heartbeat, session: "session-b"), now: wallClock, uptime: boot)
            == .ignoredUnknownSession
    )

    #expect(pipeline.diagnostics.acceptedEvents == 1)
    #expect(pipeline.diagnostics.staleEvents == 1)
    #expect(pipeline.diagnostics.unknownSessionEvents == 1)
    #expect(pipeline.diagnostics.rejectedFrames == 0)
}

@Test func aRejectedFrameIsCountedAndChangesNoState() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active), now: wallClock, uptime: boot)
    let before = pipeline.visibleState

    pipeline.noteRejectedFrame(now: wallClock, uptime: boot)

    #expect(pipeline.visibleState == before)
    #expect(pipeline.diagnostics.rejectedFrames == 1)
    #expect(pipeline.diagnostics.acceptedEvents == 1)
    #expect(pipeline.diagnostics.hasObservedTraffic)
}

@Test func aRejectedFrameAloneNeverAdvancesTheLastAcceptedTimestamp() {
    var pipeline = pipeline()

    pipeline.noteRejectedFrame(now: wallClock, uptime: boot)

    #expect(pipeline.diagnostics.lastAcceptedAt == nil)
    #expect(pipeline.diagnostics.hasObservedTraffic)
    #expect(pipeline.visibleState.state == .offline)
}

@Test func twoProvidersCollapseToOneStateAndSurfaceBothInDiagnostics() {
    var pipeline = pipeline()
    pipeline.ingest(event(.active, provider: .claudeCode), now: wallClock, uptime: boot)
    pipeline.ingest(event(.active, provider: .codex, session: "session-b"), now: wallClock, uptime: boot)

    #expect(pipeline.visibleState.state == .working)
    #expect(pipeline.visibleState.providers == [.claudeCode, .codex])
    #expect(pipeline.diagnostics.trackedSessions == 2)
}

// MARK: - Per-provider visible states

@Test func thePipelinePublishesAVisibleStateForEveryProvider() {
    // The calendar is pinned rather than left as `.current`: with the default
    // one this test passes or fails depending on what time the machine running
    // it thinks it is, because a provider with no sessions reduces to
    // `sleeping` instead of `offline` inside the nightly window.
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Yangon")!
    var components = DateComponents()
    components.year = 2026
    components.month = 7
    components.day = 29
    components.hour = 14
    let now = calendar.date(from: components)!

    var pipeline = EventPipeline(reducer: MascotStateReducer(calendar: calendar))
    // Always populated, so a caller never has to decide what a missing key
    // means for a mascot it is about to animate.
    #expect(pipeline.visibleStates.count == EventProvider.allCases.count)
    for provider in EventProvider.allCases {
        #expect(pipeline.visibleStates[provider]?.state == .offline)
    }

    let uptime = Uptime(seconds: 500)
    for event in [AgentEvent.started, .active] {
        pipeline.ingest(
            EventEnvelope(
                provider: .claudeCode,
                sessionID: SessionID("claude-1")!,
                event: event,
                occurredAt: now
            ),
            now: now,
            uptime: uptime
        )
    }

    #expect(pipeline.visibleStates[.claudeCode]?.state == .working)
    #expect(pipeline.visibleStates[.codex]?.state == .offline)
    // The collapsed state is unchanged and still drives the diagnostics line.
    #expect(pipeline.visibleState.state == .working)
}
