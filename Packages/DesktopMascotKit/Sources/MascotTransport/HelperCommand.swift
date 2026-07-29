import CryptoKit
import Foundation
import MascotCore

/// Argument handling for the `dockpet-event` helper, kept out of `main.swift` so
/// every parsing and hashing rule is unit-testable.
public enum HelperCommand {
    /// No case echoes an argument value. A caller-supplied string is untrusted
    /// input that may contain private content, exactly as on the decode path.
    public enum ParseError: Error, Equatable, Sendable {
        case helpRequested
        case unknownFlag
        case missingValue
        case missingProvider
        case missingEvent
        case missingSession
        case unknownProvider
        case unknownEvent
        case repeatedFlag
    }

    public static let usage = """
    usage: dockpet-event --provider <claude-code|codex> --event <event> --session <id> [--detail <detail>] [--verbose]

      events:  started active waiting completed failed stopped heartbeat
      details: tool permission input network timeout cancelled

    Sends one local lifecycle event to a running Dock Pet over the current user's
    private socket. Exits 0 when Dock Pet is not running, so a provider hook is
    never failed by the mascot being closed.

    The session value is hashed locally before it is sent; the raw value never
    reaches the app. No other argument is accepted, so prompt text, file paths,
    tool arguments, and tool output have nowhere to go.
    """

    public static func envelope(from arguments: [String], now: Date) throws -> EventEnvelope {
        var provider: String?
        var event: String?
        var session: String?
        var detail: String?

        var index = 0
        while index < arguments.count {
            let flag = arguments[index]
            if flag == "--help" || flag == "-h" { throw ParseError.helpRequested }
            if flag == "--verbose" {
                index += 1
                continue
            }

            guard index + 1 < arguments.count else { throw ParseError.missingValue }
            let value = arguments[index + 1]
            index += 2

            switch flag {
            case "--provider":
                guard provider == nil else { throw ParseError.repeatedFlag }
                provider = value
            case "--event":
                guard event == nil else { throw ParseError.repeatedFlag }
                event = value
            case "--session":
                guard session == nil else { throw ParseError.repeatedFlag }
                session = value
            case "--detail":
                guard detail == nil else { throw ParseError.repeatedFlag }
                detail = value
            default:
                throw ParseError.unknownFlag
            }
        }

        guard let provider else { throw ParseError.missingProvider }
        guard let event else { throw ParseError.missingEvent }
        guard let session, !session.isEmpty else { throw ParseError.missingSession }
        guard let resolvedProvider = EventProvider(rawValue: provider) else { throw ParseError.unknownProvider }
        guard let resolvedEvent = AgentEvent(rawValue: event) else { throw ParseError.unknownEvent }

        return EventEnvelope(
            provider: resolvedProvider,
            sessionID: opaqueSessionID(from: session),
            event: resolvedEvent,
            occurredAt: now,
            // An unrecognized detail is dropped, matching the decoder: detail only
            // refines a reaction and must not invalidate the event.
            detail: detail.flatMap(EventDetail.init(rawValue:))
        )
    }

    /// Hashes whatever the provider supplied into a fixed-shape opaque ID.
    ///
    /// The raw value never leaves this process. Hashing means the app cannot be
    /// handed a provider's real session identifier even by a careless adapter,
    /// and it makes `SessionID` validity a property of construction rather than
    /// something the caller has to get right.
    public static func opaqueSessionID(from raw: String) -> SessionID {
        let digest = SHA256.hash(data: Data(raw.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        // 32 hex characters is 128 bits of the digest: far beyond collision risk
        // for a handful of concurrent local sessions, and short enough to read.
        return SessionID(String(hex.prefix(32)))!
    }
}
