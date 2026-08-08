import Foundation
@testable import MascotTransport
import Testing

/// Writes `chunks` to a pipe with a pause between them, optionally leaving the
/// write end open to imitate a provider that never closes stdin.
///
/// Returns the `Pipe` rather than just its read handle, and the caller must keep
/// it alive: a released `Pipe` closes its write end, which produces the very EOF
/// the "never closes" case is trying to withhold.
///
/// The writer runs on a **dedicated thread, not `DispatchQueue.global()`**.
/// It did use the global queue until 2026-08-08, when CI failed on its first
/// ever run and then failed a *different* test in this file on re-run. Every
/// test here parks three threads at once — the test thread on the reader's
/// semaphore, a pool thread inside `handle.availableData`, and a pool thread
/// sleeping here — and Swift Testing runs them in parallel. On a CI runner with
/// few cores the pool cannot grow fast enough, so a writer block waits seconds
/// to be scheduled and the reader hits its deadline. The proof it was
/// scheduling and not slowness: the failing re-run was the empty-chunks case,
/// whose writer only closes the handle, and it still took the full 5 seconds.
/// A machine with spare cores hides this completely, which is why it passed
/// locally for weeks. Do not move this back onto a shared queue.
private func makePipe(
    chunks: [String],
    gap: TimeInterval = 0.05,
    closeAfterWriting: Bool = true
) -> Pipe {
    let pipe = Pipe()
    let thread = Thread {
        for chunk in chunks {
            pipe.fileHandleForWriting.write(Data(chunk.utf8))
            Thread.sleep(forTimeInterval: gap)
        }
        if closeAfterWriting {
            try? pipe.fileHandleForWriting.close()
        }
    }
    thread.name = "HookPayloadReaderTests.writer"
    thread.start()
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
