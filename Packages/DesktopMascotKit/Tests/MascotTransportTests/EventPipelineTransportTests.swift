import Foundation
import MascotCore
@testable import MascotTransport
import Testing

/// End-to-end coverage of the arrangement the app runs: a live socket server
/// feeding an `EventPipeline`, exactly as `AgentEventBridge` wires them.
///
/// The app-side bridge adds only a timer, the manual overrides, and two strings,
/// so these fixtures are what prove that a helper invocation actually reaches
/// reduced state rather than stopping at the decoder.
private final class PipelineSink: @unchecked Sendable {
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private var pipeline: EventPipeline
    /// Advanced by the test, never read from a real clock, so expiry and reaction
    /// windows stay deterministic here too.
    private var uptime = Uptime(seconds: 1_000)

    init(reducer: MascotStateReducer) {
        pipeline = EventPipeline(reducer: reducer)
    }

    func ingest(_ envelope: EventEnvelope) {
        lock.withLock { pipeline.ingest(envelope, now: Date(), uptime: uptime) }
        semaphore.signal()
    }

    func noteRejection() {
        lock.withLock { pipeline.noteRejectedFrame(now: Date(), uptime: uptime) }
        semaphore.signal()
    }

    func advance(by seconds: TimeInterval) {
        lock.withLock {
            uptime = uptime.advanced(by: seconds)
            pipeline.refresh(now: Date(), uptime: uptime)
        }
    }

    var visibleState: MascotVisibleState { lock.withLock { pipeline.visibleState } }
    var diagnostics: EventPipelineDiagnostics { lock.withLock { pipeline.diagnostics } }

    /// Guards against a hang; it is not a timing assertion.
    @discardableResult
    func waitForCallbacks(_ count: Int, timeout: TimeInterval = 5) -> Bool {
        for _ in 0 ..< count {
            guard semaphore.wait(timeout: .now() + timeout) == .success else { return false }
        }
        return true
    }
}

/// Short unique path: the full socket path has to fit `sun_path`.
private func temporarySocketURL() -> URL {
    let unique = String(UUID().uuidString.prefix(8))
    return FileManager.default.temporaryDirectory
        .appendingPathComponent("dp-\(unique)", isDirectory: true)
        .appendingPathComponent("events.sock", isDirectory: false)
}

/// Fixed time zone so the sleep window cannot depend on the test machine.
private let daytimeReducer = MascotStateReducer(
    sleepWindow: SleepWindow(startHour: 23, endHour: 6),
    calendar: {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
)

private func send(_ event: AgentEvent, session: String, to url: URL) throws {
    let envelope = EventEnvelope(
        provider: .claudeCode,
        sessionID: SessionID(session)!,
        event: event,
        occurredAt: Date()
    )
    let client = EventSocketClient(socketURL: url)
    try client.send(envelope)
}

@Test func aDeliveredEventReachesReducedStateThroughTheRealSocket() throws {
    let url = temporarySocketURL()
    // Midday in the fixed calendar, so the reduction cannot land in sleep.
    let sink = PipelineSink(reducer: daytimeReducer)
    let server = EventSocketServer(
        configuration: EventSocketServer.Configuration(socketURL: url),
        onEvent: { sink.ingest($0) },
        onRejection: { _ in sink.noteRejection() }
    )
    try server.start()
    defer { server.stop() }

    try send(.active, session: "bridge-session", to: url)
    #expect(sink.waitForCallbacks(1))

    #expect(sink.visibleState.state == .working)
    #expect(sink.visibleState.providers == [.claudeCode])
    #expect(sink.diagnostics.acceptedEvents == 1)
    #expect(sink.diagnostics.trackedSessions == 1)
}

@Test func aCompletedTurnReachesSuccessAndThenDecaysOnItsOwn() throws {
    let url = temporarySocketURL()
    let sink = PipelineSink(reducer: daytimeReducer)
    let server = EventSocketServer(
        configuration: EventSocketServer.Configuration(socketURL: url),
        onEvent: { sink.ingest($0) },
        onRejection: { _ in sink.noteRejection() }
    )
    try server.start()
    defer { server.stop() }

    try send(.active, session: "bridge-session", to: url)
    try send(.completed, session: "bridge-session", to: url)
    #expect(sink.waitForCallbacks(2))
    #expect(sink.visibleState.state == .success)

    // No further traffic: the reaction and then the session expire on time alone.
    sink.advance(by: 5)
    #expect(sink.visibleState.state == .idle)
    sink.advance(by: 200)
    #expect(sink.visibleState.state == .offline)
    #expect(sink.diagnostics.trackedSessions == 0)
}

@Test func aMalformedFrameIsCountedAndLeavesReducedStateAlone() throws {
    let url = temporarySocketURL()
    let sink = PipelineSink(reducer: daytimeReducer)
    let server = EventSocketServer(
        configuration: EventSocketServer.Configuration(socketURL: url),
        onEvent: { sink.ingest($0) },
        onRejection: { _ in sink.noteRejection() }
    )
    try server.start()
    defer { server.stop() }

    try send(.active, session: "bridge-session", to: url)
    #expect(sink.waitForCallbacks(1))

    let raw = EventSocketClient(socketURL: url)
    try raw.send(frame: Data(#"{"version":1,"provider":"nope"}"#.utf8 + [0x0A]))
    #expect(sink.waitForCallbacks(1))

    #expect(sink.visibleState.state == .working)
    #expect(sink.diagnostics.rejectedFrames == 1)
    #expect(sink.diagnostics.acceptedEvents == 1)
}
