import Foundation
import MascotCore

/// Generates the configuration a user pastes into their provider settings.
///
/// Dock Pet prints this and never writes it. Editing someone's agent
/// configuration is not a mascot's business: a bad write there breaks the tool
/// they actually work in, and an installer that silently edits `settings.json`
/// is exactly the kind of thing this project promised not to be.
public enum HookConfiguration {
    /// The hooks worth registering. Deliberately a subset: every additional hook
    /// is another process spawned inside the user's session, and the states the
    /// mascot can actually show do not need the rest.
    ///
    /// `SessionEnd` is included even though its budget is tight — it is what
    /// retires a session promptly instead of waiting out the heartbeat timeout.
    public static let registeredEvents = [
        "SessionStart",
        "UserPromptSubmit",
        "PreToolUse",
        "PostToolUse",
        "PermissionRequest",
        "Stop",
        "StopFailure",
        "SessionEnd",
    ]

    /// Events the provider does not offer, so they are omitted rather than
    /// registered and silently ignored.
    static func events(for provider: EventProvider) -> [String] {
        switch provider {
        case .claudeCode:
            return registeredEvents
        case .codex:
            // Codex documents no `StopFailure`; a turn that dies on an API error
            // surfaces only as the session ending.
            return registeredEvents.filter { $0 != "StopFailure" }
        }
    }

    /// A `hooks` object for the provider's settings file.
    ///
    /// `timeout` is 5 seconds rather than the 600-second default: this helper
    /// connects to a local socket and exits, so anything approaching a timeout
    /// means something is wrong, and a hook that hangs would stall the user's
    /// real session. Every handler is the same one-shot command, which is why
    /// the mapping lives in the helper rather than in eight shell snippets.
    public static func snippet(for provider: EventProvider, helperPath: String) -> String {
        let handlers = events(for: provider).map { event in
            """
                "\(event)": [
                  {
                    "matcher": "*",
                    "hooks": [
                      {
                        "type": "command",
                        "command": \(quoted(helperPath)),
                        "args": ["--hook", "--provider", "\(provider.rawValue)"],
                        "timeout": 5
                      }
                    ]
                  }
                ]
            """
        }
        return """
        {
          "hooks": {
        \(handlers.joined(separator: ",\n"))
          }
        }
        """
    }

    /// Where the snippet goes, and the one caveat that actually bites.
    public static func instructions(for provider: EventProvider, helperPath: String) -> String {
        let destination = provider == .claudeCode
            ? "~/.claude/settings.json"
            : "~/.codex/hooks.json (or an inline [hooks] table in config.toml)"
        return """
        Merge the following into \(destination).

        If that file already has a "hooks" object, merge these events into it
        rather than replacing it — this snippet is not the whole file.

        The command path below points at the running app bundle. It is not
        durable: rebuilding or moving Dock Pet invalidates it, and the hook then
        does nothing until the path is updated. That is a missing-install
        problem, not a hook failure.

        \(snippet(for: provider, helperPath: helperPath))
        """
    }

    /// JSON string escaping for the one value that is interpolated. The path is
    /// machine-supplied rather than user-typed, but it still gets escaped, since
    /// a bundle can legitimately live under a directory containing a quote.
    private static func quoted(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
