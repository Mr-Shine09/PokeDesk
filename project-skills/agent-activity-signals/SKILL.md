---
name: agent-activity-signals
description: Design, implement, review, or debug adapters that map Claude Code, OpenAI Codex, terminal, and coding-agent lifecycle signals into a stable mascot state machine. Use for hooks, notification commands, local IPC, heartbeat/timeout logic, multi-session aggregation, privacy boundaries, process fallbacks, and status mappings such as working, waiting, success, failure, idle, sleeping, and disconnected.
---

# Agent Activity Signals

Prefer explicit agent lifecycle events over guessing from CPU use, window titles, terminal contents, or process names.

## Event Contract

Normalize every provider event into a local envelope:

```json
{
  "version": 1,
  "provider": "codex|claude|manual",
  "session_id": "opaque-local-id",
  "event": "started|active|waiting|completed|failed|stopped|heartbeat",
  "occurred_at": "RFC3339 timestamp",
  "detail": "optional non-sensitive category"
}
```

Do not include prompts, code, file paths, repository names, command output, or credentials unless the user explicitly opts into diagnostics that require them.

## Adapter Priority

1. Official hooks or notification commands documented by the provider.
2. A user-invoked wrapper that launches the coding agent and emits lifecycle events.
3. Read-only process presence as a coarse fallback for `active` versus `offline` only.

Never scrape terminal text, inspect another process's memory, use private APIs, or silently alter global agent configuration.

## Transport

- Prefer a user-local Unix domain socket or atomically replaced JSON file in the app container/support directory.
- Authenticate or permission the endpoint so only the current user can write.
- Validate version, provider, event enum, timestamp skew, payload size, and session identifier.
- Treat malformed events as diagnostics, not state transitions.

## State Reduction

Track sessions separately, then reduce them by priority:

`failed > waiting > active > completed-recently > idle > sleeping > disconnected`

- Debounce rapid changes.
- Require heartbeat expiry before declaring an abandoned active session disconnected.
- Keep success and failure reactions time-bounded, then fall back to the next aggregate state.
- Define deterministic behavior when Codex and Claude are active simultaneously.
- Make manual override higher priority until the user clears it.

## Verification

Test duplicated, reordered, missing, delayed, malformed, and concurrent events. Verify that agent crashes, laptop sleep/wake, clock changes, hook removal, and mascot restarts converge to a safe state without exposing user content.
