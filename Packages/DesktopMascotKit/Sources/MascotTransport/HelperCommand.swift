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
           dockpet-event --provider <claude-code|codex> --hook [--verbose]
           dockpet-event --provider <claude-code|codex> --print-hooks

      events:  started active waiting completed failed stopped heartbeat
      details: tool permission input network timeout cancelled

    Sends one local lifecycle event to a running Dock Pet over the current user's
    private socket. Exits 0 when Dock Pet is not running, so a provider hook is
    never failed by the mascot being closed.

    --hook reads a provider hook payload on stdin and maps it onto the event
    vocabulary. Only `hook_event_name` and `session_id` are read; every other key
    is dropped without being inspected, so the working directory, transcript
    path, tool arguments, and tool output have nowhere to go.

    --print-hooks writes a ready-to-paste configuration snippet to stdout. It
    never edits a configuration file: installing the hook stays the user's action.

    The session value is hashed locally before it is sent; the raw value never
    reaches the app.
    """

    /// What the caller asked for. Parsed before anything is sent, so an
    /// unusable invocation cannot half-execute.
    public enum Invocation: Equatable, Sendable {
        case send(EventEnvelope)
        /// Read a hook payload from stdin and map it.
        case hook(provider: EventProvider)
        case printHooks(provider: EventProvider)
    }

    public static func invocation(from arguments: [String], now: Date) throws -> Invocation {
        if arguments.contains("--help") || arguments.contains("-h") {
            throw ParseError.helpRequested
        }
        let wantsHook = arguments.contains("--hook")
        let wantsPrint = arguments.contains("--print-hooks")
        guard !(wantsHook && wantsPrint) else { throw ParseError.unknownFlag }

        guard wantsHook || wantsPrint else {
            return .send(try envelope(from: arguments, now: now))
        }

        // Both modes take exactly one other flag, so anything else is a mistake
        // worth reporting rather than ignoring.
        let mode = wantsHook ? "--hook" : "--print-hooks"
        var provider: EventProvider?
        var index = 0
        while index < arguments.count {
            let flag = arguments[index]
            if flag == mode || flag == "--verbose" {
                index += 1
                continue
            }
            guard flag == "--provider" else { throw ParseError.unknownFlag }
            guard index + 1 < arguments.count else { throw ParseError.missingValue }
            guard provider == nil else { throw ParseError.repeatedFlag }
            guard let resolved = EventProvider(rawValue: arguments[index + 1]) else {
                throw ParseError.unknownProvider
            }
            provider = resolved
            index += 2
        }
        guard let provider else { throw ParseError.missingProvider }
        return wantsHook ? .hook(provider: provider) : .printHooks(provider: provider)
    }

    /// Maps an extracted hook payload onto an envelope.
    ///
    /// `nil` means the hook has no honest equivalent in the vocabulary and
    /// nothing should be sent — not that anything went wrong.
    public static func envelope(
        forHook payload: HookPayload,
        provider: EventProvider,
        now: Date
    ) -> EventEnvelope? {
        guard let reaction = HookEventMapping.reaction(for: payload.hookEventName, provider: provider) else {
            return nil
        }
        return EventEnvelope(
            provider: provider,
            sessionID: opaqueSessionID(from: payload.sessionID),
            event: reaction.event,
            occurredAt: now,
            detail: reaction.detail
        )
    }

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
