import Foundation
import MascotCore
@testable import MascotTransport
import Testing

/// Collects server callbacks from the socket queue and lets a test block until a
/// given number of them have arrived.
private final class Recorder: @unchecked Sendable {
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private var storedEvents: [EventEnvelope] = []
    private var storedRejections: [EventRejection] = []

    func record(_ envelope: EventEnvelope) {
        lock.withLock { storedEvents.append(envelope) }
        semaphore.signal()
    }

    func record(_ rejection: EventRejection) {
        lock.withLock { storedRejections.append(rejection) }
        semaphore.signal()
    }

    /// Generous timeout: this guards against a hang, it is not a timing assertion.
    @discardableResult
    func waitForCallbacks(_ count: Int, timeout: TimeInterval = 5) -> Bool {
        for _ in 0 ..< count {
            guard semaphore.wait(timeout: .now() + timeout) == .success else { return false }
        }
        return true
    }

    var events: [EventEnvelope] { lock.withLock { storedEvents } }
    var rejections: [EventRejection] { lock.withLock { storedRejections } }
}

/// Short unique path: the full socket path has to fit `sun_path`, and a macOS
/// temporary directory already consumes about half of the 103 usable bytes.
private func temporarySocketURL() -> URL {
    let unique = String(UUID().uuidString.prefix(8))
    return FileManager.default.temporaryDirectory
        .appendingPathComponent("dp-\(unique)", isDirectory: true)
        .appendingPathComponent("events.sock", isDirectory: false)
}

private func makeServer(
    at url: URL,
    recorder: Recorder,
    now: @escaping @Sendable () -> Date = Date.init,
    limits: EventDecoderLimits = EventDecoderLimits()
) -> EventSocketServer {
    EventSocketServer(
        configuration: EventSocketServer.Configuration(socketURL: url, decoderLimits: limits),
        now: now,
        onEvent: { recorder.record($0) },
        onRejection: { recorder.record($0) }
    )
}

private func envelope(_ event: AgentEvent = .active, at date: Date = Date()) -> EventEnvelope {
    EventEnvelope(
        provider: .claudeCode,
        sessionID: SessionID("round-trip-session")!,
        event: event,
        occurredAt: date
    )
}

// MARK: - Round trip

@Test func deliversAnEventFromTheHelperToTheApp() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    let sent = envelope(.waiting)
    try EventSocketClient(socketURL: url).send(sent)

    #expect(recorder.waitForCallbacks(1))
    #expect(recorder.events.count == 1)
    #expect(recorder.events.first?.event == .waiting)
    #expect(recorder.events.first?.sessionID == sent.sessionID)
    #expect(recorder.rejections.isEmpty)
}

@Test func deliversEveryEventTypeAcrossSeparateConnections() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    let client = EventSocketClient(socketURL: url)
    for event in AgentEvent.allCases {
        try client.send(envelope(event))
    }

    #expect(recorder.waitForCallbacks(AgentEvent.allCases.count))
    #expect(Set(recorder.events.map(\.event)) == Set(AgentEvent.allCases))
    #expect(recorder.rejections.isEmpty)
}

@Test func deliversTwoFramesWrittenAsOneChunk() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    let encoder = EventEncoder()
    var chunk = encoder.encodeFrame(envelope(.started))
    chunk.append(encoder.encodeFrame(envelope(.completed)))
    try EventSocketClient(socketURL: url).send(frame: chunk)

    #expect(recorder.waitForCallbacks(2))
    #expect(recorder.events.map(\.event) == [.started, .completed])
}

// MARK: - Hostile input

@Test func aMalformedFrameIsRejectedAndTheNextFrameStillArrives() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    var chunk = Data("this is not json at all\n".utf8)
    chunk.append(EventEncoder().encodeFrame(envelope(.active)))
    try EventSocketClient(socketURL: url).send(frame: chunk)

    #expect(recorder.waitForCallbacks(2))
    #expect(recorder.rejections == [.decoding(.malformedJSON)])
    #expect(recorder.events.map(\.event) == [.active])
}

@Test func anOversizedFrameIsRejectedAndTheNextFrameStillArrives() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    var chunk = Data(repeating: 0x41, count: 9_000)
    chunk.append(0x0A)
    chunk.append(EventEncoder().encodeFrame(envelope(.active)))
    try EventSocketClient(socketURL: url).send(frame: chunk)

    #expect(recorder.waitForCallbacks(2))
    #expect(recorder.rejections == [.oversizedFrame(bytes: 9_000)])
    #expect(recorder.events.map(\.event) == [.active])
}

@Test func unknownProviderBytesAreRejectedWithoutPayloadContent() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    let hostile = """
    {"version": 1, "provider": "/Users/someone/secret", "session_id": "a", \
    "event": "active", "occurred_at": "2026-07-29T18:00:00Z"}

    """
    try EventSocketClient(socketURL: url).send(frame: Data(hostile.utf8))

    #expect(recorder.waitForCallbacks(1))
    #expect(recorder.rejections == [.decoding(.unknownProvider)])
    #expect(recorder.events.isEmpty)
    #expect(!"\(recorder.rejections)".contains("secret"))
}

@Test func theInjectedServerClockDecidesSkewRejection() throws {
    let url = temporarySocketURL()
    let recorder = Recorder()
    // The server believes it is a day behind the helper, so a correctly stamped
    // event is beyond the future-skew bound.
    let frozen = Date().addingTimeInterval(-86_400)
    let server = makeServer(at: url, recorder: recorder, now: { frozen })
    try server.start()
    defer { server.stop() }

    try EventSocketClient(socketURL: url).send(envelope(.active))

    #expect(recorder.waitForCallbacks(1))
    #expect(recorder.events.isEmpty)
    if case .decoding(.timestampTooFarInFuture) = recorder.rejections.first {
        // Expected.
    } else {
        Issue.record("expected a future-skew rejection, got \(recorder.rejections)")
    }
}

// MARK: - Socket lifecycle

@Test func theClientReportsNotListeningWhenTheAppIsClosed() {
    let url = temporarySocketURL()
    try? FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )

    #expect(throws: EventSocketClientError.self) {
        try EventSocketClient(socketURL: url).send(envelope())
    }
}

@Test func aStaleSocketFileIsReplacedOnStart() throws {
    let url = temporarySocketURL()
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    // Stand in for the file a crashed process would leave behind.
    try Data("leftover".utf8).write(to: url)

    let recorder = Recorder()
    let server = makeServer(at: url, recorder: recorder)
    try server.start()
    defer { server.stop() }

    try EventSocketClient(socketURL: url).send(envelope())
    #expect(recorder.waitForCallbacks(1))
    #expect(recorder.events.count == 1)
}

@Test func aSecondServerRefusesToStealALiveSocket() throws {
    let url = temporarySocketURL()
    let first = makeServer(at: url, recorder: Recorder())
    try first.start()
    defer { first.stop() }

    let second = makeServer(at: url, recorder: Recorder())
    #expect(throws: EventSocketServerError.addressInUse) {
        try second.start()
    }
}

@Test func startingTheSameServerTwiceIsRefused() throws {
    let url = temporarySocketURL()
    let server = makeServer(at: url, recorder: Recorder())
    try server.start()
    defer { server.stop() }

    #expect(throws: EventSocketServerError.alreadyRunning) {
        try server.start()
    }
}

@Test func stopRemovesTheSocketFileAndIsIdempotent() throws {
    let url = temporarySocketURL()
    let server = makeServer(at: url, recorder: Recorder())
    try server.start()
    #expect(FileManager.default.fileExists(atPath: url.path))
    #expect(server.isListening)

    server.stop()
    server.stop()

    #expect(!FileManager.default.fileExists(atPath: url.path))
    #expect(!server.isListening)
}

@Test func aSocketPathTooLongForSunPathIsRefusedBeforeAnythingIsCreated() {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(String(repeating: "d", count: 120), isDirectory: true)
    let url = directory.appendingPathComponent("events.sock")

    let server = makeServer(at: url, recorder: Recorder())
    #expect(throws: EventSocketServerError.socketPathTooLong) {
        try server.start()
    }
    #expect(!FileManager.default.fileExists(atPath: directory.path))
}

@Test func theSocketAndItsDirectoryAreOwnerOnly() throws {
    let url = temporarySocketURL()
    let server = makeServer(at: url, recorder: Recorder())
    try server.start()
    defer { server.stop() }

    let socketMode = try FileManager.default
        .attributesOfItem(atPath: url.path)[.posixPermissions] as? NSNumber
    let directoryMode = try FileManager.default
        .attributesOfItem(atPath: url.deletingLastPathComponent().path)[.posixPermissions] as? NSNumber

    #expect(socketMode?.int16Value == 0o600)
    #expect(directoryMode?.int16Value == 0o700)
}
