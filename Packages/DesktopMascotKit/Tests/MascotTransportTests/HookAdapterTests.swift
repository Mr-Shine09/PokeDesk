import Foundation
import MascotCore
@testable import MascotTransport
import Testing

private let now = ISO8601DateFormatter().date(from: "2026-07-30T11:00:00Z")!

/// A realistic Claude Code `PreToolUse` payload, including every field the
/// project promises never to read.
private let realisticToolPayload = """
{
  "session_id": "abc123-session",
  "prompt_id": "550e8400-e29b-41d4-a716-446655440000",
  "transcript_path": "/Users/someone/.claude/projects/secret-client/transcript.jsonl",
  "cwd": "/Users/someone/code/acquisition-model",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "psql -c 'select * from salaries' --password hunter2" },
  "tool_use_id": "toolu_01ABC123"
}
"""

// MARK: - Privacy boundary

@Test func extractionKeepsOnlyTheEventNameAndSessionID() throws {
    let payload = try #require(HookPayload.extract(from: Data(realisticToolPayload.utf8)))

    #expect(payload.hookEventName == "PreToolUse")
    #expect(payload.sessionID == "abc123-session")
}

@Test func nothingFromThePayloadSurvivesIntoTheEnvelope() throws {
    let payload = try #require(HookPayload.extract(from: Data(realisticToolPayload.utf8)))
    let envelope = try #require(
        HelperCommand.envelope(forHook: payload, provider: .claudeCode, now: now)
    )

    // The whole envelope, rendered as text, must contain none of the payload's
    // private content — not the path, the cwd, the command, or the password.
    let rendered = String(decoding: EventEncoder().encodeFrame(envelope), as: UTF8.self)
    for forbidden in [
        "transcript", "secret-client", "acquisition-model", "psql",
        "salaries", "hunter2", "Bash", "toolu_01ABC123", "abc123-session",
    ] {
        #expect(!rendered.contains(forbidden), "envelope leaked \(forbidden)")
    }
}

@Test func theRawSessionIDIsHashedRatherThanForwarded() throws {
    let payload = try #require(HookPayload.extract(from: Data(realisticToolPayload.utf8)))
    let envelope = try #require(
        HelperCommand.envelope(forHook: payload, provider: .claudeCode, now: now)
    )

    #expect(envelope.sessionID.rawValue != "abc123-session")
    #expect(envelope.sessionID == HelperCommand.opaqueSessionID(from: "abc123-session"))
    // Same session, same opaque ID, or the registry could not track a session
    // across its own lifecycle.
    #expect(
        HelperCommand.opaqueSessionID(from: "abc123-session")
            == HelperCommand.opaqueSessionID(from: "abc123-session")
    )
}

@Test func oversizedPayloadsAreAbandonedRatherThanParsed() {
    // A tool event carrying a large file is realistic; reading it is not.
    let huge = #"{"hook_event_name":"PreToolUse","session_id":"s","tool_input":""#
        + String(repeating: "x", count: HookPayload.maximumPayloadBytes)
        + #""}"#

    #expect(HookPayload.extract(from: Data(huge.utf8)) == nil)
}

// MARK: - Unusable input never becomes an error

@Test func unusablePayloadsExtractToNilInsteadOfThrowing() {
    let cases = [
        "",
        "not json at all",
        "[]",
        "null",
        #"{"hook_event_name":"Stop"}"#,
        #"{"session_id":"abc"}"#,
        #"{"hook_event_name":"","session_id":"abc"}"#,
        #"{"hook_event_name":"Stop","session_id":""}"#,
        #"{"hook_event_name":42,"session_id":"abc"}"#,
    ]

    for raw in cases {
        #expect(HookPayload.extract(from: Data(raw.utf8)) == nil, "should be unusable: \(raw)")
    }
}

// MARK: - Mapping

@Test func lifecycleHooksMapOntoTheFrozenVocabulary() {
    let expected: [(String, AgentEvent, EventDetail?)] = [
        ("SessionStart", .started, nil),
        ("UserPromptSubmit", .active, nil),
        ("PreToolUse", .active, .tool),
        ("PostToolUse", .active, .tool),
        ("PermissionRequest", .waiting, .permission),
        ("Stop", .completed, nil),
        ("StopFailure", .failed, nil),
        ("SessionEnd", .stopped, nil),
    ]

    for (hook, event, detail) in expected {
        let reaction = HookEventMapping.reaction(for: hook, provider: .claudeCode)
        #expect(reaction?.event == event, "\(hook) mapped to \(String(describing: reaction?.event))")
        #expect(reaction?.detail == detail, "\(hook) detail")
    }
}

@Test func aFailedToolIsNotAFailedTurn() {
    // The agent usually retries; flinching at routine tool errors would make the
    // failure state meaningless.
    let reaction = HookEventMapping.reaction(for: "PostToolUseFailure", provider: .claudeCode)

    #expect(reaction?.event == .active)
    #expect(reaction?.event != .failed)
}

@Test func bookkeepingHooksOnlyRefreshLiveness() {
    for hook in ["SubagentStart", "SubagentStop", "PreCompact", "PostCompact"] {
        #expect(HookEventMapping.reaction(for: hook, provider: .claudeCode)?.event == .heartbeat)
    }
}

@Test func hooksWithNoHonestEquivalentSendNothing() {
    for hook in [
        "UserPromptExpansion", "MessageDisplay", "InstructionsLoaded", "ConfigChange",
        "CwdChanged", "FileChanged", "WorktreeCreate", "TaskCreated", "Setup", "",
    ] {
        #expect(
            HookEventMapping.reaction(for: hook, provider: .claudeCode) == nil,
            "\(hook) should not map"
        )
    }
}

@Test func notificationIsClaudeCodeOnly() {
    // Codex documents no Notification hook, so mapping it there would invent a
    // state from a signal that never arrives.
    #expect(HookEventMapping.reaction(for: "Notification", provider: .claudeCode)?.event == .waiting)
    #expect(HookEventMapping.reaction(for: "Notification", provider: .codex) == nil)
}

@Test func anUnmappedHookProducesNoEnvelopeAtAll() {
    let payload = HookPayload(hookEventName: "FileChanged", sessionID: "abc")

    #expect(HelperCommand.envelope(forHook: payload, provider: .claudeCode, now: now) == nil)
}

@Test func everyMappedEventSurvivesTheStrictDecoder() throws {
    // The adapter must not be able to produce something the app would reject.
    let decoder = EventDecoder()
    for hook in HookConfiguration.registeredEvents {
        guard
            let envelope = HelperCommand.envelope(
                forHook: HookPayload(hookEventName: hook, sessionID: "session-value"),
                provider: .claudeCode,
                now: now
            )
        else { continue }
        let frame = EventEncoder().encodeFrame(envelope)
        #expect(throws: Never.self) { try decoder.decode(frame, now: now) }
    }
}

// MARK: - Invocation parsing

@Test func hookModeParsesToTheProviderItWasGiven() throws {
    #expect(
        try HelperCommand.invocation(from: ["--hook", "--provider", "codex"], now: now)
            == .hook(provider: .codex)
    )
    #expect(
        try HelperCommand.invocation(from: ["--provider", "claude-code", "--hook", "--verbose"], now: now)
            == .hook(provider: .claudeCode)
    )
}

@Test func hookModeRequiresAKnownProvider() {
    #expect(throws: HelperCommand.ParseError.missingProvider) {
        try HelperCommand.invocation(from: ["--hook"], now: now)
    }
    #expect(throws: HelperCommand.ParseError.unknownProvider) {
        try HelperCommand.invocation(from: ["--hook", "--provider", "cursor"], now: now)
    }
    #expect(throws: HelperCommand.ParseError.unknownFlag) {
        try HelperCommand.invocation(from: ["--hook", "--provider", "codex", "--session", "x"], now: now)
    }
}

@Test func directSendStillWorksUnchanged() throws {
    let invocation = try HelperCommand.invocation(
        from: ["--provider", "codex", "--event", "active", "--session", "s"],
        now: now
    )

    guard case .send(let envelope) = invocation else {
        Issue.record("expected a direct send")
        return
    }
    #expect(envelope.event == .active)
    #expect(envelope.provider == .codex)
}

// MARK: - Printed configuration

@Test func theSnippetIsValidJSONNamingTheHelperAndProvider() throws {
    let path = "/Applications/Dock Pet.app/Contents/MacOS/dockpet-event"
    let snippet = HookConfiguration.snippet(for: .claudeCode, helperPath: path)

    let parsed = try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    let hooks = try #require((parsed as? [String: Any])?["hooks"] as? [String: Any])

    #expect(Set(hooks.keys) == Set(HookConfiguration.events(for: .claudeCode)))
    #expect(snippet.contains(path))
    #expect(snippet.contains("--provider claude-code"))
}

@Test func codexOmitsTheHookItDoesNotHave() throws {
    let snippet = HookConfiguration.snippet(for: .codex, helperPath: "/tmp/dockpet-event")
    let parsed = try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    let hooks = try #require((parsed as? [String: Any])?["hooks"] as? [String: Any])

    #expect(!hooks.keys.contains("StopFailure"))
    #expect(hooks.keys.contains("Stop"))
}

/// Covers **both** providers, because covering only Codex is what let the bug
/// ship twice: neither one supports an `args` field, and a helper launched
/// without `--hook --provider` exits 64 on every hook while the mascot sits
/// still in a session that is plainly working.
@Test(arguments: [EventProvider.claudeCode, EventProvider.codex])
func hookModeGoesInTheCommandRatherThanAnUnsupportedArgsField(
    provider: EventProvider
) throws {
    let path = "/Applications/Dock Pet.app/Contents/MacOS/dockpet-event"
    let snippet = HookConfiguration.snippet(for: provider, helperPath: path)
    let parsed = try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    let hooks = try #require((parsed as? [String: Any])?["hooks"] as? [String: Any])
    let groups = try #require(hooks["UserPromptSubmit"] as? [[String: Any]])
    let handlers = try #require(groups.first?["hooks"] as? [[String: Any]])
    let handler = try #require(handlers.first)

    #expect(
        handler["command"] as? String
            == "'\(path)' --hook --provider \(provider.rawValue)"
    )
    #expect(handler["args"] == nil)
}

@Test func codexSessionEndUsesItsSupportedTimeoutCeiling() throws {
    let snippet = HookConfiguration.snippet(for: .codex, helperPath: "/tmp/dockpet-event")
    let parsed = try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    let hooks = try #require((parsed as? [String: Any])?["hooks"] as? [String: Any])
    let groups = try #require(hooks["SessionEnd"] as? [[String: Any]])
    let handlers = try #require(groups.first?["hooks"] as? [[String: Any]])

    #expect(handlers.first?["timeout"] as? Int == 3)
}

@Test func codexShellQuotesAnApostropheInTheHelperPath() throws {
    let path = "/Users/o'connor/Dock Pet.app/Contents/MacOS/dockpet-event"
    let snippet = HookConfiguration.snippet(for: .codex, helperPath: path)
    let parsed = try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    let hooks = try #require((parsed as? [String: Any])?["hooks"] as? [String: Any])
    let groups = try #require(hooks["Stop"] as? [[String: Any]])
    let handlers = try #require(groups.first?["hooks"] as? [[String: Any]])

    #expect(
        handlers.first?["command"] as? String
            == "'/Users/o'\"'\"'connor/Dock Pet.app/Contents/MacOS/dockpet-event' --hook --provider codex"
    )
}

@Test func aPathContainingAQuoteStillProducesValidJSON() throws {
    let snippet = HookConfiguration.snippet(
        for: .codex,
        helperPath: #"/Users/od"d/Dock Pet.app/Contents/MacOS/dockpet-event"#
    )

    #expect(throws: Never.self) {
        try JSONSerialization.jsonObject(with: Data(snippet.utf8))
    }
}

@Test func theInstructionsSayTheyDoNotEditAnything() {
    let text = HookConfiguration.instructions(for: .claudeCode, helperPath: "/tmp/x")

    #expect(text.contains("~/.claude/settings.json"))
    #expect(text.lowercased().contains("merge"))
    // Wording wraps across lines, so match the word rather than the phrase.
    #expect(text.lowercased().contains("durable"))
}
