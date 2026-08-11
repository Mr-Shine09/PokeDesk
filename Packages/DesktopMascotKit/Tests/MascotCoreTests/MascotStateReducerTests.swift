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
    chat: ChatPresence = .none,
    now: Date = daytime,
    uptime: Uptime = boot
) -> MascotVisibleState {
    reducer().reduce(
        registry: registry(events),
        overrides: overrides,
        chat: chat,
        now: now,
        uptime: uptime
    )
}

private let claudeChat = ChatPresence(providers: [.claudeCode])

@Test func aFrontmostChatAppMakesTheMascotThink() {
    let state = reduce([], chat: claudeChat)

    #expect(state.state == .ideating)
    // Unlike manual ideating, this signal is attributable, so it names the
    // mascot that should react.
    #expect(state.providers == [.claudeCode])
}

/// The rung that separates this from manual ideating.
///
/// Manual ideating outranks `working` (2026-08-09) because it is a deliberate
/// standing preference. A frontmost chat app is a guess, and a much weaker one:
/// glancing at the Claude app while an agent grinds away must keep showing the
/// real work.
@Test func aWorkingSessionOutranksAFrontmostChatApp() {
    let state = reduce([(.active, .claudeCode, "s-work")], chat: claudeChat)

    #expect(state.state == .working)
}

@Test func manualIdeatingStillOutranksWorkingSoTheTwoRungsAreDistinct() {
    let state = reduce(
        [(.active, .claudeCode, "s-work")],
        overrides: ManualOverrides(isIdeating: true)
    )

    #expect(state.state == .ideating)
}

/// The case the ladder alone did not cover.
///
/// The Claude desktop app hosts the chat *and* Claude Code under one bundle
/// identifier, so a frontmost Claude.app between turns — session known, nothing
/// running — must not read as chatting. Ranking chat below `working` handled a
/// turn in flight and left this gap showing a Thinker pose at someone who was
/// not chatting.
@Test func aProviderWithAnyLiveSessionIgnoresTheChatSignal() {
    // `.started` leaves the session present but idle: Claude Code open, quiet.
    let state = reduce([(.started, .claudeCode, "s-quiet")], chat: claudeChat)

    #expect(state.state == .idle)
}

/// Sessions expire on the ordinary timeout, so closing the agent hands the
/// mascot back to the chat signal without any extra machinery.
@Test func theChatSignalReturnsOnceTheSessionHasExpired() {
    let storage = registry([(.started, .claudeCode, "s-gone")])
    let expired = boot.advanced(by: 200)

    let state = reducer().reduce(
        registry: storage,
        chat: claudeChat,
        now: daytime,
        uptime: expired
    )

    #expect(state.state == .ideating)
}

/// A finished turn keeps its fist pump even with the chat app in front.
@Test func aSuccessReactionOutranksAFrontmostChatApp() {
    let state = reduce(
        [(.active, .claudeCode, "s-done"), (.completed, .claudeCode, "s-done")],
        chat: claudeChat
    )

    #expect(state.state == .success)
}

/// Someone using a chat app at 02:00 is awake, and the documented rule is that
/// ideating interrupts scheduled sleep.
@Test func aFrontmostChatAppInterruptsScheduledSleep() {
    let state = reduce([], chat: claudeChat, now: nighttime)


    #expect(state.state == .ideating)
}

@Test func aWaitingSessionOutranksAFrontmostChatApp() {
    let state = reduce([(.waiting, .claudeCode, "s-ask")], chat: claudeChat)

    #expect(state.state == .waiting)
}

/// The Claude app must not make the Codex mascot think.
@Test func aChatAppOnlyReachesItsOwnProvidersMascot() {
    let reducer = reducer()
    let sessions = registry([]).sessions(at: boot)

    let claude = reducer.reduce(
        sessions: sessions,
        attributedTo: .claudeCode,
        chat: claudeChat,
        now: daytime,
        uptime: boot
    )
    let codex = reducer.reduce(
        sessions: sessions,
        attributedTo: .codex,
        chat: claudeChat,
        now: daytime,
        uptime: boot
    )

    #expect(claude.state == .ideating)
    #expect(codex.state == .offline)
}

@Test func onlyTheTwoAllowlistedChatAppsAreRecognized() {
    #expect(ChatApp.provider(forBundleIdentifier: "com.anthropic.claudefordesktop") == .claudeCode)
    // ChatGPT's desktop app really does ship as `com.openai.codex`.
    #expect(ChatApp.provider(forBundleIdentifier: "com.openai.codex") == .codex)
    #expect(ChatApp.provider(forBundleIdentifier: "com.mrshine09.dockpet") == nil)
    #expect(ChatApp.provider(forBundleIdentifier: "com.apple.Safari") == nil)
    // A substring match would catch this; an allowlist does not.
    #expect(ChatApp.provider(forBundleIdentifier: "com.example.claude-notes") == nil)
    #expect(ChatApp.provider(forBundleIdentifier: nil) == nil)
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

@Test func manualIdeatingOutranksWorking() {
    // Reversed on 2026-08-09. Below `working`, the menu toggle was inert
    // whenever an agent was running, which is when the pet is being watched.
    let visible = reduce([(.active, .codex, "a")], overrides: ManualOverrides(isIdeating: true))

    #expect(visible.state == .ideating)
    // Still a manual mode with no originating session, even though a real
    // working session exists and is being outranked.
    #expect(visible.providers.isEmpty)
}

@Test func waitingStillOutranksManualIdeating() {
    // The ceiling on the change above: ideating is a standing preference, and a
    // waiting session is asking the user for something right now.
    let visible = reduce([(.waiting, .claudeCode, "a")], overrides: ManualOverrides(isIdeating: true))

    #expect(visible.state == .waiting)
    #expect(visible.providers == [.claudeCode])
}

@Test func aRecentFailureStillOutranksManualIdeating() {
    let visible = reduce([(.failed, .codex, "a")], overrides: ManualOverrides(isIdeating: true))

    #expect(visible.state == .failure)
    #expect(visible.providers == [.codex])
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

// MARK: - A customized or disabled sleep window

@Test func aNilSleepWindowNeverSleeps() {
    let reducer = MascotStateReducer(sleepWindow: nil, calendar: testCalendar)
    let storage = registry([(.started, .claudeCode, "a")])
    let stateAt = { (hour: Int) in
        reducer.reduce(registry: storage, now: localTime(hour: hour), uptime: boot).state
    }

    // Every hour of the day, so this cannot pass by testing only the hours the
    // default window happened to exclude.
    #expect((0 ..< 24).allSatisfy { stateAt($0) == .idle })
}

@Test func aCustomWindowSleepsOnItsOwnHoursAndNotTheDefaultOnes() {
    // A night worker: awake through the small hours, asleep in the morning.
    let reducer = MascotStateReducer(
        sleepWindow: SleepWindow(startHour: 7, endHour: 14),
        calendar: testCalendar
    )
    let storage = registry([(.started, .claudeCode, "a")])
    let stateAt = { (hour: Int) in
        reducer.reduce(registry: storage, now: localTime(hour: hour), uptime: boot).state
    }

    #expect(stateAt(7) == .sleeping)
    #expect(stateAt(13) == .sleeping)
    #expect(stateAt(14) == .idle)
    // The hours the built-in window would have slept through.
    #expect(stateAt(23) == .idle)
    #expect(stateAt(2) == .idle)
}

@Test func aWindowWithEqualHoursIsEmptyRatherThanAllDay() {
    let reducer = MascotStateReducer(
        sleepWindow: SleepWindow(startHour: 3, endHour: 3),
        calendar: testCalendar
    )
    let storage = registry([(.started, .claudeCode, "a")])

    #expect((0 ..< 24).allSatisfy {
        reducer.reduce(registry: storage, now: localTime(hour: $0), uptime: boot).state == .idle
    })
}

@Test func sleepWindowHoursAreClampedRatherThanTrusted() {
    // These arrive from persisted preferences, which anything can write.
    #expect(SleepWindow(startHour: -5, endHour: 99) == SleepWindow(startHour: 0, endHour: 23))
    #expect(SleepWindow(startHour: 24, endHour: 24) == SleepWindow(startHour: 23, endHour: 23))
}

@Test func workInterruptsACustomWindowJustAsItInterruptsTheDefault() {
    let reducer = MascotStateReducer(
        sleepWindow: SleepWindow(startHour: 7, endHour: 14),
        calendar: testCalendar
    )
    let storage = registry([(.active, .codex, "a")])

    #expect(reducer.reduce(registry: storage, now: localTime(hour: 9), uptime: boot).state == .working)
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

// MARK: - Per-provider reduction

// Owner decision, 2026-08-01: one mascot per provider. Each reduces only its
// own provider's sessions, using the same priority ladder as the collapsed
// reduction rather than a parallel one.

private func reduce(
    _ events: [(AgentEvent, EventProvider, String)],
    attributedTo provider: EventProvider,
    overrides: ManualOverrides = .none,
    now: Date = daytime,
    uptime: Uptime = boot
) -> MascotVisibleState {
    reducer().reduce(
        registry: registry(events),
        attributedTo: provider,
        overrides: overrides,
        now: now,
        uptime: uptime
    )
}

@Test func eachProviderReducesOnlyItsOwnSessions() {
    let events: [(AgentEvent, EventProvider, String)] = [
        (.started, .claudeCode, "claude-1"),
        (.active, .claudeCode, "claude-1"),
    ]
    #expect(reduce(events, attributedTo: .claudeCode).state == .working)
    // Codex has no session at all, so its mascot is offline rather than
    // inheriting Claude's working state.
    #expect(reduce(events, attributedTo: .codex).state == .offline)
}

@Test func aProviderWithNoSessionsIsOfflineSoItsMascotStrolls() {
    // `offline` is what keeps the other pet ambient and on screen instead of
    // frozen. If this ever becomes a distinct state, the mascot that is not
    // running needs a new answer here.
    #expect(reduce([], attributedTo: .claudeCode).state == .offline)
    #expect(reduce([], attributedTo: .codex).state == .offline)
}

@Test func oneProviderWorkingLeavesTheOtherIdleWhenItHasAQuietSession() {
    let events: [(AgentEvent, EventProvider, String)] = [
        (.started, .claudeCode, "claude-1"),
        (.active, .claudeCode, "claude-1"),
        (.started, .codex, "codex-1"),
    ]
    #expect(reduce(events, attributedTo: .claudeCode).state == .working)
    #expect(reduce(events, attributedTo: .codex).state == .idle)
}

@Test func perProviderReductionAttributesOnlyThatProvider() {
    let events: [(AgentEvent, EventProvider, String)] = [
        (.started, .claudeCode, "claude-1"),
        (.active, .claudeCode, "claude-1"),
        (.started, .codex, "codex-1"),
        (.active, .codex, "codex-1"),
    ]
    #expect(reduce(events, attributedTo: .codex).providers == [.codex])
    #expect(reduce(events, attributedTo: .claudeCode).providers == [.claudeCode])
    // The collapsed reduction still names both, for the menu-bar diagnostics.
    #expect(reduce(events).providers == [.claudeCode, .codex])
}

@Test func manualOverridesReachEveryProvidersMascot() {
    let events: [(AgentEvent, EventProvider, String)] = [
        (.started, .claudeCode, "claude-1"),
        (.active, .claudeCode, "claude-1"),
    ]
    // Pause, ideating, and preview are aimed at the app rather than one pet,
    // so they must not be filtered away with the other provider's sessions.
    let paused = ManualOverrides(isPaused: true)
    #expect(reduce(events, attributedTo: .claudeCode, overrides: paused).state == .paused)
    #expect(reduce(events, attributedTo: .codex, overrides: paused).state == .paused)

    let preview = ManualOverrides(preview: .sleeping)
    #expect(reduce(events, attributedTo: .claudeCode, overrides: preview).state == .sleeping)
    #expect(reduce(events, attributedTo: .codex, overrides: preview).state == .sleeping)
}
