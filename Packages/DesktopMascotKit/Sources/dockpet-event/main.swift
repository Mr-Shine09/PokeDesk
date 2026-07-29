import Darwin
import Foundation
import MascotTransport

// Exit codes are chosen so a provider hook is never failed by Dock Pet:
//   0  sent, or Dock Pet is simply not running
//   64 usage error (EX_USAGE)
let arguments = Array(CommandLine.arguments.dropFirst())
let verbose = arguments.contains("--verbose")

func note(_ message: String) {
    guard verbose else { return }
    FileHandle.standardError.write(Data("dockpet-event: \(message)\n".utf8))
}

do {
    let envelope = try HelperCommand.envelope(from: arguments, now: Date())
    let client = EventSocketClient(socketURL: try EventSocketLocation.socketURL())
    try client.send(envelope)
    note("sent \(envelope.event.rawValue) for \(envelope.provider.rawValue)")
} catch HelperCommand.ParseError.helpRequested {
    print(HelperCommand.usage)
} catch let error as HelperCommand.ParseError {
    // Usage errors are the only failure a caller can fix, so they are the only
    // ones reported unconditionally — and the message names the rule, never the
    // offending argument value.
    FileHandle.standardError.write(Data("dockpet-event: \(error)\n\(HelperCommand.usage)\n".utf8))
    exit(64)
} catch let error as EventSocketClientError {
    // Dock Pet being closed is the normal case, not an error worth surfacing.
    note("not delivered: \(error)")
} catch {
    note("not delivered")
}
