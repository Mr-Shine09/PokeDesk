# Desktop Mascot

> Living implementation ledger. Read this entire file at the start of every project session and update it before ending the session.

## Project snapshot

| Field | Current value |
| --- | --- |
| Project | Desktop Mascot for macOS |
| Owner | [Mr-Shine09](https://github.com/Mr-Shine09) |
| Started | 2026-07-28 |
| Last updated | 2026-07-28 |
| Status | Foundation complete; product grill in progress; implementation has not started |
| Current gate | Resolve the remaining product questions in [issue #1](https://github.com/Mr-Shine09/desktop-mascot/issues/1), then begin the bounded art spike in [issue #2](https://github.com/Mr-Shine09/desktop-mascot/issues/2) |
| Repository | [Mr-Shine09/desktop-mascot](https://github.com/Mr-Shine09/desktop-mascot) (private) |
| Initial release | Local-only native macOS app, macOS 14+ |
| Canonical source image | `/Users/oaksoekhant/Mr-Shine09/source-avatar-magenta.png` |

## Purpose

Create a tiny pixel-art version of the owner that lives near the macOS Dock and communicates the current state of local Codex or Claude Code work through animation. The mascot should be delightful at a glance without covering work, stealing focus, reading private content, or consuming meaningful idle resources.

The product is successful when a user can tell within one second whether an agent is working, waiting for them, finished, failed, idle, or asleep—and can pause or quit the mascot immediately.

## Product principles

1. **Readable at native size.** Identity must survive at 1x; enlargement is for inspection, not comprehension.
2. **Status, not surveillance.** Integrations consume explicit lifecycle events and never scrape prompts, code, terminal text, or process memory.
3. **Polite presence.** The mascot does not activate the app, block Dock targets, trap the pointer, or become impossible to dismiss.
4. **Local first.** No account, server, telemetry, or network access is required for the first release.
5. **Deterministic behavior.** Concurrent sessions and missing events reduce to documented states instead of visual randomness.
6. **Opt-in integration.** The app previews hook configuration before the user installs it and can remove only the entries it owns.
7. **Evidence before completion.** Every phase has a binary acceptance gate and verification record.

## Reference review

Reviewed on 2026-07-28:

- The supplied Instagram carousel shows small characters moving around the Dock or cursor and reacting when agent work finishes or becomes idle.
- The user-provided Claude mascot sheet demonstrates how a compact silhouette, a small palette, and state-specific props or poses read more clearly than a shrunken detailed character.
- The owner avatar is `1254x1254`, opaque PNG art with a magenta background. Its strongest small-scale identity cues are the dark high-volume hair, square black glasses, navy top with white side panels, gray wide-leg trousers, and navy shoes.

The reference work is inspiration only. Do not copy Claude's mascot body, palette, face, or animation frames.

## Grill-me decisions

### Settled for the first release

| Decision | Rationale |
| --- | --- |
| Native SwiftUI + AppKit app | Best access to macOS window behavior, screen geometry, energy controls, menu bar, signing, and launch-at-login. |
| macOS 14+ initial target | Keeps the first release small while covering modern SwiftUI/AppKit APIs; revisit based on tester demand. |
| Dock-edge behavior first | Lower interruption and accessibility risk than cursor-following. |
| Cursor-following deferred and opt-in | It needs separate pointer-obstruction, speed, distance, and multi-display testing. |
| 32x32 logical sprite target, rendered at integer scale | Small enough to read as pixel art near the Dock; a 40x40 fallback experiment is allowed if glasses and hair collapse at 32x32. |
| No readable Chelsea crest or other logo | It will not survive at native size and creates unnecessary trademark/detail noise. Preserve navy/white color blocking instead. |
| No briefcase in the base identity | Reserve props for unmistakable action states; keep the default silhouette clean. |
| Explicit hooks before process fallback | Hooks provide reliable lifecycle meaning without inspecting private content. |
| Private repository initially | The project contains personal likeness work and unfinished integration decisions. Visibility can be changed after the owner reviews the first release. |
| Chilling means strolling | Outside working and scheduled sleep, the mascot walks along a dedicated Dock-edge lane rather than remaining in a static idle pose. |
| Working means seated typing | When Claude or ChatGPT/Codex work is active, the mascot sits at a tiny computer and types. |
| Failure means confused/dizzy | A genuine provider or integration failure triggers a short confused/dizzy reaction before returning to the appropriate ambient state. |
| Scheduled sleep is 23:00–06:00 local time | During this window the inactive mascot sleeps under a blanket; new work interrupts sleep immediately. |
| Independent Dock-edge window | The mascot visually occupies a lane at the Dock edge but does not inject into or modify the macOS Dock. Dock auto-hide may remain enabled. |
| Dock-only movement for 0.1 | Broader roaming across the lower screen is a later experiment after Dock hit-testing and distraction are validated. |
| Broad Claude/ChatGPT coverage is the goal | Supported lifecycle hooks are authoritative. Any ordinary ChatGPT app/web coverage must be explicitly labeled best-effort unless a documented lifecycle signal is available. |

### Questions to resolve before feature freeze

- Final product name and mascot name.
- Whether the owner prefers the 32x32 or 40x40 concept after side-by-side 1x review.
- Whether automatic hook installation is acceptable or the app should only generate copyable configuration snippets.
- Whether the first public release should remain private, become public source, or ship only as a notarized binary.
- Whether Claude Code and Codex deserve distinct visual accents when both are active.
- How ordinary ChatGPT app/browser activity should behave when no documented public lifecycle event is available.
- The waiting-for-input and completion reactions.
- Whether the mascot is purely click-through or supports a deliberate interaction/drag gesture.

These questions do not block the foundation or prototype. They do block a 1.0 release.

## Scope

### Version 0.1 — smallest lovable prototype

- One miniature owner mascot.
- Transparent, non-activating floating window in a bounded strolling lane immediately above or beside the Dock.
- Menu-bar controls: show/hide, pause animation, manual state, launch at login, diagnostics, quit.
- States: `offline`, `idle`, `working`, `waiting`, `success`, `failure`, `sleeping`, `paused`.
- Reliable Codex and Claude Code event adapters based on supported lifecycle hooks.
- A documented capability boundary for ordinary ChatGPT app/browser activity; no unsupported scraping or fabricated fine-grained states.
- Local-only event transport.
- Multiple simultaneous agent sessions reduced to one deterministic mascot state.
- Reduced Motion support and an animation speed control.
- No network dependency after installation.

### Explicit non-goals for 0.1

- Windows or Linux.
- iOS companion app.
- Reading prompts, source code, terminal output, repository names, or transcripts.
- Injecting into or modifying the Dock process.
- Private macOS APIs.
- General-purpose pet marketplace or arbitrary user-imported sprites.
- Cloud sync, user accounts, analytics, or remote control.
- Cursor-following, desktop roaming, sound effects, speech, or notifications.
- App Store distribution. Direct notarized distribution is the first packaging target.

## Mascot art direction

### Identity hierarchy

1. Dark asymmetric hair mass.
2. Square black glasses framing two light face pixels.
3. Navy torso with bold white side panels.
4. Light gray trousers and navy shoes.
5. Warm skin tone against a transparent background.

Remove garment texture, zipper detail below one pixel, belt detail, hand anatomy, shoe stripes, and the crest. If the sprite is not recognizable without those details, improve silhouette and proportions rather than adding noise.

### Technical sprite specification

- Prototype canvases: `32x32` and, only if needed, `40x40` logical pixels.
- Production scale: integer-only nearest-neighbor rendering, expected 2x on Retina.
- Palette target: 12 colors or fewer, plus transparency.
- Alpha: binary edges for production frames; no magenta spill or semitransparent fringe.
- Shared baseline and anchor point across every frame.
- Minimum one-pixel separation where limb readability depends on a gap.
- Validate on both light and dark desktop backgrounds at 1x and 2x.

### Animation inventory

| State | Intent | Initial frame budget | Loop behavior |
| --- | --- | ---: | --- |
| Offline | Agent integrations unavailable | 2 | Quiet, dim breathing |
| Idle/chilling | Daytime with no active work | 6 each direction | Stroll along the Dock-edge lane with occasional pause/blink |
| Working | At least one agent is active | 6 | Sit at a tiny computer and type |
| Waiting | User approval or input needed | 4 | Expectant look/hand raise |
| Success | Most recent turn completed | 6 | One-shot jump, then idle |
| Failure | Agent turn or integration failed | 4–6 | Brief confused/dizzy reaction, then ambient state |
| Sleeping | Inactive during 23:00–06:00 local time | 4 | Sleep under a blanket; wake immediately for activity |
| Paused | User disabled automatic behavior | 2 | Still pose |

Detached effects should be sparse. Prefer posture and expression; do not rely on readable text or tiny UI props.

## System architecture

```text
Codex hooks ───────┐
                   ├─> mascot-event helper ─> local Unix socket ─> Session registry
Claude Code hooks ─┘                                          │
Manual override ───────────────────────────────────────────────┤
Best-effort presence signal (optional, unresolved) ────────────┤
                                                              v
                                                   Deterministic reducer
                                                              │
                                            ┌─────────────────┴───────────────┐
                                            v                                 v
                                    Animation controller               Diagnostics UI
                                            │
                                            v
                              Transparent Dock-edge NSPanel
```

### Proposed package layout

```text
DesktopMascot/
├── App/
│   ├── DesktopMascotApp.swift
│   ├── AppDelegate.swift
│   └── MenuBar/
├── MascotCore/
│   ├── AgentEvent.swift
│   ├── MascotState.swift
│   ├── SessionRegistry.swift
│   └── StateReducer.swift
├── MascotWindow/
│   ├── MascotPanel.swift
│   ├── DockGeometry.swift
│   └── WindowCoordinator.swift
├── Integrations/
│   ├── EventServer.swift
│   ├── HookInstaller.swift
│   ├── CodexAdapter.swift
│   └── ClaudeCodeAdapter.swift
├── Animation/
│   ├── SpriteAtlas.swift
│   ├── AnimationController.swift
│   └── SpriteView.swift
├── Resources/Sprites/
├── DesktopMascotTests/
└── DesktopMascotUITests/
```

This is a proposed layout, not an implemented one. Adjust it after the Xcode scaffold exists, then update this ledger.

## Agent event contract

All provider-specific events normalize to a small local envelope:

```json
{
  "version": 1,
  "provider": "codex",
  "session_id": "opaque-local-id",
  "event": "active",
  "occurred_at": "2026-07-28T18:00:00Z",
  "detail": "tool"
}
```

Allowed event values: `started`, `active`, `waiting`, `completed`, `failed`, `stopped`, `heartbeat`.

Forbidden by default: prompt text, assistant text, transcript path, code, tool arguments, tool output, file paths, working directory, repository name, username, access token, and environment contents.

Transport defaults:

- Unix domain socket in the app's user-local application-support or container directory.
- Socket and any fallback file readable/writable only by the current user.
- Maximum payload size and strict JSON schema validation.
- RFC 3339 timestamps with bounded clock-skew tolerance.
- Versioned messages so old helpers fail safely after upgrades.
- Atomically replaced state file fallback only if the socket is unavailable.

## Provider mappings

### Codex

Use current supported hooks rather than transcript parsing:

| Codex hook | Normalized signal | Mascot meaning |
| --- | --- | --- |
| `SessionStart` | `started` | Session exists; idle unless active work follows |
| `UserPromptSubmit` | `active` | Work begins |
| `PreToolUse` / `PostToolUse` | `heartbeat` | Work remains active; payload contents are discarded |
| `PermissionRequest` | `waiting` | User attention required |
| `Stop` | `completed` | Turn finished; trigger short success reaction |
| `SessionEnd` | `stopped` | Remove session after grace period |

Codex `Stop` means the turn finished, not necessarily that every external command succeeded. Do not infer overall failure from a single non-zero shell result. A later implementation may accept explicit failure metadata only when a stable provider signal exists.

### Claude Code

Use the documented hook lifecycle:

| Claude Code hook | Normalized signal | Mascot meaning |
| --- | --- | --- |
| `SessionStart` | `started` | Session exists |
| `UserPromptSubmit` | `active` | Work begins |
| `PreToolUse` / `PostToolUse` | `heartbeat` | Work remains active |
| `Notification: permission_prompt` or `agent_needs_input` | `waiting` | User attention required |
| `Notification: agent_completed` or `Stop` | `completed` | Turn finished |
| `StopFailure` | `failed` | Turn ended due to provider/API failure |
| `SessionEnd` | `stopped` | Remove session after grace period |

### Safe fallback

If hooks are unavailable, a wrapper command may emit `started`, periodic `heartbeat`, and `stopped`. Plain process detection may only distinguish `offline` from `possibly active`; it must not claim waiting, success, or failure.

### Ordinary ChatGPT app and browser sessions

The product goal includes ChatGPT use beyond Codex tasks, but 0.1 must distinguish aspiration from proven signal coverage. Codex hooks are shared across supported Codex surfaces, including local Codex use in the ChatGPT desktop app, but the current public documentation does not expose equivalent external lifecycle hooks for every ordinary ChatGPT conversation.

- Do not inspect chat text, screen pixels, browser content, accessibility trees, network traffic, or private app APIs.
- If the owner approves an optional presence-only adapter, it may report `possibly active` while the ChatGPT app is foregrounded or a user-launched wrapper is running.
- Presence-only detection must not claim `waiting`, `success`, or `failure` and must be visibly identified as best-effort in diagnostics/settings.
- A documented first-party lifecycle mechanism can replace this limitation later after a privacy and reliability review.

## Aggregate state reducer

Track every session independently. Reduce to the visible state using this priority:

`paused > failure-recent > waiting > working > success-recent > scheduled-sleep > idle/strolling > offline`

Rules:

- Manual pause remains authoritative until the user clears it.
- Failure reaction initially lasts 4 seconds; the success reaction remains unresolved.
- Waiting persists until that session emits `active`, `completed`, `failed`, or `stopped`.
- An active session expires to `offline` after a configurable heartbeat timeout; start with 120 seconds.
- From 23:00 through 06:00 in the Mac's current local time zone, inactivity becomes scheduled sleep immediately rather than strolling.
- Any `active` or `waiting` signal interrupts scheduled sleep immediately. When the last active session ends inside the sleep window, the mascot returns to sleep after any approved completion reaction.
- Outside the sleep window, no active or waiting sessions means chilling/strolling.
- Duplicate events are idempotent.
- Reordered older events do not overwrite newer state.
- If Claude and Codex are active together, show one working animation and surface both providers in the menu-bar detail view.
- Laptop sleep/wake and wall-clock changes use monotonic elapsed time where possible and force a registry reconciliation on wake.

## macOS window behavior

- SwiftUI menu-bar shell with an AppKit-managed borderless transparent `NSPanel`.
- Non-activating panel with clear background and no shadow.
- Click-through while passive; temporarily interactive only for a documented gesture or future drag mode.
- Position from `NSScreen.visibleFrame` versus `frame` to infer Dock exclusion on each display.
- Support bottom, left, and right Dock orientation, auto-hide, multiple displays, screen changes, Spaces, and scale-factor changes.
- Use an independent safety lane immediately above or beside the Dock; never place the window over app-icon hit targets.
- Dock auto-hide does not need to be disabled. When the Dock hides, the mascot remains a separate visible overlay at the screen edge unless testing shows that following the hidden Dock is less distracting.
- Keep an initial 8-point safety gap from the Dock hit region and clamp the entire sprite to the visible frame.
- Reposition with bounded motion; never teleport across unrelated displays unless the user selects a display.
- Menu-bar item remains the reliable pause/hide/quit control.

No code should inject into `Dock.app`, use accessibility privileges merely to discover the Dock, or use private window-server APIs.

## Privacy and security model

- No network entitlement for 0.1 unless notarization/update infrastructure later requires a separately reviewed change.
- No telemetry.
- No prompt, transcript, code, file-path, or repository-name collection.
- Hook scripts accept JSON on stdin but select only the small allowlisted fields needed to identify event type and opaque session ID.
- The app displays the exact hook snippets before installation.
- Installation backs up only the settings file it changes and tags owned entries so uninstall removes only owned entries.
- Symlink, path traversal, payload-size, malformed JSON, and socket-permission tests are required.
- Diagnostics default to timestamps, provider, normalized event, validation result, and app version only.

## Accessibility and energy budget

- Respect macOS Reduce Motion and provide a separate pause toggle.
- Never play sound by default.
- The mascot window should not become a repetitive VoiceOver element; status is available through menu-bar text.
- Stop display timers when hidden, paused, sleeping on a static frame, or the screen is locked.
- Decode sprite sheets once and reuse textures.
- Coalesce event bursts and render only at the frame rate required by the active animation.

Release targets on an idle release build:

- median CPU below 1% over a 10-minute idle sample;
- memory below 80 MB after 10 minutes;
- no growth trend across 100 state transitions;
- state transition visible within 500 ms of a local event;
- no app activation or focus theft during automated state changes.

## Dated implementation plan

Dates are working targets, not promises. Update them when evidence changes the estimate.

### Phase 0 — Foundation (2026-07-28)

**Status: Complete on 2026-07-28.**

1. Review visual and Instagram references.
2. Install relevant curated skills.
3. Create and validate project-specific skills, including `grill-me`.
4. Create this living ledger.
5. Create a private GitHub repository and issue backlog.

Acceptance: all artifacts exist, custom skills validate, repository URL resolves, and every later phase has a GitHub issue. Passed on 2026-07-28.

### Phase 1 — Product contract and art spike (2026-07-29 to 2026-07-30)

1. Run a user-facing grill-me round on naming, interaction tolerance, hook installation, and release visibility.
   - Round 1 completed on 2026-07-28: core animations, 23:00–06:00 sleep behavior, broad provider goal, and Dock-only 0.1 were confirmed.
2. Produce 32x32 and 40x40 idle concept variants from the supplied avatar.
3. Review both at 1x on light and dark backgrounds.
4. Approve one native grid, palette, identity hierarchy, and baseline.
5. Write animation frame and atlas specification.

Acceptance: owner selects one concept; chosen sprite is recognizable at 1x; palette and frame geometry are frozen for 0.1.

### Phase 2 — Native app skeleton (2026-07-31 to 2026-08-02)

1. Create Xcode project and Swift package boundaries.
2. Implement menu-bar lifecycle and settings model.
3. Implement transparent non-activating panel.
4. Implement Dock-edge geometry with bottom/left/right and multi-display fixtures.
5. Render a static approved sprite with nearest-neighbor interpolation.

Acceptance: release build launches, shows/hides/quits reliably, never steals focus, and positions correctly in the geometry test matrix.

### Phase 3 — State engine and local bridge (2026-08-03 to 2026-08-04)

1. Implement versioned event decoder and validation.
2. Implement local socket server and helper CLI.
3. Implement session registry, heartbeat expiry, and deterministic reducer.
4. Add fixtures for duplicates, ordering, clock skew, malformed input, and concurrent providers.
5. Add manual-state controls for testing.

Acceptance: all reducer and transport tests pass; malformed data cannot change mascot state; no forbidden field is stored.

### Phase 4 — Codex and Claude Code adapters (2026-08-05 to 2026-08-06)

1. Implement minimal hook scripts that discard sensitive input fields.
2. Generate previewable Codex hook configuration.
3. Generate previewable Claude Code hook configuration.
4. Implement install, verify, disable, and uninstall flows with ownership markers.
5. Exercise start, active, waiting, complete, failure where supported, crash, and session-end scenarios.

Acceptance: both providers drive the state engine in fixture and live smoke tests; removing the integration leaves unrelated settings untouched.

### Phase 5 — Animation system and full sprite set (2026-08-06 to 2026-08-08)

1. Implement sprite atlas loader and animation controller.
2. Create idle, walk, work, wait, success, failure, sleep, offline, and paused frames.
3. Validate baseline, alpha, palette, silhouette, and loop timing.
4. Connect state transitions with debouncing and bounded reaction durations.
5. Add Reduced Motion variants.

Acceptance: contact sheet and motion previews pass visual review at 1x/2x on light/dark backgrounds; state changes do not jitter or slide.

### Phase 6 — Hardening and release candidate (2026-08-08 to 2026-08-10)

1. Add unit, integration, UI, and configuration-mutation tests.
2. Test multiple displays, Dock orientations, auto-hide, full-screen Spaces, sleep/wake, screen lock, and agent crashes.
3. Measure CPU, memory, transition latency, and focus behavior.
4. Add diagnostics export with privacy-safe fields.
5. Configure signing, hardened runtime, notarization, release notes, install, upgrade, and uninstall instructions.

Acceptance: verification matrix is green, energy targets pass, notarized build installs on a clean test account, and all P0/P1 issues are closed.

### Phase 7 — Post-0.1 experiments (after 2026-08-10)

- Opt-in cursor-following with pointer-avoidance testing.
- User-imported sprite packs.
- Per-provider animation accents.
- Auto-update framework.
- Public-source readiness review.

None of these may enter 0.1 without an explicit scope change in this ledger and GitHub.

## GitHub issue map

| Issue | Phase | Status |
| --- | --- | --- |
| [#1 Lock the 0.1 product contract with grill-me](https://github.com/Mr-Shine09/desktop-mascot/issues/1) | 1 | Open |
| [#2 Reduce the source avatar into 32x32 and 40x40 concepts](https://github.com/Mr-Shine09/desktop-mascot/issues/2) | 1 | Open |
| [#3 Specify and produce the animation-ready sprite atlas](https://github.com/Mr-Shine09/desktop-mascot/issues/3) | 1 / 5 | Open |
| [#4 Scaffold the native SwiftUI/AppKit macOS app](https://github.com/Mr-Shine09/desktop-mascot/issues/4) | 2 | Open |
| [#5 Implement the transparent Dock-edge mascot window](https://github.com/Mr-Shine09/desktop-mascot/issues/5) | 2 | Open |
| [#6 Implement the mascot state model and reducer](https://github.com/Mr-Shine09/desktop-mascot/issues/6) | 3 | Open |
| [#7 Build the private local event bridge and helper CLI](https://github.com/Mr-Shine09/desktop-mascot/issues/7) | 3 | Open |
| [#8 Add the Codex lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/8) | 4 | Open |
| [#9 Add the Claude Code lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/9) | 4 | Open |
| [#10 Build menu-bar settings and integration management](https://github.com/Mr-Shine09/desktop-mascot/issues/10) | 2 / 4 | Open |
| [#11 Integrate animations, transitions, and Reduced Motion](https://github.com/Mr-Shine09/desktop-mascot/issues/11) | 5 | Open |
| [#12 Verify privacy, accessibility, performance, and multi-display behavior](https://github.com/Mr-Shine09/desktop-mascot/issues/12) | 6 | Open |
| [#13 Add CI, signing, notarization, packaging, and release docs](https://github.com/Mr-Shine09/desktop-mascot/issues/13) | 6 | Open |

## Verification matrix

| Area | Evidence required | Current state |
| --- | --- | --- |
| Custom skills | `quick_validate.py` passes for all project skills | Passed 2026-07-28 |
| Reference understanding | Instagram third card and supplied images reviewed | Passed 2026-07-28 |
| Repository | URL resolves under owner account | Passed 2026-07-28: [private repository](https://github.com/Mr-Shine09/desktop-mascot) |
| Issue backlog | Every implementation phase mapped to an issue | Passed 2026-07-28: [issues #1–#13](https://github.com/Mr-Shine09/desktop-mascot/issues) |
| Sprite readability | 1x light/dark review and owner approval | Not started |
| Window geometry | Automated fixtures plus manual multi-display matrix | Not started |
| State reducer | Unit tests for ordering, duplicates, expiry, concurrency | Not started |
| Privacy | Forbidden fields absent from storage and diagnostic output | Not started |
| Provider adapters | Fixture tests and live smoke tests | Not started |
| Accessibility | Reduce Motion, pause, VoiceOver/menu-bar review | Not started |
| Energy | CPU, memory, leak, and latency targets | Not started |
| Release | Signed/notarized clean-account install | Not started |

## Risk register

| Risk | Impact | Mitigation | Status |
| --- | --- | --- | --- |
| Tiny sprite loses the owner's identity | High | Compare 32x32/40x40 at 1x; prioritize hair, glasses, and garment blocks | Open |
| Provider hooks change over time | High | Version adapters, validate on install, link official docs, keep wrapper fallback | Open |
| Ordinary ChatGPT conversations lack a documented external lifecycle signal | High | Reliable-hook tier first; optional presence-only mode; no content/accessibility/private-API scraping | Open decision |
| “Completed” is mistaken for “successful” | Medium | Treat Codex Stop as completion reaction, not proof every command passed | Mitigated in design |
| Hook installation damages user config | High | Preview, back up, tag ownership, mutation tests, remove only owned entries | Open |
| Mascot blocks Dock or steals focus | High | Non-activating click-through panel, safe gap, menu-bar escape hatch | Open |
| Multiple sessions thrash visible state | Medium | Per-session registry, priority reducer, debounce, bounded reactions | Open |
| Cursor-following annoys or obstructs | Medium | Defer; require explicit opt-in and dedicated tests | Deferred |
| Idle animation wastes battery | Medium | Event-driven updates, suspend timers, measurable energy budget | Open |
| Personal likeness ships before review | Medium | Private repository until owner changes visibility | Mitigated for foundation |

## Decision log

### 2026-07-28

- Use a native SwiftUI/AppKit implementation.
- Target macOS 14+ for the first release.
- Keep 0.1 local-only and telemetry-free.
- Use explicit Codex and Claude Code lifecycle hooks as the primary signal source.
- Transmit only coarse normalized event metadata.
- Start with Dock-edge behavior; defer cursor-following.
- Prototype both 32x32 and 40x40, with 32x32 as the preferred target.
- Preserve identity through hair, glasses, and navy/white color blocking; omit the tiny crest and briefcase.
- Keep the GitHub repository private until the owner reviews release visibility.
- Chilling is a daytime Dock-edge stroll; working is seated typing at a tiny computer; failure is a confused/dizzy reaction.
- Schedule inactive sleep under a blanket from 23:00–06:00 local time, interrupted immediately by agent activity.
- Keep Dock auto-hide compatible by using an independent transparent window; do not require changing the user's Dock setting.
- Limit 0.1 roaming to a safe Dock-edge lane and defer the wider lower-screen area.
- Treat “all Claude or ChatGPT use” as the coverage goal, with fine-grained states only where trustworthy lifecycle signals exist.

## Session log

### 2026-07-28 — Foundation and planning

- Objective: establish reusable project skills, inspect the references, write the living plan, and create the repository backlog before product implementation.
- Completed:
  - Reviewed the supplied avatar and Claude-style reference sheet.
  - Inspected the referenced Instagram post and its third carousel card.
  - Installed curated `hatch-pet`, `define-goal`, `security-best-practices`, and `screenshot` skills.
  - Created and validated `grill-me`, `pixel-mascot-art`, `macos-desktop-mascot`, `agent-activity-signals`, and `session-ledger` under `project-skills/`.
  - Installed the custom skills into the personal Codex skills directory.
  - Verified current official Codex and Claude Code lifecycle-hook capabilities.
  - Created this ledger.
- Decisions: see the 2026-07-28 decision log.
- Verification: five custom skills passed `quick_validate.py`; source images inspected at `1254x1254` and `1600x1200`.
- Risks or blockers: GitHub CLI credentials are stale; repository creation will use an authenticated GitHub surface or require reauthentication.
- Next: create `Mr-Shine09/desktop-mascot`, create every mapped issue, add issue links here, then end the foundation session without starting app implementation.

### 2026-07-28 — GitHub foundation completion

- Objective: resume the failed GitHub authorization session and finish Phase 0 without starting product implementation.
- Completed:
  - Verified GitHub CLI authentication for `Mr-Shine09`.
  - Created the private [Mr-Shine09/desktop-mascot](https://github.com/Mr-Shine09/desktop-mascot) repository.
  - Pushed the foundation commit `29d5453` to `main`.
  - Created [issues #1–#13](https://github.com/Mr-Shine09/desktop-mascot/issues) with tasks, dependencies, and acceptance criteria for every planned phase.
  - Added the permanent repository and issue links to this ledger.
- Decisions: keep the repository private and keep product implementation gated behind issue #1 and owner review of the issue #2 concept comparison.
- Verification: `gh auth status` succeeded; `git push -u origin main` succeeded; all 13 issue-creation commands returned GitHub issue URLs.
- Risks or blockers: the connected GitHub app returned 404 for the newly created private repository, so issue creation used the authenticated GitHub CLI fallback. This does not affect the repository or issues.
- Next: run the user-facing grill-me round in issue #1. Do not scaffold the app before the owner approves a 1x concept from issue #2.

### 2026-07-28 — Product grill round 1

- Objective: turn the owner's desired personality, schedule, provider coverage, and Dock placement into explicit behavior rules.
- Completed:
  - Confirmed daytime chilling as strolling along the Dock edge.
  - Confirmed active work as sitting at a tiny computer and typing.
  - Confirmed genuine failures as a brief confused/dizzy reaction.
  - Confirmed inactive sleep under a blanket from 23:00–06:00 local time, interrupted immediately by new activity.
  - Confirmed Dock-only movement for 0.1, with the wider lower-screen region deferred.
  - Documented that Dock auto-hide may remain enabled because the mascot is an independent transparent window.
  - Split Claude/ChatGPT support into authoritative lifecycle hooks and an unresolved, best-effort ordinary ChatGPT presence tier.
- Decisions: see the 2026-07-28 decision log and the updated state reducer.
- Verification: refreshed the current official Codex manual and checked documented hooks, notification states, and desktop-pet behavior.
- Risks or blockers: ordinary ChatGPT app/browser conversations do not currently provide the same documented external lifecycle stream as Codex and Claude Code; owner preference for a coarse presence mode is unresolved.
- Next: complete grill round 2 on coarse ChatGPT presence, waiting/completion behavior, and mascot interaction, then begin the 32x32/40x40 art comparison.

## Next-session handoff

1. Read this file in full.
2. Continue [issue #1](https://github.com/Mr-Shine09/desktop-mascot/issues/1) with grill round 2: ordinary ChatGPT presence, waiting/completion reactions, and interaction.
3. Record the answers and issue #1 verdict in this ledger.
4. Start only the 32x32/40x40 comparison in [issue #2](https://github.com/Mr-Shine09/desktop-mascot/issues/2); do not scaffold the app before owner review.
5. Update this ledger before ending the session.

## Documentation sources

- [Official Codex hooks documentation](https://learn.chatgpt.com/docs/hooks)
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Instagram reference post](https://www.instagram.com/p/DbV-I14FKJ2/?img_index=3)
