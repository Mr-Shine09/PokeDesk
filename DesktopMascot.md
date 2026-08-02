# Desktop Mascot

> Living implementation ledger. Read this entire file at the start of every project session and update it before ending the session.

## Project snapshot

| Field | Current value |
| --- | --- |
| Project | Desktop Mascot for macOS |
| Owner | [Mr-Shine09](https://github.com/Mr-Shine09) |
| Started | 2026-07-28 |
| Last updated | 2026-08-01 |
| Status | Feature-complete for 0.1 and verified against a **real Claude Code session**: provider hooks drive the bundled helper, which feeds the socket server, the reducer, and animation. Installed durably at `~/Applications/Dock Pet.app`. The mascot appears only when summoned, and the menu bar carries the full control surface including state preview |
| Current gate | Owner hands-on QA. The dismiss/quit transition and its two cues were approved on 2026-08-01 (happy path only). What remains, in priority order: **listen to the two reaction cues** (still never heard by anyone — measured non-silent is not the same as correct), drop the mascot from several heights to confirm the drop-and-roam feel, then the display matrix, which now has a known multi-display clamping defect waiting for it. Alongside it, one owner decision is still outstanding: the **animation speed control** has been in 0.1 scope since 2026-07-28, was never built, and was never dropped — build it or strike it. Launch-at-login and distribution are closed by owner decision |
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
- Transparent, non-activating floating window in a bounded strolling lane immediately above the Dock. *Beside* the Dock left with the removal of Dock-edge tracking (2026-07-30); the lane is bottom-anchored by default, and a dropped mascot roams at the height it landed at.
- Menu-bar controls: summon/dismiss, pause animation, manual ideating state, reposition, reaction-sound mute, state preview, hook-setup snippet, diagnostics, quit. **No launch at login** (owner decision, 2026-07-30).
- States: `offline`, `idle`, `working`, `ideating`, `waiting`, `success`, `failure`, `sleeping`, `paused`.
- Idle animation variants include directional strolling and directional sitting on a small chair with one lower leg shaking.
- Reliable Codex and Claude Code event adapters based on supported lifecycle hooks.
- A documented capability boundary for ordinary ChatGPT app/browser activity; no unsupported scraping or fabricated fine-grained states.
- Local-only event transport.
- Multiple simultaneous agent sessions reduced to one deterministic mascot state.
- Reduced Motion support. Honored by the portal summon transition only; broader coverage is open under [#11](https://github.com/Mr-Shine09/desktop-mascot/issues/11).
- An animation speed control. **Never built, and never explicitly dropped** — see the open scope question below. This is the only 0.1 scope line with no implementation and no decision behind its absence.
- Short success and failure reaction cues (added 2026-07-30; this reverses an original non-goal, see below).
- No network dependency after installation.

### Explicit non-goals for 0.1

- Windows or Linux.
- iOS companion app.
- Reading prompts, source code, terminal output, repository names, or transcripts.
- Injecting into or modifying the Dock process.
- Private macOS APIs.
- General-purpose pet marketplace or arbitrary user-imported sprites.
- Cloud sync, user accounts, analytics, or remote control.
- Cursor-following, free desktop roaming, speech, or notifications. **Sound effects were on this list and no longer are**: two short reaction cues for `success` and `failure` were added on 2026-07-30, muted by a persisted menu toggle and silent while dismissed. Nothing else in the app makes sound. "Free desktop roaming" still means what it always did — the mascot walks a bounded horizontal lane; letting the user choose that lane's height by dropping it is not free roaming.
- App Store distribution — and, since 2026-07-30, **any** distribution. Notarization needs a Developer ID certificate, which the owner classified as a purchase rather than an engineering task. An ad-hoc signed local install is the finished state for 0.1.

### Scope changes since the original contract

The list above is the current contract. It differs from the 2026-07-28 original in five places, recorded here because a definition of done that drifts silently is worse than one that is merely out of date. Four are owner decisions; one is an unanswered question.

| Change | Direction | Date | Basis |
| --- | --- | --- | --- |
| Launch at login removed | Narrowed | 2026-07-30 | Owner decision; nothing should start the app for you |
| Placement beside the Dock removed | Narrowed | 2026-07-30 | Dock-edge tracking was buggy and was deleted rather than fixed |
| Distribution and notarization removed | Narrowed | 2026-07-30 | Owner decision; a certificate purchase, not engineering |
| Reaction cues added | **Widened** | 2026-07-30 | Owner asked for a success cue; reverses the original sound-effects non-goal |
| Animation speed control | **Undecided** | — | In scope since 2026-07-28, never implemented, never dropped |

**Open scope question, for the owner:** the animation speed control is the only 0.1 commitment that is neither built nor consciously abandoned. `grep -ri speed` across the Swift sources returns nothing, and `Preferences` stores only `roaming` and `reactionSoundsMuted`. It should either be built or struck from scope; leaving it unanswered is what lets 0.1 be "finished" and incomplete at the same time. Until it is answered, treat 0.1 as feature-complete *except* for this line.

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
| Sit-shake right/left | Ambient idle on a chair | 6 each | Sit on a small freestanding chair and casually swing one lower leg |
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

Completed on 2026-07-28: the owner selected a 40-point footprint, rejected every native tall treatment, and explicitly ordered the secondary chibi fallback. `mascot-base-chibi-40pt-at2x-80px-final.png` is frozen as the base. The owner approved the 13-row revision 2 atlas, including the requested status effects and directional corner-sit clips. On 2026-07-29 the owner's explicit hanging request authorized revision 3, which added one dedicated cursor-hanging row and top grip anchor; the later chair request authorized revision 4, which replaces the two sit-shake ledges without changing atlas geometry or timing. The current geometry, row order, palette, timing, anchors, acceptance rules, and QA outputs live in `art/animation/ATLAS.md` and `art/animation/atlas-contract.json`.

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
| [#3 Specify and produce the animation-ready sprite atlas](https://github.com/Mr-Shine09/desktop-mascot/issues/3) | 1 / 5 | Closed 2026-07-30: every row owner-approved, contract and atlas validate |
| [#4 Scaffold the native SwiftUI/AppKit macOS app](https://github.com/Mr-Shine09/desktop-mascot/issues/4) | 2 | Closed 2026-07-30: Debug and Release both build; SwiftPM package tests accepted as unit-test evidence; no Xcode UI test target exists, logged as a deliberate 0.1 gap |
| [#5 Implement the transparent Dock-edge mascot window](https://github.com/Mr-Shine09/desktop-mascot/issues/5) | 2 | Open, rescoped 2026-07-30: mascot now always anchors to the screen's bottom edge; Dock-edge tracking removed rather than fixed. Automated fixtures pass; the hands-on display/orientation matrix in `docs/QA_CHECKLIST.md` remains |
| [#6 Implement the mascot state model and reducer](https://github.com/Mr-Shine09/desktop-mascot/issues/6) | 3 | Closed 2026-07-30 via [PR #14](https://github.com/Mr-Shine09/desktop-mascot/pull/14), merged to `main` |
| [#7 Build the private local event bridge and helper CLI](https://github.com/Mr-Shine09/desktop-mascot/issues/7) | 3 | Complete as of 2026-07-30 pending GitHub closure: transport and helper implemented and tested, the app runs the server, reduced state drives animation and is owner-verified, and the helper is bundled in the app and invocable by absolute path |
| [#8 Add the Codex lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/8) | 4 | Implemented 2026-07-30 as `--hook --provider codex`, with mapping, privacy, and decoder fixtures. Awaiting a live Codex session before closure |
| [#9 Add the Claude Code lifecycle-hook adapter](https://github.com/Mr-Shine09/desktop-mascot/issues/9) | 4 | Implemented 2026-07-30 as `--hook --provider claude-code`, with mapping, privacy, and decoder fixtures. Awaiting a live Claude Code session before closure |
| [#10 Build menu-bar settings and integration management](https://github.com/Mr-Shine09/desktop-mascot/issues/10) | 2 / 4 | Open |
| [#11 Integrate animations, transitions, and Reduced Motion](https://github.com/Mr-Shine09/desktop-mascot/issues/11) | 5 | In progress; ambient playback and the portal summon transition merged via PR #15, and reduced state now selects the row with a dwell as of 2026-07-30. Broader Reduced Motion coverage beyond the summon transition remains open |
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
| Chair sit-shake rows | Six frames each direction, stable chair/torso, one swinging leg, mirrored temporal order | Revision 4 passes deterministic and internal native-size visual QA on 2026-07-29; owner review pending |
| Retina atlas assembly | Exact current grid, used/unused occupancy, palette, alpha, transparent RGB, and cell guards | **Current: revision 6, 16 rows, `768x1792`, passes the validator on 2026-08-01.** Revision 4 `768x1568` passed on 2026-07-29; owner chair and drag QA pending |
| Dismiss transition | Ninja seal row, pixel smoke row, deferred panel hide, quit farewell, and the two transition cues | Rows and timeline pass deterministic validation and 184 package tests on 2026-08-01; **owner watched and approved summon/dismiss/quit the same day, happy path only.** Reduce Motion, re-summon mid-poof, dismiss-while-paused, and the second-Quit escape hatch are unexercised |
| App icon | Rendered from the frozen base, full macOS slot set, present in the built bundle | Renders correctly when extracted from the built bundle on 2026-08-01; **not yet confirmed in Finder** |
| Cursor-hanging row | Six frames, fixed top grip, frozen palette, binary alpha, no cliff/ledge, and cursor-attached drag geometry | Passed deterministic art validation, runtime pixel equality, drag geometry test, and Debug build on 2026-07-29; physical feel pending |
| Native app scaffold | Generated Xcode project, modular package, embedded atlas resources, static nearest-neighbor render, and startup/reopen smoke tests | Passed initial scaffold on 2026-07-28; fresh Debug relaunch restored a visible `96x112` window on 2026-07-29 |
| Window geometry | Automated fixtures plus manual multi-display matrix | Rescoped 2026-07-30: `DockGeometry` is bottom-anchored only and has no Dock-edge inference, but later the same day `WindowCoordinator.settleAfterDrop()` gained a sanctioned override so a dropped mascot roams at the height it landed at, with `reposition()` the one way back to the default lane. Thirteen tests pass (`swift test --filter MascotWindowTests`), covering placement, clamp-with-guard, visibility, manual-position preservation across Hide/Show, non-activating interaction, click routing, drag begin/end routing, a drop that keeps both axes, an off-edge drop that clamps, roaming that preserves a dropped height, and reposition restoring the lane. The multi-display matrix is still pending, and a dropped height interacting with a display change is new untested surface |
| Atlas runtime mapping | Every declared row crops to the matching frozen frame pixels | Passed 2026-07-29 for offline, idle, working, ideating, both walk directions, both chair sit rows, and hanging; extended 2026-08-01 to `hand-sign`. `poof` is covered by the atlas validator but not by the pixel-equality test |
| Ambient animation | Atlas timing, directional movement, alternating walk direction, random offline rests, and bounded bottom-lane motion | Corrected live samples show distinct right gait while x increases and left gait while x decreases; offline transition also visually verified |
| Portal summon | Portal opens before mascot emergence, mascot is fully visible before closure, hide/show and reopen replay the transition, and Reduce Motion avoids translation/scale motion | Passed three deterministic timeline fixtures inside a 116-test package suite and an unsigned Debug build on 2026-07-29; owner visual QA pending |
| Event envelope and decoder | Version/provider/event allowlists, opaque session-ID validation, payload ceiling, RFC 3339 parsing, injected-clock skew bounds | Passed 2026-07-29: 21 decoder fixtures inside a 31-test package suite |
| State reducer | Unit tests for ordering, duplicates, expiry, concurrency | Passed 2026-07-29: 39 registry/reducer fixtures inside a 70-test package suite, covering the full documented priority order, duplicate idempotence, stale-event rejection, heartbeat expiry boundaries, bounded reaction boundaries, stopped grace, capacity eviction, wake reconciliation, sleep-window hours, and concurrent providers. Two mutation checks confirmed the heartbeat-refresh-only and stale-ordering guards are genuinely enforced. Not yet wired to the app |
| Privacy | Forbidden fields absent from storage and diagnostic output | Passed 2026-07-30 across all three layers: forbidden keys are discarded at the decoder, `AgentSession` stores only the envelope's allowlisted fields, and the menu-bar diagnostics carry counts, a session count, and one coarse state. Rejection reasons are deliberately dropped at the bridge, so no caller-controlled byte can reach the interface |
| Local event transport | Framing fixtures, same-user peer check, owner-only permissions, malformed/oversized frame survival, socket lifecycle, and a cross-process helper run | Passed 2026-07-29: 37 transport fixtures inside a 113-test package suite, plus a cross-process run in which the real `dockpet-event` binary delivered a hashed-session `waiting` event to a listener on the real default path. Wired into the running app on 2026-07-30 |
| Reduced state drives animation | Every state maps to a declared row, only chilling states stroll, rapid flips do not thrash, manual pause and ideating travel through the reducer | Passed 2026-07-30: 13 `AnimationSelector` fixtures inside a 143-test suite. Owner-verified live the same day against a process confirmed newer than the binary — `active` stopped the pet at the computer, `completed` played the success sparkle then returned it to strolling, Pause stopped it instantly, and Manual Ideating held the Thinker pose. The 120-second expiry boundary stays fixture-only, since idle and offline both stroll and are not visually distinguishable |
| Event path inside the app | Server starts at launch, delivered events reach reduced state, counters and status appear in the menu bar, socket is removed on quit | Passed 2026-07-30 for the transport and pipeline layers: 9 `EventPipeline` fixtures and 3 fixtures running a real socket server into a real pipeline, inside a 130-test suite. Live: the launched Debug app bound `events.sock` at `0600`, accepted a five-event `dockpet-event` sequence plus a malformed frame without dying, and unlinked the socket on quit. Owner-verified on screen 2026-07-30: with the app running and one `dockpet-event --provider claude-code --event active` delivered, the menu bar read `Event socket: listening • 1 accepted • 1 session` and `Reduced state: Working (claude-code) — not driving animation yet` |
| Provider adapters | Fixture tests and live smoke tests | Passed 2026-07-30. 23 adapter fixtures in a 172-test suite, including a realistic `PreToolUse` payload proving no path, directory, command, or credential reaches the envelope. **Live smoke test passed**: a real `claude -p` session produced `started -> active -> active(tool) -> active(tool) -> completed -> stopped` in order, captured on the production socket path, with two concurrent sessions staying distinct and no private content in any frame. Repeated successfully through the installed `~/Applications` bundle. `waiting` and `failed` stay fixture-only (the run pre-approved its tool and hit no API error), and **Codex has never been run live** |
| Reaction cues | Deterministic regeneration, non-silent measurement, correct firing moment, mute toggle, and owner listening | Partial 2026-07-30. `tools/author_sound_effects.py` reproduces both WAVs byte for byte, both measured non-silent at 0.54s/0.42s, the cue is fired from `onStateAppeared` so it lands with the frames rather than ahead of them, sound is gated on `success`/`failure` plus `isVisible`, and a persisted menu toggle mutes it. **Nobody has ever heard either cue.** Measured non-silent is not the same as correct, and this is the largest unverified claim in the project — it is owner QA |
| Accessibility | Reduce Motion, pause, VoiceOver/menu-bar review | Partial 2026-07-30: menu-bar status lines carry spoken labels and every control is reachable without the mascot on screen; Reduce Motion is honored by the portal summon transition only. Not reviewed with VoiceOver actually running — that is owner QA |
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
| Multiple sessions thrash visible state | Medium | Per-session registry, priority reducer, debounce, bounded reactions | Registry, priority reducer, and bounded reactions implemented and tested 2026-07-29. The debounce at the animation boundary landed 2026-07-30 as `AnimationSelector`'s 0.75-second dwell, which holds a new state back and keeps only the newest inside one window; pause and resume bypass it deliberately. Closed |
| Cursor-following annoys or obstructs | Medium | Defer; require explicit opt-in and dedicated tests | Deferred |
| Idle animation wastes battery | Medium | Event-driven updates, suspend timers, measurable energy budget | Open |
| Generated state frames drift from the frozen identity | High | Ground every job in the frozen base, normalize deterministically, reject drift, and use native pixel editing only with explicit owner approval | Revision 2 owner-approved and frozen |
| Detached status effects crowd the face or become noisy | Medium | Reserve the upper guard area, reuse the frozen palette, keep effects compact, and review at native size on light/dark backgrounds | Revision 2 owner-approved and frozen |
| Personal likeness ships before review | Medium | Private repository until owner changes visibility | Mitigated for foundation |
| Roaming on a left or right Dock walks across mid-screen | High | Found 2026-07-29 during maintainer onboarding: `panelOrigin` centered the panel vertically for side Docks while `horizontalMovementBounds` still swept the full `visibleFrame` width. Owner decided 2026-07-30 to stop tracking Dock edge entirely rather than fix the branch; `DockGeometry` now always anchors to the screen's bottom edge | Resolved 2026-07-30 by removing the Dock-edge code path, not by fixing it. Left/right Dock-aware placement is future scope if ever revisited |
| Hide/Show discards a manually dragged position | Medium | Found 2026-07-29 during maintainer onboarding: `WindowCoordinator.setVisible(true)` repositioned unconditionally. Fixed 2026-07-30 with a `repositioning` parameter. It was first driven from `isRoaming`; since dragging stopped switching roaming off later the same day, `AppDelegate` reads `WindowCoordinator.hasManualPlacement` instead | Resolved 2026-07-30; the 176-test suite includes fixtures for the preserved case, the reset case, a drop that keeps both axes, an off-edge drop that clamps, and roaming that preserves a dropped height |
| `MascotCore` state vocabulary is unused by the running app | Medium | `AmbientAnimationController` drives animation with raw atlas row strings; `MascotState`/`AmbientAnimation` are exercised only by tests. The reducer must become the single typed source of visible state instead of growing beside the string-keyed controller | Closed 2026-07-30. `MascotStateReducer` emits typed `MascotVisibleState`, and `EventPipeline`, `AgentEventBridge`, `AppDelegate`, and `AmbientAnimationController` all consume it; the controller no longer carries pause/ideating flags of its own. The invariant that replaced the risk: anything that wants to change what the pet is doing goes through the reducer, never by setting an atlas row directly |
| The default socket path may not fit `sun_path` for every user | Medium | `AF_UNIX` allows 103 usable path bytes. The real path measured 86 bytes for an 11-character user name on 2026-07-29, leaving roughly 17 bytes of headroom, so a much longer home directory path would fail. The failure is fail-closed and explicit (`socketPathTooLong`), not a truncated bind, but the bridge would be unavailable | Open; found 2026-07-29. If it ever bites, shorten the directory or socket name rather than truncating the path |
| The helper is not installed anywhere a hook can reach | Medium | Resolved 2026-07-30: built as a native tool target and bundled at `Contents/MacOS/dockpet-event`, installed durably to `~/Applications` by `tools/install_app.sh`, and verified driving the mascot from a real Claude Code session | Closed |
| Atlas revision is tracked only in prose | Low | `atlas-contract.json` carries `schema_version` but no revision field, so no tool can assert which revision is loaded. Geometry itself validates and matches documented revision 4 | Open; low impact while one contract ships |

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
- Supersede the Dock-corner ledge art with atlas revision 4: both sit-shake rows use one small freestanding chair with a visible backrest, seat, and two grounded legs. Preserve the existing seated identity and leg-swing cadence, and continue deriving the left row by per-frame mirroring without reversing time.
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

### 2026-07-30

- Anchor mascot placement and roaming to the screen's bottom edge unconditionally; stop inferring the Dock's edge for positioning. Owner's stated reason: the Dock can be moved to any side at any time, but a screen's bottom edge cannot, so tracking the Dock buys nothing but fragility. Left/right Dock-aware placement is deferred to a future release rather than fixed in place; `DockGeometry` no longer has an edge-inference code path at all, so reviving it means restoring it from git history, not un-commenting something dormant.
- Preserve a manually dragged position across Hide/Show and application reopen instead of always repositioning to the default lane. `WindowCoordinator.setVisible` takes a `repositioning` parameter (default `true`); `AppDelegate` passes `isRoaming` as that flag, since dragging already sets `isRoaming = false`.
- Treat SwiftPM package tests as sufficient evidence for issue #4's "unit test target" criterion for the 0.1 prototype; do not add an Xcode XCUITest target now. Revisit before release packaging (issue #13) if release QA needs to exercise the compiled app process itself rather than its logic in isolation.
- Supersede "dropping stops roaming and retains the manual position" with: dragging is a placement gesture only and leaves roaming untouched. The old behavior stranded the pet in the `offline` row's dozing Z-trail with no obvious way to restart it, which read as a malfunction rather than as a placement.
- Supersede unconditional bottom-edge anchoring *for manual placement only*: the mascot now roams at whatever height it was dropped at, including above the Dock and through open air. Owner's stated reason, after rejecting a lane-snapping first implementation: it should roam wherever it is dropped. The walk cycle still only moves along X, so this buys horizontal roaming at an arbitrary height, not free 2D movement. The bottom lane remains the default placement and Reposition is the one deliberate way back to it. `DockGeometry` is untouched — this is a `WindowCoordinator` placement override, not a revival of Dock-edge inference.
- Supersede `AppDelegate` passing `isRoaming` as the `repositioning` flag with `WindowCoordinator.hasManualPlacement`. Roaming can no longer stand in for "the user placed this themselves", because dragging no longer switches roaming off; the coordinator's own record of the drop is the only reliable answer.
- Synthesize the reaction cues from committed tooling rather than sourcing audio. Every sprite in this repository is generated by a script a reviewer can read, and audio should be no different: it stays regenerable, reviewable, and free of any licensing question. Cue playback hangs off the animation controller's `onStateAppeared`, not off reduced state, so a cue cannot arrive before the frames it belongs to.

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
- Verification: 116 Swift package tests pass; the unsigned Debug Xcode build succeeds; atlas contract and pixels remain unchanged; `git diff --check` passes; the Debug app launched successfully in the background; [draft PR #15](https://github.com/Mr-Shine09/desktop-mascot/pull/15) is open for Mr. C's review. Owner visual QA of color, scale, and timing remains pending.
- Risks or blockers: the compact panel bounds intentionally clip the pet below the portal during emergence. The exact perceived alignment with different Dock configurations still needs hands-on QA alongside the existing display matrix.
- Next: owner hides and shows the mascot (and reopens the running app) to approve the portal timing and Dock alignment, then resume the event-server app wiring milestone.

### 2026-07-29 — Chair sit-shake revision

- Objective: replace the corner/ledge prop in both directional sit-shake animations with a small chair while preserving the approved mascot and leg motion.
- Completed:
  - Edited the six-frame right-facing source so every frame uses one compact freestanding chair with a visible backrest, seat, and two grounded legs.
  - Normalized the edited source to the frozen 12-color palette, binary alpha, shared baseline, and cell guard, then derived the left-facing row by per-frame mirroring with temporal order preserved.
  - Reassembled atlas revision 4 and regenerated the 1x/8x light/dark contact sheets, silhouettes, and both contract-timed sit-shake GIFs.
  - Updated the current-facing atlas contract, production prompt, animation status, verification matrix, decision log, and maintainer handoff. Historical ledge entries remain unchanged as the record of the superseded design.
- Decisions: preserve the `sit-shake-right` and `sit-shake-left` state identifiers, frame counts, timing, row order, body pose, and leg cadence. Revision 4 changes the prop concept and affected row pixels only.
- Verification: both rows and the complete atlas pass `tools/validate_animation_atlas.py`; native-size light/dark and silhouette review shows a readable chair and preserved identity; all 118 Swift package tests pass; the unsigned Debug build succeeds; the bundled atlas and contract match the workspace copies; `git diff --check` passes.
- Risks or blockers: automated checks cannot prove the chair's taste or motion feel. Owner review remains required before treating revision 4 as visually approved.
- Next: open a focused draft PR for Mr. C, then obtain owner visual approval of the chair at native size and in motion.

### 2026-07-30 — PR review, issue #6 closure, and window-geometry bug fixes

- Objective: review the two open PRs, merge what was safe, and clean up issues #3, #4, and #5 against actual evidence rather than assumption.
- Completed:
  - Read every new source file in [PR #14](https://github.com/Mr-Shine09/desktop-mascot/pull/14) rather than trusting the description; confirmed the privacy boundary, the `AF_UNIX`-only transport, the `getpeereid` same-user check, and the `sun_path` fail-closed behavior. Re-ran all 116 tests, unsigned Debug build, atlas/contract validation, and `git diff --check` locally, then fast-forwarded `main` to `2b8dfbd` (`0ba5a85..2b8dfbd`) and pushed.
  - Closed issue #6 with the evidence above; the registry and reducer are complete and tested, deliberately not yet wired to the app.
  - Reviewed [PR #15](https://github.com/Mr-Shine09/desktop-mascot/pull/15) (portal summon), retargeted its base to `main`, and posted findings: `PortalSummonTimeline` is pure and correctly clamped, Reduce Motion genuinely removes translation/scale, and pausing mid-summon still finishes the entrance before settling. Flagged two things for owner attention: `AmbientAnimationController.isVisible` now defaults to `false` and depends on `AppDelegate` calling `setVisible`, and the cyan/violet portal art sits outside the frozen 12-color palette (not a violation — the palette rule governs the atlas, not overlays — but a deliberate departure worth an explicit decision).
  - Owner approved the portal art (it was Codex-generated at their direction) and confirmed the palette departure is acceptable.
  - Verified issue #3's remaining acceptance criteria are already satisfied by prior owner-approved rows recorded earlier in this ledger, plus a fresh `validate_animation_atlas.py` pass; closed #3.
  - Verified issue #4's Release configuration builds (previously only Debug had been checked); closed #4, recording SwiftPM package tests as the accepted "unit test" evidence and the missing XCUITest target as a deliberate, logged gap rather than a silent one.
  - Read `WindowCoordinator.swift` and `DockGeometry.swift` directly rather than trusting the risk register's descriptions, and confirmed both previously flagged risks were still live in the code: `horizontalMovementBounds()` always swept the full visible-frame width regardless of Dock edge, and `setVisible(true)` always repositioned the panel, discarding a manual drag.
  - Owner decided (see Decision log) to drop Dock-edge tracking entirely rather than fix it in place: roaming and placement now always anchor to the screen's bottom edge. Rewrote `DockGeometry.panelOrigin` to a single unconditional bottom-anchored formula and deleted `DockEdge`/`inferDockEdge`. This fixes the side-Dock roaming bug as a side effect, since there is no longer a side-Dock code path to diverge from the roaming bounds.
  - While simplifying `DockGeometry`, found and fixed a related latent bug the removed branching had been masking: the horizontal/vertical clamp bounds had no guard against a visible frame narrower or shorter than the panel, which can invert the clamp range. Added the same `max(minimum, ...)` guard `WindowCoordinator.horizontalMovementBounds()` already used.
  - Fixed the Hide/Show position-reset bug: `WindowCoordinator.setVisible(_:repositioning:)` now takes a `repositioning` flag (default `true`); `AppDelegate.setVisible` passes `isRoaming`, since a manual drag already clears that flag. A dragged mascot now stays where it was left across Hide/Show and app reopen.
  - Added four new fixtures (two `DockGeometryTests`, two `WindowCoordinatorTests`) and rewrote the two that exercised the deleted edge-inference branches. Package suite: 118 tests, up from 116.
- Verification: 118 Swift package tests pass; unsigned Debug and Release `xcodebuild` both succeed; atlas contract and full atlas validate; bundled atlas hash and contract byte-match the workspace; `git diff --check` passes.
- Decisions: recorded in the Decision log above (bottom-anchored placement, deferred left/right Dock support, SwiftPM tests accepted in place of an XCUITest target for 0.1).
- Risks or blockers: left/right Dock placement no longer exists in code at all (not just untested), so reintroducing it later is a feature addition, not a bug fix. The bottom-anchored formula has not been hands-on tested on a real left/right-Dock machine, since it no longer branches on Dock position at all — the remaining owner QA is the display/orientation matrix in `docs/QA_CHECKLIST.md`, now simpler because there is only one placement path to verify instead of three.
- Next: owner runs `gh pr ready 15 && gh pr merge 15 --merge --delete-branch` to merge the portal summon PR (approved, held back only because merge/branch-delete are treated as sensitive actions requiring the owner's own terminal). After that, resume the deferred Phase 3 milestone: run the event socket server inside the app, surface it in menu-bar diagnostics, then wire `MascotVisibleState` into animation selection.

### 2026-07-30 — Session closure: three PRs merged, backlog reconciled

- Objective: land the reviewed work, reconcile the GitHub backlog with actual evidence, and close the session cleanly.
- Completed:
  - All three open PRs merged to `main`: [#15](https://github.com/Mr-Shine09/desktop-mascot/pull/15) portal summon (owner-approved art), [#17](https://github.com/Mr-Shine09/desktop-mascot/pull/17) bottom-anchored window placement and manual-position preservation, and [#16](https://github.com/Mr-Shine09/desktop-mascot/pull/16) the chair sit-shake atlas revision 4. `main` is at `a351aed` and level with `origin/main`.
  - Issues #3, #4, and #6 closed with recorded evidence. #5 remains open with a status comment explaining that its two code defects are fixed and its scope narrowed to bottom-anchored placement; only the hands-on display matrix remains.
  - Reviewed the chair atlas visually at inspection scale before approving #16: both sit-shake rows read as a compact freestanding chair, the seated identity and leg-swing cadence survive, and the frozen palette and silhouette rules hold.
  - Answered two owner questions without writing code, because both were already covered: the menu-bar escape hatch already exists (`MenuBarExtra` in `DesktopMascotApp.swift` plus `MenuBarContent.swift`), and relaunching after Quit is currently the documented `xcodebuild` + `open -g` pair. Confirmed the broader menu-bar settings surface (launch-at-login, animation speed, display selection, provider hook management, VoiceOver) is issue #10 and deliberately untouched.
  - Quit the running Debug instance (PID 33766) at the owner's request; no Dock Pet process remains.
- Verification: no code changed in this closing segment. The last full verification stands at 118 Swift package tests passing, unsigned Debug and Release builds succeeding, atlas contract and atlas validating, and bundled resources byte-matching the workspace.
- Decisions: none beyond those already recorded in the 2026-07-30 Decision log block.
- Risks or blockers: the app is still not installed anywhere durable — the only binary lives under `/private/tmp/DesktopMascotDerivedData`, which macOS clears on reboot, so after a restart the app must be rebuilt before it can be launched at all. That is expected until packaging (issue #13), but it means "reopen the mascot" is a developer action rather than a user action today. The capability boundary is unchanged and still the most important thing to state honestly: the event path is fully built and tested but nothing in the running app uses it.
- Next: run the event socket server inside the app, feed the registry and reducer, and surface the result in menu-bar diagnostics before touching animation selection. Then map `MascotVisibleState` onto animation rows with ambient roaming as the no-signal default.

### 2026-07-30 — Event socket server running inside the app

- Objective: close the long-standing gap in which the whole event path existed and was tested but nothing in the running app used it. Deliberately stop short of animation, per the standing instruction to surface the result in diagnostics before changing any animation.
- Completed:
  - Added `EventPipeline` to `MascotCore`: a clock-injected value type owning the registry, the reducer, and diagnostic counters. It keeps the two clocks separate exactly as the registry does, and it extends rather than widens the privacy boundary — counts, a session count, and one coarse `MascotState`, with rejection *reasons* deliberately discarded because they are derived from caller-controlled bytes.
  - Added `AgentEventBridge` to the app target: it owns `EventSocketServer`, hops each delivered envelope to the main actor, mirrors manual pause/ideating into `ManualOverrides` so the documented priority still holds, and refreshes on a timer so heartbeat expiry, reaction windows, and the nightly sleep window advance without new traffic. The timer runs at 1 s while any session is tracked and drops to 15 s when none is, so a quiet machine is not woken once a second for a reduction that cannot change.
  - Started the server before mascot resources load, so an atlas failure still leaves the event path diagnosable, and stopped it in `applicationWillTerminate` so the socket file does not outlive the process.
  - Surfaced two new menu-bar lines: listener status with counters, and the reduced state. The reduced-state line says outright that it is not driving animation yet, so the diagnostics cannot be misread as a claim of live agent tracking.
  - Added the `MascotTransport` dependency to the app target in `project.yml` and regenerated the project; the `project.pbxproj` diff is 11 added lines and nothing else.
- Decisions: keep `EventPipeline` in the package rather than in the app, so the registry/reducer/counter composition stays unit-testable; the app-side bridge is then only a timer, the overrides, and two strings. Use `ProcessInfo.systemUptime` as the monotonic source: it does not advance during machine sleep, so a closed lid cannot retire a live session, and `refresh` still reconciles after wake. Publish `MascotVisibleState` without consuming it, so a transport bug this week cannot be mistaken for an animation bug.
- Verification: 130 Swift package tests pass, up from 118 — nine `EventPipeline` fixtures plus three that run a *real* socket server into a *real* pipeline, which is the same composition the bridge uses and is what actually proves a helper invocation reaches reduced state. Unsigned Debug and Release `xcodebuild` both succeed. Atlas contract and full atlas validate; the bundled atlas hash and contract byte-match the workspace. `git diff --check` passes. Live: the launched Debug app bound `events.sock` at `0600`, a `dockpet-event` `active` event was delivered, a four-event `codex` lifecycle sequence plus a deliberately malformed frame left the process alive, and quitting unlinked the socket.
- Owner QA: the menu-bar readout could not be checked by the assistant, because reading a `MenuBarExtra` needs assistive access that was not granted (and granting it was declined as a security-settings change not worth making for a cosmetic check). The owner verified it directly the same day: with the app running and one `active` event delivered for `claude-code`, the menu showed `Event socket: listening • 1 accepted • 1 session` and `Reduced state: Working (claude-code) — not driving animation yet`, above the unchanged `Ambient roaming` line. The app-side event path is therefore verified end to end, on screen.
- Risks or blockers: the helper is still not bundled anywhere a provider hook could invoke it, so the path remains developer-only end to end — a human running `dockpet-event` is the only event source. Reaction decay and the 120-second heartbeat expiry were verified by fixture, not on screen.
- Merged to `main` as `970d316` via [PR #18](https://github.com/Mr-Shine09/desktop-mascot/pull/18) on 2026-07-30.
- Next: map `MascotVisibleState` onto animation rows, replacing the raw atlas row strings in `AmbientAnimationController` rather than growing beside them, with debounce and ambient roaming as the no-signal default. Then bundle the helper, then adapters #8 and #9.

### 2026-07-30 — Animation driven by reduced state

- Objective: make `MascotVisibleState` the single typed source of what the pet is doing, replacing the raw atlas row strings in `AmbientAnimationController` rather than growing beside them.
- Completed:
  - Added `AnimationSelector` to `MascotAnimation`: the state-to-row mapping plus a trailing dwell. Sessions legitimately flip between working and waiting several times a second while tools run, and a flip faster than ~0.75 s reads as a glitch rather than an animation, so only the newest state inside a window is ever shown — a burst collapses to its outcome instead of a stutter. Pause and resume bypass the dwell, because a direct user action must not feel delayed.
  - Made movement part of the plan, per the animation inventory: only chilling/strolling moves along the lane, working sits and types, waiting stops and turns, and every reaction plays in place.
  - Rewrote `AmbientAnimationController` around `MascotState`. Its `setPaused`/`setIdeating` are gone: manual pause and ideating now reach animation *through* the reducer as `ManualOverrides` and arrive as `.paused` and `.ideating`, so there is exactly one path from any cause to one row. `isRoaming` stays separate because it governs placement, not agent state.
  - Cached every declared atlas row instead of a hand-listed subset, since the reduced state can now select any of them and a missing row would silently freeze the pet.
  - Rewrote the menu-bar status line to name the state and its providers, and removed the bridge's now-false "not driving animation yet" label.
- Decisions: `.offline` strolls rather than standing still. The inventory describes offline as a quiet bowed blink, but with no adapter installed every machine sits in `.offline` permanently, so a literal reading would ship a motionless pet to everyone; roaming is the owner-approved no-signal default and the offline row still supplies the rests. Recorded here because it is a deliberate departure from the inventory, not an oversight.
- Verification: 143 package tests pass, up from 130 — 13 `AnimationSelector` fixtures covering the row mapping, which states stroll, dwell hold-back, newest-wins collapse, pending commit, flap cancellation, and the pause bypass. Debug and Release `xcodebuild` both succeed; atlas contract and atlas validate; bundled resources byte-match; `git diff --check` passes.
- Owner-verified live on 2026-07-30, against a process confirmed newer than the binary: an `active` event stopped the pet and put it at the computer; `completed` played the success sparkle and returned it to strolling; menu-bar Pause stopped it instantly; Manual Ideating held the Thinker pose. Idle and offline are both strolling states, so the 120-second expiry is not visually distinguishable from idle — that boundary remains fixture-verified only.
- Risks or blockers: a stale-process incident cost part of this session. `open -g` does not relaunch an app that is already running, so a rebuild attached to the previous binary and "the app is alive" was mistaken for "the new code is running"; one live claim was reported on that basis and was wrong. The quit-first procedure and a start-time-versus-build-time check are now in `docs/DEVELOPMENT.md`. Unchanged and more important: no provider adapter exists and the helper is not bundled, so a human running `dockpet-event` is still the only event source.
- Next: bundle the `dockpet-event` helper inside the app so a hook can invoke it by path, then add the Claude Code and Codex adapters (#8, #9). Only then does the mascot reflect real agent activity.

### 2026-07-30 — Event helper bundled into the app

- Objective: put `dockpet-event` somewhere a provider hook can actually invoke it, which is the last blocker before the adapters.
- Completed:
  - Added a native `dockpet-event` tool target to `project.yml` compiling the existing helper sources against `MascotTransport`, and embedded it in the app via a copy-files phase. Built as a target rather than copied from SwiftPM output, so the helper inside the bundle comes from the same build as the app and cannot drift from it.
  - Added `EventHelperLocation`, which resolves the helper through `Bundle.main.url(forAuxiliaryExecutable:)` rather than hard-coding a path, and a **Copy Event Helper Path** menu item plus a status line. Copying is the entire action: Dock Pet does not edit anyone's hook configuration.
- Decisions: the helper lands in `Contents/MacOS/`, which is where the `executables` copy destination puts it. It is a plain executable, not a login item or an XPC service — nothing launches it except a hook, one event at a time, which keeps the "no background agent of our own" property intact.
- Verification: the bundled helper links only system dylibs — no `@rpath` back to the package — and delivered an event end to end while running from `/` with `env -i`, so it does not depend on a shell, a working directory, or SwiftPM. Present and self-contained in both Debug and Release bundles. 143 package tests still pass; atlas and contract validate; bundled resources match; `git diff --check` passes. The relaunch was confirmed newer than the binary before testing, per the procedure added earlier today.
- Risks or blockers: **embedding an executable creates a signing obligation that does not exist yet.** A notarized build must sign the helper as well as the app, and a hardened-runtime app will not launch an unsigned nested executable. That is new work for issue #13, not a detail of it. The bundle path is also still a DerivedData path, so any hook configured today breaks on the next rebuild — the menu item copies the current path rather than pretending a fixed one exists.
- Next: adapters #8 and #9. They must map provider lifecycle hooks onto the existing event vocabulary without widening the envelope, and must fail silently so a hook never breaks the user's actual agent session.

### 2026-07-30 — Session closure: the local event path is complete end to end

- Objective: close the session with the ledger matching reality.
- Completed this session, all merged to `main` at `70953f8`:
  - [PR #18](https://github.com/Mr-Shine09/desktop-mascot/pull/18) — the app runs the event socket server, feeds the registry and reducer, and surfaces the result in menu-bar diagnostics.
  - [PR #19](https://github.com/Mr-Shine09/desktop-mascot/pull/19) — `MascotVisibleState` drives animation selection, with a dwell so rapid flips do not thrash, and manual pause/ideating routed through the reducer instead of around it.
  - [PR #20](https://github.com/Mr-Shine09/desktop-mascot/pull/20) — `dockpet-event` is built as a native tool target and bundled at `Contents/MacOS/dockpet-event`.
  - The package suite grew from 118 to 143 tests across the three changes.
- Owner-verified live, not just built: an `active` event stopped the pet at its computer, `completed` played the success sparkle and returned it to strolling, menu-bar Pause stopped it instantly, and Manual Ideating held the Thinker pose. The menu-bar event readout was confirmed on screen showing `listening • 1 accepted • 1 session` and `Working (claude-code)`.
- Decisions recorded this session: `.offline` strolls rather than standing still, a deliberate departure from the animation inventory taken because every machine without an adapter would otherwise show a motionless pet; the helper is a plain bundled executable rather than a login item or XPC service, so Dock Pet still runs no background agent of its own.
- Risks carried forward: **embedding an executable creates a signing obligation** that #13 must now handle — a hardened-runtime app will not launch an unsigned nested executable. The bundle path is a DerivedData path, so any hook configured today breaks on the next rebuild. A stale-process incident cost part of this session and produced one live claim that was wrong; `open -g` reopens rather than relaunches, and the quit-first procedure plus a start-time-versus-build-time check are now in `docs/DEVELOPMENT.md`.
- Next: adapters #8 and #9. Read the official Codex and Claude Code hooks documentation first, because the event mapping depends on which lifecycle points each provider actually exposes. Two non-negotiables: map onto the existing event vocabulary without widening `EventEnvelope`, and fail silently — a hook that errors or hangs breaks the user's real agent session, which is far worse than a mascot that does not animate.

### 2026-07-30 — Claude Code and Codex hook adapters

- Objective: let a real agent session drive the mascot, which is the last thing standing between Dock Pet and its stated purpose.
- Read both providers' official hook references first. They turn out to be near-identical: a JSON object on stdin carrying `session_id`, `hook_event_name`, `cwd`, `transcript_path`, and on tool events the full `tool_input`; matcher-grouped `command` handlers in a settings file; exit 2 as the blocking signal. That similarity is why one adapter serves both.
- Completed:
  - Added `--hook` mode to the helper instead of shipping shell scripts. A script would need `jq` or `python` on the user's machine and would put the mapping in eight places; a mode keeps it in one testable Swift path with the existing fail-silent behavior already around it.
  - `HookPayload.extract` pulls exactly two fields out by name and **drops every other key without inspecting it**. This is the privacy boundary at the point of entry: the payload contains the working directory, the transcript path, and the full tool arguments, and a provider adding fields cannot widen what Dock Pet sees, because nothing enumerates the payload's keys.
  - `HookEventMapping` maps onto the frozen vocabulary without extending it. A hook with no honest equivalent sends nothing rather than approximating, because a wrong state on screen is worse than no state.
  - Added `--print-hooks`, which writes a configuration snippet to stdout naming the running helper's own path. It never edits a settings file: a bad write there breaks the tool the user actually works in.
  - Added `HookPayloadReader` after live testing exposed two real defects, both of which would have shipped invisibly. See below.
- Decisions:
  - **A failed tool is not a failed turn.** `PostToolUseFailure` maps to `active`, not `failed`. Agents retry routinely, and flinching at every tool error would make the failure state meaningless.
  - **`StopFailure` is the only turn-level failure**, and Codex does not document it, so the Codex snippet omits it rather than registering a hook that never fires.
  - Subagent and compaction hooks map to `heartbeat`, which refreshes expiry without promoting an idle session to working and cannot conjure a session the registry never saw start.
  - Eight hooks are registered, not the thirty Claude Code offers. Every extra hook is another process spawned inside the user's session, and the states the mascot can show do not need the rest.
- Verification: 166 package tests pass, up from 143 — 23 new fixtures. The central one feeds a realistic `PreToolUse` payload containing a transcript path, a client-named directory, and a command with a password, then asserts that none of it appears anywhere in the encoded envelope. Others prove the raw session ID is hashed, that every mapped event survives the strict decoder, and that unmapped and malformed payloads produce no envelope at all. Debug and Release build; atlas and contract validate; bundled resources match; `git diff --check` passes. Live against the running app, a full `SessionStart → UserPromptSubmit → PreToolUse → PostToolUse → PermissionRequest → Stop → SessionEnd` sequence produced exactly the expected events, and `FileChanged` correctly sent nothing.
- Two defects found by testing the real binary rather than trusting the unit tests, both fixed:
  - `availableData` returns only the **first chunk**. A payload arriving in pieces parsed as truncated JSON and silently mapped to nothing — which would have looked like "the mascot just misses events sometimes", the hardest class of bug to notice.
  - Reading to EOF **stalls indefinitely** if the provider holds stdin open. A hook that hangs stalls the user's real session, which is far worse than a mascot that does not animate. The reader now abandons the attempt after 2 seconds, verified at the binary level: the helper exits 0 after 2.04 s against a writer that never closes.
- Risks or blockers: **no live-session run has happened yet.** Every event above was synthesized by writing payloads to the helper, which proves the mapping and the transport but not that the providers fire the hooks as documented, with the fields documented, at the moments documented. That requires the owner to install the snippet and use Claude Code or Codex normally. Until that happens, "Dock Pet reflects real agent activity" remains unproven rather than true. The helper path in the snippet is still a DerivedData path, so any configuration installed today breaks on the next rebuild.
- Next: owner installs the printed snippet and runs a real session, then records what the mascot actually did. After that, the remaining 0.1 work is packaging (#13), the menu-bar settings surface (#10), and the outstanding display-matrix QA.

### 2026-07-30 — Durable local install and signed nested helper

- Objective: stop the installed hook path from dying on every rebuild and reboot. The adapters worked, but they pointed into `/private/tmp`, which macOS clears — so a configured hook was guaranteed to break.
- Completed:
  - Added `tools/install_app.sh`: builds Release, signs, installs to `~/Applications/Dock Pet.app`, and prints the durable helper path. `~/Applications` rather than `/Applications` so no administrator password is needed.
  - Signs the **nested helper before the enclosing bundle**. The reverse order leaves the app's seal describing a helper that is then modified, and the app fails its own validation — this is the concrete form of the signing obligation flagged when the helper was first bundled.
  - Repointed the installed Claude Code hooks at the durable path, preserving the seven pre-existing statusbar handlers.
- Decisions and constraints found:
  - **Notarization is not possible on this machine.** The keychain holds only `Apple Development` certificates; a distributable notarized build needs a `Developer ID Application` certificate from the paid Apple Developer Program. Recorded as a hard blocker on the distribution half of #13, not a task that was skipped.
  - Identity signing fails with `errSecInternalComponent` from a non-interactive shell, because `codesign` cannot reach the private key without a keychain prompt nothing can answer. The script falls back to ad-hoc signing, which needs no key and is sufficient for a self-built local app; running the script from an interactive terminal signs with the real identity instead.
  - Certificates are selected by hash, not common name: three certificates share one name here, and passing the name fails as "ambiguous".
- Verification: the installed bundle passes `codesign --verify --deep --strict` and satisfies its designated requirement; the nested helper verifies independently. A real `claude -p` session run against the **installed** helper produced `started -> active -> active(tool) -> active(tool) -> completed -> stopped` in order, captured on the production socket path. The app relaunches from `~/Applications` and binds the socket at `0600`.
- Risks or blockers: the install is ad-hoc signed and unnotarized, so it is trustworthy only on the machine that built it — it cannot be given to anyone else. Launch-at-login still does not exist, so the app must be started manually after a reboot even though its path now survives one. The owner reverted the first hook install and reported no problems; the reinstall at the durable path was made only after confirming that.
- Next: launch-at-login so the durable install actually runs after a restart, then the menu-bar settings surface (#10). Distribution stays blocked on a Developer ID certificate.

### 2026-07-30 — Summon on demand; launch-at-login declined

- Objective: make the mascot appear only when the owner asks for it. Launching the app was putting a pet on screen unasked, which contradicts how the owner actually wants to use it.
- Owner decisions, recorded because they narrow the product rather than implement it:
  - **No launch-at-login, ever.** Previously listed as remaining 0.1 work under #13; it is now out of scope by decision, not deferred. Dock Pet is started deliberately.
  - **Launching is not summoning.** The app starts with the menu-bar item and nothing else; the mascot appears only on an explicit Summon.
  - Distribution is not a goal: this is a personal project, so an ad-hoc signed local install is the finished state and notarization is not worth a paid developer account.
- Completed:
  - `isVisible` now defaults to `false`, and launch calls `setVisible(false)` explicitly. That orders the panel out and leaves the animation timer stopped, so an unsummoned Dock Pet costs nothing but its menu-bar item.
  - Renamed the action for what it does: **Summon Mascot** / **Dismiss Mascot**, in both the menu bar and the mascot's own right-click menu. The old "Show Mascot" checkmark read as a state toggle rather than a deliberate call.
  - Idle diagnostics now say `Not summoned — choose Summon Mascot`, since this is the state the app launches in rather than an unusual one.
- Verification: measured with `CGWindowListCopyWindowInfo` rather than by eye — at launch there are **0** on-screen Dock Pet windows; after a summon there is exactly one at `96x112` with alpha 1. 166 package tests still pass and the Debug build succeeds.
- Public-repo audit, for the owner's stated goal of open-sourcing later: no tokens or email addresses are tracked, but 12 tracked files embed the owner's home path (`art/animation/frames/*/normalization.json` and the ledger), and **the mascot is a pixel-art likeness of the owner derived from their personal avatar**. Publishing the repository publishes that likeness. Both are the owner's call; neither is a blocker.
- Risks or blockers: none introduced. The portal summon transition is now the only way a mascot ever reaches the screen, so any bug in it becomes a bug in the app's only entry point.
- Next: the menu-bar settings surface (#10), and the outstanding hands-on display-matrix QA. Distribution and launch-at-login are both closed by decision rather than open.

### 2026-07-30 — Menu-bar settings surface (#10)

- Objective: give the user a control surface that works whether or not the mascot is on screen, and make every animation inspectable without an agent.
- Completed:
  - **State preview.** `ManualOverrides` gained `preview: MascotState?`, and the reducer returns it above every other rule. Selecting a state from **Preview State** forces that animation; `Off` returns to whatever the reducer actually believes.
  - **Preference persistence.** `Preferences` stores exactly one key — roaming — in `UserDefaults`, restored at launch.
  - **Hook setup from the menu.** `Agent Hook Setup` copies the full configuration for either provider, or just the helper path.
  - **VoiceOver.** Status lines carry spoken labels, because the compact form a sighted user scans (`3 accepted • 1 session`) reads as noise aloud. `AgentEventBridge.spokenSummary` says what the numbers mean.
- Decisions:
  - **A preview is an override, not a synthetic event.** Injecting fake events would put fabricated sessions in the registry, and a fabricated session is indistinguishable from a real one afterwards. A preview changes what is *shown* and never what is *believed*, so the registry stays a record of real events only. It also outranks pause — a preview that silently showed something else would be useless — and is mutually exclusive with the other overrides.
  - **A preview is never persisted**, and neither is visibility. Restoring a forced state on launch would strand the pet in a fabrication the user has no memory of choosing.
  - **Issue #10 asks for verify, disable, and uninstall actions per provider; those are deliberately not built.** Each means editing the file that runs the user's actual agent, and a mascot getting that wrong breaks the tool they work in. Preview-and-paste is the substitute: Dock Pet shows every line it would add and the user installs it. This is a narrowing of #10, recorded rather than quietly dropped.
- Verification: 172 package tests pass, up from 166 — six preview fixtures covering every state, provider attribution, precedence over pause, restoration, and that a preview leaves the registry empty. Debug and Release build. Persistence measured directly: roaming survives a relaunch, and the app's entire `UserDefaults` domain contains one key and nothing else.
- **Debugging note worth keeping.** Six unrelated transport tests failed convincingly — a live session reducing to `offline` — and the cause was a stale incremental build holding the old `ManualOverrides` layout after a stored property was added. `swift package clean` fixed it. Recorded in `docs/DEVELOPMENT.md`; the failure was entirely believable and cost a detour.
- Risks or blockers: the preview menu itself has not been clicked by the owner — the reducer path is fixture-verified and the app wiring is the same path pause uses, but the submenu has not been exercised on screen. Animation speed and display selection from #10's task list are not built; they are not required by any acceptance criterion and are recorded as deferred.
- Next: owner clicks through the new menu, especially Preview State. Then the outstanding hands-on display matrix, which is the last item standing between 0.1 and done.

### 2026-07-30 — Ledger correction

- Found while resolving the #23 merge: several summary rows had been reported updated in earlier sessions and were **not** actually updated. The snapshot still said "no provider adapter exists yet", the current gate still asked for a live provider session that had already happened, the verification matrix still said the live smoke test had not been run, and the risk register still listed the bundled helper as uninstalled. `git log -S` confirms one of those strings never entered history at all.
- Cause: doc edits were applied with string replacement, and a replacement whose target does not match silently changes nothing. The post-edit checks searched the in-memory text for a marker that could also match other content, so they reported success either way. The committed file was never re-read.
- Corrected: snapshot status, current gate, provider-adapter and accessibility matrix rows, the resolved helper-install risk, and two stale claims in `CLAUDE.md` including the instruction not to claim real agent activity — which had been true when written and false since the live run.
- Guard added to `CLAUDE.md`: verify documentation claims against the committed file (`git show HEAD:<file> | grep`), not against an edit script's output.
- No code was affected. This was a documentation-accuracy failure, which matters here because the ledger is what the next session trusts instead of re-deriving.

### 2026-07-30 — Session closure: 0.1 feature-complete, QA outstanding

- Objective: close the session with the ledger matching the repository.
- Landed on `main` this session: [PR #18](https://github.com/Mr-Shine09/desktop-mascot/pull/18) app-side event server, [#19](https://github.com/Mr-Shine09/desktop-mascot/pull/19) animation from reduced state, [#20](https://github.com/Mr-Shine09/desktop-mascot/pull/20) bundled helper, [#21](https://github.com/Mr-Shine09/desktop-mascot/pull/21) provider hook adapters, [#22](https://github.com/Mr-Shine09/desktop-mascot/pull/22) durable install with signed nested helper. [PR #24](https://github.com/Mr-Shine09/desktop-mascot/pull/24) merged into `agent/summon-on-demand` rather than `main`, so [PR #23](https://github.com/Mr-Shine09/desktop-mascot/pull/23) now carries both summon-on-demand and the menu-bar settings surface and is the one merge outstanding.
- The single most important change: **Dock Pet went from a mascot that knew nothing to one driven by real Claude Code activity**, verified from a live session rather than synthesized events. The package suite grew 118 -> 172 tests across the session.
- Owner decisions recorded, each of which closed open work rather than adding it: no launch-at-login ever; launching is not summoning; distribution is not a goal, so an ad-hoc signed local install is the finished state.
- Verification at session end: 172 package tests pass, Debug and Release build, atlas and contract validate, `git diff --check` clean, and the conflict-resolved branch was re-tested after merging `origin/main`.
- Risks carried forward:
  - **Codex has never been run live.** It shares the adapter with Claude Code and its snippet generates correctly, but that is inference. `waiting` and `failed` are likewise fixture-only.
  - The install is ad-hoc signed and unnotarized, so it is trustworthy only on the machine that built it. Distribution needs a Developer ID certificate, which is a purchase, not an engineering task.
  - A documentation-accuracy failure occurred and is recorded in the entry above; the guard against a repeat is in `CLAUDE.md`.
- Next: owner hands-on QA is the only remaining 0.1 work — the Preview State menu, the cursor-hanging feel, and the display matrix (auto-hide, multiple displays, full-screen Spaces, sleep/wake). If open-sourcing later, scrub the owner's home path from 12 tracked files and decide deliberately about publishing a likeness derived from a personal avatar.

### 2026-07-30 — Drop resumes roaming; reaction cues added

- Objective: act on the owner's first hands-on QA pass of the installed app.
- Owner findings, and what each turned out to be:
  - **Dropping the mascot froze it in a dozing pose.** Not an animation bug. `AmbientAnimationController.userDidEndDrag()` called `setRoaming(false)` by design, and with no agent connected the resulting resting row is `offline`, which carries the deterministic `Z` trail added on 2026-07-28. Stopped plus `Z` reads as "the pet broke", which is not what the manual-placement decision intended.
  - **The mascot types at the computer while Claude Code runs.** Owner-observed in the installed build. This is the `working` row driven by a live provider, and it is the second independent live confirmation of the adapter after the 2026-07-30 socket capture.
  - **Success needs a sparkle animation.** It already had one. Verified against `art/animation/mascot-atlas@2x.png` directly rather than the ledger: success is row 5, six frames, stars entering over frames 1-5 with star-eyes and a raised fist; failure is row 6 with the cracked bulb. The reaction windows are 3s (success) and 4s (failure).
- Completed:
  - Dragging is now a placement gesture only and no longer switches roaming off. On drop the panel keeps **both** the released X and the released Y via the new `WindowCoordinator.settleAfterDrop()`, then resumes walking, resting, or its stationary row according to the reduced state.
  - **Owner decision, superseding the bottom-anchored-only rule for manual placement:** the mascot roams from wherever it is dropped, including above the Dock. The first implementation snapped the height back to the lane to preserve that rule; the owner rejected it and asked explicitly for roaming at the drop point, accepting that the walk cycle only moves along X and the pet therefore walks through open air. The bottom lane remains the *default* placement and the destination of Reposition, which is now the one deliberate way back. `DockGeometry` is unchanged — this is a coordinator-level placement override, not a return to Dock-edge inference.
  - `hasManualPlacement` records the drop so Hide/Show, reopen, display changes, and re-enabling roaming all preserve it. Roaming can no longer be used as the "did the user place this?" signal, because dragging leaves roaming on. Off-edge drops clamp back into both axes' bounds.
  - Added `tools/author_sound_effects.py`, which synthesizes both cues as square-wave chiptune WAVs — a rising C-major arpeggio resolving on the octave for success, two descending detuned tones for failure. Deterministic and idempotent: re-running reproduces both files byte for byte.
  - Added `ReactionSoundPlayer`, fired from the new `AmbientAnimationController.onStateAppeared` callback so a cue lands with the frames rather than ahead of them — the selector's dwell holds a state back, and the reduced state would have been the wrong trigger.
  - Sound is limited to `success` and `failure`; those are the states where a turn *ends*. It is additionally gated on `isVisible`, so a dismissed mascot is silent. A persisted **Reaction Sounds** menu toggle mutes it.
- Decisions: synthesize rather than source audio, so the cues are regenerable from committed tooling and carry no licensing question, matching how every sprite in this repository is authored. Peak amplitude is 22% of full scale — this plays unprompted, so it must read as a chime, not an alert.
- Fixed a latent time bomb in `EventPipelineTransportTests`, found because it broke this session's baseline: the fixtures pinned the reducer's *calendar* to UTC but still reduced against the real `Date()`, so the whole suite passed until the wall clock crossed 23:00 UTC and then failed inside the sleep window. It fails daily between 16:00 and 23:00 PDT and passes the rest of the day, which is why it survived every previous session. The sink now reduces against a fixed midday instant; the first replacement constant chosen was itself inside the sleep window, so verify the UTC hour rather than assuming any round epoch is daytime.
- Verification: 176 package tests pass (up from 172; four new placement cases plus the repaired fixture). Debug builds and the Release install succeeds. Both WAVs measured non-silent at 0.54s/0.42s. `started -> completed` and `started -> failed` were driven through the installed helper against the running app.
- Risks or blockers: **the cues themselves are unheard by anyone.** They were measured, not listened to; the owner has not yet confirmed they sound right or fire at the right moment. The drop-resumes-roaming feel is likewise unconfirmed on screen. Driving `failed` through the helper by hand is still not a live provider signal — `waiting` and `failed` remain unproven from a real agent.
- Also corrected the three stale claims flagged at the start of this session: next-session handoff items 7 and 12 asserted that no provider adapter and no installed copy existed, and `docs/HANDOFF.md` repeated the install claim while contradicting itself twelve lines earlier. All three were overtaken by PRs #21/#22 on 2026-07-30 and are now fixed, along with every current-state doc line that today's drop-placement change invalidated. Cite claims by section rather than by line number: this file is append-heavy and line references rot within a session.
- Next: owner listens to both cues and drops the mascot from several heights.

### 2026-07-30 — Session closure: first QA pass acted on, docs reconciled

- Objective: act on the owner's first hands-on QA of the installed app, then close with the ledger matching the repository.
- Landed on `main` this session: [PR #25](https://github.com/Mr-Shine09/desktop-mascot/pull/25), merged as `4a1dbd7`. No PR is open and no branch is outstanding for the first time in several sessions.
- The single most important change: **the mascot stopped looking broken after a drag.** Everything else this session was smaller. The old drop behavior was a deliberate design decision that turned out to read, on screen, as a malfunction — which is exactly the class of thing only hands-on QA finds, and an argument for doing the remaining QA rather than deferring it again.
- Owner decisions recorded: roam from the drop point, accepting mid-air walking, over lane-snapping; synthesize the reaction cues from committed tooling rather than sourcing audio; and keep the repository private, since the stated goal (CI, contribution graph) does not require publishing and three real exposures do not currently justify it.
- Repository visibility was discussed and deliberately **not** changed. If it is revisited, the blockers are unchanged and were verified rather than assumed: 12 tracked files embed `/Users/oaksoekhant/...`; all 60 commits carry the owner's real name and personal email, which cannot be scrubbed without rewriting history and breaking every clone; and the mascot is a recognizable likeness derived from a personal avatar, which forks make permanent. The path scrubbing is worth doing regardless of visibility, because those absolute paths break the art tooling on any other machine.
- Two bugs found that nobody had reported: a time-of-day-dependent test failure that only reproduces between 16:00 and 23:00 PDT, and five stale documentation claims, two of which (`DockGeometry` edge inference, controller-owned pause/ideating) had been false since 2026-07-30 and survived a documentation-accuracy incident that was specifically about this.
- Verification at session end: 176 package tests pass, Debug builds, the Release install succeeds, atlas and contract validate, `git diff --check` clean, and every corrected doc claim was re-checked with `git show HEAD:<file> | grep` against the committed blob rather than the worktree.
- Risks carried forward:
  - **The reaction cues have never been heard by anyone.** They are measured non-silent; that is not the same as correct. This is the largest unverified claim in the session.
  - The drop-and-roam feel is unconfirmed on screen. If mid-air roaming reads badly, `settleAfterDrop()` is a one-line revert to lane-snapping.
  - `waiting` and `failed` remain fixture-only, and **Codex has never been run live**. Driving `failed` through the helper by hand this session did not change that and must not be cited as if it did.
  - The display matrix is still untouched, and a dropped height interacting with a display change is new untested surface.
- Next: owner hands-on QA remains the only 0.1 work. In priority order: listen to both cues, drop the mascot from several heights, then the display matrix in `docs/QA_CHECKLIST.md`.

### 2026-07-31 — Documentation accuracy sweep against the committed tree

- Objective: with all remaining 0.1 work being owner hands-on QA that an agent cannot perform, close the smallest gate that was actually open — project priority 2, verifying documentation claims against the repository rather than against prior prose.
- Baseline first, and green: 176 package tests pass, `validate_animation_atlas.py` validates both contract and atlas, and the worktree was clean apart from an empty untracked `project-skills/agent-activity-signals/.Rhistory` (left in place, not deleted).
- Nine stale claims found and corrected. Every one was checked against code or `git`/`gh` output, not against another document:
  - `docs/HANDOFF.md` named `main` as `d31b893` with PR #23 open. `main` was `6a7e631` through PR #26, with no PR open and no branch outstanding (`gh pr list`, `git branch -a`).
  - `DesktopMascot.md` next-session item 4 named `4a1dbd7`/PR #25 — one merge behind for the same reason.
  - Three different test-count baselines were in circulation: `docs/DEVELOPMENT.md` said 166, `docs/HANDOFF.md` said 172, the actual suite is 176.
  - `docs/DEVELOPMENT.md` still pointed hooks at the DerivedData helper copy and said the path becomes durable "only once the app is installed somewhere permanent (issue #13)". The app has been installed at `~/Applications/Dock Pet.app` since PR #22; the durable path is the one to document.
  - The `MascotCore` state-vocabulary risk said "nothing consumes it". `MascotVisibleState` is consumed by `EventPipeline`, `AgentEventBridge`, `AppDelegate`, and `AmbientAnimationController`. Closed.
  - The Hide/Show risk said `AppDelegate` sets `repositioning` from `isRoaming`. It reads `WindowCoordinator.hasManualPlacement` — the change dragging-keeps-roaming forced, and exactly the trap next-session item 9 warns about.
  - The multi-session thrash risk said debounce "remains open". It landed as `AnimationSelector`'s 0.75-second dwell. Closed.
  - The window-geometry verification row said "bottom-anchored-only placement; ten tests". `settleAfterDrop()` is a sanctioned override of that rule, and the suite runs thirteen.
  - The handoff's QA priority order predated the reaction cues entirely, and its milestone step 11 was still unstruck despite the live Claude Code run.
- Added a verification-matrix row for the reaction cues, which had none. It records what is genuinely verified (deterministic regeneration, non-silent measurement, firing from `onStateAppeared`, visibility gate, persisted mute) and states plainly that **nobody has ever heard either cue**.
- Method note, since this is the second documentation-accuracy entry in this ledger: the first drafts of two edits asserted a test count from memory. Both were replaced with counts from an actual `swift test --filter` run. Prose about tests is worth exactly as much as the command behind it.
- No code changed. Verification: 176 tests still pass, atlas validates, and every corrected claim was re-read from `git show HEAD:<file>` after committing rather than from the worktree.
- Risks carried forward, unchanged and deliberately not softened: the reaction cues are unheard, the drop-and-roam feel is unconfirmed on screen, the display matrix is untouched, `waiting`/`failed` are fixture-only, and **Codex has never been run live**.
- Landed on `main`: [PR #27](https://github.com/Mr-Shine09/desktop-mascot/pull/27) as `d72be8b`, [PR #28](https://github.com/Mr-Shine09/desktop-mascot/pull/28) as `4afe2d6`, both squash-merged by the owner.
- A third documentation error, found by re-reading this entry after the merges: every date in it was written as `2026-07-30`, but the session ran on **2026-07-31**. The dates were carried over from the previous session's entries instead of checked. Corrected here, in the snapshot's `Last updated`, in `docs/HANDOFF.md`, and in the `DEVELOPMENT.md` test baseline; dates describing *earlier* sessions' work were left alone, since those were accurate. Worth recording rather than quietly fixing: this is the third distinct way one session's documentation went wrong while the session's whole subject was documentation accuracy. The edits were applied with a script that asserts each target matches exactly once, which is the guard against the silent-no-op failure recorded on 2026-07-30.
- Immediately afterward, the fix demonstrated the defect it was fixing. Two of the nine corrections were revision snapshots naming `6a7e631`/PR #26; merging PR #27 made both wrong the moment it landed. The line had now rotted three times across three sessions. It was removed rather than corrected a fourth time: `docs/HANDOFF.md` and next-session item 4 now give the commands (`git status --short --branch`, `gh pr list`, `git branch -a`) and name no revision at all. **The general lesson, which applies past this one line: a documentation claim that the next ordinary action invalidates cannot be fixed by writing it more carefully. Either it stops being written down, or it rots on a schedule.** The test-count baselines have the same shape and are the next candidate if they drift again.
- Next: unchanged. Owner hands-on QA is the only remaining 0.1 work, in the order now recorded identically in `CLAUDE.md`, the snapshot gate, and `docs/HANDOFF.md`.

### 2026-07-31 — Reconcile Scope with the decisions that overtook it

- Objective: the owner asked when the project will be finished *as planned*. Answering it honestly meant checking whether the plan still described the product. It did not, so this entry fixes the definition of done rather than estimating against a stale one.
- The `Scope` section still described the 2026-07-28 contract. Five discrepancies, now recorded in a table there rather than silently rewritten:
  - **Launch at login** listed as an in-scope menu-bar control; closed by owner decision 2026-07-30.
  - **Placement "above or beside the Dock"**; side-Dock tracking was deleted rather than fixed 2026-07-30.
  - **"Direct notarized distribution is the first packaging target"**; distribution was closed 2026-07-30 as a certificate purchase, not engineering.
  - **Sound effects listed as an explicit non-goal** — while 0.1 now ships two reaction cues that are currently the top QA item. A shipped feature sat on the non-goals list for a day.
  - **An animation speed control** listed in scope, never built.
- The first four are owner decisions that were simply never written back, and are now annotated with direction and date. The fifth is different in kind and is called out as such: `grep -ri speed` across the Swift sources returns nothing and `Preferences` stores only `roaming` and `reactionSoundsMuted`, so the control does not exist — but no decision ever dropped it either. **It is the only 0.1 commitment that is neither built nor consciously abandoned**, and it is recorded as an open owner question in `Scope`, the snapshot gate, and `CLAUDE.md` rather than being quietly deleted. An agent tidying scope must not resolve this by deletion.
- Why this matters beyond bookkeeping: the project has been described as "feature-complete for 0.1 pending QA" since 2026-07-30, and that claim was measured against a scope list containing an unbuilt item and excluding a shipped one. The finish line was not where the ledger said it was.
- No code changed. Verification: 176 package tests pass, contract and atlas validate, and each scope claim was checked against the sources (`grep -ri speed`, `Preferences.swift`, `MenuBarContent.swift`) rather than against other prose.
- Risks carried forward, unchanged: the reaction cues are unheard, drop-and-roam is unconfirmed on screen, the display matrix is untouched, `waiting`/`failed` are fixture-only, and **Codex has never been run live**.
- Next: unchanged for implementation — owner hands-on QA, cues first. Newly added alongside it: decide the animation speed control.

### 2026-07-31 — Session closure: documentation made to match the repository

- Objective: with every remaining 0.1 item gated on owner hands-on QA, spend the session on the largest thing an agent could actually close — the gap between what the documentation claimed and what the repository contained.
- Landed on `main` this session: [PR #27](https://github.com/Mr-Shine09/desktop-mascot/pull/27) nine corrected doc claims, [#28](https://github.com/Mr-Shine09/desktop-mascot/pull/28) removal of revision snapshots, [#29](https://github.com/Mr-Shine09/desktop-mascot/pull/29) corrected dates, [#30](https://github.com/Mr-Shine09/desktop-mascot/pull/30) gitignored the stray REPL artifact, and [#31](https://github.com/Mr-Shine09/desktop-mascot/pull/31) reconciled `Scope` and added the branch tool. All five merged. One further PR carries the correction to this very line, since a closing entry cannot record its own merge — verify with `gh pr list` rather than trusting any of this.
- The single most important change: **the finish line moved to where it actually is.** 0.1 had been called feature-complete-pending-QA since 2026-07-30, but that was measured against a `Scope` list containing an item nobody built and omitting one that shipped. Everything else this session was smaller.
- The one new open item: the **animation speed control**, in scope since 2026-07-28, absent from the sources, never dropped. Recorded as an owner decision in three places, deliberately not deleted.
- Three documentation errors were introduced *by this session* and are recorded rather than quietly fixed: two revision snapshots that PR #28 then had to remove, and a whole set of entries dated 2026-07-30 when the session ran on 2026-07-31. A session about documentation accuracy produced three documentation defects, which is the honest measure of how easy this class of error is.
- **New trap for the next session, found while cleaning up branches:** `git branch -r --merged main` is misleading in this repository. Every PR is squash-merged, so the branch tip never becomes an ancestor of `main`, and the command reported three branches merged minutes earlier as *unmerged*. It is wrong in both directions and must not be used to decide what is safe to delete. Fixed rather than only documented: `tools/list_merged_branches.sh` classifies every remote branch against GitHub's merge record as `SAFE`, `KEEP` (open PR), or `REVIEW`, and never deletes anything itself.
- **The tool immediately justified itself.** The branch-delete command handed to the owner earlier in the session listed `agent/provider-hook-adapters` as safe. It is not obviously so: commit `302a24c` was pushed to it *after* PR #21 merged and is absent from `main`, which the tip-versus-merged-head comparison catches and a bare merged/not-merged answer cannot. Inspection showed the commit is documentation recording the live Claude Code run, and that substance did reach `main` through a later PR — so deleting the branch loses nothing. The point stands anyway: the original command was right by luck, not by verification, and the same shape of mistake on a branch carrying real work would have been unrecoverable from this machine.
- Verification at session end: 176 package tests pass, contract and atlas validate, `git diff --check` clean, and every corrected claim re-read from `git show HEAD:<file>` rather than the worktree.
- Risks carried forward, unchanged and deliberately not softened:
  - **The reaction cues have never been heard by anyone.** Measured non-silent is not the same as correct. Still the largest unverified claim in the project.
  - The drop-and-roam feel is unconfirmed on screen; `settleAfterDrop()` is a one-line revert if it reads badly.
  - The display matrix is untouched, and a dropped height interacting with a display change is untested surface.
  - `waiting` and `failed` are fixture-only, and **Codex has never been run live.**
- Branch cleanup resolved itself: merging with `--delete-branch` removed seven of the nine remote branches. `tools/list_merged_branches.sh` reports the remainder — `phase-3-event-engine` as `SAFE`, and `agent/provider-hook-adapters` as `REVIEW` because commit `302a24c` was pushed after PR #21 merged. That commit was inspected this session and its substance is in `main`, so it is fine to delete; the tool will keep flagging it, correctly, because it cannot know that a human already looked.
- Next: owner hands-on QA, cues first, then drop-from-heights, then the display matrix. Plus one decision: build the animation speed control or strike it from `Scope`.

### 2026-08-01 — Dismiss transition and app icon

- Objective: two owner requests made after the QA pass. Give dismissal an animation to match the summon portal — a Naruto-style hand seal and a smoke poof — and put a headshot of the mascot on the app icon.
- Completed, dismiss transition:
  - Atlas **revision 5**: new row 14, `hand-sign`, four frames, `once-hold`, `110/110/130/hold`. The atlas is now 15 rows and `768x1680`.
  - `tools/author_hand_sign_frames.py` composes the row from the approved `idle-00` cell by erasing the arms and redrawing them. The head, torso core, trousers, and shoes are the approved pixels, not a new drawing, so identity cannot drift. The torso outline the removed arms used to provide is derived from what survives the erase rather than hard-coded, because the white side panels sit at a different column on almost every row.
  - `PoofDismissTimeline` in `MascotAnimation`, alongside `PortalSummonTimeline`: 1.1 seconds, smoke bursting at 40% and clearing by the end, with the mascot vanishing while the smoke is fully opaque.
  - The smoke is eleven code-rendered puffs in `MascotPreviewView`, following the portal's precedent of not putting transition effects into the atlas. It has to be larger than the mascot and fade continuously, and the frozen palette's binary alpha cannot express that.
  - `AmbientAnimationController.beginDismiss(completion:)` runs it; `AppDelegate.setVisible(false)` now defers hiding into that completion instead of ordering the panel out immediately.
- Completed, app icon: `tools/render_app_icon.py` crops the headshot out of the frozen base and renders the full macOS slot set into a new asset catalog, wired up through `ASSETCATALOG_COMPILER_APPICON_NAME`.
- Decisions:
  - **The dismiss transition is not agent state and does not go through the reducer.** It sits with the summon portal and dragging as something `AmbientAnimationController` drives directly. The rule that reduced state is the single source of what the pet is *doing* is intact; this is what the pet does on the way out.
  - **Re-summoning cancels a dismiss in flight and the pending hide never runs.** The alternative — letting the completion fire — would hide the mascot a moment after the user asked for it back.
  - Dismiss outranks pause. A paused pet still leaves when told to.
  - The icon's 16px and 32px slots are resampled from the 1024px master rather than nearest-neighbored. Below 64px the source grid cannot survive, and a nearest-neighbor version is illegible rather than faithful. This is an icon-only exception; atlas art is unaffected.
- Two corrections found while doing this, both caught by looking at renders rather than by any check:
  - The first arm pass was four pixels thick with the elbows swung wide. It validated cleanly and looked wrong — the arms buried the torso and both white side panels, which are identity anchors. Thinner limbs with the elbows near the idle silhouette fixed it. **The validator cannot see this class of error at all.**
  - The first smoke layout clustered around the torso and left the legs and shoes sticking out below the cloud, and started too small to hide the mascot it was supposed to hide. Both were found by compositing the timeline against the frames offline before trusting it.
- Verification: 183 package tests pass (up from 176; seven new, including one that checks the `hand-sign` row's declared durations finish before the poof starts, since the seal and the smoke are timed independently). Contract, frame row, and full atlas all validate. QA sheets and all fifteen motion previews regenerated. Unsigned Debug build succeeds, bundled atlas hash matches the workspace, bundled contract byte-matches, and `AppIcon.icns` plus `CFBundleIconName` are present in the built bundle.
- Risks or blockers: **neither the dismiss transition nor the icon has been seen on screen by anyone.** The seal frames, the timeline arithmetic, and the composite were each reviewed as renders, but a still render is not motion, and an offline composite is not the SwiftUI view. The owner's installed build was running throughout this session and was deliberately left alone rather than quit for a live test. Treat the whole feature as unproven until watched.
- Next: owner watches a dismiss — normally, under Reduce Motion, while paused, and interrupted by an immediate re-summon — and checks the icon in Finder. Then back to the pre-existing queue: reaction cues, drop-from-heights, display matrix, and the animation speed control decision.

### 2026-08-01 — Pixel smoke, transition cues, and a farewell on quit

- Objective: three follow-up requests after the owner saw the first dismiss build. Apply the same transition to Quit, give summon and dismiss their own cues, and redraw the smoke as pixel art.
- Completed:
  - **Atlas revision 6**: new row 15, `poof`, eight frames, `once-hold`. The atlas is now 16 rows and `768x1792`. Authored by `tools/author_poof_frames.py` directly on the atlas grid, in four palette colors.
  - The code-rendered SwiftUI cloud shipped hours earlier is gone. A Gaussian blur cannot be pixelated after the fact, so the effect moved into the atlas and now plays as a normal sprite row on its own layer over the mascot.
  - Two new cues in `tools/author_sound_effects.py`: a thin rising run for summon, and a filtered noise burst over a falling blip for dismiss. Both synthesized, both deterministic — the noise uses a hand-rolled LCG so the bytes reproduce.
  - `ReactionSoundPlayer` became `MascotSoundPlayer`, since its own doc comment ("only the two reaction states make a sound") had stopped being true.
  - Quit plays the farewell when a mascot is on screen, with the escape hatches that keeps quitting reliable.
- Decisions:
  - **`poof` is the first atlas row that is not the character.** The 2026-07-29 portal decision — transition effects stay code-rendered and out of the atlas — was overtaken by the owner asking for pixel smoke, which the atlas is the only place to author. The row carries no body and no baseline, and the validator's grounded-state set deliberately excludes it.
  - **The cloud never opens a hole over the middle of the cell.** The first attempt punched round gaps to suggest dissipation; they read as slices of cheese, and they sit exactly where the mascot is standing. It breaks up from its edges instead, and the layer's opacity fade finishes the job.
  - **The smoke bursts near full size.** Same lesson as the code-rendered version: a cloud growing from a point leaves the mascot visible through smoke too thin to hide it.
  - **One sound toggle, not two.** Two switches for four cues is clutter in a menu-bar app. The persisted key stays `reactionSoundsMuted` even though the property is now `soundsMuted` — renaming it would silently un-mute anyone who had already turned sound off.
  - **Quitting never depends on an animation finishing.** A second Quit terminates immediately, an unsummoned mascot skips the farewell, and `isQuitting` stops a summon from cancelling the transition and stranding the app alive.
- **A pre-existing multi-display defect surfaced, and is deliberately not fixed here.** `aDropPastAnEdgeIsClampedBackIntoView` began failing mid-session, when a second display was attached to the machine. `WindowCoordinator` resolves bounds through `panel.screen ?? NSScreen.main`, and `NSScreen.main` follows keyboard focus — so a drop past an edge is clamped against whichever screen happens to have focus. Verified on `origin/main` in a clean worktree, full suite, twice: it fails there too, and passes under `--filter` in both trees. It is a real defect on the display matrix this project has never tested, not a flaky test and not a regression from this change. Recorded in `DEVELOPMENT.md` with the instruction not to loosen the assertion.
- Verification: 184 package tests pass, apart from that one display-dependent failure. Contract, both new frame rows, and the full atlas validate. QA sheets and all sixteen previews regenerated. Unsigned Debug build succeeds; the bundle carries all four WAVs, the new atlas at a matching hash, and a byte-identical contract. All three generators re-run byte-identical.
- Risks or blockers: **still nothing has been seen or heard on screen.** Four cues, two of which are new, have never been played by anyone; the sprite composite was checked as a render, not in the app. The seal-to-smoke handoff is timed by two independent mechanisms — the atlas row's declared durations and the timeline's fade — and the tests only prove the numbers fit, not that the join looks right in motion.
- Next: owner watches and listens to a dismiss and a quit, then the pre-existing queue: reaction cues, drop-from-heights, display matrix (now with a known defect waiting for it), and the animation speed control decision.

### 2026-08-01 — Owner QA: dismiss, quit, and the transition cues approved

- Objective: put the day's three changes in front of the owner and record what they actually confirmed.
- Result: **approved.** The owner ran summon, dismiss, and quit and reported the animations and sound effects working. This is the first owner-verified claim for the dismiss transition, the quit farewell, the pixel smoke, and the two new cues.
- Scope of that approval, stated exactly so it is not read as more than it is: the **happy path only**. Reduce Motion, re-summoning part-way through the poof, dismissing a paused mascot, the second-Quit escape hatch, quitting unsummoned, and the light/dark desktop matrix were **not** walked. They are unticked in `docs/QA_CHECKLIST.md` as unexercised, not as failing. The app icon renders correctly when extracted from the built bundle but has not been confirmed in Finder.
- **The first QA attempt was invalid, and the reason is worth more than the result.** The owner reported no summon sound, no dismiss animation, no quit animation, and no icon — four features, all missing at once. That shape was the clue: one cause, not four bugs. The Debug bundle had been rebuilt from `main` at 17:02 by the background session working on the multi-display defect, because `docs/DEVELOPMENT.md` documents a single hardcoded `-derivedDataPath` and the second worktree wrote to it. The owner tested a build of `main` and reported, accurately, that none of the work was in it.
  - Diagnosis was by inspection rather than by argument: the bundle held the 14-row atlas (98594 bytes against this branch's 102061), no `summon.wav`, no `dismiss.wav`, and no `Assets.car`.
  - Fixed by rebuilding to a branch-specific path. `DEVELOPMENT.md` now warns that the derived-data path is shared mutable state, and gives the one-line check that catches it: list the bundle's `Contents/Resources/`.
  - **This was self-inflicted.** The parallel task was suggested from this session without isolating its build output, and the cost landed on the owner as a wasted test cycle and a false bug report.
- Also worth keeping: the owner's screenshot showed the *installed* `~/Applications/Dock Pet.app`, still the July 30 build, which genuinely has no icon. Two different stale artifacts pointed at the same symptom.
- Verification: 184 package tests pass apart from the known multi-display failure; contract, both new rows, and the atlas validate; the isolated Debug build carries the 16-row atlas at a matching hash, all four WAVs, `Assets.car`, and `AppIcon.icns`.
- Next: the queue is unchanged apart from what closed today — the **reaction cues**, still never heard by anyone; drop-from-heights; the display matrix, which now has a known defect waiting for it; and the **animation speed control** decision.

## Next-session handoff

1. Read this file in full.
2. Treat `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` as the frozen base; never present another native tall variant as viable.
3. Treat atlas revision 6 as the current candidate: 16 rows, `768x1792`. Row 15 is the eight-frame `poof` smoke cloud and row 14 the four-frame `hand-sign` dismiss seal, both added 2026-08-01. `poof` is the only row that is not the character — no body, no baseline, drawn over the mascot on its own layer — the six-frame `hanging` row remains at index 13 with a `(48, 4)` top grip anchor, and the directional sit-shake rows use a small freestanding chair.
4. Establish the repository state with `git status --short --branch`, `gh pr list`, and `git branch -a`. Note that `git branch -r --merged main` is **not** a safe way to decide what is merged here: every PR is squash-merged, so a merged branch's tip is never an ancestor of `main`, and the command has reported branches merged minutes earlier as unmerged. Run `tools/list_merged_branches.sh`, which cross-references the remote refs against GitHub's merge record and flags branches that moved after their PR merged. This item deliberately no longer names a revision or a PR number. It did until 2026-07-31, and the claim went stale three times — the last time within minutes, because the commit that corrected it was merged immediately after. A hash here is invalidated by the very next merge, so it was removed rather than corrected again.
5. Treat the current presentation as `96x112` points with a 10-point transparent Dock inset. Revisions 5 and 6 append rows inside the existing cell geometry; they change nothing about the cell, the anchors, or any earlier row.
6. Ask the owner to test dragging from several body points and verify that the raised hand remains under the cursor while the body swings left/center/right. Since 2026-07-30 also verify what happens *after* the drop: the mascot must carry on roaming at the height it landed at, keep that spot across Dismiss/Summon and reopen, and return to the bottom lane only via Reposition. Retain the broader click, reopen, relaunch, and display-matrix QA. The full list is in `docs/QA_CHECKLIST.md`.
7. Preserve the honest capability boundary, which moved on 2026-07-30 and is no longer where earlier revisions of this line said it was. The app listens on the socket, reduces real events, animates from that state, ships an invocable helper inside its bundle, and **both provider adapters exist** as `dockpet-event --hook --provider <name>` (#8, #9 landed in [PR #21](https://github.com/Mr-Shine09/desktop-mascot/pull/21)). The Claude Code hooks were installed into `~/.claude/settings.json` and **observed driving the mascot from a live session**. What remains unproven is narrower and must still be stated exactly: **Codex has never been run live** — it shares the adapter, which is inference rather than evidence — and `waiting` and `failed` are fixture-covered but have never been seen from a real provider. Driving `failed` through the helper by hand does not count.
8. Treat `EventEnvelope` as the privacy boundary and `EventDecoder` as fail-closed. Do not widen the envelope, relax the `SessionID` charset, or copy payload text into an error without a recorded product decision. `AgentSession` and `EventPipelineDiagnostics` extend the same boundary and must gain no new field either — in particular, do not surface transport rejection *reasons* in the interface, since they are derived from bytes a caller controls. Keep the two clocks separate as well: wall-clock `occurredAt` orders events inside one session, monotonic `Uptime` drives expiry and reactions, and both stay caller-injected so fixtures remain deterministic. On the transport side, keep the helper's flag set closed, keep the session value hashed inside the helper, keep the `getpeereid` same-user check, and keep the socket path derived rather than passed in.
9. `DockGeometry` computes a bottom-anchored origin and has no Dock-edge inference at all. Do not reintroduce left/right Dock-aware placement without a fresh owner decision; it is future scope, not a bug to quietly fix back in. The one sanctioned exception to bottom anchoring lives in `WindowCoordinator`: `settleAfterDrop()` adopts the height the user dropped the mascot at, `hasManualPlacement` reports it, and `reposition()` is what discards it. Roaming is no longer a proxy for "the user placed this themselves" — dragging leaves roaming on — so do not reach for `isRoaming` to answer that question. `MascotVisibleState` remains the single typed source of visible state, and `AmbientAnimationController` has no `setPaused`/`setIdeating` of its own. Keep it that way: anything that wants to change what the pet is doing must go through the reducer, never by setting a row directly. Anything that wants to *accompany* an animation hangs off `onStateAppeared`, which fires after the selector's dwell, rather than off reduced state.
10. Do not mistake direct `open` activation for automatic panel focus theft; the verified background launch (`open -g`) left ChatGPT/Codex frontmost. Do not use `open -j`, which intentionally hides the app.
11. Merge and branch-delete commands are sometimes refused for the assistant by the auto-mode permission classifier and sometimes allowed; the outcome is not predictable in advance. If one is denied, hand the owner the exact command to run in their own terminal rather than retrying it or working around the denial.
12. The app **is** installed durably at `~/Applications/Dock Pet.app` by `tools/install_app.sh` ([PR #22](https://github.com/Mr-Shine09/desktop-mascot/pull/22)), ad-hoc signed with the nested helper signed first, and survives reboot. Relaunching is `open -g "$HOME/Applications/Dock Pet.app"`, not a rebuild. Two things still hold: the build is **not notarized**, so it is trustworthy only on the machine that built it and cannot be given to anyone else without a Developer ID certificate; and there is no launch-at-login by owner decision, so nothing starts it for you. `install_app.sh` will find and *attempt* any Apple Development identity in the local keychain before falling back to ad-hoc — set `CODESIGN_IDENTITY=-` to skip that lookup entirely.
13. More than one agent session may be working in this repository at the same time, sharing one working tree. Before committing, run `git status --short --branch` and confirm every staged file is yours; stash and rebranch rather than bundling another session's work into your commit.
14. One 0.1 scope line is unresolved and must not be closed by tidying it away: the **animation speed control** has been in `Scope` since 2026-07-28, does not exist in the sources (`grep -ri speed` returns nothing; `Preferences` holds only `roaming` and `reactionSoundsMuted`), and was never dropped by any decision. It is the only 0.1 commitment that is neither built nor consciously abandoned. Ask the owner to build it or strike it; do not resolve it yourself in either direction.
15. `aDropPastAnEdgeIsClampedBackIntoView` fails whenever a second display is attached, on `origin/main` as well as on any branch. `WindowCoordinator` resolves bounds through `panel.screen ?? NSScreen.main`, which follows keyboard focus. It is a real multi-display defect, not a flaky test — do not loosen the assertion to make the suite green.
16. The dismiss transition, the quit farewell, and the two transition cues were **owner-approved on 2026-08-01, happy path only.** Reduce Motion, re-summon mid-poof, dismiss-while-paused, and the second-Quit escape hatch are unexercised, and the icon is unconfirmed in Finder. Do not promote "the owner liked it" into "the edge cases pass."
17. **Give every worktree its own `-derivedDataPath`.** It is shared mutable state: on 2026-08-01 a background session rebuilt the Debug bundle from `main` while the owner tested a feature branch, producing a four-feature false bug report. Check `Contents/Resources/` before trusting any hands-on test.
18. Update this ledger before ending the next session.
19. Use `CLAUDE.md` and `docs/HANDOFF.md` as the maintainer onboarding entry points; keep them synchronized when architecture, commands, or asset contracts materially change.

## Documentation sources

- [Official Codex hooks documentation](https://learn.chatgpt.com/docs/hooks)
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Instagram reference post](https://www.instagram.com/p/DbV-I14FKJ2/?img_index=3)
