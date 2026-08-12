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

private func reduce(
    _ events: [(AgentEvent, EventProvider, String)],
    attributedTo provider: EventProvider,
    overrides: ManualOverrides = .none,
    chat: ChatPresence = .none,
    now: Date = daytime,
    uptime: Uptime = boot
) -> MascotVisibleState {
    reducer().reduce(
        registry: registry(events),
        attributedTo: provider,
        overrides: overrides,
        chat: chat,
        now: now,
        uptime: uptime
    )
}

/// A registry holding one session whose events carry an explicit surface.
private func surfacedRegistry(
    _ events: [(AgentEvent, EventProvider, String, EventSurface?, EventDetail?)],
    at uptime: Uptime = boot
) -> SessionRegistry {
    var registry = SessionRegistry()
    for (index, entry) in events.enumerated() {
        registry.ingest(
            EventEnvelope(
                provider: entry.1,
                sessionID: SessionID(entry.2)!,
                event: entry.0,
                occurredAt: daytime.addingTimeInterval(TimeInterval(index)),
                detail: entry.4,
                surface: entry.3
            ),
            at: uptime
        )
    }
    return registry
}

private func reduceSurfaced(
    _ events: [(AgentEvent, EventProvider, String, EventSurface?, EventDetail?)],
    uptime: Uptime = boot
) -> MascotVisibleState {
    reducer().reduce(
        registry: surfacedRegistry(events),
        overrides: .none,
        chat: .none,
        now: daytime,
        uptime: uptime
    )
}

private let claudeChat = ChatPresence(activities: [.claudeCode: .generating])
private let claudeChatOpen = ChatPresence(activities: [.claudeCode: .open])
private let claudeChatDone = ChatPresence(activities: [.claudeCode: .completed])

@Test func aGeneratingChatResponseMakesTheMascotThink() {
    let state = reduce([], chat: claudeChat)

    #expect(state.state == .ideating)
    // Unlike manual ideating, this signal is attributable, so it names the
    // mascot that should react.
    #expect(state.providers == [.claudeCode])
}

/// The correction that came out of watching the first version run.
///
/// Until 2026-08-11 a frontmost chat app alone drove the Thinker pose, and it
/// looked wrong for the obvious reason: the pet thought continuously while a
/// human was reading and typing. Being in front is context, not thought.
@Test func aChatAppThatIsMerelyOpenChangesNothing() {
    let state = reduce([], chat: claudeChatOpen)

    #expect(state.state == .offline)
}

/// A finished chat response gets the same fist pump a finished agent turn does.
@Test func aCompletedChatResponsePlaysTheSuccessReaction() {
    let state = reduce([], chat: claudeChatDone)

    #expect(state.state == .success)
    #expect(state.providers == [.claudeCode])
}

/// Chat activity is attributed like everything else: the Claude app must not
/// make the Codex mascot react.
@Test func aChatResponseReachesOnlyItsOwnProvidersMascot() {
    let claude = reduce([], attributedTo: .claudeCode, chat: claudeChat)
    let codex = reduce([], attributedTo: .codex, chat: claudeChat)

    #expect(claude.state == .ideating)
    #expect(codex.state == .offline)
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

/// An idle Claude Code session must not block a chat response, and this rule
/// replaced its own opposite on 2026-08-11.
///
/// While the signal was "a chat app is frontmost", any live session had to
/// suppress it: one bundle identifier hosts both the chat and Claude Code, so
/// frontmost could not tell asking a question from watching an agent between
/// turns. That suppression made the feature unreachable in practice — anyone
/// using Claude Code at all keeps a session alive, and the owner saw exactly
/// nothing. The signal is now the chat window's own streaming marker, which is
/// a fact rather than an inference, so ordering alone is enough.
@Test func anIdleSessionDoesNotBlockAGeneratingChatResponse() {
    // `.started` leaves the session present but idle: Claude Code open, quiet.
    let state = reduce([(.started, .claudeCode, "s-quiet")], chat: claudeChat)

    #expect(state.state == .ideating)
}

/// The other half of the same rule: a *working* agent still wins, so a real turn
/// is never hidden by a chat response in the same app.
@Test func aWorkingSessionStillOutranksAGeneratingChatResponse() {
    let state = reduce([(.active, .claudeCode, "s-work")], chat: claudeChat)

    #expect(state.state == .working)
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

@Test func onlyAppsWithACapturedMarkerAreWatchable() {
    // The distinction the `Descriptor` type exists to make: an app can be known
    // and probed without being watched. ChatGPT is listed and permanently
    // unwatched — the ChatGPT desktop app is the Codex app, so its turns already
    // arrive as real hook events, which outrank and outclass a "probably
    // thinking" guess. Capturing a marker for it would add a weaker second
    // signal that the ladder would never show.
    let claude = ChatApp.descriptor(forBundleIdentifier: "com.anthropic.claudefordesktop")
    #expect(claude?.streamingMarker == "Currently streaming message")
    #expect(claude?.streamingSubrole == "AXDocumentArticle")
    #expect(claude?.isWatchable == true)

    let chatGPT = ChatApp.descriptor(forBundleIdentifier: "com.openai.codex")
    #expect(chatGPT?.provider == .codex)
    #expect(chatGPT?.streamingMarker == nil)
    #expect(chatGPT?.isWatchable == false)

    #expect(ChatApp.watchable.map(\.provider) == [.claudeCode])
}

// MARK: - Event surface

@Test func aTurnDrivenFromADesktopChatThinksRatherThanTypes() {
    // The ChatGPT desktop app is the Codex app, so this arrives as an ordinary
    // codex `active` event. Owner rule, 2026-08-11: the chat interface thinks.
    let visible = reduceSurfaced([(.active, .codex, "chat", .desktopChat, nil)])
    #expect(visible.state == .ideating)
    #expect(visible.providers == [.codex])
}

@Test func anAgentRunInsideTheChatAppTypesRatherThanThinks() {
    // The owner's correction, watched on screen: surface alone made Codex agent
    // runs think along with the chat, because the ChatGPT app hosts both behind
    // one binary and one process tree. Tool traffic is what separates them.
    let visible = reduceSurfaced([
        (.active, .codex, "agent", .desktopChat, nil),
        (.active, .codex, "agent", .desktopChat, .tool),
    ])
    #expect(visible.state == .working)
}

@Test func aNewPromptEndsTheAgentRunAndReturnsToThinking() {
    // Turn-scoped, not session-scoped. One conversation alternates between
    // asking a question and asking for work; a sticky flag would leave the pet
    // typing at a chat for the rest of the session.
    let visible = reduceSurfaced([
        (.active, .codex, "mixed", .desktopChat, .tool),
        (.active, .codex, "mixed", .desktopChat, nil),
    ])
    #expect(visible.state == .ideating)
}

@Test func aCommandLineRunTypesBeforeItReachesAnyTool() {
    // The surface half of the rule earns its place here: a terminal turn is
    // agent work from the prompt onward, so it must not think during the gap
    // before its first tool call.
    #expect(reduceSurfaced([(.active, .codex, "cli", .commandLine, nil)]).state == .working)
}

@Test func aTurnDrivenFromACommandLineStillTypes() {
    #expect(reduceSurfaced([(.active, .codex, "cli", .commandLine, nil)]).state == .working)
}

@Test func aTurnWithNoSurfaceStillTypes() {
    // The default must be the behavior Dock Pet had before surfaces existed: an
    // older helper, or a provider whose origin could not be determined, must not
    // silently turn agent work into a Thinker pose.
    #expect(reduceSurfaced([(.active, .codex, "unknown", nil, nil)]).state == .working)
    #expect(reduceSurfaced([(.active, .claudeCode, "cc", nil, nil)]).state == .working)
}

@Test func aTerminalRunOutranksAChatTurnOnTheSameMascot() {
    // Both are `.codex` and both drive the navy mascot. Real agent work at a
    // command line is the stronger claim, which is why the chat turn shares the
    // weaker chat-ideating rung instead of competing at the working one.
    let visible = reduceSurfaced([
        (.active, .codex, "chat", .desktopChat, nil),
        (.active, .codex, "cli", .commandLine, nil),
    ])
    #expect(visible.state == .working)
    #expect(visible.providers == [.codex])
}

@Test func aFinishedChatTurnStillGetsItsSuccessReaction() {
    // Completion is unchanged by surface: the fist pump is the same for a chat
    // turn as for an agent run, which is what the owner already watched happen.
    #expect(reduceSurfaced([(.completed, .codex, "chat", .desktopChat, nil)]).state == .success)
}

@Test func aLaterHookWithNoSurfaceDoesNotEraseTheOriginalOne() {
    // Only the first hook of a turn may be able to see the app in its ancestry.
    // If a later one writing `nil` could clear it, the pose would flip from
    // thinking to typing partway through a single chat turn.
    let visible = reduceSurfaced([
        (.started, .codex, "chat", .desktopChat, nil),
        (.active, .codex, "chat", nil, nil),
    ])
    #expect(visible.state == .ideating)
}

@Test func everyChatAppHasADistinctIdentifierAndProvider() {
    // Two descriptors sharing a provider would give one mascot two sources of
    // chat truth; two sharing an identifier would make the lookup order matter.
    #expect(Set(ChatApp.all.map(\.bundleIdentifier)).count == ChatApp.all.count)
    #expect(Set(ChatApp.all.map(\.provider)).count == ChatApp.all.count)
    #expect(ChatApp.identifiers.count == ChatApp.all.count)
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
