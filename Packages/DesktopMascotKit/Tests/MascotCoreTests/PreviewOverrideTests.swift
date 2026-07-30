import Foundation
import MascotCore
import Testing

private let wallClock = ISO8601DateFormatter().date(from: "2026-07-30T14:00:00Z")!
private let boot = Uptime(seconds: 9_000)

private let daytimeReducer = MascotStateReducer(
    sleepWindow: SleepWindow(startHour: 23, endHour: 6),
    calendar: {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
)

/// Built through the registry rather than by constructing an `AgentSession`
/// directly: its initializer is internal on purpose, and widening that API for a
/// test would weaken the same privacy boundary the type exists to hold.
private func workingSessions(provider: EventProvider = .claudeCode) -> [AgentSession] {
    var registry = SessionRegistry()
    registry.ingest(
        EventEnvelope(
            provider: provider,
            sessionID: SessionID("preview-session")!,
            event: .active,
            occurredAt: wallClock
        ),
        at: boot
    )
    return registry.sessions(at: boot)
}

@Test func everyStateCanBePreviewedWithoutAnAgent() {
    // The point of the feature: all of them, not just the ones a session can
    // currently produce.
    for state in MascotState.allCases {
        let reduced = daytimeReducer.reduce(
            sessions: [],
            overrides: ManualOverrides(preview: state),
            now: wallClock,
            uptime: boot
        )
        #expect(reduced.state == state)
    }
}

@Test func aPreviewNeverClaimsAProviderProducedIt() {
    let reduced = daytimeReducer.reduce(
        sessions: workingSessions(),
        overrides: ManualOverrides(preview: .failure),
        now: wallClock,
        uptime: boot
    )

    #expect(reduced.state == .failure)
    // A real claude-code session is present and working, but the failure on
    // screen is not its doing, so attributing it would be a lie.
    #expect(reduced.providers.isEmpty)
}

@Test func aPreviewOutranksPauseSoItCannotSilentlyShowSomethingElse() {
    let reduced = daytimeReducer.reduce(
        sessions: [],
        overrides: ManualOverrides(isPaused: true, preview: .sleeping),
        now: wallClock,
        uptime: boot
    )

    #expect(reduced.state == .sleeping)
}

@Test func clearingThePreviewRestoresTheRealReducedState() {
    let sessions = workingSessions()

    let previewing = daytimeReducer.reduce(
        sessions: sessions,
        overrides: ManualOverrides(preview: .success),
        now: wallClock,
        uptime: boot
    )
    let restored = daytimeReducer.reduce(
        sessions: sessions,
        overrides: .none,
        now: wallClock,
        uptime: boot
    )

    #expect(previewing.state == .success)
    #expect(restored.state == .working)
    #expect(restored.providers == [.claudeCode])
}

@Test func previewChangesWhatIsShownAndNotWhatIsBelieved() {
    // A preview must not enter the registry, or a fabricated state would become
    // indistinguishable from a real one after the fact.
    var pipeline = EventPipeline(reducer: daytimeReducer)
    pipeline.refresh(overrides: ManualOverrides(preview: .failure), now: wallClock, uptime: boot)

    #expect(pipeline.visibleState.state == .failure)
    #expect(pipeline.registry.trackedSessionCount == 0)
    #expect(pipeline.diagnostics.acceptedEvents == 0)
}

@Test func theDocumentedPriorityIsUnchangedWhenNoPreviewIsSet() {
    // Guards the rest of the chain against this addition.
    let paused = daytimeReducer.reduce(
        sessions: workingSessions(),
        overrides: ManualOverrides(isPaused: true),
        now: wallClock,
        uptime: boot
    )
    let working = daytimeReducer.reduce(
        sessions: workingSessions(),
        overrides: .none,
        now: wallClock,
        uptime: boot
    )

    #expect(paused.state == .paused)
    #expect(working.state == .working)
}
