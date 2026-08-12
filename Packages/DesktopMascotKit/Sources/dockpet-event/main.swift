import Darwin
import Foundation
import MascotCore
import MascotTransport

// Exit codes are chosen so a provider hook is never failed by Dock Pet:
//   0  sent, nothing worth sending, or Dock Pet is simply not running
//   64 usage error (EX_USAGE)
//
// Nothing below can exit non-zero once parsing has succeeded. A hook runs inside
// the user's real Claude Code or Codex session, so a mascot that cannot be
// reached must look exactly like a mascot that was updated.
let arguments = Array(CommandLine.arguments.dropFirst())
let verbose = arguments.contains("--verbose")

func note(_ message: String) {
    guard verbose else { return }
    FileHandle.standardError.write(Data("dockpet-event: \(message)\n".utf8))
}

func send(_ envelope: EventEnvelope) {
    do {
        let client = EventSocketClient(socketURL: try EventSocketLocation.socketURL())
        try client.send(envelope)
        note("sent \(envelope.event.rawValue) for \(envelope.provider.rawValue)")
    } catch let error as EventSocketClientError {
        // Dock Pet being closed is the normal case, not an error worth surfacing.
        note("not delivered: \(error)")
    } catch {
        note("not delivered")
    }
}

do {
    switch try HelperCommand.invocation(from: arguments, now: Date()) {
    case .send(let envelope):
        send(envelope)

    case .hook(let provider):
        // Reads the payload whole, and gives up rather than waiting forever if
        // the provider holds stdin open. See `HookPayloadReader`.
        guard
            let payload = HookPayloadReader.read(from: .standardInput),
            let extracted = HookPayload.extract(from: payload)
        else {
            // Unparsable, oversized, or missing the two fields. Silence is the
            // correct outcome: the user's session must not learn about this.
            note("hook payload not usable")
            break
        }
        // Worked out here, in the process the hook actually spawned, because the
        // app receives nothing that could tell it apart later — see
        // `EventSurfaceDetector`. Only two words ever leave this process.
        guard
            let envelope = HelperCommand.envelope(
                forHook: extracted,
                provider: provider,
                now: Date(),
                surface: EventSurfaceDetector.current()
            )
        else {
            note("hook has no mapped event")
            break
        }
        send(envelope)

    case .printHooks(let provider):
        print(HookConfiguration.instructions(for: provider, helperPath: CommandLine.arguments[0]))
    }
} catch HelperCommand.ParseError.helpRequested {
    print(HelperCommand.usage)
} catch let error as HelperCommand.ParseError {
    // Usage errors are the only failure a caller can fix, so they are the only
    // ones reported unconditionally — and the message names the rule, never the
    // offending argument value. A hook is configured once by a human, so a
    // wrong flag is worth failing loudly at that moment.
    FileHandle.standardError.write(Data("dockpet-event: \(error)\n\(HelperCommand.usage)\n".utf8))
    exit(64)
} catch {
    note("not delivered")
}
