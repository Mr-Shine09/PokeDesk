import Foundation
@testable import MascotTransport
import Testing

/// Writes `chunks` to a pipe with a pause between them, optionally leaving the
/// write end open to imitate a provider that never closes stdin.
///
/// Returns the `Pipe` rather than just its read handle, and the caller must keep
/// it alive: a released `Pipe` closes its write end, which produces the very EOF
/// the "never closes" case is trying to withhold.
private func makePipe(
    chunks: [String],
    gap: TimeInterval = 0.05,
    closeAfterWriting: Bool = true
) -> Pipe {
    let pipe = Pipe()
    DispatchQueue.global().async {
        for chunk in chunks {
            pipe.fileHandleForWriting.write(Data(chunk.utf8))
            Thread.sleep(forTimeInterval: gap)
        }
        if closeAfterWriting {
            try? pipe.fileHandleForWriting.close()
        }
    }
    return pipe
}

@Test func aPayloadSplitAcrossChunksIsReadWhole() throws {
    // The bug this guards: reading only the first chunk yields truncated JSON
    // that extracts to nothing, so the mascot silently misses events.
    let pipe = makePipe(chunks: [
        #"{"hook_event_name":"Stop","#,
        #""session_id":"split-session""#,
        "}",
    ])

    let data = try #require(
        HookPayloadReader.read(from: pipe.fileHandleForReading, deadline: 5)
    )
    let payload = try #require(HookPayload.extract(from: data))

    #expect(payload.hookEventName == "Stop")
    #expect(payload.sessionID == "split-session")
}

@Test func aWriterThatNeverClosesDoesNotStallForever() {
    let pipe = makePipe(chunks: [#"{"hook_event_name":"Stop""#], closeAfterWriting: false)

    let started = Date()
    let data = withExtendedLifetime(pipe) {
        HookPayloadReader.read(from: pipe.fileHandleForReading, deadline: 0.3)
    }

    #expect(data == nil)
    // The point is the bound, not the exact number: a hook must never outlive
    // its own deadline by a meaningful margin.
    #expect(Date().timeIntervalSince(started) < 2)
}

@Test func anOversizedStreamIsAbandonedWithoutBuffering() {
    let pipe = makePipe(chunks: [String(repeating: "x", count: 5_000)], gap: 0)

    #expect(
        HookPayloadReader.read(
            from: pipe.fileHandleForReading, byteLimit: 1_000, deadline: 5
        ) == nil
    )
}

@Test func anImmediatelyClosedStdinReadsAsEmptyRatherThanHanging() throws {
    let pipe = makePipe(chunks: [])

    let data = try #require(
        HookPayloadReader.read(from: pipe.fileHandleForReading, deadline: 5)
    )

    #expect(data.isEmpty)
    #expect(HookPayload.extract(from: data) == nil)
}
