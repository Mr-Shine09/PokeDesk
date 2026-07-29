import Foundation
import MascotCore
import Testing

private let encoderReferenceNow = ISO8601DateFormatter().date(from: "2026-07-29T18:00:00Z")!

private func envelope(
    provider: EventProvider = .claudeCode,
    event: AgentEvent = .active,
    detail: EventDetail? = .tool,
    occurredAt: Date = encoderReferenceNow
) -> EventEnvelope {
    EventEnvelope(
        provider: provider,
        sessionID: SessionID("encoder-session")!,
        event: event,
        occurredAt: occurredAt,
        detail: detail
    )
}

@Test func encodesTheDocumentedWireShape() {
    let json = String(decoding: EventEncoder().encode(envelope()), as: UTF8.self)

    #expect(json == """
    {"version": 1, "provider": "claude-code", "session_id": "encoder-session", \
    "event": "active", "occurred_at": "2026-07-29T18:00:00.000Z", "detail": "tool"}
    """)
}

@Test func omitsDetailEntirelyWhenAbsent() {
    let json = String(decoding: EventEncoder().encode(envelope(detail: nil)), as: UTF8.self)

    #expect(!json.contains("detail"))
}

@Test func everyEnvelopeRoundTripsThroughTheDecoder() throws {
    let decoder = EventDecoder()

    for provider in EventProvider.allCases {
        for event in AgentEvent.allCases {
            for detail in EventDetail.allCases.map(Optional.some) + [nil] {
                let original = envelope(provider: provider, event: event, detail: detail)
                let decoded = try decoder.decode(EventEncoder().encode(original), now: encoderReferenceNow)
                #expect(decoded == original)
            }
        }
    }
}

@Test func fractionalSecondsSurviveTheRoundTrip() throws {
    let original = envelope(occurredAt: encoderReferenceNow.addingTimeInterval(0.25))
    let decoded = try EventDecoder().decode(EventEncoder().encode(original), now: encoderReferenceNow)

    #expect(abs(decoded.occurredAt.timeIntervalSince(original.occurredAt)) < 0.001)
}

@Test func aFrameEndsWithExactlyOneNewline() {
    let frame = EventEncoder().encodeFrame(envelope())

    #expect(frame.last == 0x0A)
    #expect(frame.filter { $0 == 0x0A }.count == 1)
}

@Test func anEncodedFrameFitsInsideThePayloadCeiling() {
    // The envelope has six fixed-shape fields, so a frame can never approach the
    // 4 KB ceiling. If this ever fails, a field was widened.
    #expect(EventEncoder().encodeFrame(envelope()).count < 200)
}
