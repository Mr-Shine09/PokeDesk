# Dock Pet engineering handoff

Prepared for Mr. C (Claude Code) on 2026-07-29.

## Mission

Dock Pet is a native macOS menu-bar accessory that displays a pixel-art owner mascot near the Dock. It should communicate coding-agent lifecycle state at a glance while remaining local, private, non-activating, inexpensive when idle, and immediately dismissible.

The long-term state flow is:

```text
Codex hooks ───────┐
                   ├─> strict event decoder -> local transport -> session registry
Claude Code hooks ─┘                                      |
                                                          v
                                                deterministic reducer
                                                          |
                                              animation + window controller
```

As of 2026-07-30 every stage of this flow is implemented: hook adapters for both providers (`dockpet-event --hook`), the bundled helper, the socket transport, the reducer, and animation driven by the result. What has *not* happened is a live provider session driving it — every event so far was synthesized by writing payloads to the helper. The mapping and transport are proven; the providers' documented hook behavior is trusted, not observed. Do not describe Dock Pet as reflecting real agent activity until that run happens.

## Current working state

- Native SwiftUI/AppKit app launches as an `LSUIElement` accessory.
- Transparent `96x112`-point non-activating `NSPanel` remains visible across Spaces.
- The mascot animates from reduced state: working sits at a computer, waiting stops and turns, reactions play in place, and only the chilling/offline states stroll the lane. A 0.75-second dwell stops rapid state flips from thrashing; pause and resume bypass it.
- While strolling, the mascot walks left/right along the bottom visible-frame lane, pauses randomly, reverses at bounds, and renders at nearest-neighbor scale. Placement and roaming always anchor to the screen's bottom edge; Dock-edge tracking (left/right Dock) was tried, found buggy, and removed rather than fixed — see the Decision log in `DesktopMascot.md`, 2026-07-30.
- Click/right-click opens Pause/Resume, Stop/Resume Roaming, Hide, and Quit actions.
- Dragging switches to a six-frame one-handed hanging animation. The raised hand is fixed under the cursor; dropping stops roaming at the manual position.
- Reopening an already-running hidden app restores the mascot panel, preserving a manually dragged position rather than snapping back to the default lane.
- Launching, showing, or reopening the mascot plays a 1.25-second Dock portal transition before normal behavior resumes; Reduce Motion uses a stationary fade.
- Manual Ideating, Pause, Show/Hide, Roaming, Reposition, diagnostics, and Quit controls exist in the menu bar.
- Atlas revision 4 contains 14 rows, replaces the sit-shake ledges with small freestanding chairs, and validates structurally.
- 166 Swift package tests pass, and unsigned Debug and Release Xcode builds both succeed.
- The app runs the local event path as of 2026-07-30: it binds the owner-only socket at launch, ingests delivered events through `SessionRegistry` and `MascotStateReducer` via `EventPipeline`, drives animation from the result, shows listener status and reduced state in the menu bar, and unlinks the socket on quit.
- Both provider adapters exist as `dockpet-event --hook --provider <name>`, and `--print-hooks` emits the settings snippet to install them. Nothing has been installed into a real provider yet.

## Repository warning

`main` was level with `origin/main` at `0b90cef` (PRs #14–#20 merged) when the adapter branch `agent/provider-hook-adapters` was cut. This is a snapshot, not a promise — check `git status --short --branch` and `gh pr list` at session start rather than trusting this file. The repository remains private.

Merge and branch-delete commands are sometimes refused for the assistant by the auto-mode permission classifier and sometimes allowed; the outcome is not predictable in advance. When one is denied, give the owner the exact command to run in their own terminal instead of retrying or working around the denial.

More than one agent session may share this working tree at once. Before committing, confirm every staged file belongs to your own change; stash and rebranch rather than bundling another session's work into your commit.

Preserve every current modification/untracked file. Do not reset, clean, checkout over, or regenerate blindly. Make a deliberate checkpoint commit before risky refactors, but do not publish or change repository visibility without the owner's approval.

## First hour checklist

1. Read `CLAUDE.md` and the full `DesktopMascot.md` ledger.
2. Inspect `git status --short --branch` and `git log --oneline --decorate -12`.
3. Run the atlas and Swift checks from `docs/DEVELOPMENT.md`.
4. Build the app and confirm the bundled atlas/contract match the workspace versions.
5. Ask the owner to drag the mascot from several body points and confirm the cursor snap/swing feels right.
6. Record the QA result in `DesktopMascot.md`.
7. Every stage of the event path is implemented, including both hook adapters. The open milestone is observing a *live* provider session drive the mascot; do not treat the fixture evidence as a substitute for it.
8. The two menu-bar lines (`Event socket:` and `Reduced state:`) were owner-verified on screen on 2026-07-30 and need no re-check.

## Key ownership boundaries

| Concern | Current owner/location | Status |
| --- | --- | --- |
| Product history and gates | `DesktopMascot.md` | Authoritative living ledger |
| Xcode project definition | `project.yml` | Source of truth; Xcode project is generated |
| App lifecycle/UI | `DesktopMascot/App/` | Prototype implemented |
| State vocabulary | `Packages/DesktopMascotKit/Sources/MascotCore/` | Enum, envelope, decoder, registry, reducer, and `EventPipeline` implemented and tested; fed by the app and consumed for animation since 2026-07-30 |
| App-side event bridge | `DesktopMascot/App/AgentEventBridge.swift` | Runs the server, ingests on the main actor, refreshes on a timer, publishes diagnostics |
| Atlas loading | `Packages/DesktopMascotKit/Sources/MascotAnimation/` | Implemented and tested |
| Panel/Dock geometry | `Packages/DesktopMascotKit/Sources/MascotWindow/` | Implemented, bottom-anchored only as of 2026-07-30; hands-on display matrix incomplete |
| Frozen base art | `art/production/` | Do not replace |
| Atlas contract and output | `art/animation/` | Revision 4; chair sit-shake rows merged 2026-07-30 |
| Deterministic art tooling | `tools/` | Implemented and reusable |
| Provider lifecycle adapters | `Packages/DesktopMascotKit/Sources/MascotTransport/HookPayload.swift` | Implemented 2026-07-30 as helper `--hook` mode for both providers; awaiting a live session |
| Local event reducer | `Packages/DesktopMascotKit/Sources/MascotCore/` | Registry and priority reducer implemented 2026-07-29; issue #6 closed 2026-07-30; drives animation since 2026-07-30 |
| Local event transport | `Packages/DesktopMascotKit/Sources/MascotTransport/` | Socket server, client, framing, and helper implemented 2026-07-29; run by the app since 2026-07-30 |
| Event helper CLI | `Packages/DesktopMascotKit/Sources/dockpet-event/` | Bundled at `Contents/MacOS/dockpet-event`; also the hook adapter via `--hook`, and prints its own install snippet via `--print-hooks` |

## Product truths that must survive the handoff

- Broad Claude/ChatGPT coverage is a goal, not a license to scrape screens or conversations.
- Fine-grained states require explicit trustworthy lifecycle signals.
- Ordinary ChatGPT/Claude conversations use manual Ideating in 0.1 unless an appropriate first-party signal exists.
- Codex `Stop` means a turn completed; it does not prove every tool command succeeded.
- Multiple sessions must reduce deterministically with this priority:

```text
paused > failure-recent > waiting > working > ideating > success-recent > scheduled-sleep > idle/strolling > offline
```

- Scheduled inactive sleep is 23:00–06:00 local time; work interrupts it immediately.
- No telemetry, accounts, network dependency, Dock injection, private API use, or prompt/transcript storage in 0.1.

## Immediate next milestone

Build the core event system before provider-specific installers. Steps 1–6 are complete as of 2026-07-29:

1. ~~Define a versioned event envelope and strict decoder.~~
2. ~~Reject oversized, malformed, reordered, future-skewed, and unknown events.~~
3. ~~Store only provider, opaque session ID, event type, timestamp, and allowlisted coarse detail.~~
4. ~~Implement per-session registry state and heartbeat expiry (initially 120 seconds).~~
5. ~~Implement the reducer priority and recent success/failure windows.~~
6. ~~Add deterministic clock injection and comprehensive unit fixtures.~~
7. ~~Add a same-user local Unix-domain socket and small helper.~~
8. ~~Run the server inside the app, feed the registry and reducer, and surface the result in menu-bar diagnostics before changing any animation.~~
9. ~~Connect reducer output to animation selection, preserving manual pause/ideating behavior and keeping ambient roaming as the no-signal default.~~
10. ~~Bundle the helper inside the app bundle so a hook can invoke it by path, then add the Codex and Claude Code adapters (#8, #9).~~
11. Install the printed hook snippet and observe a real Claude Code or Codex session driving the mascot.

Acceptance criteria are in the Phase 3 section of `DesktopMascot.md`.

## Known risks and incomplete verification

- Physical hanging drag feel is not yet owner-approved; snapping the clicked body point to the overhead grip may need refinement.
- Dock auto-hide, multiple displays, full-screen Spaces, non-Retina, sleep/wake, and screen-lock behavior need broader hands-on coverage. Left/right Dock placement is no longer in scope: as of 2026-07-30 the mascot always anchors to the screen's bottom edge regardless of Dock position.
- Pointer/control avoidance is not implemented for roaming.
- Launch at login, energy measurement, signing, notarization, packaging, and clean-account install remain open. Reduce Motion is honored by the portal summon transition only; broader Reduce Motion coverage is still open under issue #11.
- The app is not installed anywhere durable. The only binary is the unsigned Debug build under `/private/tmp/DesktopMascotDerivedData`, which macOS clears on reboot, so relaunching means rebuilding first. Reopening the mascot is a developer action, not a user action, until packaging (issue #13).
- The canonical original owner source listed in the ledger is outside the repository. The promoted production base and selected reference are inside the repository and are sufficient for current atlas work; do not assume the external path exists on another machine.
- Generated image sources are not authoritative until normalized, validated, visually reviewed, and promoted into `art/animation/frames/`.

## Definition of a good handoff continuation

A new change is complete only when code/art, automated checks, hands-on evidence where required, and `DesktopMascot.md` all agree. Do not mark a phase complete based solely on a successful build.
