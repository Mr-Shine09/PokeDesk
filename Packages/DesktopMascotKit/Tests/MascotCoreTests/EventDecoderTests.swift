import Foundation
import MascotCore
import Testing

private let referenceNow = ISO8601DateFormatter().date(from: "2026-07-29T18:00:00Z")!

private func payload(
    version: String = "1",
    provider: String = "claude-code",
    sessionID: String = "opaque-local-id",
    event: String = "active",
    occurredAt: String = "2026-07-29T18:00:00Z",
    detail: String? = "tool",
    extra: String = ""
) -> Data {
    let detailField = detail.map { ",\n  \"detail\": \"\($0)\"" } ?? ""
    return Data("""
    {
      "version": \(version),
      "provider": "\(provider)",
      "session_id": "\(sessionID)",
      "event": "\(event)",
      "occurred_at": "\(occurredAt)"\(detailField)\(extra)
    }
    """.utf8)
}

// MARK: - Accepting valid events

@Test func decodesAValidClaudeCodeEvent() throws {
    let envelope = try EventDecoder().decode(payload(), now: referenceNow)

    #expect(envelope.version == 1)
    #expect(envelope.provider == .claudeCode)
    #expect(envelope.sessionID.rawValue == "opaque-local-id")
    #expect(envelope.event == .active)
    #expect(envelope.occurredAt == referenceNow)
    #expect(envelope.detail == .tool)
}

@Test func decodesCodexAndFractionalSecondTimestamps() throws {
    let envelope = try EventDecoder().decode(
        payload(provider: "codex", event: "waiting", occurredAt: "2026-07-29T18:00:00.250Z", detail: "permission"),
        now: referenceNow
    )

    #expect(envelope.provider == .codex)
    #expect(envelope.event == .waiting)
    #expect(envelope.detail == .permission)
    #expect(abs(envelope.occurredAt.timeIntervalSince(referenceNow) - 0.25) < 0.001)
}

@Test func decodesEveryDeclaredEventValue() throws {
    for event in AgentEvent.allCases {
        let envelope = try EventDecoder().decode(payload(event: event.rawValue), now: referenceNow)
        #expect(envelope.event == event)
    }
}

@Test func decodingIsIdempotentForIdenticalBytes() throws {
    let decoder = EventDecoder()
    let bytes = payload()

    #expect(try decoder.decode(bytes, now: referenceNow) == decoder.decode(bytes, now: referenceNow))
}

// MARK: - Privacy boundary

@Test func forbiddenPayloadFieldsAreDiscarded() throws {
    let hostile = """
    ,
      "prompt": "SECRET PROMPT TEXT",
      "transcript_path": "/Users/someone/.claude/transcript.jsonl",
      "cwd": "/Users/someone/private-repo",
      "tool_input": {"command": "cat ~/.ssh/id_rsa"},
      "tool_output": "ssh-rsa SECRET",
      "repository": "private-repo",
      "access_token": "sk-SECRET"
    """
    let envelope = try EventDecoder().decode(payload(extra: hostile), now: referenceNow)

    let rendered = String(describing: envelope)
    for secret in ["SECRET", "transcript", "private-repo", "id_rsa", "sk-"] {
        #expect(rendered.contains(secret) == false)
    }
    #expect(envelope.sessionID.rawValue == "opaque-local-id")
}

@Test func envelopeExposesOnlyTheAllowlistedFields() throws {
    let envelope = try EventDecoder().decode(payload(), now: referenceNow)
    let fields = Mirror(reflecting: envelope).children.compactMap(\.label).sorted()

    #expect(fields == ["detail", "event", "occurredAt", "provider", "sessionID", "version"])
}

@Test func errorsNeverCarryPayloadContent() {
    // Contains spaces so it is invalid as a provider, an event, and a session ID.
    let secret = "SECRET PROMPT TEXT"

    for bytes in [payload(provider: secret), payload(event: secret), payload(sessionID: secret)] {
        do {
            _ = try EventDecoder().decode(bytes, now: referenceNow)
            Issue.record("Expected the payload to be rejected")
        } catch {
            #expect(String(describing: error).contains("SECRET") == false)
            #expect(String(reflecting: error).contains("SECRET") == false)
        }
    }
}

// MARK: - Failing closed

@Test func rejectsUnsupportedVersions() {
    for version in ["0", "2", "99"] {
        #expect(throws: EventDecodingError.self) {
            try EventDecoder().decode(payload(version: version), now: referenceNow)
        }
    }
}

@Test func rejectsUnknownProvidersAndEvents() {
    #expect(throws: EventDecodingError.unknownProvider) {
        try EventDecoder().decode(payload(provider: "chatgpt-web"), now: referenceNow)
    }
    #expect(throws: EventDecodingError.unknownEvent) {
        try EventDecoder().decode(payload(event: "thinking"), now: referenceNow)
    }
}

@Test func rejectsMalformedJSON() {
    let cases: [Data] = [
        Data("".utf8),
        Data("not json".utf8),
        Data("{\"version\": 1".utf8),
        Data("[]".utf8),
        Data("{\"version\": \"one\", \"provider\": \"codex\"}".utf8),
        payload(detail: nil, extra: "").dropLast(1),
    ]

    for bytes in cases {
        #expect(throws: EventDecodingError.self) {
            try EventDecoder().decode(Data(bytes), now: referenceNow)
        }
    }
}

@Test func rejectsMissingRequiredFields() {
    let missingEvent = Data("""
    {"version": 1, "provider": "codex", "session_id": "abc", "occurred_at": "2026-07-29T18:00:00Z"}
    """.utf8)

    #expect(throws: EventDecodingError.malformedJSON) {
        try EventDecoder().decode(missingEvent, now: referenceNow)
    }
}

@Test func rejectsOversizedPayloadsBeforeParsing() {
    let limits = EventDecoderLimits(maximumPayloadBytes: 64)
    let bytes = payload()

    #expect(bytes.count > 64)
    #expect(throws: EventDecodingError.payloadTooLarge(bytes: bytes.count, limit: 64)) {
        try EventDecoder(limits: limits).decode(bytes, now: referenceNow)
    }
}

// MARK: - Session identifiers

@Test func rejectsSessionIdentifiersThatCouldCarryPrivateContent() {
    let rejected = [
        "",
        "/Users/someone/private-repo",
        "session id with spaces",
        "session:with:colons",
        "\(String(repeating: "a", count: 129))",
    ]

    for candidate in rejected {
        #expect(SessionID(candidate) == nil)
        #expect(throws: EventDecodingError.invalidSessionID) {
            try EventDecoder().decode(payload(sessionID: candidate), now: referenceNow)
        }
    }
}

@Test func acceptsOpaqueSessionIdentifiers() {
    #expect(SessionID("a") != nil)
    #expect(SessionID("7f3c1d2e-9ab0-4c5d-8e6f-0123456789ab") != nil)
    #expect(SessionID(String(repeating: "a", count: 128)) != nil)
}

// MARK: - Timestamps and the injected clock

@Test func rejectsUnparsableTimestamps() {
    for stamp in ["", "2026-07-29", "yesterday", "18:00:00"] {
        #expect(throws: EventDecodingError.invalidTimestamp) {
            try EventDecoder().decode(payload(occurredAt: stamp), now: referenceNow)
        }
    }
}

@Test func rejectsTimestampsBeyondTheSkewTolerance() {
    let decoder = EventDecoder()
    let farFuture = referenceNow.addingTimeInterval(600)
    let farPast = referenceNow.addingTimeInterval(-7_200)
    let formatter = ISO8601DateFormatter()

    #expect(throws: EventDecodingError.self) {
        try decoder.decode(payload(occurredAt: formatter.string(from: farFuture)), now: referenceNow)
    }
    #expect(throws: EventDecodingError.self) {
        try decoder.decode(payload(occurredAt: formatter.string(from: farPast)), now: referenceNow)
    }
}

@Test func acceptsTimestampsInsideTheSkewTolerance() throws {
    let decoder = EventDecoder()
    let formatter = ISO8601DateFormatter()
    let slightlyAhead = formatter.string(from: referenceNow.addingTimeInterval(60))

    let envelope = try decoder.decode(payload(occurredAt: slightlyAhead), now: referenceNow)
    #expect(envelope.occurredAt > referenceNow)
}

@Test func theInjectedClockAloneDecidesSkewOutcomes() throws {
    let decoder = EventDecoder()
    let bytes = payload(occurredAt: "2026-07-29T18:00:00Z")

    _ = try decoder.decode(bytes, now: referenceNow)
    #expect(throws: EventDecodingError.self) {
        try decoder.decode(bytes, now: referenceNow.addingTimeInterval(7_200))
    }
}

// MARK: - Detail handling

@Test func unknownDetailIsDiscardedWithoutRejectingTheEvent() throws {
    let envelope = try EventDecoder().decode(payload(detail: "brand-new-provider-detail"), now: referenceNow)

    #expect(envelope.event == .active)
    #expect(envelope.detail == nil)
}

@Test func absentDetailDecodesAsNil() throws {
    let envelope = try EventDecoder().decode(payload(detail: nil), now: referenceNow)

    #expect(envelope.detail == nil)
}

@Test func decodesEveryDeclaredDetailValue() throws {
    for detail in EventDetail.allCases {
        let envelope = try EventDecoder().decode(payload(detail: detail.rawValue), now: referenceNow)
        #expect(envelope.detail == detail)
    }
}
