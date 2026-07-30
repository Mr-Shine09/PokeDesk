# Desktop Mascot

> Living implementation ledger. Read this entire file at the start of every project session and update it before ending the session.

## Project snapshot

| Field | Current value |
| --- | --- |
| Project | Desktop Mascot for macOS |
| Owner | [Mr-Shine09](https://github.com/Mr-Shine09) |
| Started | 2026-07-28 |
| Last updated | 2026-07-29 |
| Status | Portal summon, revision 3 cursor-hanging, ambient animation, event engine, and local transport are implemented and build-verified |
| Current gate | Owner-verify the portal summon and physical cursor-hanging feel; then wire the tested local event path into the app |
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
| Enlarged 80-point body presentation | On 2026-07-28 the owner asked twice for a larger mascot. Keep the frozen atlas unchanged but present its 48x56-point cell at 2x (`96x112` points), producing an apparent body footprint of about 80x80 points. |
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
| Direct mascot interaction | The owner's later explicit request supersedes passive click-through: the mascot accepts clicks for Pause/Resume, Stop/Resume Roaming, Close, and Quit options, and accepts drag/drop at any time. The menu-bar escape hatch remains available. |
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
- Idle animation variants include directional strolling and directional Dock-corner sitting with one dangling leg shaking.
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

- On-screen footprint: `80x80` apparent body points inside a `96x112`-point panel, enlarged 2x from the frozen atlas cell after owner review.
- Retina production body asset remains `80x80` pixels inside the frozen `96x112` atlas cell. The approved larger presentation uses nearest-neighbor 2x display scaling and does not modify atlas pixels.
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
| Offline | Agent integrations unavailable | 4 | Quiet bowed blink with a rising/disappearing `Z` trail |
| Idle/chilling | Daytime with no active work | 6 each direction | Stroll along the Dock-edge lane with occasional pause/blink |
| Working | At least one agent is active | 6 | Sit at a tiny computer and type |
| Ideating | A non-coding Claude/ChatGPT task is active | 6 | Sit in a Thinker pose while a tiny thought cloud pops in and out |
| Waiting | User approval or input needed | 4 | Stop, turn toward the user, raise one hand, and show a clock above the head |
| Success | Most recent turn completed | 6 | Sparkling eyes, stars above the head, and one quick fist pump, then ambient state |
| Failure | Agent turn or integration failed | 6 | Confused/dizzy reaction with a broken light bulb above the head, then ambient state |
| Sleeping | Inactive during 23:00–06:00 local time | 6 | Sleep under a blanket with a looping `Z` trail; wake immediately for activity |
| Paused | User disabled automatic behavior | 2 | Still pose |
| Sit-shake right/left | Ambient idle at a Dock corner | 6 each | Sit on a compact Dock-edge ledge and casually swing one dangling leg |
| Hanging | Direct mascot drag | 6 | One raised hand stays attached to the cursor while the body swings beneath it; no cliff or ledge |

Detached effects should be sparse and bounded above the character. The approved effect vocabulary is the ideating cloud, offline/sleeping `Z` trails, waiting clock, success stars/sparkles, and failure bulb. All reuse the frozen palette, stay inside the cell guard, and must remain readable at native size without obscuring the face.

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

### Implemented package layout

```text
DesktopMascot/
├── App/
│   ├── DesktopMascotApp.swift
│   ├── AppDelegate.swift
│   ├── AmbientAnimationController.swift
│   ├── AppResources.swift
│   ├── MascotPreviewView.swift
│   └── MenuBarContent.swift
├── Packages/DesktopMascotKit/
│   ├── Sources/MascotCore/MascotState.swift
│   ├── Sources/MascotAnimation/
│   │   ├── AtlasContract.swift
│   │   └── SpriteAtlas.swift
│   ├── Sources/MascotWindow/
│   │   ├── MascotPanel.swift
│   │   ├── DockGeometry.swift
│   │   └── WindowCoordinator.swift
│   └── Tests/
├── art/animation/
├── project.yml
└── DesktopMascot.xcodeproj/
```

XcodeGen owns the generated project. The app layer now contains the first ambient animation controller; event transport, the deterministic reducer, and provider adapters will extend the package boundaries in later phases.

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
- The compact mascot panel accepts direct clicks and drag/drop. A click opens local Pause/Resume, Stop/Resume Roaming, Close Mascot, and Quit options. Dragging stops roaming at the dropped position; Resume Roaming returns it to the bottom lane.
- Position from `NSScreen.visibleFrame` versus `frame` to infer Dock exclusion on each display.
- Support bottom, left, and right Dock orientation, auto-hide, multiple displays, screen changes, Spaces, and scale-factor changes.
- Use an independent safety lane immediately above or beside the Dock; never place the window over app-icon hit targets.
- Dock auto-hide does not need to be disabled. When the Dock hides, the mascot remains a separate visible overlay at the screen edge unless testing shows that following the hidden Dock is less distracting.
- Align the visible character baseline to the Dock boundary. The default 2x panel uses a 10-point transparent visual inset so only transparent cell padding overlaps the Dock exclusion; visible character pixels remain on the workspace side.
- Reposition with bounded motion; never teleport across unrelated displays unless the user selects a display.
- Menu-bar item remains the reliable pause/hide/quit control.
- Reopening an already-running app restores a hidden mascot panel through `applicationShouldHandleReopen`; “Hide Mascot” and “Quit Dock Pet” remain intentionally distinct.

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

**Status: Complete on 2026-07-28.**

1. Run a user-facing grill-me round on naming, interaction tolerance, hook installation, and release visibility.
   - Round 1 completed on 2026-07-28: core animations, 23:00–06:00 sleep behavior, broad provider goal, and Dock-only 0.1 were confirmed.
   - Round 2 completed on 2026-07-28: ideating, waiting, and successful-completion animations were confirmed; automatic non-coding activity detection remains unresolved.
   - Round 3 completed on 2026-07-28: manual ideating control, temporary unlock-to-drag, and previewed one-click hook installation were approved. Verdict: `ready with experiments`.
2. Produce 32x32 and 40x40 idle concept variants from the supplied avatar.
3. Review both at 1x on light and dark backgrounds.
4. Approve one native grid, palette, identity hierarchy, and baseline.
5. Write animation frame and atlas specification.

Completed on 2026-07-28: the owner selected a 40-point footprint, rejected every native tall treatment, and explicitly ordered the secondary chibi fallback. `mascot-base-chibi-40pt-at2x-80px-final.png` is frozen as the base. The owner approved the 13-row revision 2 atlas, including the requested status effects and directional corner-sit clips. On 2026-07-29 the owner's explicit hanging request authorized revision 3, which adds one dedicated cursor-hanging row and top grip anchor. The current geometry, row order, palette, timing, anchors, acceptance rules, and QA outputs live in `art/animation/ATLAS.md` and `art/animation/atlas-contract.json`.

Acceptance: owner selects one concept; chosen sprite is recognizable at 1x; palette and frame geometry are frozen for 0.1. Passed on 2026-07-28.

### Phase 2 — Native app skeleton (2026-07-31 to 2026-08-02)

**Status: In progress; steps 1–5 implemented, eight automated tests pass, and the live bottom-Dock/single-display pass is complete as of 2026-07-28. Remaining manual configurations are pending.**

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

**Status: In progress; atlas playback, random ambient walk/offline phases, and a Reduce-Motion-aware portal summon transition are implemented. Provider-driven transitions and broader Reduced Motion coverage remain open.**

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
| [#3 Specify and produce the animation-ready sprite atlas](https://github.com/Mr-Shine09/desktop-mascot/issues/3) | 1 / 5 | Owner-approved and frozen locally on 2026-07-28; GitHub status sync pending |
| [#4 Scaffold the native SwiftUI/AppKit macOS app](https://github.com/Mr-Shine09/desktop-mascot/issues/4) | 2 | Implemented and build-verified locally; manual acceptance and GitHub status sync pending |
| [#5 Implement the transparent Dock-edge mascot window](https://github.com/Mr-Shine09/desktop-mascot/issues/5) | 2 | In progress; eight automated tests and live bottom-Dock/single-display/focus checks pass, but the remaining manual matrix is pending |
| [#6 Implement the mascot state model and reducer](https://github.com/Mr-Shine09/desktop-mascot/issues/6) | 3 | In progress; envelope, decoder, session registry, and reducer are implemented and tested locally on 2026-07-29. App wiring is deliberately deferred until transport #7 exists; GitHub status sync pending |
| [#7 Build the private local event bridge and helper CLI](https://github.com/Mr-Shine09/desktop-mascot/issues/7) | 3 | In progress; `MascotTransport` and the `dockpet-event` helper are implemented, unit-tested, and verified cross-process on 2026-07-29. The app does not yet run the server and the helper is not yet bundled; GitHub status sync pending |
| [#8 Add the Codex lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/8) | 4 | Open |
| [#9 Add the Claude Code lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/9) | 4 | Open |
| [#10 Build menu-bar settings and integration management](https://github.com/Mr-Shine09/desktop-mascot/issues/10) | 2 / 4 | Open |
| [#11 Integrate animations, transitions, and Reduced Motion](https://github.com/Mr-Shine09/desktop-mascot/issues/11) | 5 | In progress; cached ambient playback and the portal summon transition run locally; provider transitions and broader Reduced Motion coverage remain open |
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
| Directional walk rows | Six frames each direction, shared baseline, frozen palette, light/dark contact sheet, and motion previews | Passed internal QA and owner review on 2026-07-28 |
| Idle row | Four native frames preserve the base silhouette and change only lens interiors for a half/full blink | Passed deterministic, internal visual, and owner review on 2026-07-28 |
| Working, ideating, waiting rows | Contract frame counts, shared baseline, frozen palette, light/dark contact sheet, silhouettes, and motion previews | Passed deterministic, internal visual, and owner review on 2026-07-28 |
| Effect-revised offline, waiting, success, failure, sleeping rows | Contract frame counts, requested effects, shared baseline, frozen palette, silhouettes, and motion previews | Passed deterministic, internal visual, and owner review on 2026-07-28 |
| Dock-corner sit-shake rows | Six frames each direction, stable seat/torso, one swinging leg, mirrored temporal order | Passed deterministic, internal visual, and owner review on 2026-07-28 |
| Retina atlas assembly | Exact current grid, used/unused occupancy, palette, alpha, transparent RGB, and cell guards | Revision 3 `768x1568` candidate passes validator on 2026-07-29; owner drag QA pending |
| Cursor-hanging row | Six frames, fixed top grip, frozen palette, binary alpha, no cliff/ledge, and cursor-attached drag geometry | Passed deterministic art validation, runtime pixel equality, drag geometry test, and Debug build on 2026-07-29; physical feel pending |
| Native app scaffold | Generated Xcode project, modular package, embedded atlas resources, static nearest-neighbor render, and startup/reopen smoke tests | Passed initial scaffold on 2026-07-28; fresh Debug relaunch restored a visible `96x112` window on 2026-07-29 |
| Window geometry | Automated fixtures plus manual multi-display matrix | Ten tests pass, including bottom/left/right/clamp, visibility, non-activating interaction, click routing, and drag begin/end routing; remaining display matrix pending |
| Atlas runtime mapping | Every declared row crops to the matching frozen frame pixels | Passed 2026-07-29 for offline, idle, working, ideating, both walk directions, and both cliff-edge sit rows |
| Ambient animation | Atlas timing, directional movement, alternating walk direction, random offline rests, and bounded bottom-lane motion | Corrected live samples show distinct right gait while x increases and left gait while x decreases; offline transition also visually verified |
| Portal summon | Portal opens before mascot emergence, mascot is fully visible before closure, hide/show and reopen replay the transition, and Reduce Motion avoids translation/scale motion | Passed three deterministic timeline fixtures inside a 116-test package suite and an unsigned Debug build on 2026-07-29; owner visual QA pending |
| Event envelope and decoder | Version/provider/event allowlists, opaque session-ID validation, payload ceiling, RFC 3339 parsing, injected-clock skew bounds | Passed 2026-07-29: 21 decoder fixtures inside a 31-test package suite |
| State reducer | Unit tests for ordering, duplicates, expiry, concurrency | Passed 2026-07-29: 39 registry/reducer fixtures inside a 70-test package suite, covering the full documented priority order, duplicate idempotence, stale-event rejection, heartbeat expiry boundaries, bounded reaction boundaries, stopped grace, capacity eviction, wake reconciliation, sleep-window hours, and concurrent providers. Two mutation checks confirmed the heartbeat-refresh-only and stale-ordering guards are genuinely enforced. Not yet wired to the app |
| Privacy | Forbidden fields absent from storage and diagnostic output | Partially passed 2026-07-29 at the decoder boundary: forbidden keys are discarded, the envelope exposes only six allowlisted fields, and no error carries payload text. Storage and diagnostics remain unverified because neither exists yet |
| Local event transport | Framing fixtures, same-user peer check, owner-only permissions, malformed/oversized frame survival, socket lifecycle, and a cross-process helper run | Passed 2026-07-29: 37 transport fixtures inside a 113-test package suite, plus a cross-process run in which the real `dockpet-event` binary delivered a hashed-session `waiting` event to a listener on the real default path. Not yet wired into the app |
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
| Mascot blocks Dock or steals focus | High | Non-activating compact interactive panel, transparent Dock inset, and menu-bar escape hatch | Bottom-Dock live pass succeeds; manual direct-interaction and display QA pending |
| Bottom-Dock lane visually covers lower-screen app controls | High | Use bounded bottom motion, stop roaming when manually dragged, and add pointer/control avoidance before release | Open; owner explicitly requested roaming, so pointer/control avoidance remains required hardening |
| Ambient animation claims agent inactivity without a lifecycle signal | High | Label the current controller as ambient/no-signal behavior and replace it with reducer output after issues #6–#9 | Constrained; current diagnostics explicitly say no agent signal is connected |
| Hidden mascot is mistaken for a quit app and will not reopen | Medium | Label the action “Hide Mascot,” retain a distinct Quit action, and restore the panel on application reopen events | Fixed 2026-07-29; owner retest pending |
| Atlas rows render in reverse vertical order | High | Compare runtime crops pixel-for-pixel with frozen frame files across distant rows | Fixed 2026-07-29; regression test covers eight representative rows |
| Multiple sessions thrash visible state | Medium | Per-session registry, priority reducer, debounce, bounded reactions | Registry, priority reducer, and bounded reactions implemented and tested 2026-07-29. Debounce at the animation boundary remains open and belongs with the app wiring |
| Cursor-following annoys or obstructs | Medium | Defer; require explicit opt-in and dedicated tests | Deferred |
| Idle animation wastes battery | Medium | Event-driven updates, suspend timers, measurable energy budget | Open |
| Generated state frames drift from the frozen identity | High | Ground every job in the frozen base, normalize deterministically, reject drift, and use native pixel editing only with explicit owner approval | Revision 2 owner-approved and frozen |
| Detached status effects crowd the face or become noisy | Medium | Reserve the upper guard area, reuse the frozen palette, keep effects compact, and review at native size on light/dark backgrounds | Revision 2 owner-approved and frozen |
| Personal likeness ships before review | Medium | Private repository until owner changes visibility | Mitigated for foundation |
| Roaming on a left or right Dock walks across mid-screen | High | `panelOrigin` centers the panel vertically for side Docks while `horizontalMovementBounds` still sweeps the full `visibleFrame` width, so the mascot would walk horizontally through the middle of the screen over app windows | Open; found 2026-07-29 during maintainer onboarding. Needs an owner decision before the side-Dock matrix can pass |
| Hide/Show discards a manually dragged position | Medium | `WindowCoordinator.setVisible(true)` repositions unconditionally, so Hide→Show and app reopen snap the mascot back to the Dock lane while roaming stays off, stranding it where the user did not put it | Open; found 2026-07-29 during maintainer onboarding |
| `MascotCore` state vocabulary is unused by the running app | Medium | `AmbientAnimationController` drives animation with raw atlas row strings; `MascotState`/`AmbientAnimation` are exercised only by tests. The reducer must become the single typed source of visible state instead of growing beside the string-keyed controller | Still open, and now larger: `MascotStateReducer` emits typed `MascotVisibleState` but nothing consumes it. Wiring was deliberately deferred because with no transport the reducer would report `offline` forever and would regress the owner-approved ambient roaming. Close this together with #7 |
| The default socket path may not fit `sun_path` for every user | Medium | `AF_UNIX` allows 103 usable path bytes. The real path measured 86 bytes for an 11-character user name on 2026-07-29, leaving roughly 17 bytes of headroom, so a much longer home directory path would fail. The failure is fail-closed and explicit (`socketPathTooLong`), not a truncated bind, but the bridge would be unavailable | Open; found 2026-07-29. If it ever bites, shorten the directory or socket name rather than truncating the path |
| The helper is not installed anywhere a hook can reach | Medium | `dockpet-event` builds as a package executable but is not bundled into `Dock Pet.app` and has no install flow, so no provider hook can invoke it yet. Bundling requires a `project.yml` change plus regeneration and belongs with the adapter work | Open; deliberate scope boundary for issues #8 and #9 |
| Atlas revision is tracked only in prose | Low | `atlas-contract.json` carries `schema_version` but no revision field, so no tool can assert which revision is loaded. Geometry itself validates and matches documented revision 3 | Open; low impact while one contract ships |

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
- Treat the owner instruction to continue after the directional preview and native-edit authorization request as approval of the directional candidate and authorization for native pixel-level idle editing.
- Author idle entirely from the frozen base: frames 0 and 3 are exact base copies; frame 1 is a half blink and frame 2 is a full blink; only the white lens-interior pixels may change.
- Treat the owner instruction to update this ledger and end the session after reviewing the idle preview as final approval of the idle row. Idle and both directional rows are now frozen for issue #3 production.
- Treat the owner instruction to continue after reviewing the working, ideating, and waiting previews as final approval of those three rows. Freeze all six approved rows before producing the final group.
- Build `paused` from approved idle cells rather than generating a new neutral pose; use the half-blink as its short settle and the exact neutral idle cell as its static hold.
- Repair only the failing success and failure scopes: hold the first fist-pump peak through the last three success frames, and remove detached generated failure symbols through a stricter connected-component threshold.
- Supersede the earlier ban on detached sleep text with the owner's explicit revision: add looping `Z` trails to offline and sleeping, a clock to waiting, stars/sparkles to success, and a cracked bulb to failure.
- Interpret the requested two Dock-corner leg-shake animations as right- and left-facing ambient idle clips. Generate the right-facing source and derive the left row by per-frame mirroring without reversing time.
- Treat the owner's “Ok good. Now let's continue” after reviewing all revision 2 previews as final approval. Freeze the 13-row `768x1456` atlas as the app-integration contract.
- Use XcodeGen for a reproducible SwiftUI app shell backed by local `MascotCore`, `MascotAnimation`, and `MascotWindow` Swift package products.
- Keep the first native checkpoint static: prove atlas decoding, nearest-neighbor frame extraction, transparent non-activating panel behavior, Dock geometry, and menu-bar recovery controls before adding timers or lifecycle signals.
- Reposition relative to the panel's current display, falling back to the main display only when the panel has no screen.
- Propagate timer-driven position relocking back to app state so the menu-bar lock indicator cannot remain stale.
- Start bottom-Dock placement at the left third of the safe lane rather than the screen center, which commonly contains compose and approval controls.
- Present the frozen atlas at 1.5x (`72x84` panel points) and align its visible baseline to the Dock with a 7.5-point transparent inset. This supersedes the original 48x56-point panel presentation without revising atlas art.
- Supersede the 1.5x presentation with the owner's later request for a 2x `96x112`-point panel and 10-point transparent Dock inset; the frozen atlas pixels remain unchanged.
- Supersede passive click-through and temporary unlock with direct click options and always-available drag/drop. Dragging stops roaming at the dropped position; Resume Roaming restores the bottom lane.
- Pull the first issue #11 slice forward: cache offline/walk/paused/ideating frames, alternate random 7–13-second walks with 2.5–5-second offline rests, reverse at lane bounds, and move at 20 Hz on backing-pixel-aligned coordinates.
- Until issues #6–#9 land, do not claim ambient roaming means ChatGPT or Claude is truly inactive. The controller has no provider signal and must yield to the future deterministic reducer.
- Distinguish Hide from Quit in the direct mascot menu. Handle a LaunchServices reopen event by restoring the existing panel and animation rather than leaving a hidden accessory process with no visible window.
- Treat atlas JSON row indices as top-origin coordinates when cropping the CGImage. The earlier bottom-origin conversion inverted all runtime states and is prohibited by pixel-equality tests.
- Alternate walk direction after each offline rest instead of repeatedly selecting direction from the mascot's current half of the screen; reverse immediately at lane bounds.
- During active drag, play the approved directional `sit-shake` cliff-edge/dangling-leg row. On drop, stop roaming and retain the manual position until Resume Roaming.
- Supersede the temporary sit-shake drag treatment with atlas revision 3: use one dedicated six-frame `hanging` row, fix its raised-hand grip to atlas coordinate `(48, 4)`, map that to AppKit panel point `(48, 108)`, and draw no cliff, ledge, rope, or cursor.
- Make `EventEnvelope` itself the privacy boundary. It declares exactly six fields and has no storage for prompt text, transcripts, code, tool arguments or output, paths, repository names, usernames, or tokens, so retaining forbidden content requires an explicit product decision rather than an implementation slip.
- Model the session identifier as a validated `SessionID` restricted to `[A-Za-z0-9._-]` and 128 characters. The excluded characters are exactly those needed to express a path, URL, or prose, so an opaque ID cannot structurally smuggle private content.
- Fail closed on an unknown `version`, `provider`, or `event`, but discard an unknown `detail` instead of rejecting the event. `detail` only refines a reaction, so new provider vocabulary must not invalidate the `event` that actually drives state.
- Never copy payload text into an error value. `unknownProvider` and `unknownEvent` report kind only, because the offending string is untrusted input that may contain private content.
- Inject `now` into every decode rather than reading the clock inside the decoder, so skew, ordering, and expiry behavior stay deterministic under test.
- Keep unknown top-level JSON keys silently dropped by the fixed `Decodable` payload shape rather than rejected. This satisfies the "forbidden fields are discarded" rule without making provider hook evolution brittle.
- Separate the two clocks explicitly. Wall-clock `occurredAt` orders events *within* one session; a monotonic `Uptime` drives heartbeat expiry and reaction windows. Laptop sleep, a time-zone change, or an NTP correction must not retire a live session or freeze a reaction on screen.
- Key sessions by provider *and* opaque ID. Per-provider IDs share no namespace, so two providers may legitimately emit the same string.
- Let only state-asserting events (`started`, `active`, `waiting`, `completed`, `failed`) create a session. `heartbeat` and `stopped` refer to a session rather than assert one, so they cannot conjure a session the registry never saw start.
- Treat `heartbeat` as refresh-only. It means "work continues", never "work began", so it must not promote an idle session to working — otherwise a `PostToolUse` hook alone could claim work that no prompt started.
- Accept an event whose `occurredAt` equals the session's newest accepted timestamp, and reject only strictly older ones. Same-second sequences are ordinary, and a redelivered identical event is idempotent because it recomputes the same state.
- Never let a bounded reaction be cut short by either the heartbeat timeout or the stopped grace period. A session with a live reaction is retained regardless, which is what makes "returns to sleep after the completion reaction" hold.
- Exclude `stopped` sessions from presence. The grace period exists so a finished turn's reaction can play, not to hold the mascot in strolling after the agent is gone.
- Cap the registry at 64 sessions and evict the least recently seen. A looping or hostile helper must not grow local state without bound.
- Treat the sleep window as `[23:00, 06:00)` in the Mac's current local time zone, so 06:00 is already awake.
- Surface only the providers responsible for the chosen state, and surface none for manual ideating, which has no originating session.
- Frame the transport as newline-delimited JSON over `AF_UNIX`/`SOCK_STREAM`. The family itself makes a network path impossible, and the framing is a pure value type separated from all I/O so every hostile-input case is a unit test rather than a socket test.
- Verify the same-user guarantee with `getpeereid` against `getuid`, not by inferring it from the socket's file mode. The `0700` directory and `0600` socket are the second layer, because a mode changed out from under the app is a weaker promise than a checked peer identity.
- Have both sides derive the socket path independently from the current user's Application Support directory. No environment variable, argument, or config file carries it, so there is no way to point the helper somewhere unintended.
- Reject a path that does not fit `sun_path` instead of truncating it. A truncated path binds a *different* socket than the one intended.
- Distinguish a stale socket file from a live listener by probing `connect` before binding. A crashed process's leftover file is removed; a live Dock Pet's socket is never stolen.
- Drop one malformed or oversized frame without closing the connection or affecting any other frame on it. Malformed data must not be able to interrupt a working session's event stream.
- Close every descriptor only from its dispatch source's cancel handler, and make both the listener and each connection non-blocking. A blocking `accept` inside the drain loop would wedge the serial queue, and closing a descriptor a source still owns is a use-after-free.
- Have the helper hash the provider's session value (SHA-256, first 32 hex characters) rather than forwarding it. The raw value never leaves the helper process, `SessionID` validity becomes a property of construction, and a careless adapter cannot hand the app a provider's real identifier.
- Have the helper exit 0 when Dock Pet is not running and reserve non-zero (64) for usage errors alone. A provider hook must never fail the user's turn because the mascot is closed.
- Accept only `--provider`, `--event`, `--session`, `--detail`, `--verbose`, and `--help` in the helper. There is no free-form passthrough, so prompt text, paths, tool arguments, and tool output have nowhere to go even if an adapter tried.

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

### 2026-07-28 — Native idle blink candidate

- Objective: resolve idle identity drift with the owner-authorized native pixel-editing path.
- Completed:
  - Inspected the exact frozen palette and face pixel coordinates before editing.
  - Added `tools/author_idle_frames.py`, which refuses to run unless the frozen base hash and every expected lens-highlight pixel match.
  - Authored four idle cells: exact base, half blink, full blink, exact base.
  - Changed only lens-interior pixels in frames 1 and 2; hair, glasses outlines, face silhouette, clothing, trousers, shoes, alpha silhouette, anchor, and baseline remain unchanged.
  - Regenerated the combined light/dark contact sheet, silhouette sheet, and idle plus directional motion previews.
- Decisions: use a blink-only idle loop. Do not add body bobbing or geometric transforms; the zero-motion silhouette is calmer, preserves identity exactly, and supports Reduced Motion.
- Verification:
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states idle walk-right walk-left` passes.
  - Idle frames 0 and 3 match every frozen-base pixel after placement at `(8, 25)`.
  - All four frames are `96x112`, use only the frozen palette, have binary alpha and clean transparent RGB, remain inside the guard, and end on baseline `y=102`.
  - The contract-timed GIF and light/dark contact sheet show a calm half/full blink with no size, baseline, or silhouette movement.
- Risks or blockers: idle awaits owner review. Generated action and prop rows may still drift from the frozen identity and must use the same reject-or-repair discipline.
- Next: present the idle preview for owner review. If accepted, produce `working`, `ideating`, and `waiting` as the next bounded state group before any app scaffolding.

### 2026-07-28 — Idle approval and session close

- Objective: record owner approval of the current animation rows and close the session with an exact next handoff.
- Completed:
  - Recorded the owner instruction to update this ledger and end the session after the idle preview as approval of the four-frame idle row.
  - Promoted idle, `walk-right`, and `walk-left` from production candidates to approved issue #3 rows.
  - Reconciled the project snapshot, issue map, verification matrix, risk register, decision log, and next-session handoff.
- Decisions: freeze the approved idle and directional rows. Do not revise them unless later full-atlas motion QA finds a concrete defect or the owner explicitly requests a change.
- Verification:
  - Directional checkpoint: commit `3d6c6a8`.
  - Native idle checkpoint: commit `df6708f`.
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states idle walk-right walk-left` passes.
  - Owner reviewed the directional and idle previews and instructed the project to continue, then close this session.
- Risks or blockers: remaining generated action and prop rows may drift from the frozen identity. The dedicated `@1x` asset strategy also remains an open experiment. Neither changes the approved rows.
- Next: begin the next session with `working`, `ideating`, and `waiting` as one bounded issue #3 production group. Do not scaffold the app before the complete atlas passes owner review.

### 2026-07-28 — Working, ideating, and waiting candidates

- Objective: produce the next bounded issue #3 state group without changing the frozen base or approved rows.
- Completed:
  - Generated separate grounded source strips for six-frame `working`, six-frame `ideating`, and four-frame `waiting` rows.
  - Extended `tools/prepare_animation_frames.py` with explicit normal-versus-guard bounds and a configurable detached-component threshold so the ideating cloud can use its contracted effect area without weakening normal body-row cleanup.
  - Normalized all frames to the frozen 12-color palette, binary alpha, clean transparent RGB, shared anchor, and baseline.
  - Regenerated the combined light/dark contact sheet, silhouette sheet, and contract-timed previews for every approved and candidate row.
- Decisions: admit the three rows only as owner-review candidates. Preserve idle and both directional rows unchanged; do not start the last five rows or app scaffold until the owner reviews this bounded group.
- Verification:
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states idle working ideating waiting walk-right walk-left` passes.
  - `python3 -m py_compile tools/prepare_animation_frames.py` and `git diff --check` pass.
  - Internal native-size review confirms seated typing, the prescribed cloud lifecycle, a one-way raised-hand intro/hold, stable ground contact, and light/dark readability.
- Risks or blockers: owner visual approval is pending. The generated poses necessarily change posture and props, so the owner remains the authority on likeness before these rows are frozen.
- Next: present the three motion previews for approval. If accepted, freeze them and produce `success`, `failure`, `sleeping`, `offline`, and `paused` as the final bounded state group.

### 2026-07-28 — Final state rows and complete atlas candidate

- Objective: record approval of the middle state group, produce the final five rows, and assemble the complete Retina atlas for owner review.
- Completed:
  - Promoted `working`, `ideating`, and `waiting` to owner-approved rows based on the instruction to continue after their previews.
  - Produced `success`, `failure`, `sleeping`, and `offline` from separate frozen-base-grounded source strips.
  - Authored `paused` deterministically from the approved idle half-blink and exact neutral cells.
  - Removed detached failure symbols with a stricter connected-component threshold and froze the success fist-pump peak across its final three frames so it cannot read as a second pump.
  - Added deterministic atlas assembly plus a frame-hash manifest and generated the complete `768x1232` `mascot-atlas@2x.png`.
  - Extended QA rendering with full eight-column light/dark sheets at backing 1x and nearest-neighbor inspection 8x.
- Decisions: the final five rows and assembled atlas are owner-review candidates only. Do not close issue #3 or scaffold the app until the owner approves them.
- Verification:
  - `python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png` passes.
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states offline idle working ideating waiting success failure sleeping paused walk-right walk-left` passes.
  - All failure frames contain one connected opaque component after symbol cleanup; paused reuses approved idle cells exactly.
  - Full 1x light/dark, 8x light/dark, silhouette, and per-row motion previews pass internal visual QA.
- Risks or blockers: final owner visual approval is pending. A dedicated authored `@1x` asset remains a post-Retina experiment and does not alter this candidate.
- Next: present the complete atlas and final five motion previews. If accepted, freeze issue #3 and begin the native app scaffold in issue #4.

### 2026-07-28 — Owner-directed effects and corner-sit expansion

- Objective: add the requested status effects and two Dock-corner leg-shake animations without redrawing approved body poses.
- Completed:
  - Expanded the contract from 11 to 13 rows and the Retina atlas from `768x1232` to `768x1456`.
  - Added deterministic native-pixel `Z` trails to offline and sleeping, a ticking clock to waiting, stars/sparkles to success, and a cracked light bulb to failure.
  - Expanded offline to four frames and sleeping to six frames so their `Z` trails can appear and disappear smoothly.
  - Generated a six-frame right-facing corner-sit leg-shake source and derived the left-facing row by per-frame mirroring with temporal order preserved.
  - Reassembled the atlas and regenerated all 13 motion previews, silhouettes, and 1x/8x light/dark contact sheets.
- Decisions: treat the two new clips as directional ambient idle variants, not reducer states. Preserve all existing body pixels when applying effects; the effect authoring tool clears and redraws only the reserved upper area.
- Verification:
  - `python3 tools/author_status_effects.py` is idempotent across all five revised rows.
  - `python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png` passes.
  - `python3 tools/validate_animation_atlas.py --frames-root art/animation/frames --states offline idle working ideating waiting success failure sleeping paused walk-right walk-left sit-shake-right sit-shake-left` passes.
  - Native-size light/dark and silhouette QA confirms the effects avoid the face; the corner-sit torso, hip, ledge, and supporting leg remain stable.
- Risks or blockers: owner visual approval of revision 2 is pending. Exact ambient selection frequency and which Dock corner triggers each sit direction remain app-controller decisions for issue #11.
- Next: present all seven revised/new previews. If accepted, freeze revision 2 and begin the native app scaffold.

### 2026-07-28 — Atlas approval and native app scaffold

- Objective: freeze the approved revision 2 art contract and begin issues #4 and #5 with a buildable native macOS checkpoint.
- Completed:
  - Recorded owner approval and froze the 13-row `768x1456` Retina atlas as the app-integration contract.
  - Added a reproducible XcodeGen project and a local Swift package split into `MascotCore`, `MascotAnimation`, and `MascotWindow` products.
  - Added atlas-contract decoding, validated ImageIO frame extraction, AppKit/SwiftUI nearest-neighbor rendering, a transparent non-activating click-through `NSPanel`, bottom/left/right Dock inference, safe placement and clamping, and screen/wake repositioning.
  - Added an accessory menu-bar app with show, pause, manual ideating, temporary 15-second position unlock, reposition, diagnostics, and quit controls.
  - Corrected the XcodeGen resource phase after built-bundle inspection caught that the first successful compile did not embed the atlas or JSON contract.
- Decisions: keep animation playback and live agent events outside this checkpoint. Use menu buttons with explicit checkmark/lock labels because Swift 6.3.3 crashed during IR generation for the original closure-based `Toggle` bindings.
- Verification:
  - `swift test` passes five tests covering state-enum stability, ambient corner-sit inventory, bottom/left/right Dock detection, and panel clamping.
  - `xcodegen generate` succeeds and the unsigned arm64 Debug app passes `xcodebuild` with `CODE_SIGNING_ALLOWED=NO`.
  - The built app contains `mascot-atlas@2x.png` and `atlas-contract.json` under `Contents/Resources`.
  - A three-second direct launch smoke test stayed alive without startup output or a resource-load crash, then was stopped intentionally.
- Risks or blockers: manual focus, show/hide/quit, Dock orientation, auto-hide, and multi-display behavior still require visual QA. Release signing and notarization remain Phase 6 work.
- Next: complete the issue #5 manual window matrix, then add the animation controller and state-driven row playback without changing the frozen atlas.

### 2026-07-28 — Native scaffold session closure

- Objective: reconcile the repository and ledger, preserve the verified scaffold checkpoint, and end the session with an exact restart point.
- Completed:
  - Confirmed the atlas approval, implemented package layout, Phase 2 progress, issue map, verification matrix, risks, and handoff all match the repository evidence.
  - Confirmed the native scaffold is committed at `609f151` (`Scaffold native macOS mascot app`).
  - Left the manual issue #5 display and focus matrix as the next bounded milestone; no animation-controller or provider-integration work was started implicitly.
- Decisions: end this session at the static native checkpoint. Keep revision 2 frozen and do not expand scope during the next manual window-validation pass.
- Verification: `git status --short --branch` was clean before this ledger-only closure update; `main` was four commits ahead of `origin/main`, with `609f151` at `HEAD`. The earlier five Swift package tests, unsigned Debug Xcode build, embedded-resource inspection, atlas validation, and startup smoke test remain the acceptance evidence for the checkpoint.
- Risks or blockers: no implementation blocker. The unpushed local commits must be preserved; manual multi-display, Dock-orientation, auto-hide, focus, show/hide, and quit validation remains incomplete.
- Next: start from issue #5 and execute the manual window matrix before implementing state-driven animation playback.

### 2026-07-28 — Issue #5 live bottom-Dock validation

- Objective: resume from the static scaffold checkpoint and execute the available portion of the manual Dock-edge window matrix before animation work.
- Completed:
  - Re-ran the package suite and unsigned Debug Xcode build with the real macOS toolchain.
  - Launched the app on the single built-in `1280x832`-point Retina display with a bottom Dock and inspected the full desktop, native `48x56` panel, and Dock-adjacent crop.
  - Confirmed background launch leaves ChatGPT/Codex frontmost, the sprite renders sharply at native size, the panel is transparent, and its frame remains above the Dock hit region.
  - Fixed “Reposition on Current Display” to prefer the panel's actual screen instead of always selecting `NSScreen.main`.
  - Fixed the 15-second automatic position relock so it updates the observable menu state and diagnostics as well as the panel flags.
  - Moved the static bottom-Dock start from screen center to the left third of the safe lane after native QA showed the center overlapping Codex's approval bar.
  - Enlarged the panel and nearest-neighbor sprite presentation from `48x56` to `72x84` points at the owner's request.
  - Replaced the visible eight-point gap with a 7.5-point transparent-edge inset, placing the character baseline directly on the Dock boundary while keeping opaque pixels outside Dock hit targets.
  - Added AppKit regression coverage for panel visibility, non-key/non-main, click-through defaults, temporary interaction unlock, timer-driven relock, and relock state reporting.
- Decisions: keep issue #5 open and do not start state-driven animation. Use the left third as the safer static bottom-Dock start; require a separate pointer/control-avoidance decision before issue #11 enables full-width strolling.
- Verification:
  - `swift test` passes eight tests.
  - `xcodebuild -project DesktopMascot.xcodeproj -scheme DesktopMascot -configuration Debug -derivedDataPath .build/xcode-derived CODE_SIGNING_ALLOWED=NO -quiet build` exits successfully.
  - AppKit reported one `1280x832`-point screen, a `1280x736` visible frame beginning at `y=66`, and `2.0` backing scale; window inspection reported a `48x56` Dock Pet panel.
  - A background `open -g` relaunch left `ChatGPT` frontmost. Final window inspection reported `72x84+390+690`; native visual QA showed the foot baseline on the Dock top edge and the larger sprite clear of Dock icons.
- Risks or blockers: the current environment has one display and a bottom Dock, so left/right Dock and multi-display behavior cannot be honestly marked manually verified. Menu automation is blocked because `osascript` lacks Accessibility permission. Full-width strolling will later need pointer/control avoidance rather than assuming every point in the lane is visually safe.
- Next: ask the owner to exercise show/hide, drag/relock, quit, left/right Dock, auto-hide, and any available multi-display cases before closing issue #5.

### 2026-07-28 — Interactive roaming prototype

- Objective: respond to owner QA by enlarging the mascot again, adding visible motion and random offline rests, keeping it at the bottom across app/tab changes, and making the mascot directly clickable and draggable.
- Completed:
  - Enlarged the presentation from `72x84` to `96x112` points, giving the frozen 80-pixel body an apparent 80-point footprint without modifying atlas pixels.
  - Updated the transparent Dock inset from 7.5 to 10 points so the larger sprite baseline remains aligned with the Dock boundary.
  - Added `AmbientAnimationController.swift`, which caches atlas frames, honors row timings, walks left/right along bounded bottom-lane coordinates, reverses at screen bounds, and enters random offline rest phases.
  - Added menu-bar roaming control. Manual ideating and pause remain authoritative over ambient playback.
  - Made the non-activating panel directly interactive. A click opens Pause/Resume, Stop/Resume Roaming, Close Mascot, and Quit options; right-click opens the same options.
  - Added always-available drag/drop. Completing a drag stops roaming and keeps the manual position; Resume Roaming repositions to and restarts the bottom lane.
  - Regenerated the Xcode project so the new app source is reproducibly included.
- Decisions: the owner's explicit interaction request supersedes the earlier passive click-through/temporary-unlock contract. Pull only ambient atlas playback forward from issue #11; do not fabricate working/waiting state detection before the event bridge and adapters exist.
- Verification:
  - `swift test` passes eight tests, including non-activating interactive-panel invariants, panel visibility, direct-click event routing, bottom/left/right visual alignment, and clamping.
  - `xcodegen generate` succeeds.
  - The unsigned Debug `xcodebuild` succeeds with `CODE_SIGNING_ALLOWED=NO`.
  - Live inspection reported a `96x112` panel aligned at `y=664`; successive samples moved from `x=419` to `x=485` in two seconds.
  - Native visual inspection observed both directional walking and the random offline rest/effect state at the bottom edge.
- Risks or blockers: direct click-menu and physical drag feel still require owner hands-on QA because external UI automation lacks Accessibility permission. Current roaming is ambient/no-signal behavior and will continue even during real provider work until issues #6–#9 connect lifecycle events. Pointer/control avoidance and Reduced Motion remain open.
- Next: owner-test click options and drag/drop. Then implement the local event decoder, reducer, and bridge so authoritative working/waiting/completion signals replace ambient behavior when available.

### 2026-07-29 — Hidden-app reopen repair

- Objective: reproduce and fix the report that Dock Pet would not reopen after the owner believed it had quit.
- Completed:
  - Found the original Dock Pet process still alive for more than eleven hours with no visible mascot window; opening the bundle therefore targeted the hidden process instead of starting a new one.
  - Added `applicationShouldHandleReopen` to restore the panel and resume its animation timer whenever LaunchServices reopens the existing accessory app.
  - Renamed the direct action from “Close Mascot” to “Hide Mascot” so it cannot be confused with the separate “Quit Dock Pet” action.
  - Rebuilt, terminated the stale hidden process, and launched the corrected build.
- Decisions: Hide keeps the menu-bar app running and must be reversible by reopening the bundle or choosing Show Mascot. Quit terminates the process and a later launch starts a fresh instance.
- Verification:
  - Unsigned Debug `xcodebuild` succeeds.
  - The stale process was replaced by a fresh process and window inspection reported a visible `96x112` Dock Pet panel.
  - The public `NSRunningApplication.hide()` API cannot hide this accessory app externally (`false`), so the exact Hide-menu-to-reopen path still requires owner hands-on confirmation.
- Risks or blockers: external UI automation still lacks Accessibility permission, preventing an automated click of Hide Mascot. Owner retest is required, but the missing reopen lifecycle handler that caused the failure is now implemented.
- Next: owner selects Hide Mascot, then reopens the app bundle and confirms the panel returns; separately verify Quit Dock Pet removes the process and a fresh launch returns it.

### 2026-07-29 — Directional playback and drag-cliff repair

- Objective: fix the owner's report that the mascot appeared left-facing, showed no walking gait, and lacked a hanging/cliff motion during drag.
- Completed:
  - Diagnosed a vertical atlas-cropping inversion: runtime `offline` displayed `sit-shake-left`, `walk-right` displayed `ideating`, and `walk-left` displayed `working`, causing seated sprites to slide instead of walk.
  - Corrected `SpriteAtlas` to treat contract row indices as top-origin coordinates.
  - Added a pixel-equality regression test comparing runtime crops with the frozen files for eight representative rows.
  - Changed ambient direction selection to alternate after each offline rest and still reverse at lane bounds, rather than repeating one direction until crossing the screen midpoint.
  - Reduced walking speed from 34 to 24 points per second so contact/passing gait frames remain visible instead of reading as sliding.
  - Added drag-begin and drag-end callbacks. Active dragging now plays the appropriate approved `sit-shake-left/right` ledge animation as the requested cliff-edge/dangling motion; dropping stops roaming at the manual position.
  - Changed drag tracking to use each mouse event's window coordinate converted to screen space and added synthetic drag lifecycle coverage.
- Decisions: reuse the owner-approved directional ledge/leg-shake rows for drag hanging rather than revise the frozen atlas. No image generation or atlas revision is required.
- Verification:
  - `swift test` passes ten tests without warnings.
  - `python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png` passes; atlas pixels remain unchanged.
  - Three successive corrected native captures show distinct right-facing contact, passing, and stride frames.
  - Correlated live samples show x increasing with `walk-right` pixels and, after the next rest, x decreasing with `walk-left` pixels.
  - The unsigned Debug Xcode build succeeds.
- Risks or blockers: the drag lifecycle and hanging-row selection are automated, but the owner's physical drag feel still requires hands-on QA. The sit-shake row reads as seated/dangling at a ledge; if the owner wants a two-handed suspended hang instead, that requires an explicit revision 3 art change.
- Next: owner verifies both walk directions, visible gait, and cliff-edge drag motion in the relaunched app.

### 2026-07-29 — Interactive prototype session closure

- Objective: reconcile the completed prototype changes, verification evidence, and exact restart point, then end the session without beginning the agent bridge.
- Completed:
  - Confirmed the current ledger records the 2x presentation, bottom alignment, ambient walk/offline controller, direct click menu, drag/drop, hide/reopen repair, atlas-row correction, alternating direction, and drag-cliff behavior.
  - Confirmed the final corrected Dock Pet process is running from the Debug bundle with a visible `96x112` panel.
  - Reconciled the verification matrix, risk register, decision log, dated session history, and next-session handoff.
- Decisions: close this implementation session at the owner-QA gate. Do not begin the local event bridge or revise atlas art implicitly.
- Verification: ten Swift package tests pass without warnings; the unsigned Debug Xcode build succeeds; atlas revision 2 validates; `git diff --check` passes.
- Risks or blockers: changes remain uncommitted in a worktree where `main` is five commits ahead of `origin/main`. Owner hands-on QA and provider lifecycle integration remain open.
- Next: resume with owner feedback on gait, drag-cliff feel, and hide/reopen. If accepted, implement issues #6 and #7 before provider adapters.

### 2026-07-29 — Dedicated cursor-hanging animation

- Objective: replace the temporary seated cliff-edge drag pose with a new one-handed hanging animation that visibly attaches to the cursor without a cliff.
- Completed:
  - Generated a six-frame horizontal pixel-art source strip using the frozen chibi identity and the supplied pose reference; promoted it to `art/animation/sources/hanging-row.png`.
  - Added deterministic top-grip normalization, a fixed `(48, 4)` hanging anchor, validator coverage, six production cells, QA sheets, a motion GIF, and atlas revision 3 at `768x1568`.
  - Integrated the `hanging` state into the frame cache and drag lifecycle.
  - Changed panel drag geometry so the raised-hand grip at AppKit panel point `(48, 108)` remains under the cursor throughout dragging.
  - Extended runtime pixel-equality and drag-geometry tests and rebuilt the app with the revision 3 atlas and contract embedded.
- Decisions: hanging is a separate interaction-only state; the approved Dock-corner sit-shake rows remain available for ambient behavior and are no longer reused during drag.
- Verification: hanging frame-row validation passes; the complete atlas validates; full light/dark and silhouette QA regenerated; all ten Swift package tests pass; unsigned Debug Xcode build succeeds; bundled atlas hash matches the workspace atlas; `git diff --check` passes.
- Risks or blockers: physical drag feel and the perceived snap from the clicked body point to the raised-hand cursor anchor require owner hands-on QA.
- Next: owner tests dragging from several mascot body points and confirms the swing timing and cursor attachment feel.

### 2026-07-29 — Claude Code maintainer handoff

- Objective: transfer the complete project context, assets, operating procedures, and next-work sequence to Mr. C (Claude Code) so development can continue without reconstructing prior decisions.
- Completed:
  - Added root `CLAUDE.md` with mandatory session startup, project invariants, safety boundaries, and current priorities.
  - Added `docs/HANDOFF.md`, `docs/DEVELOPMENT.md`, `docs/ARCHITECTURE.md`, `docs/ASSET_PIPELINE.md`, and `docs/QA_CHECKLIST.md`, plus a documentation index.
  - Documented the uncommitted worktree, five unpushed local commits, implemented prototype behavior, asset ownership, revision 3 geometry, reproducible commands, planned event architecture, known risks, and ordered first-hour/next-milestone actions.
- Decisions: keep `DesktopMascot.md` authoritative for evolving status and history; use focused documents as operational guides; make `CLAUDE.md` the automatic Claude Code entry point.
- Verification: documentation paths and referenced repository files were checked against the current tree; commands reflect the passing 2026-07-29 package/atlas/build baseline; `git diff --check` is required before closure.
- Risks or blockers: documentation cannot replace owner hands-on QA or preserve the external original owner-source path on another machine. In-repository promoted production assets remain sufficient for continued atlas work.
- Next: Mr. C reads `CLAUDE.md` and `docs/HANDOFF.md`, preserves the dirty worktree, runs the baseline, records hanging QA, then starts the event decoder/reducer milestone.

### 2026-07-29 — Maintainer onboarding and local event decoder

- Objective: take over the project as Mr. C, verify the documented baseline against the real repository, preserve the uncommitted prototype work, and implement the smallest useful slice of the Phase 3 event system without touching provider adapters.
- Completed:
  - Read `CLAUDE.md`, `docs/HANDOFF.md`, this ledger in full, and all four procedure documents; inspected `git status --short --branch` and `git log --oneline --decorate -12`.
  - Ran the full documented read-only baseline and confirmed every documented claim reproduces.
  - Preserved all 25 modified files and 8 untracked paths, then recorded them as deliberate checkpoint commit `46bd324` on local `main`. Nothing was pushed, reset, cleaned, or discarded.
  - Added `MascotCore/EventEnvelope.swift`: `EventProvider`, `AgentEvent`, `EventDetail`, a validated opaque `SessionID`, and the six-field `EventEnvelope`.
  - Added `MascotCore/EventDecoder.swift`: `EventDecoderLimits`, a payload-content-free `EventDecodingError`, a 4 KB pre-parse payload ceiling, allowlist checks, RFC 3339 parsing with and without fractional seconds, and injected-clock skew bounds of 120 seconds ahead and 3600 seconds behind.
  - Added 21 decoder fixtures covering valid events, every declared event and detail value, idempotence, discarded forbidden fields, the exact allowlisted field set, payload-free errors, unknown version/provider/event, malformed and truncated JSON, missing fields, oversized payloads, path-like and oversized session IDs, unparsable timestamps, skew boundaries on both sides, and unknown-detail discard.
  - Reported four documentation-versus-code discrepancies and recorded them in the risk register.
- Decisions: see the seven event-model entries appended to the decision log. No transport, session registry, reducer, app wiring, or provider adapter was written; `project.yml` and the atlas were not touched.
- Verification:
  - `python3 tools/validate_animation_atlas.py --contract-only` and `--atlas art/animation/mascot-atlas@2x.png` pass.
  - `swift test` passes **31 tests** with no warnings, up from the documented baseline of 10.
  - The unsigned Debug `xcodebuild` succeeds.
  - The bundled atlas hash matches the workspace atlas (`9475bf6d…`) and `cmp` reports the bundled contract byte-identical.
  - `git diff --check` passes.
  - One self-inflicted test defect was found and fixed during the run: the payload-free-error fixture originally used a secret string that is a *valid* opaque session ID, so it decoded instead of throwing.
- Risks or blockers: the cursor-hanging drag feel is still unverified by the owner and remains the stated gate; the side-Dock roaming lane and the Hide/Show position reset both need an owner decision; `main` is now six commits ahead of `origin/main` and still unpushed.
- Next: obtain the owner's hanging-drag verdict and the two behavior decisions, then implement `SessionRegistry` with heartbeat expiry on an injected monotonic clock, followed by `MascotStateReducer` with the documented priority order.

### 2026-07-29 — Maintainer session closure and first publish

- Objective: close the maintainer onboarding session, reconcile the ledger with the repository, and publish the accumulated local history at the owner's explicit direction.
- Completed:
  - Confirmed the ledger, risk register, verification matrix, decision log, and handoff match the code and the recorded evidence.
  - Published `main` to `origin/main` on the owner's explicit instruction. This is the first push since `26d7988`; it moves seven commits, including the previously unpushed art, scaffold, revision 3, and event-decoder work.
  - Left repository visibility unchanged. `Mr-Shine09/desktop-mascot` remains private.
- Decisions: end the session at the owner-QA gate. No session registry, reducer, transport, or provider adapter was started, and the atlas remains untouched.
- Verification: 31 Swift package tests pass with no warnings; atlas contract and full atlas validate; the unsigned Debug build succeeds; the bundled atlas hash and contract match the workspace; `git diff --check` passes; the worktree is clean at closure.
- Risks or blockers: three owner decisions remain open and are the gate on the next milestone — the physical cursor-hanging drag verdict, side-Dock roaming behavior, and whether Hide/Show should preserve a manually dragged position. None of these can be answered by automation; external UI automation still lacks Accessibility permission.
- Next: collect the three owner answers, then implement `SessionRegistry` with heartbeat expiry on an injected monotonic clock, followed by `MascotStateReducer` using the documented priority order. Do not start provider adapters #8 and #9 before those pass.

### 2026-07-29 — Session registry and deterministic reducer

- Objective: advance issue #6 by implementing the smallest gate that does not require an owner answer — per-session state with heartbeat expiry, then the documented priority reducer — without touching transport, provider adapters, the atlas, or `project.yml`.
- Completed:
  - Re-ran the documented read-only baseline and reproduced it exactly: contract and full atlas validate, 31 package tests pass, worktree clean at `0ba5a85`.
  - Added `MascotCore/SessionRegistry.swift`: monotonic `Uptime`, `SessionActivity`, `SessionReaction`, provider-scoped `SessionKey`, privacy-bounded `AgentSession`, `SessionRegistryLimits` (120 s heartbeat, 5 s stopped grace, 3 s success, 4 s failure, 64-session cap), `IngestOutcome`, and a value-type registry with `ingest`, `sessions(at:)`, `session(for:at:)`, and `reconcile(at:)`.
  - Added `MascotCore/MascotStateReducer.swift`: `ManualOverrides`, `SleepWindow`, `MascotVisibleState`, and a reducer implementing `paused > failure-recent > waiting > working > ideating > success-recent > scheduled-sleep > idle/strolling > offline` with an injected calendar and both clocks passed in separately.
  - Added 39 fixtures across two test files covering event-to-activity mapping, duplicate idempotence, stale-event rejection, equal-timestamp arrival order, cross-provider ID collision, deterministic snapshot order, waiting persistence, heartbeat expiry boundaries at 120 s, stopped grace, reaction survival past both deadlines, capacity eviction, wake reconciliation, every priority rung, reaction boundaries at 3 s and 4 s, sleep-window hours 22:59/23:00/00:30/05:59/06:00, sleep interruption, post-reaction return to sleep, and concurrent-provider collapse.
  - Recorded ten new decision-log entries covering the two-clock split, session keying, which events may create a session, heartbeat-as-refresh, equal-timestamp acceptance, reaction survival, stopped-session presence, the registry cap, the half-open sleep window, and provider surfacing.
- Decisions: see those ten entries. Deliberately **not** done — no transport, no provider adapter, and no app wiring. Wiring the reducer into `AmbientAnimationController` now would replace owner-approved ambient roaming with a permanent `offline` state, because nothing produces events yet. That step belongs with issue #7.
- Verification:
  - `swift test` passes **70 tests** with no warnings, up from 31.
  - Two deliberate mutations were introduced and reverted to prove the fixtures have teeth: promoting `heartbeat` to `working` failed 2 tests, and disabling the stale-ordering guard failed `reorderedOlderEventsDoNotOverwriteNewerState` on all 3 of its expectations.
  - `python3 tools/validate_animation_atlas.py --contract-only` and `--atlas art/animation/mascot-atlas@2x.png` pass.
  - The unsigned Debug `xcodebuild` succeeds; bundled atlas hash still `9475bf6d…` and `cmp` reports the bundled contract byte-identical.
  - `git diff --check` passes. The four new files are untracked and nothing existing was modified except this ledger.
- Risks or blockers: the same three owner decisions are still open and still gate the window work — the physical cursor-hanging drag verdict, side-Dock roaming behavior, and whether Hide/Show preserves a manually dragged position. The typed-vocabulary risk grew rather than shrank, because the reducer now exists but nothing consumes it.
- Next: implement the same-user local Unix-domain socket transport and helper CLI (#7) on top of `EventDecoder`, then wire `MascotVisibleState` into animation selection with debounce, preserving manual pause and ideating. Do not start adapters #8 and #9 first.

### 2026-07-29 — Local event transport and helper CLI

- Objective: implement issue #7 — the same-user local socket transport and the helper CLI — on top of the tested decoder and reducer, without touching the atlas, `project.yml`, or provider hook installation.
- Completed:
  - Committed the preceding registry/reducer work as `fda2298` at the owner's direction.
  - Added `MascotCore/EventEncoder.swift` so the helper and the decoder share one definition of the wire format instead of the helper hand-assembling JSON.
  - Added a new `MascotTransport` module: `EventFrameReader` (pure newline framing with a hard ceiling and overlong-frame recovery), `UnixSocketAddress` (validated `sun_path`), `EventSocketLocation` (owner-only paths both sides derive independently), `EventSocketServer` (`AF_UNIX` listener, `getpeereid` same-user check, per-connection framing, decode, and bounded connections), `EventSocketClient` (one-shot frame write), and `HelperCommand` (argument parsing and session hashing).
  - Added the `dockpet-event` executable target as a thin shell over `HelperCommand` and `EventSocketClient`.
  - Added 37 transport fixtures and 6 encoder fixtures: framing across split writes and byte-at-a-time delivery, empty lines, carriage returns, terminated and unterminated oversized frames, recovery after a discard, argument parsing including unknown/repeated/valueless flags, payload-free parse errors, session-hash determinism and rescue of invalid raw values, full encoder/decoder round trips, socket delivery of every event type, two frames in one chunk, malformed and oversized frame survival, injected-clock skew rejection, stale-socket replacement, live-socket protection, double-start refusal, idempotent stop, overlong-path refusal, and owner-only permissions.
  - Recorded eleven new decision-log entries covering framing, the peer check, path derivation, truncation refusal, stale-versus-live sockets, frame-level error isolation, descriptor ownership, session hashing, helper exit codes, and the closed flag set.
- Decisions: see those eleven entries. Three defects in my own first draft were found and fixed before any test ran: a blocking `accept` inside the drain loop that would have wedged the serial dispatch queue, and two paths that closed a descriptor both directly and from a dispatch cancel handler.
- Verification:
  - `swift test` passes **113 tests** with no warnings, up from 70.
  - Cross-process evidence, which no unit test covers: the built `dockpet-event` binary delivered `{"version": 1, "provider": "claude-code", "session_id": "2bb131e8…", "event": "waiting", "occurred_at": "…", "detail": "permission"}` to a listener bound to the real default path. The raw `--session` value does not appear in the frame. The path measured 86 of 103 usable bytes.
  - Helper exit codes verified directly: 0 with no listener running, 0 for `--help`, 64 for an unknown flag and for an unknown event. The unknown-flag message printed `unknownFlag` and did not echo the `/Users/oaksoekhant/secret` argument value.
  - `python3 tools/validate_animation_atlas.py --contract-only` and `--atlas …` pass; the unsigned Debug `xcodebuild` still succeeds; `git diff --check` passes.
  - The temporary Application Support directory created by the smoke test was removed afterwards.
- Risks or blockers: the same three owner decisions remain open. Two new risks are recorded — `sun_path` headroom is about 17 bytes for this user, and the helper is not yet bundled anywhere a hook could invoke it. The app still does not run the server, so the end-to-end path is proven only between the helper and a test listener.
- Next: run `EventSocketServer` inside the app, feed `SessionRegistry` and `MascotStateReducer`, and surface the result in menu-bar diagnostics *before* changing any animation. Then map `MascotVisibleState` onto animation rows with debounce, keeping ambient roaming as the no-signal behavior so the owner-approved default is not regressed. Bundle the helper and add the adapters (#8, #9) after that.

### 2026-07-29 — Dock portal summon transition

- Objective: make every mascot summon feel intentional by opening a portal at the Dock and having the pet emerge through it before normal behavior resumes.
- Completed:
  - Added a deterministic 1.25-second `PortalSummonTimeline` to `MascotAnimation`: the portal opens first, the pet emerges, the pet reaches its resting pose, and the portal then closes.
  - Layered a cyan/violet portal behind and in front of the frozen mascot sprite without changing the approved atlas or character pixels.
  - Routed initial launch, menu-bar Show, and application reopen through the summon transition while preserving paused, manual ideating, roaming, and manual-position outcomes afterward.
  - Added a Reduce Motion path that replaces portal translation/scaling with a stationary fade.
  - Added three timing fixtures covering ordering, full emergence before closure, clamping, and completion.
- Decisions: keep the portal code-rendered and local to the existing `96x112` panel; do not add an atlas row or alter frozen art for this effect. A drag that begins during the transition cancels it immediately so direct interaction remains responsive.
- Verification: 116 Swift package tests pass; the unsigned Debug Xcode build succeeds; atlas contract and pixels remain unchanged; `git diff --check` passes; the Debug app launched successfully in the background. Owner visual QA of color, scale, and timing remains pending.
- Risks or blockers: the compact panel bounds intentionally clip the pet below the portal during emergence. The exact perceived alignment with different Dock configurations still needs hands-on QA alongside the existing display matrix.
- Next: owner hides and shows the mascot (and reopens the running app) to approve the portal timing and Dock alignment, then resume the event-server app wiring milestone.

## Next-session handoff

1. Read this file in full.
2. Treat `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` as the frozen base; never present another native tall variant as viable.
3. Treat atlas revision 3 as the current candidate: 14 rows, `768x1568`, with the new six-frame `hanging` row at index 13 and a `(48, 4)` top grip anchor.
4. `main` was published to `origin/main` at the owner's direction and is level with it as of `0ba5a85`. The registry/reducer commit `fda2298` and the transport commit that follows it are local and **unpushed**. Do not push without the owner's explicit direction.
5. Treat the current presentation as `96x112` points with a 10-point transparent Dock inset. The frozen atlas itself remains unchanged.
6. Ask the owner to test dragging from several body points and verify that the raised hand remains under the cursor while the body swings left/center/right; also retain the broader click, reopen, relaunch, and display-matrix QA.
7. Preserve the honest capability boundary: portal summon and ambient random walking/offline playback are implemented, but neither knows whether ChatGPT or Claude is working. The envelope, decoder, registry, reducer, transport, and helper all exist and are tested, but **the app itself still runs none of them** — it neither listens on the socket nor consumes reducer output, and no provider hook can reach the helper. The next steps are app wiring, then bundling the helper, then adapters #8 and #9. Until then, do not describe Dock Pet as reflecting real agent activity.
8. Treat `EventEnvelope` as the privacy boundary and `EventDecoder` as fail-closed. Do not widen the envelope, relax the `SessionID` charset, or copy payload text into an error without a recorded product decision. `AgentSession` extends the same boundary and must gain no new field either. Keep the two clocks separate as well: wall-clock `occurredAt` orders events inside one session, monotonic `Uptime` drives expiry and reactions, and both stay caller-injected so fixtures remain deterministic. On the transport side, keep the helper's flag set closed, keep the session value hashed inside the helper, keep the `getpeereid` same-user check, and keep the socket path derived rather than passed in.
9. Resolve the four onboarding discrepancies in the risk register. Side-Dock roaming and the Hide/Show position reset still need owner decisions. The unused-vocabulary risk is now the reducer-wiring task: `MascotVisibleState` must become the single typed source of visible state, replacing the raw atlas row strings in `AmbientAnimationController` — not growing beside them.
10. Do not mistake direct `open` activation for automatic panel focus theft; the verified background launch (`open -g`) left ChatGPT/Codex frontmost. Do not use `open -j`, which intentionally hides the app.
11. Update this ledger before ending the next session.
12. Use `CLAUDE.md` and `docs/HANDOFF.md` as the maintainer onboarding entry points; keep them synchronized when architecture, commands, or asset contracts materially change.

## Documentation sources

- [Official Codex hooks documentation](https://learn.chatgpt.com/docs/hooks)
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Instagram reference post](https://www.instagram.com/p/DbV-I14FKJ2/?img_index=3)
