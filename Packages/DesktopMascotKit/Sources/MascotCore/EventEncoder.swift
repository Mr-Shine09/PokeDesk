import Foundation

/// Writes an `EventEnvelope` back to the wire form `EventDecoder` accepts.
///
/// The encoder exists so the helper CLI and the decoder share one definition of
/// the wire format instead of the helper hand-assembling JSON. It can only
/// serialize an already-validated envelope, so it cannot introduce a field the
/// envelope does not have.
public struct EventEncoder: Sendable {
    public init() {}

    public func encode(_ envelope: EventEnvelope) -> Data {
        // Keys are written in the documented order with a fixed formatter rather
        // than `JSONEncoder`, so the bytes are reproducible and fixtures can
        // compare them directly.
        var fields = [
            "\"version\": \(envelope.version)",
            "\"provider\": \"\(envelope.provider.rawValue)\"",
            "\"session_id\": \"\(envelope.sessionID.rawValue)\"",
            "\"event\": \"\(envelope.event.rawValue)\"",
            "\"occurred_at\": \"\(Self.rfc3339(envelope.occurredAt))\""
        ]
        if let detail = envelope.detail {
            fields.append("\"detail\": \"\(detail.rawValue)\"")
        }
        if let surface = envelope.surface {
            fields.append("\"surface\": \"\(surface.rawValue)\"")
        }
        return Data("{\(fields.joined(separator: ", "))}".utf8)
    }

    /// A single frame: the JSON object plus the newline the transport splits on.
    public func encodeFrame(_ envelope: EventEnvelope) -> Data {
        var data = encode(envelope)
        data.append(0x0A)
        return data
    }

    /// Every value interpolated above comes from a validated enum, an `Int`, or
    /// this formatter, so none of them can contain a quote or backslash that
    /// would need escaping.
    private static func rfc3339(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
