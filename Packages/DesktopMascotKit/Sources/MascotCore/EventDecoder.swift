import Foundation

public struct EventDecoderLimits: Equatable, Sendable {
    /// Rejected before any parsing so a hostile payload cannot be walked at all.
    public var maximumPayloadBytes: Int
    /// How far ahead of the injected clock a timestamp may sit.
    public var maximumFutureSkew: TimeInterval
    /// How far behind the injected clock a timestamp may sit.
    public var maximumAge: TimeInterval

    public init(
        maximumPayloadBytes: Int = 4_096,
        maximumFutureSkew: TimeInterval = 120,
        maximumAge: TimeInterval = 3_600
    ) {
        self.maximumPayloadBytes = maximumPayloadBytes
        self.maximumFutureSkew = maximumFutureSkew
        self.maximumAge = maximumAge
    }
}

/// Decoding failures.
///
/// No case carries a value copied from the payload. An unknown provider or
/// event name is untrusted text that may contain private content, so it is
/// reported by kind only and never returned, stored, or logged.
public enum EventDecodingError: Error, Equatable, Sendable {
    case payloadTooLarge(bytes: Int, limit: Int)
    case malformedJSON
    case unsupportedVersion(Int)
    case unknownProvider
    case unknownEvent
    case invalidSessionID
    case invalidTimestamp
    case timestampTooFarInFuture(skew: TimeInterval)
    case timestampTooOld(age: TimeInterval)
}

/// Strict, side-effect-free decoder from transport bytes to an `EventEnvelope`.
///
/// The decoder never reads the clock itself; callers inject `now` so ordering,
/// skew, and expiry behavior are deterministic under test.
public struct EventDecoder: Sendable {
    /// Mirrors the wire schema. Keys outside this set are dropped by
    /// `JSONDecoder` and therefore never reach the app.
    private struct Payload: Decodable {
        let version: Int
        let provider: String
        let sessionID: String
        let event: String
        let occurredAt: String
        let detail: String?
        let surface: String?

        enum CodingKeys: String, CodingKey {
            case version
            case provider
            case sessionID = "session_id"
            case event
            case occurredAt = "occurred_at"
            case detail
            case surface
        }
    }

    public let limits: EventDecoderLimits

    public init(limits: EventDecoderLimits = EventDecoderLimits()) {
        self.limits = limits
    }

    public func decode(_ data: Data, now: Date) throws -> EventEnvelope {
        guard data.count <= limits.maximumPayloadBytes else {
            throw EventDecodingError.payloadTooLarge(bytes: data.count, limit: limits.maximumPayloadBytes)
        }
        guard let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            throw EventDecodingError.malformedJSON
        }
        guard payload.version == EventEnvelope.currentVersion else {
            throw EventDecodingError.unsupportedVersion(payload.version)
        }
        guard let provider = EventProvider(rawValue: payload.provider) else {
            throw EventDecodingError.unknownProvider
        }
        guard let event = AgentEvent(rawValue: payload.event) else {
            throw EventDecodingError.unknownEvent
        }
        guard let sessionID = SessionID(payload.sessionID) else {
            throw EventDecodingError.invalidSessionID
        }
        guard let occurredAt = Self.date(fromRFC3339: payload.occurredAt) else {
            throw EventDecodingError.invalidTimestamp
        }

        let skew = occurredAt.timeIntervalSince(now)
        if skew > limits.maximumFutureSkew {
            throw EventDecodingError.timestampTooFarInFuture(skew: skew)
        }
        if -skew > limits.maximumAge {
            throw EventDecodingError.timestampTooOld(age: -skew)
        }

        return EventEnvelope(
            version: payload.version,
            provider: provider,
            sessionID: sessionID,
            event: event,
            occurredAt: occurredAt,
            detail: payload.detail.flatMap(EventDetail.init(rawValue:)),
            surface: payload.surface.flatMap(EventSurface.init(rawValue:))
        )
    }

    /// Formatters are built per call rather than shared: `ISO8601DateFormatter`
    /// is not `Sendable`, and event volume is far too low for this to matter.
    private static func date(fromRFC3339 string: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: string) { return date }

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: string)
    }
}
