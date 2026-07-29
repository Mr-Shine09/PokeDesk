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

Everything from the decoder through the transport and helper is implemented and tested, but nothing in the running app listens on the socket or consumes reducer output, and the provider adapters do not exist. The prototype therefore still alternates ambient walking and offline animations without knowing whether an agent is active.

## Current working state

- Native SwiftUI/AppKit app launches as an `LSUIElement` accessory.
- Transparent `96x112`-point non-activating `NSPanel` remains visible across Spaces.
- Mascot walks left/right along the bottom visible-frame lane, pauses randomly in `offline`, reverses at bounds, and renders at nearest-neighbor scale.
- Click/right-click opens Pause/Resume, Stop/Resume Roaming, Hide, and Quit actions.
- Dragging switches to a six-frame one-handed hanging animation. The raised hand is fixed under the cursor; dropping stops roaming at the manual position.
- Reopening an already-running hidden app restores the mascot panel.
- Manual Ideating, Pause, Show/Hide, Roaming, Reposition, diagnostics, and Quit controls exist in the menu bar.
- Atlas revision 3 contains 14 rows and validates structurally.
- 113 Swift package tests pass and an unsigned Debug Xcode build succeeds.
- The local event path exists but the app does not run it: `EventEnvelope`, `EventDecoder`, `SessionRegistry`, `MascotStateReducer`, `MascotTransport`, and the `dockpet-event` helper are all implemented and tested, and the helper delivers events cross-process to a listener on the real socket path. The app itself neither listens nor consumes reducer output, and no provider hook can reach the helper yet.

## Repository warning

At the original handoff, `main` was five commits ahead of `origin/main` with the interactive animation/window work and revision 3 hanging assets uncommitted.

As of the 2026-07-29 maintainer session that work is committed (`46bd324`), the event decoder was added (`39074b2`), and `main` was published to `origin/main` at the owner's explicit direction. The repository remains private.

Run `git status --short --branch` and preserve every current modification/untracked file. Do not reset, clean, checkout over, or regenerate blindly. Make a deliberate checkpoint commit before risky refactors, but do not publish or change repository visibility without the owner’s approval.

## First hour checklist

1. Read `CLAUDE.md` and the full `DesktopMascot.md` ledger.
2. Inspect `git status --short --branch` and `git log --oneline --decorate -12`.
3. Run the atlas and Swift checks from `docs/DEVELOPMENT.md`.
4. Build the app and confirm the bundled atlas/contract match the workspace versions.
5. Ask the owner to drag the mascot from several body points and confirm the cursor snap/swing feels right.
6. Record the QA result in `DesktopMascot.md`.
7. If accepted, begin the local event model/reducer work; do not jump directly to hook installers.

## Key ownership boundaries

| Concern | Current owner/location | Status |
| --- | --- | --- |
| Product history and gates | `DesktopMascot.md` | Authoritative living ledger |
| Xcode project definition | `project.yml` | Source of truth; Xcode project is generated |
| App lifecycle/UI | `DesktopMascot/App/` | Prototype implemented |
| State vocabulary | `Packages/DesktopMascotKit/Sources/MascotCore/` | Enum, envelope, decoder, registry, and reducer implemented and tested; not yet wired to the app |
| Atlas loading | `Packages/DesktopMascotKit/Sources/MascotAnimation/` | Implemented and tested |
| Panel/Dock geometry | `Packages/DesktopMascotKit/Sources/MascotWindow/` | Implemented; manual matrix incomplete |
| Frozen base art | `art/production/` | Do not replace |
| Atlas contract and output | `art/animation/` | Revision 3 candidate |
| Deterministic art tooling | `tools/` | Implemented and reusable |
| Provider lifecycle adapters | not yet created | Planned issues #8 and #9 |
| Local event reducer | `Packages/DesktopMascotKit/Sources/MascotCore/` | Registry and priority reducer implemented 2026-07-29 |
| Local event transport | `Packages/DesktopMascotKit/Sources/MascotTransport/` | Socket server, client, framing, and helper implemented 2026-07-29; app wiring is the next milestone |
| Event helper CLI | `Packages/DesktopMascotKit/Sources/dockpet-event/` | Works cross-process; not bundled into the app and not installed for any hook |

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
8. Run the server inside the app, feed the registry and reducer, and surface the result in menu-bar diagnostics before changing any animation. Then connect reducer output to animation selection, preserving manual pause/ideating behavior and keeping ambient roaming as the no-signal default.

Acceptance criteria are in the Phase 3 section of `DesktopMascot.md`.

## Known risks and incomplete verification

- Physical hanging drag feel is not yet owner-approved; snapping the clicked body point to the overhead grip may need refinement.
- Left/right Dock, Dock auto-hide, multiple displays, full-screen Spaces, non-Retina, sleep/wake, and screen-lock behavior need broader hands-on coverage.
- Pointer/control avoidance is not implemented for roaming.
- Reduce Motion, launch at login, energy measurement, signing, notarization, packaging, and clean-account install remain open.
- The canonical original owner source listed in the ledger is outside the repository. The promoted production base and selected reference are inside the repository and are sufficient for current atlas work; do not assume the external path exists on another machine.
- Generated image sources are not authoritative until normalized, validated, visually reviewed, and promoted into `art/animation/frames/`.

## Definition of a good handoff continuation

A new change is complete only when code/art, automated checks, hands-on evidence where required, and `DesktopMascot.md` all agree. Do not mark a phase complete based solely on a successful build.

