import Foundation
import MascotCore
@testable import MascotTransport
import Testing

private let referenceNow = ISO8601DateFormatter().date(from: "2026-07-29T18:00:00Z")!

private let validArguments = ["--provider", "codex", "--event", "active", "--session", "abc123"]

@Test func parsesAFullCommand() throws {
    let envelope = try HelperCommand.envelope(
        from: validArguments + ["--detail", "tool"],
        now: referenceNow
    )

    #expect(envelope.provider == .codex)
    #expect(envelope.event == .active)
    #expect(envelope.detail == .tool)
    #expect(envelope.occurredAt == referenceNow)
    #expect(envelope.version == 1)
}

@Test func acceptsVerboseAnywhereWithoutConsumingAValue() throws {
    let envelope = try HelperCommand.envelope(
        from: ["--verbose"] + validArguments + ["--verbose"],
        now: referenceNow
    )

    #expect(envelope.event == .active)
}

@Test func requiresProviderEventAndSession() {
    #expect(throws: HelperCommand.ParseError.missingProvider) {
        try HelperCommand.envelope(from: ["--event", "active", "--session", "a"], now: referenceNow)
    }
    #expect(throws: HelperCommand.ParseError.missingEvent) {
        try HelperCommand.envelope(from: ["--provider", "codex", "--session", "a"], now: referenceNow)
    }
    #expect(throws: HelperCommand.ParseError.missingSession) {
        try HelperCommand.envelope(from: ["--provider", "codex", "--event", "active"], now: referenceNow)
    }
    #expect(throws: HelperCommand.ParseError.missingSession) {
        try HelperCommand.envelope(
            from: ["--provider", "codex", "--event", "active", "--session", ""],
            now: referenceNow
        )
    }
}

@Test func rejectsUnknownProviderAndEvent() {
    #expect(throws: HelperCommand.ParseError.unknownProvider) {
        try HelperCommand.envelope(
            from: ["--provider", "gemini", "--event", "active", "--session", "a"],
            now: referenceNow
        )
    }
    #expect(throws: HelperCommand.ParseError.unknownEvent) {
        try HelperCommand.envelope(
            from: ["--provider", "codex", "--event", "thinking", "--session", "a"],
            now: referenceNow
        )
    }
}

@Test func rejectsUnknownRepeatedAndValuelessFlags() {
    #expect(throws: HelperCommand.ParseError.unknownFlag) {
        try HelperCommand.envelope(from: validArguments + ["--cwd", "/Users/someone/secret"], now: referenceNow)
    }
    #expect(throws: HelperCommand.ParseError.repeatedFlag) {
        try HelperCommand.envelope(from: validArguments + ["--event", "failed"], now: referenceNow)
    }
    #expect(throws: HelperCommand.ParseError.missingValue) {
        try HelperCommand.envelope(from: validArguments + ["--detail"], now: referenceNow)
    }
}

@Test func requestsHelpForBothHelpFlags() {
    for flag in ["--help", "-h"] {
        #expect(throws: HelperCommand.ParseError.helpRequested) {
            try HelperCommand.envelope(from: [flag], now: referenceNow)
        }
    }
}

@Test func anUnknownDetailIsDroppedWithoutFailingTheEvent() throws {
    let envelope = try HelperCommand.envelope(
        from: validArguments + ["--detail", "compacting"],
        now: referenceNow
    )

    #expect(envelope.event == .active)
    #expect(envelope.detail == nil)
}

@Test func parseErrorsNeverEchoArgumentValues() {
    let secret = "/Users/someone/Projects/private-repo/prompt.txt"

    for arguments in [
        ["--provider", secret, "--event", "active", "--session", "a"],
        ["--provider", "codex", "--event", secret, "--session", "a"],
        ["--unknown", secret]
    ] {
        do {
            _ = try HelperCommand.envelope(from: arguments, now: referenceNow)
            Issue.record("expected a parse failure")
        } catch let error as HelperCommand.ParseError {
            #expect(!"\(error)".contains("private-repo"))
            #expect(!"\(error)".contains(secret))
        } catch {
            Issue.record("unexpected error kind")
        }
    }
}

// MARK: - Session hashing

@Test func theSessionValueIsHashedRatherThanForwarded() {
    let raw = "0f9c1e6a-1111-2222-3333-444455556666"
    let hashed = HelperCommand.opaqueSessionID(from: raw)

    #expect(hashed.rawValue != raw)
    #expect(hashed.rawValue.count == 32)
    #expect(hashed.rawValue.allSatisfy { $0.isHexDigit && !$0.isUppercase })
}

@Test func hashingIsDeterministicAndCollisionFreeAcrossSessions() {
    #expect(
        HelperCommand.opaqueSessionID(from: "session-a").rawValue
            == HelperCommand.opaqueSessionID(from: "session-a").rawValue
    )
    #expect(
        HelperCommand.opaqueSessionID(from: "session-a").rawValue
            != HelperCommand.opaqueSessionID(from: "session-b").rawValue
    )
}

@Test func hashingRescuesRawValuesThatCouldNeverBeAValidSessionID() {
    // A careless adapter handing over a path, a very long string, or spaces must
    // still produce a valid opaque ID rather than a crash or a rejected event.
    for raw in [
        "/Users/someone/Library/Caches/transcript.jsonl",
        String(repeating: "x", count: 5_000),
        "session with spaces and 😀"
    ] {
        #expect(SessionID(raw) == nil)
        #expect(HelperCommand.opaqueSessionID(from: raw).rawValue.count == 32)
    }
}

@Test func aHashedSessionSurvivesTheRealDecoder() throws {
    let envelope = try HelperCommand.envelope(
        from: ["--provider", "claude-code", "--event", "waiting", "--session", "/tmp/whatever"],
        now: referenceNow
    )
    let frame = EventEncoder().encode(envelope)

    let decoded = try EventDecoder().decode(frame, now: referenceNow)
    #expect(decoded == envelope)
    #expect(!String(decoding: frame, as: UTF8.self).contains("tmp"))
}
