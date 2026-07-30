import Foundation
import MascotCore

/// The only two fields Dock Pet reads out of a provider hook payload.
///
/// Claude Code and Codex both hand a hook a JSON object on stdin containing the
/// working directory, the transcript path, the model, the permission mode, and —
/// on tool events — the tool name and its full arguments. All of that is exactly
/// what this project promises never to read.
///
/// So this is a deliberate extraction rather than a decode: two string fields are
/// pulled out by name and **every other key is dropped without being inspected**.
/// A provider adding a field cannot widen what Dock Pet sees, because nothing
/// enumerates the payload's keys.
public struct HookPayload: Equatable, Sendable {
    /// Which lifecycle point fired, e.g. `PreToolUse`. Mapped to the event
    /// vocabulary by `HookEventMapping`; never sent anywhere as text.
    public let hookEventName: String
    /// The provider's own session identifier. Hashed before it leaves the
    /// process, so the raw value never reaches the app.
    public let sessionID: String

    /// Bound on how much stdin is read. A hook payload is small, but a tool
    /// event can carry an arbitrarily large `tool_input`, and there is no reason
    /// to pull a megabyte of someone's source code into memory to find two
    /// strings. Beyond this the payload is abandoned, silently.
    public static let maximumPayloadBytes = 1 << 20

    public init(hookEventName: String, sessionID: String) {
        self.hookEventName = hookEventName
        self.sessionID = sessionID
    }

    /// Returns `nil` for anything unusable — not valid JSON, not an object, or
    /// missing either field. There is no error type on purpose: a hook must
    /// never fail the user's agent session over a payload it did not understand.
    public static func extract(from data: Data) -> HookPayload? {
        guard data.count <= maximumPayloadBytes else { return nil }
        guard
            let root = try? JSONSerialization.jsonObject(with: data),
            let object = root as? [String: Any],
            let hookEventName = object["hook_event_name"] as? String,
            let sessionID = object["session_id"] as? String,
            !hookEventName.isEmpty,
            !sessionID.isEmpty
        else {
            return nil
        }
        return HookPayload(hookEventName: hookEventName, sessionID: sessionID)
    }
}

/// Translates provider hook names into the frozen event vocabulary.
///
/// The vocabulary does not grow to fit the providers; the providers are mapped
/// onto it. A hook with no honest equivalent is ignored rather than approximated,
/// because a wrong state on screen is worse than no state.
public enum HookEventMapping {
    public struct Reaction: Equatable, Sendable {
        public let event: AgentEvent
        public let detail: EventDetail?

        init(_ event: AgentEvent, _ detail: EventDetail? = nil) {
            self.event = event
            self.detail = detail
        }
    }

    /// `nil` means "no honest mapping" and the hook sends nothing at all.
    public static func reaction(for hookEventName: String, provider: EventProvider) -> Reaction? {
        switch hookEventName {
        // A session exists but has claimed no work yet.
        case "SessionStart":
            return Reaction(.started)

        // The user asked for something, so work begins now rather than at the
        // first tool call — the model is already thinking.
        case "UserPromptSubmit":
            return Reaction(.active)

        // Tool traffic is the clearest evidence of ongoing work.
        case "PreToolUse", "PostToolUse", "PostToolBatch":
            return Reaction(.active, .tool)

        // A failed tool is not a failed turn. The agent usually retries, and
        // showing failure here would make the mascot flinch at routine errors,
        // so this only says work continues.
        case "PostToolUseFailure":
            return Reaction(.active, .tool)

        // Blocked on the human. This is the state the whole project exists to
        // make glanceable, so it is mapped from every signal that means it.
        case "PermissionRequest":
            return Reaction(.waiting, .permission)
        case "Elicitation":
            return Reaction(.waiting, .input)
        case "Notification":
            // Claude Code fires this for permission and idle prompts alike; both
            // mean the turn cannot proceed without the user.
            return provider == .claudeCode ? Reaction(.waiting, .input) : nil

        // The turn ended. `completed` asserts only that the turn finished, not
        // that everything inside it succeeded.
        case "Stop":
            return Reaction(.completed)

        // The only turn-level failure either provider reports.
        case "StopFailure":
            return Reaction(.failed)

        case "SessionEnd":
            return Reaction(.stopped)

        // Work is continuing but nothing new is being asserted. `heartbeat`
        // refreshes expiry without promoting an idle session to working, and it
        // cannot conjure a session the registry never saw start.
        case "SubagentStart", "SubagentStop", "PreCompact", "PostCompact":
            return Reaction(.heartbeat)

        // Everything else — prompt expansion, config changes, file watching,
        // message display, task bookkeeping — describes the provider's own
        // internals, not whether an agent is working.
        default:
            return nil
        }
    }
}
