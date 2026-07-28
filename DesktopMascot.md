# Desktop Mascot

> Living implementation ledger. Read this entire file at the start of every project session and update it before ending the session.

## Project snapshot

| Field | Current value |
| --- | --- |
| Project | Desktop Mascot for macOS |
| Owner | [Mr-Shine09](https://github.com/Mr-Shine09) |
| Started | 2026-07-28 |
| Last updated | 2026-07-28 |
| Status | Directional walk rows normalized and internally approved; idle production is blocked on identity-preserving art |
| Current gate | Produce and visually approve the state frames, contact sheets, and motion previews in [issue #3](https://github.com/Mr-Shine09/desktop-mascot/issues/3) before app scaffolding |
| Repository | [Mr-Shine09/desktop-mascot](https://github.com/Mr-Shine09/desktop-mascot) (private) |
| Initial release | Local-only native macOS app, macOS 14+ |
| Canonical source image | `/Users/oaksoekhant/Mr-Shine09/source-avatar-magenta.png` |

## Purpose

Create a tiny pixel-art version of the owner that lives near the macOS Dock and communicates the current state of coding and non-coding Claude or ChatGPT activity through animation. The mascot should be delightful at a glance without covering work, stealing focus, reading private content, or consuming meaningful idle resources.

The product is successful when a user can tell within one second whether an agent is coding, ideating, waiting for them, finished, failed, idle, or asleep—and can pause or quit the mascot immediately.

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
| 40x40-point on-screen footprint | Owner selected the apparent 40x40 size. On Retina this requires an 80x80-pixel `@2x` asset; 40 source pixels are insufficient for the selected tall design. |
| Secondary chibi is the production direction | Owner explicitly rejected the final native tall treatment and ordered a fallback to the secondary chibi. No further tall-face repair is allowed for 0.1. |
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
| Non-coding activity means ideating | The mascot sits in a Thinker-style pose while a small thought cloud appears, changes, disappears, and loops. |
| Waiting means asking for attention | The mascot stops its current pose, turns toward the user, and raises one hand until work resumes or ends. |
| Success means delighted recognition | The mascot shows sparkling eyes and performs one quick fist pump, then returns to strolling or scheduled sleep. |
| Manual ideating mode for ordinary chats | Version 0.1 uses a menu-bar action and optional global shortcut; automatic ordinary Claude/ChatGPT detection is deferred until a trustworthy, privacy-preserving signal exists. |
| Passive click-through interaction | Normal mascot motion never captures clicks. An explicit menu-bar “Unlock position” mode temporarily permits dragging, then returns to click-through. |
| Previewed one-click hook installation | The app shows the exact Codex/Claude Code configuration change, backs up the affected file, installs only after confirmation, verifies it, and can remove only entries it owns. |

Grill verdict on 2026-07-28: `ready with experiments`. The 0.1 contract is ready; automatic non-coding chat detection remains a future experiment and does not weaken the manual mode.

### Questions to resolve before feature freeze

- Final product name and mascot name.
- Whether the first public release should remain private, become public source, or ship only as a notarized binary.
- Whether Claude Code and Codex deserve distinct visual accents when both are active.

These questions do not block the foundation or prototype. They do block a 1.0 release.

## Scope

### Version 0.1 — smallest lovable prototype

- One miniature owner mascot.
- Transparent, non-activating floating window in a bounded strolling lane immediately above or beside the Dock.
- Menu-bar controls: show/hide, pause animation, manual ideating state, unlock position, launch at login, diagnostics, quit.
- States: `offline`, `idle`, `working`, `ideating`, `waiting`, `success`, `failure`, `sleeping`, `paused`.
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

- On-screen footprint: initially `40x40` macOS points.
- Retina production asset: `80x80` pixels at `@2x`, mapping one source pixel to one backing pixel on a 2x display.
- Non-Retina behavior remains a required experiment: test a deliberately authored `40x40` `@1x` fallback versus a larger point footprint; never silently resample the Retina asset with smoothing.
- The authoritative concept source is `art/references/owner-selected-fallback-chibi.png`.
- The approved base is `mascot-base-chibi-40pt-at2x-80px-final.png`, an exact copy of the owner-selected secondary chibi reduction. All native tall variants are rejected and must not enter the atlas or app.
- Production rendering uses nearest-neighbor interpolation and integer backing-pixel alignment.
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
| Ideating | A non-coding Claude/ChatGPT task is active | 6 | Sit in a Thinker pose while a tiny thought cloud pops in and out |
| Waiting | User approval or input needed | 4 | Stop, turn toward the user, and raise one hand persistently |
| Success | Most recent turn completed | 6 | Sparkling eyes plus one quick fist pump, then ambient state |
| Failure | Agent turn or integration failed | 4–6 | Brief confused/dizzy reaction, then ambient state |
| Sleeping | Inactive during 23:00–06:00 local time | 4 | Sleep under a blanket; wake immediately for activity |
| Paused | User disabled automatic behavior | 2 | Still pose |

Detached effects should be sparse. Prefer posture and expression; do not rely on readable text or tiny UI props. Implement the ideating cloud as a small effect layer above the character: two rising pixels lead into a compact cloud, which changes once, fades, and repeats. This keeps the 40-point body readable while allowing the panel to reserve a slightly taller effect area.

## System architecture

```text
Codex hooks ───────┐
                   ├─> mascot-event helper ─> local Unix socket ─> Session registry
Claude Code hooks ─┘                                          │
Manual override ───────────────────────────────────────────────┤
Manual ideating mode ─────────────────────────────────────────┤
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

### Ordinary ChatGPT and Claude app/browser sessions

The product goal includes non-coding Claude and ChatGPT use, with the ideating animation defined above, but 0.1 must distinguish animation design from proven signal coverage. Codex hooks are shared across supported Codex surfaces, including local Codex use in the ChatGPT desktop app, while current public documentation does not expose equivalent external lifecycle hooks for every ordinary Claude or ChatGPT conversation.

- Do not inspect chat text, screen pixels, browser content, accessibility trees, network traffic, or private app APIs.
- Version 0.1 uses a menu-bar action and optional global shortcut to explicitly enter/exit ideating mode without observing conversation content.
- Automatic presence detection is deferred. Merely foregrounding Claude or ChatGPT is not reliable enough to claim the model is generating a response.
- Presence-only detection must not claim `waiting`, `success`, or `failure` and must be visibly identified as best-effort in diagnostics/settings.
- A documented first-party lifecycle mechanism can replace this limitation later after a privacy and reliability review.

## Aggregate state reducer

Track every session independently. Reduce to the visible state using this priority:

`paused > failure-recent > waiting > working > ideating > success-recent > scheduled-sleep > idle/strolling > offline`

Rules:

- Manual pause remains authoritative until the user clears it.
- Failure reaction initially lasts 4 seconds; sparkling-eyes/fist-pump success lasts 3 seconds.
- Waiting persists until that session emits `active`, `completed`, `failed`, or `stopped`.
- An active session expires to `offline` after a configurable heartbeat timeout; start with 120 seconds.
- From 23:00 through 06:00 in the Mac's current local time zone, inactivity becomes scheduled sleep immediately rather than strolling.
- Any working, ideating, or waiting signal interrupts scheduled sleep immediately. When the last active session ends inside the sleep window, the mascot returns to sleep after the completion reaction.
- Outside the sleep window, no working, ideating, or waiting session means chilling/strolling.
- Duplicate events are idempotent.
- Reordered older events do not overwrite newer state.
- If Claude and Codex are active together, show one working animation and surface both providers in the menu-bar detail view.
- Laptop sleep/wake and wall-clock changes use monotonic elapsed time where possible and force a registry reconciliation on wake.

## macOS window behavior

- SwiftUI menu-bar shell with an AppKit-managed borderless transparent `NSPanel`.
- Non-activating panel with clear background and no shadow.
- Click-through during normal operation. A menu-bar “Unlock position” command temporarily enables dragging and exposes a clear “Lock position” action; relock automatically after a short inactivity timeout.
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
   - Round 2 completed on 2026-07-28: ideating, waiting, and successful-completion animations were confirmed; automatic non-coding activity detection remains unresolved.
   - Round 3 completed on 2026-07-28: manual ideating control, temporary unlock-to-drag, and previewed one-click hook installation were approved. Verdict: `ready with experiments`.
2. Produce 32x32 and 40x40 idle concept variants from the supplied avatar.
3. Review both at 1x on light and dark backgrounds.
4. Approve one native grid, palette, identity hierarchy, and baseline.
5. Write animation frame and atlas specification.

Progress on 2026-07-28: steps 2–5 complete. The owner selected a 40-point footprint, rejected every native tall treatment, and explicitly ordered the secondary chibi fallback. `mascot-base-chibi-40pt-at2x-80px-final.png` is frozen as the base. The version 0.1 geometry, row order, palette, timing, anchors, acceptance rules, and QA outputs are frozen in `art/animation/ATLAS.md` and `art/animation/atlas-contract.json`.

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
2. Create idle, walk, work, ideate, wait, success, failure, sleep, offline, and paused frames plus the thought-cloud effect layer.
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
| [#1 Lock the 0.1 product contract with grill-me](https://github.com/Mr-Shine09/desktop-mascot/issues/1) | 1 | Closed as completed on 2026-07-28 |
| [#2 Reduce the source avatar into 32x32 and 40x40 concepts](https://github.com/Mr-Shine09/desktop-mascot/issues/2) | 1 | Closed as completed on 2026-07-28; secondary chibi frozen |
| [#3 Specify and produce the animation-ready sprite atlas](https://github.com/Mr-Shine09/desktop-mascot/issues/3) | 1 / 5 | Open; specification complete, frame production pending |
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
| Sprite readability | 1x light/dark review and owner approval | Passed 2026-07-28: secondary chibi explicitly selected and frozen at 80x80 `@2x` |
| Atlas contract | Geometry, rows, timing, anchor, palette, alpha, and QA rules validate before frame production | Passed 2026-07-28: `python3 tools/validate_animation_atlas.py --contract-only` |
| Directional walk candidate | Six frames each direction, shared baseline, frozen palette, light/dark contact sheet, and motion previews | Internal QA passed 2026-07-28; owner review pending |
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
| Point size is confused with backing-pixel dimensions | High | Specify points and `@1x`/`@2x` assets separately; validate on real Retina/non-Retina scale factors | 40-pixel failure recorded; corrected 80-pixel contract retained |
| Tall face loses identity at the 40-point footprint | High | Use the owner-selected secondary chibi and prohibit further tall repairs for 0.1 | Resolved for 0.1; chibi frozen |
| Provider hooks change over time | High | Version adapters, validate on install, link official docs, keep wrapper fallback | Open |
| Ordinary Claude/ChatGPT conversations lack a documented external lifecycle signal | High | Manual ideating control in 0.1; automatic detection deferred; no content/accessibility/private-API scraping | Constrained for 0.1 |
| “Completed” is mistaken for “successful” | Medium | Treat Codex Stop as completion reaction, not proof every command passed | Mitigated in design |
| Hook installation damages user config | High | Preview, back up, tag ownership, mutation tests, remove only owned entries | Open |
| Mascot blocks Dock or steals focus | High | Non-activating click-through panel, safe gap, menu-bar escape hatch | Open |
| Multiple sessions thrash visible state | Medium | Per-session registry, priority reducer, debounce, bounded reactions | Open |
| Cursor-following annoys or obstructs | Medium | Defer; require explicit opt-in and dedicated tests | Deferred |
| Idle animation wastes battery | Medium | Event-driven updates, suspend timers, measurable energy budget | Open |
| Generated state frames drift from the frozen identity | High | Ground every job in the frozen base, normalize deterministically, reject drift, and use native pixel editing only with explicit owner approval | Walk candidate constrained; idle blocked after two failed generation rounds |
| Personal likeness ships before review | Medium | Private repository until owner changes visibility | Mitigated for foundation |

## Decision log

### 2026-07-28

- Use a native SwiftUI/AppKit implementation.
- Target macOS 14+ for the first release.
- Keep 0.1 local-only and telemetry-free.
- Use explicit Codex and Claude Code lifecycle hooks as the primary signal source.
- Transmit only coarse normalized event metadata.
- Start with Dock-edge behavior; defer cursor-following.
- Prototype both apparent 32x32 and 40x40 sizes; owner selected a 40x40-point footprint. Correct interpretation is an 80x80-pixel `@2x` Retina asset.
- Preserve identity through hair, glasses, and navy/white color blocking; omit the tiny crest and briefcase.
- Keep the GitHub repository private until the owner reviews release visibility.
- Chilling is a daytime Dock-edge stroll; working is seated typing at a tiny computer; failure is a confused/dizzy reaction.
- Schedule inactive sleep under a blanket from 23:00–06:00 local time, interrupted immediately by agent activity.
- Keep Dock auto-hide compatible by using an independent transparent window; do not require changing the user's Dock setting.
- Limit 0.1 roaming to a safe Dock-edge lane and defer the wider lower-screen area.
- Treat “all Claude or ChatGPT use” as the coverage goal, with fine-grained states only where trustworthy lifecycle signals exist.
- Represent non-coding Claude/ChatGPT activity with a seated Thinker pose and a looping thought cloud.
- Represent waiting for input by turning toward the user and raising one hand until the wait clears.
- Represent successful completion with sparkling eyes and one quick fist pump, followed by strolling or scheduled sleep.
- Use manual Ideating mode for ordinary Claude/ChatGPT conversations in 0.1; defer automatic detection until it can be reliable without reading content.
- Keep the mascot click-through by default and allow dragging only through a temporary menu-bar unlock mode.
- Offer previewed one-click Codex/Claude Code hook installation with backup, verification, and ownership-safe uninstall.
- Product-grill verdict: `ready with experiments`.
- Use the owner-ranked tall first concept as the primary 40x40 body style; keep the compact chibi as fallback only.
- Reject the 40-source-pixel hand-cleaned draft shown on 2026-07-28; it failed the identity and quality bar.
- Preserve the tall design with an 80x80-pixel `@2x` Retina asset displayed at 40x40 points. Do not confuse UI points with source/backing pixels again.
- Reject the first corrected tall Retina reduction because its hair, glasses, lenses, eyes, and nose merge at native size.
- Reject the expanded deterministic tall face because it reads as a goggle bar, and reject the coherent regenerated tall face because one lens disappears during reduction.
- Activate the owner's explicit second-choice chibi fallback while preserving the 40x40-point/80x80-pixel-`@2x` contract.
- Require separate readable clusters for both lenses/eyes, nose, and mouth before any base sprite can be approved.
- Owner explicitly approved the face in `art/references/owner-approved-tall-face.png`; this later decision restores the tall direction and supersedes the temporary chibi activation.
- Treat source-face approval and native-sprite approval as separate gates. Preserve the source face exactly, but do not close issue #2 until its 80x80 interpretation passes native-size QA.
- Use two independent native square frames with no continuous black bridge; an isolated center pixel may suggest the bridge without forming a visor.
- Owner rejected `mascot-base-approved-tall-40pt-at2x-80px-v3.png` as visually unacceptable and explicitly ordered the secondary chibi fallback.
- The source-level tall-face approval did not survive native-size QA and is not a production approval. Retain it only as historical evidence.
- Restore `mascot-base-owner-chibi-40pt-at2x-80px-v2.png` as the sole current candidate. Do not spend another bounded attempt on the tall face in 0.1.
- Treat the explicit instruction to fall back to the secondary chibi as final selection of the already-reviewed native reduction; do not require a duplicate approval round.
- Freeze the identical promoted copy `mascot-base-chibi-40pt-at2x-80px-final.png` as the production base and close issue #2.
- Keep only the selected chibi source, frozen native sprite, and frozen light/dark QA sheet in the active art folders. Remove rejected concepts, failed production attempts, derived transparency intermediates, and byte-identical pre-freeze copies; preserve their decision history here and their binaries in Git history through `0f292ec`.
- Freeze the version 0.1 animation atlas at 8 columns by 11 rows with 96x112-pixel `@2x` cells, a shared `(48, 102)` anchor/baseline, the exact 12-color base palette, binary alpha, transparent unused cells, and explicit playback timings in `art/animation/atlas-contract.json`.
- Include the approved `ideating` row even though issue #3's original state list omitted it; the later product contract is authoritative.
- Keep the 80x80 body canvas at 40x40 points inside a 48x56-point panel cell so the thought cloud and wider poses have bounded space without scaling the mascot.
- Accept the right-walk row as an owner-review candidate after deterministic chroma removal, shared-scale normalization, frozen-palette reduction, structural validation, and visual QA.
- Derive `walk-left` by mirroring each approved right-walk frame in place without reversing frame order. This character has no side-specific logo or prop, and the independent left-row generation failed cross-row identity QA.
- Reject both generated idle rows and the single blink repair because they changed the approved face, glasses, hair, pose, or baseline. Do not promote them to production.

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

### 2026-07-28 — Product grill round 2

- Objective: define the missing non-coding, waiting-for-input, and successful-completion animation language.
- Completed:
  - Defined non-coding Claude/ChatGPT activity as a seated Thinker pose with a compact thought cloud that appears and disappears in a loop.
  - Accepted the recommended waiting state: stop, turn toward the user, and raise one hand persistently.
  - Defined success as sparkling eyes plus a quick fist pump, then a return to strolling or scheduled sleep.
  - Added a distinct `ideating` state to the animation inventory and reducer.
- Decisions: these three visual behaviors are approved for the 0.1 art specification.
- Grill verdict: `not ready` for product implementation until the non-coding signal source and direct-interaction behavior are explicitly chosen.
- Verification: owner provided explicit animation preferences in the product grill; no art has been generated yet.
- Risks or blockers: animation intent is settled, but automatic detection of ordinary Claude/ChatGPT app and browser activity remains undefined. A manual ideating control is the recommended privacy-preserving 0.1 fallback.
- Next: resolve non-coding detection and interaction behavior, then issue the grill verdict and begin the 32x32/40x40 art comparison.

### 2026-07-28 — Product grill round 3 and art-spike start

- Objective: close the 0.1 product contract and begin the first implementation artifact only after the prerequisite gate passed.
- Completed:
  - Approved manual menu-bar/global-shortcut Ideating mode for ordinary non-coding chats.
  - Approved passive click-through behavior with a temporary menu-bar unlock-to-drag mode.
  - Approved previewed one-click lifecycle-hook installation with backup, verification, and ownership-safe uninstall.
  - Issued the grill verdict `ready with experiments`; automatic ordinary-chat detection is the deferred experiment.
  - Recorded the final decision summary on GitHub and closed issue #1 as completed.
  - Generated 32x32 and 40x40 mascot directions from the canonical owner avatar using the built-in image-generation workflow.
  - Rejected the first 40x40 draft because it changed body proportions and therefore was not a fair grid comparison.
  - Generated a compact 40x40 v2 direction, removed chroma backgrounds, enforced a 12-color/binary-alpha palette, and created native sprites plus 8x light/dark QA sheets.
  - Added the reusable `tools/prepare_pixel_concept.swift` art-preparation tool and documented prompts and artifacts in `art/concepts/README.md`.
- Decisions: recommend 40x40 v2 because its separated glasses/eyes and additional expression room materially support ideating, waiting, success, and failure animations; owner approval remains required.
- Verification: native files are `32x32` and `40x40`; QA sheets show each at 8x on light and dark backgrounds; generated sources remain concept references rather than production frames.
- Risks or blockers: the 32x32 glasses collapse into a horizontal band. The 40x40 v2 is clearer but still requires owner selection and a hand-cleaned base frame before animation.
- Next: owner selects 32x32 or 40x40 v2. Then freeze the chosen grid, hand-clean the base sprite, and write the atlas specification in issue #3.

### 2026-07-28 — Owner art selection and tall-base refinement

- Objective: record the owner's ranked aesthetic choice and turn it into a feasible native-grid production base.
- Completed:
  - Owner ranked the original tall first concept highest, with the compact chibi second, and selected a 40x40 grid.
  - Preserved both ranked reference images under `art/references/` so the temporary clipboard files are not lost.
  - Restored the tall concept as the primary direction and designated the compact chibi as fallback only.
  - Used the built-in image-generation workflow to create a tall production-direction source with a modestly enlarged head and glasses while preserving adult proportions.
  - Removed the chroma background and produced a true 40x40, binary-alpha, 12-color draft.
  - Added `tools/hand_clean_tall_base.swift` to replace the automatically collapsed face with deterministic native square-glasses pixels.
  - Produced `art/production/mascot-base-tall-40-native-final.png` and its 8x light/dark QA sheet.
- Decisions: 40x40 is frozen as the production grid. The tall silhouette is primary; the chibi is not used unless a future state fails 1x readability after a bounded hand-clean attempt.
- Verification: `sips` dimension/alpha checks and visual QA are required before closing issue #2; the current candidate has been rendered on both light and dark backgrounds.
- Risks or blockers: the tall proportions leave only a small facial area. The base now has separate square frames and lens pixels, but owner visual approval is still required before the baseline is frozen.
- Next: review the hand-cleaned 40x40 QA sheet. If approved, close issue #2, freeze the base/baseline, and begin the animation atlas specification in issue #3.

### 2026-07-28 — Failed native draft rejection and Retina correction

- Objective: respond to owner QA, reject the malformed sprite, identify the dimensional error, and restore the selected tall design.
- Completed:
  - Owner rejected `art/production/mascot-base-tall-40-review-8x-final.png` as visually unacceptable.
  - Marked every 40-source-pixel hand-clean artifact and `tools/hand_clean_tall_base.swift` as rejected evidence; none may enter the app or animation atlas.
  - Identified the root cause: the implementation treated a desired 40x40-point on-screen footprint as only 40x40 source pixels.
  - Corrected the asset contract: an 80x80-pixel `@2x` source maps exactly to a 40x40-point window on a Retina display.
  - Rebuilt directly from the owner-selected tall concept as `art/production/mascot-base-tall-40pt-at2x-80px.png` and generated a light/dark QA sheet.
- Decisions: the malformed sprite is rejected. The tall concept remains selected; the correction changes backing resolution, not the owner's chosen appearance or screen footprint.
- Verification: corrected asset is 80x80 pixels with alpha; Retina mapping is 1 source pixel per backing pixel at a 40-point footprint. Non-Retina behavior is not yet approved.
- Risks or blockers: owner QA of the corrected Retina candidate is required. A dedicated non-Retina strategy must be tested later.
- Next: review the corrected Retina QA sheet. Do not close issue #2 or start animation frames until it is approved.

### 2026-07-28 — Merged-face rejection and fallback activation

- Objective: respond to the owner's merged-face QA, test bounded repairs, and stop forcing the preferred tall direction past its native pixel budget.
- Completed:
  - Rejected the first 80x80 tall Retina candidate because hair, glasses, lenses, eyes, and nose collapse into one facial cluster.
  - Used the built-in image-editing workflow to create a cleaner tall-face reference while holding the selected appearance constraints.
  - Tested a deterministic native-pixel face expansion; rejected it because the enlarged frames read as a horizontal goggle bar.
  - Tested a coherent full-sprite reduction of the corrected tall reference; rejected it because one lens disappears at native size.
  - Activated the owner's explicitly approved second-choice chibi fallback.
  - Removed the fallback reference's chroma background, discarded isolated alpha debris with `tools/keep_largest_alpha_component.swift`, and produced an 80x80 `@2x` native candidate plus light/dark QA sheet.
- Decisions: no tall candidate is viable at the current 40-point footprint without changing its selected proportions. The exact owner-selected chibi fallback is the sole current candidate; all tall variants are evidence only.
- Verification: the current fallback is 80x80, uses exactly 12 subject colors, and has binary alpha values only (`0` or `255`); both lenses/eyes, the nose, and the mouth remain distinct on light and dark QA backgrounds.
- Risks or blockers: owner approval is still required. Issue #2 remains open, and no animation or app scaffolding may start before approval.
- Next: present `art/production/mascot-base-owner-chibi-40pt-at2x-v2-review-8x.png` for owner QA. If approved, freeze its baseline and palette; otherwise revise only the fallback face with an explicit pixel-level acceptance target.

### 2026-07-28 — Tall source-face approval and native v3

- Objective: record the owner's explicit approval of the corrected tall face and translate it into a bounded native Retina candidate without reviving rejected merged-face work.
- Completed:
  - Preserved the exact approved attachment as `art/references/owner-approved-tall-face.png`.
  - Distinguished source-design approval from final 80x80 native-sprite approval.
  - Removed the source's baked checkerboard deterministically with `tools/remove_checkerboard_background.swift`; the character itself was not regenerated.
  - Produced an automatic 80x80 reduction (`v1`) and rejected it internally because its facial clusters collapsed.
  - Produced a bounded face reconstruction (`v2`) and rejected it internally because its continuous bridge read as a goggle bar.
  - Produced `mascot-base-approved-tall-40pt-at2x-80px-v3.png` with two independent square frames and a separate eye/glint in each lens.
- Decisions: the approved tall face supersedes the temporary chibi direction. The chibi remains a fallback only. Issue #2 stays open until the owner approves native v3.
- Verification: v3 is 80x80, uses 12 subject colors, has binary alpha values only (`0` or `255`), and preserves rows 16–79 byte-for-byte from the automatic approved-source reduction.
- Risks or blockers: source approval does not prove Dock-size readability. The owner must review the v3 light/dark QA sheet at its intended 40-point footprint.
- Next: present `art/production/mascot-base-approved-tall-40pt-at2x-v3-review-8x.png` for final native QA. If approved, freeze the baseline/palette, close issue #2, and begin the atlas specification in issue #3.

### 2026-07-28 — Final tall rejection and chibi restoration

- Objective: honor the owner's rejection of native tall v3 and stop the failed tall-face iteration loop.
- Completed:
  - Marked `mascot-base-approved-tall-40pt-at2x-80px-v3.png` and its QA sheet as rejected evidence.
  - Restored the exact secondary chibi reduction, `mascot-base-owner-chibi-40pt-at2x-80px-v2.png`, as the sole production candidate.
  - Prohibited further tall-face repairs for version 0.1.
- Decisions: the secondary chibi supersedes both the preferred tall concept and the later source-face approval for production use. Historical tall sources remain in the repository only to explain the decision trail.
- Verification: the restored chibi is 80x80 with alpha; its existing verification recorded 12 subject colors and binary alpha values only (`0` or `255`).
- Risks or blockers: none for the base-character gate. Non-Retina behavior remains a later technical experiment.
- Next: close issue #2 and begin the animation-frame and atlas specification in issue #3 without any additional base-character redesign.

### 2026-07-28 — Chibi baseline freeze

- Objective: convert the explicit fallback instruction into a final, unambiguous production baseline.
- Completed:
  - Promoted the already-reviewed chibi reduction to `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` without changing any pixels.
  - Promoted its identical light/dark QA sheet to `art/production/mascot-base-chibi-40pt-at2x-final-review-8x.png`.
  - Froze the 40-point footprint, 80x80 `@2x` backing grid, 12-color palette, binary alpha, and secondary-chibi identity hierarchy.
  - Closed issue #2 as completed.
- Decisions: the explicit fallback instruction is final approval of the previously presented chibi reduction. No duplicate approval is required.
- Verification: SHA-256 hashes of the promoted native asset and QA sheet exactly match their previously reviewed v2 sources.
- Risks or blockers: none for issue #2. The dedicated `@1x` strategy remains an open implementation experiment.
- Next: write the animation atlas specification in issue #3, then begin state-frame production.

### 2026-07-28 — Session closure audit

- Objective: end the session with one reconciled record of what worked, what failed, what is frozen, and what the next session may do.
- What worked:

  | Work | Result and evidence |
  | --- | --- |
  | Project planning | The 0.1 scope, non-goals, architecture, state reducer, privacy rules, energy targets, dated phases, and acceptance gates are documented in this ledger. |
  | Product grilling | Three `grill-me` rounds settled Dock-only behavior, manual ideating, click-through interaction, previewed hook installation, sleep schedule, and every visible state animation. Issue #1 is closed. |
  | Reusable skills | `grill-me`, `pixel-mascot-art`, `macos-desktop-mascot`, `agent-activity-signals`, and `session-ledger` were created, installed, and validated. Curated image, goal, pet, screenshot, and security skills were also made available. |
  | GitHub foundation | The private `Mr-Shine09/desktop-mascot` repository, issues #1–#13, and all dated ledger links were created. Authenticated `gh` commands successfully handled writes when the connected GitHub app could not see the private repository. |
  | Product behavior contract | Strolling, typing, Thinker/idea cloud, raised-hand waiting, sparkling-eyes/fist-pump success, confused/dizzy failure, and 23:00–06:00 blanket sleep are explicitly mapped to normalized states. |
  | macOS placement contract | The mascot will use an independent transparent Dock-edge window, remain click-through by default, support Dock auto-hide, avoid Dock hit targets, and defer wider lower-screen roaming. |
  | Resolution correction | The desired footprint is correctly defined as 40x40 macOS points backed by an 80x80 `@2x` Retina asset. The earlier 40-source-pixel interpretation is permanently rejected. |
  | Art tooling | `prepare_pixel_concept.swift` consistently fits, quantizes, and builds light/dark QA sheets; `keep_largest_alpha_component.swift` removed isolated chroma debris; `remove_checkerboard_background.swift` preserved the owner-approved source while removing its baked checkerboard. |
  | Final mascot base | The secondary chibi was explicitly selected, promoted without pixel changes, verified at 80x80 with 12 subject colors and binary alpha, and frozen as `art/production/mascot-base-chibi-40pt-at2x-80px-final.png`. Issue #2 is closed. |
  | Reproducible history | The final promoted files match their reviewed v2 sources by SHA-256. Rejected and intermediate binaries were later pruned from the working tree but remain recoverable from Git history through `0f292ec`. |

- What did not work:

  | Attempt | Failure and disposition |
  | --- | --- |
  | 32x32 concept | The glasses collapsed into a broad facial band and did not leave enough room for expressive states. Rejected as production direction. |
  | First tall comparison | Its changed proportions made the initial 32/40 comparison invalid. It later became a preference reference, not an approved native sprite. |
  | 40-source-pixel tall draft | Confused UI points with backing pixels, destroyed facial detail, and produced the owner-rejected “monster” result. All related assets and `hand_clean_tall_base.swift` are evidence only. |
  | Automatic 80x80 tall reduction | Hair, glasses, eyes, and nose merged into an unreadable cluster. Rejected. |
  | First deterministic tall-face patch | Enlarged the head and frames into an oversized goggle bar. Rejected. |
  | Coherent regenerated tall reduction | Lost one lens/eye at native size even though the large source face looked good. Rejected. |
  | Approved-source tall v1 | Direct reduction still collapsed the facial construction. Rejected internally. |
  | Approved-source tall v2 | A continuous bridge recreated the goggle-bar appearance. Rejected internally. |
  | Approved-source tall v3 | Separated the frames mechanically but remained visually unacceptable to the owner. Explicitly rejected; no further tall repair is allowed for 0.1. |
  | Requested transparent ImageGen source | The generator produced a baked checkerboard rather than usable transparency. Deterministic edge-connected background removal recovered the source, but this did not rescue the native tall direction. |
  | First fallback chroma cleanup | Isolated opaque debris expanded the visible bounds and made the first reduction too small. Keeping only the largest connected alpha component fixed the pipeline. |
  | Connected GitHub app | Returned 404 for the newly created private repository. Authenticated GitHub CLI was the successful fallback for repository, issue, comment, and close operations. |
  | Automatic ordinary-chat detection | No trustworthy privacy-preserving lifecycle signal was established for every Claude/ChatGPT app or browser conversation. Version 0.1 uses manual Ideating mode instead. |

- Decisions: freeze the secondary chibi; preserve rejected tall outcomes in the ledger and Git history rather than the active art folders; do not start app scaffolding until issue #3 defines atlas geometry, anchors, timing, and frame acceptance rules.
- Verification:
  - Issue #1 and issue #2 are closed; issue #3 is the next open gate.
  - Final native asset: `art/production/mascot-base-chibi-40pt-at2x-80px-final.png`.
  - Final QA sheet: `art/production/mascot-base-chibi-40pt-at2x-final-review-8x.png`.
  - Repository history through the chibi freeze (`2eaf79d`) was pushed before this audit; the closure commit is the final session write.
  - Worktree was clean at the start of this closure audit.
- Risks or blockers: no blocker for issue #3. Open experiments are the dedicated non-Retina `@1x` strategy and automatic ordinary-chat presence detection; neither blocks atlas specification.
- Next: begin a new session at issue #3. Do not generate more base-character concepts, revive the tall direction, or scaffold the app before the atlas contract exists.

### 2026-07-28 — Art archive cleanup

- Objective: remove ignored, rejected, superseded, and duplicate images from `art/concepts/`, `art/production/`, and `art/references/` without weakening the frozen production baseline or the decision record.
- Completed:
  - Audited all 43 tracked images across the three art folders against the owner decisions, production README, hashes, and this ledger.
  - Retained exactly three live images: the selected secondary-chibi source, the frozen 80x80 `@2x` sprite, and its frozen light/dark QA sheet.
  - Removed 40 unused images: 12 superseded concept PNGs, 23 rejected or duplicate production PNGs, and five rejected or derived reference PNGs.
  - Replaced the art-folder READMEs with concise selection boundaries and added `art/references/README.md` so future sessions cannot mistake historical failures for viable inputs.
- Decisions: the active art tree is a production allowlist, not an experiment archive. Historical filenames and outcomes remain in this ledger; removed binaries remain recoverable from Git history through `0f292ec`.
- Verification: the selected source remains `1254x1254`; the frozen native base remains `80x80` with alpha and SHA-256 `954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6`; the QA sheet remains `1280x640` with alpha.
- Risks or blockers: none introduced. Issue #3 remains the next gate.
- Next: write the animation atlas specification in issue #3 using only the frozen base and selected source.

### 2026-07-28 — Animation atlas contract freeze

- Objective: complete the issue #3 specification gate before any app scaffolding or new state-frame art.
- Completed:
  - Added `art/animation/ATLAS.md` with the fixed 8x11 row layout, 96x112-pixel cells, shared `(48, 102)` anchor/baseline, body and effect bounds, per-state frame counts, playback modes, timing, Reduced Motion substitutions, and production sequence.
  - Added the machine-readable `art/animation/atlas-contract.json` covering all eleven version 0.1 rows, including the previously omitted but approved `ideating` state.
  - Reused the frozen 12-color palette for all props and effects; no new atlas colors or semitransparent pixels are allowed.
  - Added `tools/validate_animation_atlas.py` to validate the contract, frozen-base hash and dimensions, and later atlas dimensions, palette, alpha, transparent RGB, used/unused occupancy, and cell guards.
- Decisions: keep the approved 80x80 body canvas at its 40-point size inside a 96x112 backing-pixel cell; reserve bounded upper space for the ideating cloud instead of resizing the character. The custom macOS app uses its own 11-row atlas contract rather than the Codex app's unrelated fixed 9-row pet package.
- Verification: `python3 tools/validate_animation_atlas.py --contract-only` passes; `git diff --check` passes; the frozen source hash is still `954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6`.
- Risks or blockers: frame art, contact sheets, motion previews, owner visual review, and the dedicated `@1x` strategy remain open. Full visual generation will require a separately bounded art-production run.
- Next: commit the contract, then begin with the anchor fixture plus `idle`, `walk-right`, and `walk-left` rows. Do not scaffold the app before owner review of issue #3 outputs.

### 2026-07-28 — Directional walk production candidate

- Objective: begin issue #3 frame production with the anchor, idle, and directional walk rows.
- Completed:
  - Added the exact frozen base as `art/animation/frames/idle/idle-00.png` at cell offset `(8, 25)`; its opaque bounds end on baseline `y=102`.
  - Generated a six-frame right-walk source grounded in the frozen chibi, then removed the variable green background, applied one shared row scale, reduced every opaque pixel to the frozen 12-color palette, and aligned every frame to the shared anchor.
  - Rejected an independently generated left row because its face and hair language drifted from the right row.
  - Derived the left row by mirroring each right frame individually while preserving temporal order.
  - Added deterministic frame preparation, safe mirror derivation, partial-row validation, contact-sheet rendering, silhouette rendering, and GIF preview tools.
  - Produced light/dark directional contact sheets, silhouette QA, and both motion previews under `art/animation/qa/`.
- Decisions: the directional rows are owner-review candidates, not final atlas approval. Generated chroma variation is acceptable only when deterministic border-connected removal produces clean binary alpha and the resulting art passes visual QA.
- Verification:
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states walk-right walk-left` passes.
  - All twelve directional frames are `96x112`, use only the frozen palette, have alpha values `0` or `255`, contain zero RGB under transparency, stay inside the four-pixel guard, and end on baseline `y=102`.
  - Independent visual QA passed both rows for identity, scale, alternating-foot cadence, correct facing, clipping, effects, and light/dark readability.
  - `python3 tools/validate_animation_atlas.py --contract-only` and `git diff --check` pass.
- Risks or blockers: built-in image generation failed two idle-row attempts and one single-blink repair because it redesigned the face, glasses, hair, pose, or baseline. Those outputs were rejected and are not present in the project. Finishing idle now requires either explicit owner approval for native pixel-level editing or a different approved identity-preserving visual workflow.
- Next: obtain owner review of the directional candidate and direction on native idle-frame editing. Do not generate the remaining state rows or scaffold the app until this art boundary is resolved.

## Next-session handoff

1. Read this file in full.
2. Treat `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` as the frozen base; never present another native tall variant as viable.
3. Review the directional candidate in `art/animation/qa/contact-sheet-candidate.png` and the two GIF previews. If approved, explicitly authorize native pixel-level idle editing or choose another identity-preserving workflow; do not scaffold the app before issue #3 owner review.
4. Update this ledger before ending the session.

## Documentation sources

- [Official Codex hooks documentation](https://learn.chatgpt.com/docs/hooks)
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Instagram reference post](https://www.instagram.com/p/DbV-I14FKJ2/?img_index=3)
