import Foundation
import MascotCore
import Testing

private let boot = Uptime(seconds: 1_000)

/// A fixed non-UTC zone so the sleep window is exercised in local time rather
/// than accidentally passing because the test machine happens to sit on UTC.
private let testZone = TimeZone(identifier: "Asia/Yangon")!

private var testCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = testZone
    return calendar
}

private func localTime(hour: Int, minute: Int = 0) -> Date {
    var components = DateComponents()
    components.year = 2026
    components.month = 7
    components.day = 29
    components.hour = hour
    components.minute = minute
    return testCalendar.date(from: components)!
}

private let daytime = localTime(hour: 14)
private let nighttime = localTime(hour: 2)

private func reducer() -> MascotStateReducer {
    MascotStateReducer(calendar: testCalendar)
}

private func registry(
    _ events: [(AgentEvent, EventProvider, String)],
    at uptime: Uptime = boot
) -> SessionRegistry {
    var registry = SessionRegistry()
    for (index, entry) in events.enumerated() {
        registry.ingest(
            EventEnvelope(
                provider: entry.1,
                sessionID: SessionID(entry.2)!,
                event: entry.0,
                occurredAt: daytime.addingTimeInterval(TimeInterval(index))
            ),
            at: uptime
        )
    }
    return registry
}

private func reduce(
    _ events: [(AgentEvent, EventProvider, String)],
    overrides: ManualOverrides = .none,
    now: Date = daytime,
    uptime: Uptime = boot
) -> MascotVisibleState {
    reducer().reduce(registry: registry(events), overrides: overrides, now: now, uptime: uptime)
}

// MARK: - Priority order

@Test func manualPauseOutranksEveryProviderSignal() {
    let visible = reduce(
        [(.failed, .codex, "a"), (.waiting, .claudeCode, "b")],
        overrides: ManualOverrides(isPaused: true, isIdeating: true)
    )

    #expect(visible.state == .paused)
    #expect(visible.providers == [.claudeCode, .codex])
}

@Test func aRecentFailureOutranksWaitingAndWorking() {
    let visible = reduce([(.failed, .codex, "a"), (.waiting, .claudeCode, "b"), (.active, .claudeCode, "c")])

    #expect(visible.state == .failure)
    #expect(visible.providers == [.codex])
}

@Test func waitingOutranksWorking() {
    let visible = reduce([(.waiting, .claudeCode, "a"), (.active, .codex, "b")])

    #expect(visible.state == .waiting)
    #expect(visible.providers == [.claudeCode])
}

@Test func workingOutranksManualIdeating() {
    let visible = reduce([(.active, .codex, "a")], overrides: ManualOverrides(isIdeating: true))

    #expect(visible.state == .working)
}

@Test func manualIdeatingOutranksARecentSuccess() {
    let visible = reduce([(.completed, .codex, "a")], overrides: ManualOverrides(isIdeating: true))

    #expect(visible.state == .ideating)
    // Ideating is a manual mode with no originating session.
    #expect(visible.providers.isEmpty)
}

@Test func aRecentSuccessOutranksScheduledSleep() {
    let visible = reduce([(.completed, .claudeCode, "a")], now: nighttime)

    #expect(visible.state == .success)
    #expect(visible.providers == [.claudeCode])
}

@Test func aQuietSessionStrollsRatherThanGoingOffline() {
    let visible = reduce([(.started, .claudeCode, "a")])

    #expect(visible.state == .idle)
    #expect(visible.providers == [.claudeCode])
}

@Test func noSessionAtAllIsOffline() {
    let visible = reduce([])

    #expect(visible.state == .offline)
    #expect(visible.providers.isEmpty)
}

@Test func aStoppedSessionDoesNotHoldTheMascotInIdle() {
    var storage = registry([(.started, .claudeCode, "a")])
    storage.ingest(
        EventEnvelope(
            provider: .claudeCode,
            sessionID: SessionID("a")!,
            event: .stopped,
            occurredAt: daytime.addingTimeInterval(10)
        ),
        at: boot.advanced(by: 10)
    )

    let visible = reducer().reduce(
        registry: storage,
        now: daytime,
        uptime: boot.advanced(by: 10)
    )

    #expect(visible.state == .offline)
    #expect(visible.providers.isEmpty)
}

// MARK: - Reaction windows

@Test func theSuccessReactionEndsAfterThreeSecondsAndStrolls() {
    let storage = registry([(.completed, .claudeCode, "a")])
    let makeState = { (elapsed: TimeInterval) in
        reducer().reduce(registry: storage, now: daytime, uptime: boot.advanced(by: elapsed)).state
    }

    #expect(makeState(0) == .success)
    #expect(makeState(3) == .success)
    #expect(makeState(3.001) == .idle)
}

@Test func theFailureReactionEndsAfterFourSecondsAndStrolls() {
    let storage = registry([(.failed, .codex, "a")])
    let makeState = { (elapsed: TimeInterval) in
        reducer().reduce(registry: storage, now: daytime, uptime: boot.advanced(by: elapsed)).state
    }

    #expect(makeState(0) == .failure)
    #expect(makeState(4) == .failure)
    #expect(makeState(4.001) == .idle)
}

@Test func anExpiredSessionReducesToOffline() {
    let storage = registry([(.active, .codex, "a")])

    #expect(reducer().reduce(registry: storage, now: daytime, uptime: boot.advanced(by: 119)).state == .working)
    #expect(reducer().reduce(registry: storage, now: daytime, uptime: boot.advanced(by: 121)).state == .offline)
}

// MARK: - Scheduled sleep

@Test func theSleepWindowRunsFromElevenAtNightUntilSixInTheMorning() {
    let storage = registry([(.started, .claudeCode, "a")])
    let stateAt = { (hour: Int, minute: Int) in
        reducer().reduce(registry: storage, now: localTime(hour: hour, minute: minute), uptime: boot).state
    }

    #expect(stateAt(22, 59) == .idle)
    #expect(stateAt(23, 0) == .sleeping)
    #expect(stateAt(0, 30) == .sleeping)
    #expect(stateAt(5, 59) == .sleeping)
    #expect(stateAt(6, 0) == .idle)
}

@Test func workingWaitingAndIdeatingAllInterruptScheduledSleepImmediately() {
    #expect(reduce([(.active, .codex, "a")], now: nighttime).state == .working)
    #expect(reduce([(.waiting, .codex, "a")], now: nighttime).state == .waiting)
    #expect(reduce([], overrides: ManualOverrides(isIdeating: true), now: nighttime).state == .ideating)
}

@Test func completionInsideTheSleepWindowReturnsToSleepAfterTheReaction() {
    let storage = registry([(.completed, .claudeCode, "a")])
    let makeState = { (elapsed: TimeInterval) in
        reducer().reduce(registry: storage, now: nighttime, uptime: boot.advanced(by: elapsed)).state
    }

    #expect(makeState(0) == .success)
    #expect(makeState(3.001) == .sleeping)
}

@Test func offlineOutsideTheWindowBecomesSleepingInsideIt() {
    #expect(reduce([], now: daytime).state == .offline)
    #expect(reduce([], now: nighttime).state == .sleeping)
}

// MARK: - Concurrent providers

@Test func concurrentProvidersCollapseToOneWorkingStateAndSurfaceBoth() {
    let visible = reduce([(.active, .claudeCode, "a"), (.active, .codex, "b")])

    #expect(visible.state == .working)
    #expect(visible.providers == [.claudeCode, .codex])
}

@Test func onlyTheDecidingSessionsProvidersAreSurfaced() {
    let visible = reduce([(.active, .claudeCode, "a"), (.waiting, .codex, "b")])

    #expect(visible.state == .waiting)
    #expect(visible.providers == [.codex])
}

@Test func manySessionsOfOneProviderSurfaceThatProviderOnce() {
    let visible = reduce([(.active, .codex, "a"), (.active, .codex, "b"), (.active, .codex, "c")])

    #expect(visible.state == .working)
    #expect(visible.providers == [.codex])
}
