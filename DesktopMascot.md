# Desktop Mascot

> Living implementation ledger. Read this entire file at the start of every project session and update it before ending the session.

## Project snapshot

| Field | Current value |
| --- | --- |
| Project | Desktop Mascot for macOS |
| Owner | [Mr-Shine09](https://github.com/Mr-Shine09) |
| Started | 2026-07-28 |
| Last updated | 2026-08-11 |
| Status | **0.1 hands-on QA complete (2026-08-02).** Feature-complete and verified against a real Claude Code session. Orange Claude wardrobe corrected 2026-08-02 (sunglasses removed by owner decision, navy sleeves and sleeping blanket fixed), reinstalled, and owner-approved on screen the same day along with the whole two-mascot build. The Codex generator was repaired on 2026-08-02, the user-level hook file is installed, all seven definitions are trusted and Active, and a fresh real Codex turn completed with no hook failure. An independent installed-helper/socket smoke test passed. Installed durably at `~/Applications/Dock Pet.app` |
| Current gate | **Release gates only — 0.1 feature work and hands-on QA are both closed.** The **idle-CPU gate was restated to <3% by owner decision on 2026-08-09 and now passes** at a 2.17% median with an Energy Impact of 3.70, in the band of `launchd` and `bluetoothd`; the old <1% figure was unreachable by tick rate without dropping below the sprite's own frame rate. **Event-to-visible-state latency was measured the same day and passes** at ~70 ms typical against a 500 ms gate. Remaining: Reduce Motion sign-off, signing, notarization, packaging — and signing is blocked on a Developer ID purchase, which is out of scope by owner decision. **No open engineering gate remains; everything left is observation or a purchase.** **The three 2026-08-09 behavior changes were all observed on screen on 2026-08-10 and all pass** — they had been unobservable until that day, because the installed bundle predated them. **A real Codex session drove the navy mascot on screen on 2026-08-10, closing the last 0.1 provider claim** — it went to its computer, played the success reaction, and the orange mascot was unaffected throughout. **The four dismiss edge cases were walked the same day and all pass.** Hands-on claims still open: the fixture-only `failed` state, issue #11's broader Reduce Motion coverage (summon and dismiss honor it; roaming does not), the core app smoke test, and the rest of the display matrix | **The display matrix closed 2026-08-11** — eleven of eleven rows on per-row evidence, after nine of them spent a day ticked by a 2026-08-02 blanket verdict nobody had walked. It found the only behavioral defect of the week: a dragged height discarded when its display was unplugged, now fixed, unit-tested, and re-observed on screen. **Two owner decisions the same day:** mascots float over full-screen apps on purpose, and the stationary pose stays the standing `idle` blink, leaving atlas rows 11 and 12 deliberately unused. The roaming toggle was renamed **Stay in One Place**. **What is left for 0.1 is a README screenshot (owner capture), the core app smoke test, issue #11's Reduce Motion scope, the fixture-only `failed` state, and signing — a purchase.** **2026-08-11 also reversed a founding privacy promise by owner decision:** chat lifecycle detection reads one accessibility attribute on the Claude window, ships **off by default**, and **has never been observed working** — see the day's final entries and handoff item 38.
| Repository | [Mr-Shine09/desktop-mascot](https://github.com/Mr-Shine09/desktop-mascot) — **public as of 2026-08-09**, flipped by the owner. Public-release documentation, licensing, and CI landed 2026-08-08; the username scrub across 12 tracked files and the first green CI runs followed on 2026-08-09. Still true and permanent: every commit carries the owner's real name and email, so the repository is public but not anonymous. The README still has no screenshot |
| Initial release | Local-only native macOS app, macOS 14+ |
| Canonical source image | `~/Mr-Shine09/source-avatar-magenta.png` (outside the repository, on the owner's machine only) |

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
| Scheduled sleep defaults to 23:00–06:00 local time | During this window the inactive mascot sleeps under a blanket; new work interrupts sleep immediately. The hours became user-adjustable, and the schedule switchable off entirely, on 2026-08-09. |
| Independent Dock-edge window | The mascot visually occupies a lane at the Dock edge but does not inject into or modify the macOS Dock. Dock auto-hide may remain enabled. |
| Dock-only movement for 0.1 | Broader roaming across the lower screen is a later experiment after Dock hit-testing and distraction are validated. |
| Broad Claude/ChatGPT coverage is the goal | Supported lifecycle hooks are authoritative. Any ordinary ChatGPT app/web coverage must be explicitly labeled best-effort unless a documented lifecycle signal is available. |
| Non-coding activity means ideating | The mascot sits in a Thinker-style pose while a small thought cloud appears, changes, disappears, and loops. |
| Waiting means asking for attention | The mascot stops its current pose, turns toward the user, and raises one hand until work resumes or ends. |
| Success means delighted recognition | The mascot shows sparkling eyes and performs one quick fist pump, then returns to strolling or scheduled sleep. |
| Manual ideating mode for ordinary chats | Version 0.1 uses a menu-bar action and optional global shortcut; automatic ordinary Claude/ChatGPT detection is deferred until a trustworthy, privacy-preserving signal exists. |
| Direct mascot interaction | The owner's later explicit request supersedes passive click-through: the mascot accepts clicks for Pause/Resume, Stop/Resume Roaming, Close, and Quit options, and accepts drag/drop at any time. The menu-bar escape hatch remains available. |
| Previewed one-click hook installation | The app shows the exact Codex/Claude Code configuration change, backs up the affected file, installs only after confirmation, verifies it, and can remove only entries it owns. |
| Distinct Codex fashion | Claude Code and no-provider/manual states keep the approved navy/white atlas. Codex-attributed states use the same poses with dark sunglasses and an orange/white top; the lower outfit is unchanged. If both providers contribute to one reduced state, Codex wins the visual accent while diagnostics still name both. |

Grill verdict on 2026-07-28: `ready with experiments`. The 0.1 contract is ready; automatic non-coding chat detection remains a future experiment and does not weaken the manual mode.

### Questions to resolve before feature freeze

- Final product name and mascot name.
- Whether the first public release should remain private, become public source, or ship only as a notarized binary.
- ~~Whether Claude Code and Codex deserve distinct visual accents.~~ Resolved 2026-08-01: Codex uses the orange/sunglasses wardrobe; Claude Code retains the original wardrobe. **Superseded later the same day**: the owner reassigned orange to Claude and navy to Codex, then replaced selection entirely with two simultaneous mascots, one per provider. See the 2026-08-01 two-mascot decision in the implementation log. Reopened, not resolved.

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
- ~~An animation speed control.~~ **Deferred out of 0.1** on 2026-08-01 by owner decision ("forget about this for now"). No longer blocks 0.1 completion.
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
| Animation speed control | **Deferred** | 2026-08-01 | Owner decision: "forget about this for now"; no longer blocks 0.1 |

**Resolved 2026-08-01:** the animation speed control was deferred out of 0.1 by owner decision. All 0.1 scope commitments are now either built or consciously abandoned.

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
- `mascot-atlas@2x.png` remains the classic Claude/no-provider atlas. `mascot-atlas-codex@2x.png` is a deterministic semantic edit authored by `tools/author_codex_fashion_atlas.py`: orange shades replace only top-garment navy pixels, existing square glasses become dark sunglasses, and alpha, poses, props, effects, trousers, and shoes remain unchanged.
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

`paused > failure-recent > waiting > manual-ideating > working > success-recent > chat-ideating > scheduled-sleep > idle/strolling > offline`

Ideating sat below `working` until 2026-08-09; the historical entries below that date describe the original order and are not wrong about their own time.

**Chat-ideating is a second, weaker ideating rung, added 2026-08-11.** It comes from the frontmost application's bundle identifier matching an allowlist of the two desktop chat apps, and it sits below `working` — where manual ideating deliberately does not — because it cannot tell composing a prompt from re-reading an old conversation. It additionally **stands down entirely for a provider with any live session**: the Claude desktop app hosts both the chat and Claude Code behind one identifier, so hooks are treated as the authority whenever they are speaking. Browser tabs are out of scope permanently; detecting them means reading the user's browsing history.

Rules:

- Manual pause remains authoritative until the user clears it.
- Failure reaction initially lasts 4 seconds; sparkling-eyes/fist-pump success lasts 3 seconds.
- Waiting persists until that session emits `active`, `completed`, `failed`, or `stopped`.
- An active session expires to `offline` after a configurable heartbeat timeout; start with 120 seconds.
- Inside the scheduled sleep window in the Mac's current local time zone — 23:00 through 06:00 unless the user has changed it, and never if they have switched it off — inactivity becomes scheduled sleep immediately rather than strolling.
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
| Dismiss transition | Ninja seal row, pixel smoke row, deferred panel hide, quit farewell, and the two transition cues | Rows and timeline pass deterministic validation and 184 package tests on 2026-08-01; **owner watched and approved summon/dismiss/quit the same day, happy path only.** The four edge cases — Reduce Motion, re-summon mid-poof, dismiss-while-paused, and the second-Quit escape hatch — were each walked on **2026-08-10** and all pass |
| App icon | Rendered from the frozen base, full macOS slot set, present in the built bundle | Renders correctly when extracted from the built bundle on 2026-08-01; **owner confirmed in Finder from the installed `~/Applications` build on 2026-08-01** |
| Cursor-hanging row | Six frames, fixed top grip, frozen palette, binary alpha, no cliff/ledge, and cursor-attached drag geometry | Passed deterministic art validation, runtime pixel equality, drag geometry test, and Debug build on 2026-07-29; physical feel pending |
| Native app scaffold | Generated Xcode project, modular package, embedded atlas resources, static nearest-neighbor render, and startup/reopen smoke tests | Passed initial scaffold on 2026-07-28; fresh Debug relaunch restored a visible `96x112` window on 2026-07-29 |
| Window geometry | Automated fixtures plus manual multi-display matrix | Rescoped 2026-07-30: `DockGeometry` is bottom-anchored only and has no Dock-edge inference, but later the same day `WindowCoordinator.settleAfterDrop()` gained a sanctioned override so a dropped mascot roams at the height it landed at, with `reposition()` the one way back to the default lane. Thirteen tests pass (`swift test --filter MascotWindowTests`), covering placement, clamp-with-guard, visibility, manual-position preservation across Hide/Show, non-activating interaction, click routing, drag begin/end routing, a drop that keeps both axes, an off-edge drop that clamps, roaming that preserves a dropped height, and reposition restoring the lane. The multi-display matrix is still pending, and a dropped height interacting with a display change is new untested surface |
| Atlas runtime mapping | Every declared row crops to the matching frozen frame pixels | Passed 2026-07-29 for offline, idle, working, ideating, both walk directions, both chair sit rows, and hanging; extended 2026-08-01 to `hand-sign`. `poof` is covered by the atlas validator but not by the pixel-equality test |
| Provider-specific fashion (**superseded 2026-08-01** by one mascot per provider: Claude wears orange, Codex wears classic, and nothing is "selected" any more) | Codex attribution selects the orange/sunglasses atlas; Claude/no-provider selects classic; both atlases preserve cell geometry and alpha | Structural and deterministic checks passed 2026-08-01. Codex hooks were exercised by a real turn on 2026-08-02, but the navy mascot's on-screen response and the orange wardrobe still await owner visual approval |
| Ambient animation | Atlas timing, directional movement, alternating walk direction, random offline rests, and bounded bottom-lane motion | Corrected live samples show distinct right gait while x increases and left gait while x decreases; offline transition also visually verified |
| Portal summon | Portal opens before mascot emergence, mascot is fully visible before closure, hide/show and reopen replay the transition, and Reduce Motion avoids translation/scale motion | Passed three deterministic timeline fixtures inside a 116-test package suite and an unsigned Debug build on 2026-07-29; owner visual QA pending |
| Event envelope and decoder | Version/provider/event allowlists, opaque session-ID validation, payload ceiling, RFC 3339 parsing, injected-clock skew bounds | Passed 2026-07-29: 21 decoder fixtures inside a 31-test package suite |
| State reducer | Unit tests for ordering, duplicates, expiry, concurrency | Passed 2026-07-29: 39 registry/reducer fixtures inside a 70-test package suite, covering the full documented priority order, duplicate idempotence, stale-event rejection, heartbeat expiry boundaries, bounded reaction boundaries, stopped grace, capacity eviction, wake reconciliation, sleep-window hours, and concurrent providers. Two mutation checks confirmed the heartbeat-refresh-only and stale-ordering guards are genuinely enforced. Not yet wired to the app |
| Privacy | Forbidden fields absent from storage and diagnostic output | Passed 2026-07-30 across all three layers: forbidden keys are discarded at the decoder, `AgentSession` stores only the envelope's allowlisted fields, and the menu-bar diagnostics carry counts, a session count, and one coarse state. Rejection reasons are deliberately dropped at the bridge, so no caller-controlled byte can reach the interface |
| Local event transport | Framing fixtures, same-user peer check, owner-only permissions, malformed/oversized frame survival, socket lifecycle, and a cross-process helper run | Passed 2026-07-29: 37 transport fixtures inside a 113-test package suite, plus a cross-process run in which the real `dockpet-event` binary delivered a hashed-session `waiting` event to a listener on the real default path. Wired into the running app on 2026-07-30 |
| Reduced state drives animation | Every state maps to a declared row, only chilling states stroll, rapid flips do not thrash, manual pause and ideating travel through the reducer | Passed 2026-07-30: 13 `AnimationSelector` fixtures inside a 143-test suite. Owner-verified live the same day against a process confirmed newer than the binary — `active` stopped the pet at the computer, `completed` played the success sparkle then returned it to strolling, Pause stopped it instantly, and Manual Ideating held the Thinker pose. The 120-second expiry boundary stays fixture-only, since idle and offline both stroll and are not visually distinguishable |
| Event path inside the app | Server starts at launch, delivered events reach reduced state, counters and status appear in the menu bar, socket is removed on quit | Passed 2026-07-30 for the transport and pipeline layers: 9 `EventPipeline` fixtures and 3 fixtures running a real socket server into a real pipeline, inside a 130-test suite. Live: the launched Debug app bound `events.sock` at `0600`, accepted a five-event `dockpet-event` sequence plus a malformed frame without dying, and unlinked the socket on quit. Owner-verified on screen 2026-07-30: with the app running and one `dockpet-event --provider claude-code --event active` delivered, the menu bar read `Event socket: listening • 1 accepted • 1 session` and `Reduced state: Working (claude-code) — not driving animation yet` |
| Provider adapters | Fixture tests and live smoke tests | Claude live capture passed 2026-07-30. On 2026-08-02 all seven Codex hook definitions were reviewed, trusted, shown Active, and exercised by a fresh real Codex turn through clean shutdown with no hook failure; a separate installed-helper/socket smoke test delivered `active -> completed -> stopped`. **The Codex mascot's on-screen response was verified 2026-08-10** — a real turn drove the navy mascot to its computer and through the success reaction, with the orange mascot unaffected. `waiting` was seen from a real session 2026-08-09. **`failed` alone remains unverified against a real provider** |
| Reaction cues | Deterministic regeneration, non-silent measurement, correct firing moment, mute toggle, and owner listening | **Owner-approved 2026-08-01.** `tools/author_sound_effects.py` reproduces both WAVs byte for byte, both measured non-silent at 0.54s/0.42s, the cue is fired from `onStateAppeared` so it lands with the frames rather than ahead of them, sound is gated on `success`/`failure` plus `isVisible`, and a persisted menu toggle mutes it. Owner heard both cues from the installed `~/Applications` build and confirmed they work |
| Accessibility | Reduce Motion, pause, VoiceOver/menu-bar review | Partial 2026-07-30: menu-bar status lines carry spoken labels and every control is reachable without the mascot on screen; Reduce Motion is honored by the **summon and dismiss** transitions, both confirmed on screen 2026-08-10; roaming and the ambient states do not honor it, which is issue #11's open scope question. Not reviewed with VoiceOver actually running — that is owner QA |
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

### 2026-08-01

- Defer the animation speed control out of 0.1. Owner's stated reason: "forget about this for now." This resolves the last open 0.1 scope question — every scope commitment is now either built or consciously deferred. The speed control moves to post-0.1 experiments alongside cursor-following, user-imported sprites, and auto-update.
- Confirm drop-and-roam from the installed `~/Applications` build. Owner tested dragging to several heights and confirmed the mascot roams at the dropped height as intended.
- Confirm the app icon from the installed build. The previous check looked at the July 30 install, which had no icon; the current build shows the mascot headshot in Finder.
- Use provider attribution to select wardrobe without creating a second animation-state path. Claude Code and providerless/manual states use the classic navy/white atlas; any Codex-attributed reduced state uses the orange/white top and sunglasses. When both providers contribute, show Codex fashion and keep naming both providers in diagnostics.

### 2026-08-02

- **Drop the sunglasses from the orange wardrobe.** Owner's stated reason, after seeing them on screen: "Forget about the sunglasses. Just use normal glasses and go back." The two mascots are now distinguished by the hoodie alone — the orange atlas is otherwise pixel-identical to the classic one above the neck. `author_codex_fashion_atlas.py` defaults to `--eyewear clear`; the lens-filling code stays reachable behind `--eyewear sunglasses` and is the only reason that machinery is kept. Three defects were found and fixed while the shades were still in scope, and they matter regardless of eyewear: the raised-arm sleeve stayed navy in `success`, `waiting`, and the whole `hanging` row, because the shirt mask searched a rectangle that began below the chin and so never considered a sleeve lifted above the shoulders.
- **Recolor the `sleeping` row.** Owner report: the Claude mascot slept under a navy blanket while wearing an orange hoodie. The row had been excluded from the shirt recolor outright. It is now included, with the ground-line shoe guard disabled for that state only: lying down, no shoes are visible, and the blanket, the tucked sleeve, and the collar are the only navy left. The blanket is therefore per-mascot bedding, not shared bedding.
- **Do not read transcripts to build a usage bubble.** The owner asked for a speech bubble showing streak and token usage per day/week/month. Hook payloads carry no token data at all (`session_id`, `cwd`, `tool_name`, `permission_mode`, `transcript_path`); only the Claude Code *statusline* receives `context_window.total_input_tokens` and the 5h/7d rate-limit percentages, and neither is bucketed by calendar day. Day/week/month totals exist only by summing the `usage` blocks in `~/.claude/projects/**/*.jsonl`, which the first privacy rule forbids this app from touching. Token counts were dropped from the request by the owner the same day; the streak alone remains. Any future numeric bubble must read a small integers-only summary file written by tooling outside Dock Pet, never a transcript.

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
  - Helper exit codes verified directly: 0 with no listener running, 0 for `--help`, 64 for an unknown flag and for an unknown event. The unknown-flag message printed `unknownFlag` and did not echo the `~/secret` argument value.
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
- Repository visibility was discussed and deliberately **not** changed. If it is revisited, the blockers are unchanged and were verified rather than assumed: 12 tracked files embed an absolute `/Users/<owner>/...` path (scrubbed 2026-08-09); all 60 commits carry the owner's real name and personal email, which cannot be scrubbed without rewriting history and breaking every clone; and the mascot is a recognizable likeness derived from a personal avatar, which forks make permanent. The path scrubbing is worth doing regardless of visibility, because those absolute paths break the art tooling on any other machine.
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

### 2026-08-01 — Merge, install, and installed-version QA

- Objective: merge both open PRs, rebuild and install the app, and get owner QA from the installed copy rather than a debug build.
- Completed:
  - Merged [PR #32](https://github.com/Mr-Shine09/desktop-mascot/pull/32) and [PR #33](https://github.com/Mr-Shine09/desktop-mascot/pull/33) into `main`. No open PRs remain.
  - Rebuilt Release and installed to `~/Applications/Dock Pet.app` via `tools/install_app.sh` with an isolated `-derivedDataPath` at `/private/tmp/DockPetDD-dismiss`.
  - Verified the installed bundle contains all four WAVs, `Assets.car` (with the icon), and the 111 KB revision-6 atlas.
  - Owner tested the installed version and confirmed: dismiss animation, quit farewell, summon/dismiss sound cues, drag-and-drop at multiple heights, and the app icon in Finder all work.
  - Owner deferred the animation speed control out of 0.1 ("forget about this for now"). This resolves the last open scope question — all 0.1 commitments are now either built or consciously deferred.
  - Owner confirmed drop-and-roam works as intended.
  - Owner noted the mascot goes behind the Dock when near it, which is expected bottom-anchored behavior.
- Decisions: animation speed control deferred to post-0.1. See the 2026-08-01 decision log below.
- Verification: installed `~/Applications/Dock Pet.app` is the source of all owner QA this session, not a debug build. Bundle resources confirmed present before the owner tested.
- Risks or blockers: the two reaction cues remain unheard. The display matrix remains untested beyond what the owner noticed incidentally (mascot goes behind Dock).
- Next: **listen to the two reaction cues** — this is now the only remaining hands-on QA item before the display matrix.

### 2026-08-01 — Provider-specific Codex fashion

> **Superseded the same day.** The mapping below (classic for Claude, orange for Codex, Codex winning the accent when both contribute) was reversed and then replaced entirely by one mascot per provider. Kept as the record of how the atlases were authored; do not act on its wardrobe rules. See the two-mascot entries at the end of this log.

- Objective: make Claude Code and Codex visually distinguishable without changing the approved mascot identity, animation timing, lower outfit, props, or state semantics.
- Completed:
  - Added `tools/author_codex_fashion_atlas.py`, which deterministically derives `art/animation/mascot-atlas-codex@2x.png` from revision 6 and writes a full 16-row QA contact sheet plus per-frame authoring counts.
  - Changed only the top-garment navy shades to three orange shades and converted the existing square glasses into dark sunglasses with a retained native-pixel glint. Gray trousers, navy shoes, blanket, props, effects, anchors, alpha, and pose geometry remain unchanged.
  - Added `MascotFashion` selection from the provider list already carried by `MascotVisibleState`; this preserves the reducer as the single source of truth. Claude Code/no-provider/manual states use classic, Codex uses orange, and Codex wins the accent when both providers contribute while diagnostics continue to name both.
  - Bundled both atlases and made resource loading fail explicitly if the Codex atlas is missing.
- Decisions: this resolves the long-open per-provider visual-accent question. Wardrobe is presentation derived from the reduced state's provider attribution, not a new reducer state or synthetic event.
- Verification: the authoring run reproduced SHA-256 `65bcb799f02cf25c7bbe6f1dc0f5facb301e6536bda91247a0a249ac01e1c85e`; 188 Swift package tests pass; every classic/Codex frame has identical dimensions and alpha, the poof row is pixel-identical, three provider-fashion fixtures pass, the 16-row contact sheet passed internal visual review, and an isolated unsigned Debug Xcode build succeeds with a byte-identical bundled Codex atlas.
- Risks or blockers: owner visual approval is pending, and Codex still has not driven the app from a live provider session. The mixed-provider policy is deterministic but has not been observed live.
- Next: owner reviews `art/animation/qa/contact-sheet-codex-fashion-4x.png`, then the display-matrix QA queue resumes. All four sound cues are already owner-approved.

### 2026-08-01 — Orange wardrobe: celebration eyes and three severed-sleeve defects

- Objective: owner review of the orange atlas reported that the sunglasses stay on during the task-accomplished animation. Investigate, fix if warranted, and produce a preview.
- Findings: the report was correct and two further defects sat beside it, all in `tools/author_codex_fashion_atlas.py`.
  - **The shirt mask never considered a raised sleeve.** Candidate navy pixels were gathered from a rectangle starting one row below the chin, so any sleeve lifted above the shoulders fell outside it: the `success` fist-pump, the `waiting` wave, and every frame of `hanging` kept a navy arm on an orange hoodie.
  - **The lens mask missed entirely on `success` frame 2.** Lens rows were taken as a fixed offset below the top of the skin bounding box; when the head tilts back the forehead rises, so the offset landed in the hair. The lenses stayed light and two glint pixels were stamped into the hair, making the shades flicker off for one frame mid-celebration.
  - **Flat dark lenses erase the celebration.** The classic `success` row draws sparkle eyes as dark strokes on light lenses, which the sunglasses recolor blacked out — the defect the owner actually saw.
- Fixes:
  - The shirt mask now runs connected components over the whole frame. Classification is by how far below the face a component starts: shoes are left alone, sleeves and severed hem pieces are recolored.
  - Lens rows are anchored to the lens pixels themselves, searching only the upper half of the face so the white hoodie drawstrings and an open mouth cannot be mistaken for a lens. The fixed offset survives only as the blink-frame fallback, where no light lens pixel exists.
  - Added `--celebration-eyes`. **Owner chose `shades-sparkle` (2026-08-01):** the lens goes dark and the sparkle strokes flip to white, so the shades stay on in every state and the celebration still reads. `no-shades` keeps the classic light spectacles for that row and is not what shipped.
- Verification: leftover navy is now uniform across every non-sleeping row at 15–52 pixels confined to y91–101, the shoes — previously it reached y47 mid-torso. The lifted-foot shoes in `walk` and `hanging` are preserved, and `hand-sign` is a clean 31 in all four frames. The atlas adds exactly the three declared orange shades and no others; alpha silhouette and dimensions are asserted unchanged and `poof` remains untouched. 188 package tests run with only the known multi-display `aDropPastAnEdgeIsClampedBackIntoView` failure. All 16 rows passed contact-sheet review.
- Risk: the shoe/hem split is a **measured** threshold, not a structural one. Across all 92 frames of the source art the severed hem pieces start at most 19 rows below the face and the nearest shoe starts at 21. The tool raises if an accepted component ever reaches the sprite's ground line, so a drift in the source art fails loudly instead of quietly recoloring a shoe. Re-measure rather than widen the threshold.
- Next: this row-level fix is independent of the wardrobe mapping, which the owner has since superseded — see the decision below.

### 2026-08-01 — Owner decision: two mascots, one per provider

Asked whether to swap the wardrobe mapping so orange means Claude and navy means Codex, the owner replaced the feature rather than confirming it: they want **two mascots summonable at once when both providers are running**, orange for Claude and navy for Codex. When only one provider is active, that provider's mascot reacts to its lifecycle state and the other stays "normal" — ambient idle/roaming rather than absent.

This supersedes the 2026-08-01 "Provider-specific Codex fashion" resolution above and the entry at line 83. Wardrobe stops being a *selection* derived from one collapsed state and becomes the identity of a separate mascot, which conflicts with two load-bearing assumptions: `MascotStateReducer` collapses every session across all providers into a single `MascotVisibleState`, and `WindowCoordinator` owns exactly one `MascotPanel`.

Owner answers recorded the same day:

- **Presence is manual and per mascot.** The menu bar gains independent summon toggles for the Claude mascot and the Codex mascot. Neither appears on its own when a provider is detected, preserving the standing rule that launching or observing activity never puts a mascot on screen by itself.
- **One sound cue only.** If either mascot enters `success`/`failure` inside the same window, exactly one cue plays. Two identical WAVs milliseconds apart read as a glitch, and the existing `reactionSoundsMuted` key keeps its name.

- **Side by side, then independent.** The second mascot summons offset one body-width along the lane so the two never appear stacked. After that each roams and drags freely and they may cross; no collision avoidance is added to the roaming loop, which would otherwise fight a mascot the owner deliberately placed.
- **`Preview State` drives both mascots.** It is a QA tool for seeing an animation, not for testing provider attribution, so it stays a single flat menu rather than gaining a per-mascot submenu.

### 2026-08-01 — Two mascots, one per provider: implementation

- Objective: build the decision above without giving anything a second source of truth about what a pet is doing.
- Completed:
  - `MascotStateReducer.reduce(sessions:attributedTo:)` filters to one provider and reuses the existing priority ladder unchanged, rather than adding a provider-specific ordering. `EventPipeline` now publishes `visibleStates` (one entry per provider, always populated) alongside the collapsed `visibleState`, which is demoted to feeding the menu-bar diagnostics.
  - `MascotFashion` stops being a selection. `worn(by:)` maps Claude to `.orange` and Codex to `.classic`, and the case formerly called `.codex` is renamed `.orange` so the type no longer implies a provider. `AmbientAnimationController` takes one fixed atlas instead of a dictionary, and its mid-animation wardrobe-swap path is deleted — a controller can no longer change outfit.
  - New `MascotInstance` owns one provider's preview model, panel, coordinator, and animation controller. `AppDelegate` holds an array of them and exposes `setVisible(_:for:)`; `summoned` is a set of providers and `isVisible` is derived from it.
  - `WindowCoordinator` gained a `laneOffset` applied to the *default* placement only, clamped to the screen, so two mascots summoned together arrive side by side instead of stacked. Roaming and dragging stay fully independent afterwards.
  - Menu bar has an independent Summon/Dismiss per mascot; the click-through mascot menu names the pet that was clicked. Reposition and roaming apply to all mascots; pause, ideating, and Preview State reach both by going through the reducer's overrides as before. Quit says goodbye from every mascot on screen and terminates when the last farewell completes.
  - Reaction cues coalesce into one per 0.6-second window across mascots; summon and dismiss cues stay per mascot because each is the sound of a specific pet arriving or leaving.
- Verification: 194 package tests pass with only the known multi-display `aDropPastAnEdgeIsClampedBackIntoView` failure, which reproduces on `origin/main`. Six new fixtures cover per-provider isolation, the offline-means-strolling default, provider attribution, override reach, and the always-populated `visibleStates`. An isolated unsigned Debug build succeeds against its own `-derivedDataPath`, carries both atlases, and the bundled orange atlas is byte-identical to the workspace copy (`924a59ae…`). The build launches without crashing.
- Risks or blockers: **no hands-on verification exists for any of this.** Summoning each mascot alone and together, side-by-side placement on a real display, independent dismiss, the click-through per-mascot menu, and the one-cue-per-window rule have never been seen on screen. The cue-coalescing window is a guess at what reads as one sound. Codex has still never driven the app live, so a two-mascot session with both providers actually working has never happened.
- Next: owner hands-on QA of the two-mascot build, then the orange wardrobe visual check, then the display matrix — which now has twice as many panels to get wrong.

### 2026-08-02 — Codex hook connection repair and local install

- Objective: connect real Codex lifecycle events to the navy Codex mascot, matching the already-live Claude path without widening the privacy boundary.
- Root cause: `HookConfiguration` emitted Claude Code's separate `args` field for both providers. Codex command hooks accept one shell command string, so Codex launched `dockpet-event` without `--hook --provider codex`; it exited with a usage error and emitted no mascot event. The generated `SessionEnd` timeout was also 5 seconds although Codex caps it at 3.
- Completed:
  - Made hook rendering provider-specific: Claude retains executable plus `args`; Codex receives one POSIX-shell-quoted command containing the helper path and both flags. Codex `SessionEnd` now uses the documented 3-second ceiling.
  - Added three regression fixtures for the Codex command shape, absent `args`, timeout ceiling, and apostrophe-safe shell quoting.
  - Installed `~/.codex/hooks.json` with seven lifecycle events pointing at the durable helper in `~/Applications/Dock Pet.app`, rebuilt and ad-hoc signed the app, and relaunched it.
- Verification: all 22 focused hook-adapter tests pass. The full suite ran 197 tests; 196 pass and only the documented second-display `aDropPastAnEdgeIsClampedBackIntoView` defect fails. The installed binary prints a Codex snippet with no `args` field and a 3-second `SessionEnd`. The installed helper delivered `active -> completed -> stopped` as provider `codex` through the running app's real owner-only socket.
- Follow-up verification: the seven user-level hook definitions were reviewed in `/hooks`, the shared Dock Pet command was confirmed, and all seven were trusted and shown Active. A fresh Codex turn submitted a prompt, returned `OK`, and shut down cleanly with no hook failure, exercising the provider path. A second fresh CLI startup opened directly without another review prompt, proving the trust decision persisted. The app was running and the installed helper had already proven socket delivery. The navy mascot was not summoned/observed, so on-screen attribution is still a hands-on gate. No prompt, transcript, path, tool input, or output was read or forwarded by Dock Pet.
- Next: summon both mascots and run a normal Codex turn while watching that only the navy mascot enters working/success and the orange Claude mascot keeps strolling.

### 2026-08-02 — Orange wardrobe corrections and the usage-bubble question

- Objective: act on the owner's first look at the orange Claude wardrobe on screen, and answer whether a streak/token speech bubble is feasible.
- Completed:
  - Fixed the raised-arm sleeve staying navy in `success`, `waiting`, and every `hanging` frame. The shirt mask searched a rectangle beginning below the chin, so a sleeve lifted above the shoulders was never a candidate. It now runs connected components over the whole frame and classifies by how far below the face each starts, with a ground-line assertion that fires if the split ever drifts far enough to reach a shoe.
  - Fixed the lens mask misfiring on `success` frame 2, where the tilted-back head raised the skin bounding box and the fixed row offset landed in the hair, leaving the lenses lit and stamping two glint pixels into the fringe.
  - Removed the sunglasses entirely at the owner's instruction and restored the character's ordinary glasses. `--eyewear clear` is the default; `--eyewear sunglasses` still reaches the lens-filling code.
  - Recolored the `sleeping` blanket, sleeve, and collar orange. The row had been skipped by the shirt recolor outright.
  - Reinstalled to `~/Applications` and confirmed the bundled orange atlas is byte-identical to the workspace copy (`2a97fc5a…`).
- Decisions: see the 2026-08-02 decision log.
- Verification: the tool's own invariants pass — alpha silhouette and dimensions unchanged, `poof` untouched. `sleeping` now has zero navy pixels; every other row retains only its shoes. 196 of 197 package tests pass, with only the documented second-display `aDropPastAnEdgeIsClampedBackIntoView` failure. The owner reviewed a navy-versus-orange contact sheet for eight rows.
- Risks or blockers: **the corrected wardrobe has still never been seen running on screen.** Every check above is a contact sheet or a pixel assertion. The blink-frame lens fallback and the ground-line shoe assertion are both measured against the current art rather than structurally guaranteed, so new frames could invalidate either. `install_app.sh` prompted for the login keychain password chasing an Apple Development identity, failed with `errSecInternalComponent`, and fell back to ad-hoc as always; `CODESIGN_IDENTITY=-` skips the prompt.
- Next: hands-on QA of the two-mascot build, now with corrected art. Then decide where a streak value would come from — nothing in Claude Code produces one, and no local file on this machine holds one.

### 2026-08-02 — Multi-display clamp fix

- Objective: fix the `aDropPastAnEdgeIsClampedBackIntoView` failure that had been open since 2026-08-01 and documented as a deterministic second-display defect.
- Root cause: `NSWindow.screen` is nil whenever the panel lies entirely outside every display — exactly what a drop past an edge produces — and `WindowCoordinator` then fell back to `NSScreen.main`, which is *the display with keyboard focus*. The clamp therefore depended on where the user happened to be typing, so the same drop settled in different places between runs.
- Completed:
  - Added `WindowCoordinator.referenceScreen`, which prefers `panel.screen`, then the display the panel was last genuinely on, then the display nearest the panel, and only then `NSScreen.main`. A pet thrown off an edge returns to the display it came from rather than moving to another one.
  - Replaced all three `panel.screen ?? NSScreen.main` sites, including `reposition(on:)`.
  - Added `aStrandedDropSettlesDeterministicallyOnTheDisplayItCameFrom`, which asserts the panel really is stranded, that it lands back on the display it started on, and that repeating one drop lands in one place. Focus cannot be set from a test, so the test pins the property focus dependence would break rather than focus itself.
- Decisions: prefer the last-known display over the nearest one. The nearest-display rule was implemented first and rejected: with this two-display arrangement a drop above the built-in screen resolves as nearest to the *external* one, so the pet would silently change displays after being thrown off an edge. Nearest is retained only as the fallback when there is no history.
- Verification: the full 198-test suite passed five consecutive runs with two displays attached; the window suite passed four more under `--filter`. Before the fix the same test failed three consecutive filtered runs and passed in isolation, which is what established it as intermittent rather than deterministic.
- Corrections to this ledger: handoff item 15 and two `docs/HANDOFF.md` claims stated the test "fails whenever a second display is attached" and was "not a flaky test". Both were wrong — it was intermittent, and the instruction not to loosen the assertion was right for the wrong reason. All three are corrected.
- Risks or blockers: the fix is verified only against this one two-display arrangement (built-in `0,0 1280x832` plus external `1280,-248 1920x1080`). Display unplugging, mismatched-height gaps, and sleep/wake are still untested by hand. The rest of the display matrix is unchanged and still open.
- Next: unchanged — owner hands-on QA of the two-mascot build.

### 2026-08-02 — Owner hands-on QA of the two-mascot build

- Objective: close the last 0.1 gate by putting the two-mascot build, the corrected orange wardrobe, and the multi-display clamp fix in front of the owner.
- Completed: the owner ran the full hands-on pass from the installed `~/Applications` build and reported every listed item smooth — two mascots side by side, per-mascot menus and dismissal, independent dragged positions, a real Claude Code task animating the orange mascot while the navy one strolled, one success cue for both, the orange wardrobe and sleeping blanket at native size, the drag/hanging pass, the display matrix, and the four dismiss edge cases (Reduce Motion, re-summon mid-poof, dismiss-while-paused, second Quit).
- Also re-ran the automated baseline: `git diff --check` clean, contract and classic atlas validate, 198 package tests pass, the Release build succeeds, and both atlases plus the contract are byte-identical between the workspace and the installed bundle. The orange atlas's three out-of-palette colors were proven by set difference to be exactly the three shades declared in `author_codex_fashion_atlas.py`, with no palette color removed.
- **Evidence granularity, recorded deliberately:** the owner's report was a single overall verdict ("every QA done, it is smooth"), not per-item observation. `docs/QA_CHECKLIST.md` ticks those items as owner-accepted on that basis. Do not later cite any individual tick as an independently narrated observation.
- Still unverified, and deliberately left unticked: **a real Codex session driving the navy mascot on screen.** Codex's hooks are installed, trusted, and were exercised by a real turn earlier the same day, but nobody has watched the mascot react. This is the last unproven provider claim in the project. Also untested: `@1x`/non-Retina behavior, the sound-toggle persistence items, icon sizes at 16/32/128pt, and every future release gate.
- Risks or blockers: the display matrix was exercised against one two-display arrangement only. The build remains ad-hoc signed and unnotarized, so it is trustworthy only on the machine that built it — distribution needs a Developer ID certificate and is out of scope by owner decision.
- Next: 0.1's hands-on gates are closed. The remaining work is release-gate work, not feature work — energy/latency measurement, signing and notarization, and packaging. Nothing further should be treated as a 0.1 blocker without a fresh owner decision.

### 2026-08-02 — First energy and memory measurement

- Objective: measure the idle CPU, memory, and swap release gates, which had never been quantified.
- Method: installed `~/Applications` build, launched with `open -g`. Sampled cumulative CPU time (`ps -o cputime=`) every 15 s for 11 minutes and differenced it, rather than reading `ps %cpu`, which is a decaying average and would have understated a steady load. RSS and system swap sampled alongside; `footprint` read at the end.
- Result — **the idle CPU gate fails**:
  - No mascot summoned: 0.40% median CPU (n=5), 77 MB RSS.
  - One mascot on screen: **3.40% median, 3.51% mean, 6.87% max** (n=39 over 9.8 min).
  - The gate is "idle CPU median below 1% over ten minutes". At 3.40% it is missed by more than 3x. The cost is squarely the animation loop: the same build with no mascot summoned is under half a percent, so neither the event socket, the reducer, nor the menu-bar item is responsible.
  - Measured with **one** mascot. Two on screen were never measured, and there is no basis yet for assuming the cost is linear.
- Result — memory and swap pass:
  - `phys_footprint` 36 MB, peak 37 MB, 48 KB swapped. Well inside the 80 MB gate.
  - RSS reads 81 MB and appears to breach the gate, but RSS counts shared framework pages; `phys_footprint` is what Activity Monitor reports as Memory. Do not re-report the RSS figure as a failure.
  - No growth trend across the window: RSS fell from 88.7 MB to 80.9 MB.
  - System-wide `vm.swapusage` rose from 743 MB to 1055 MB during the window, but that is the whole machine under a concurrent Xcode build and is **not** attributable to Dock Pet. The 48 KB per-process figure is the one that means anything.
- Decisions: none taken. Whether to throttle the animation loop or restate the gate is an owner call, and both are defensible for an app whose entire purpose is an animated sprite.
- Risks or blockers: the idle-CPU gate is the first hard release gate to fail on evidence rather than remain unmeasured. Options are a lower frame rate while strolling, pausing the loop when the panel is occluded or on another Space, or coalescing the two mascots onto one timer. None is implemented.
- Next: owner decides between throttling the loop and restating the gate. Latency, Reduce Motion sign-off, signing, notarization, and packaging remain untouched.

### 2026-08-03 — Menu bar item became unrecoverable; app rebuilt around an owned NSStatusItem

- Symptom: the owner reported that clicking Dock Pet did nothing and no icon appeared in the menu bar. The process was not running, and launching it produced no icon, no window, and no crash report — it simply exited 0 within about two seconds.
- Root cause: the menu bar item had been removed from the menu bar at some point, almost certainly a Command-drag during QA. macOS remembers that permanently, and Control Center re-sends `NSStatusItemChangeVisibilityAction` to the app on every launch. The unified log shows that action arriving and AppKit's `terminate:` firing on the very next line, roughly 0.15 s after launch. Because the SwiftUI `MenuBarExtra` was the app's **only** scene, hiding it left SwiftUI with nothing to run, so it terminated the process. The app could not be launched, controlled, or quit through any UI.
- Why the obvious fixes failed:
  - Deleting or setting `NSStatusItem VisibleCC Item-0` to true in the app's domain did not survive: the app rewrote it to 0 within a second, because Control Center reapplies the hide on each launch.
  - Restarting `cfprefsd` and `ControlCenter` changed nothing. The removal is not stored in any `com.apple.controlcenter` plist that could be safely edited — that domain holds the entire menu bar layout, so it was left alone.
  - Pinning `MenuBarExtra(isInserted: .constant(true))` fixed the *termination* — the process stayed alive past 15 s where it had died in under 2 — but the icon stayed hidden. Control Center's hide still won. Confirmed by the owner on screen.
- Partial fix: the app now owns its menu bar item. `AppDelegate.installStatusItem()` creates an `NSStatusItem` with `autosaveName = "DockPetMenuBarItem"` — a fresh identity with no removal remembered against it — and sets `isVisible = true` unconditionally. The existing SwiftUI `MenuBarContent` is reused verbatim through `NSHostingMenu`, so no menu item changed. `DesktopMascotApp` keeps `Settings { EmptyView() }` only because `App` requires a scene; it opens no window under `LSUIElement`.
- Decisions:
  - **The menu bar item may not be user-removable.** An accessory app with a second window could honour the removal; this one cannot, because honouring it uninstalls the app by accident. Quitting remains the way to get rid of it.
  - **Deployment target raised from macOS 14.0 to 14.4** for `NSHostingMenu`. The alternative was a second hand-written AppKit copy of the whole menu kept in sync with the SwiftUI one. Still inside the project's "macOS 14+" rule, and 14.4 is a free update, but it is a narrowing and was the owner's call to accept.
- Verification: after the fix the app persists `NSStatusItem VisibleCC DockPetMenuBarItem = 1` and stays alive past 20 s. Package tests unaffected. **The owner then confirmed the icon was still missing — see the entry below. This fix stopped the app killing itself; it did not bring the icon back, and the commit message and PR #38 both overstate it.**
- Risks or blockers: `CGWindowList` reports zero layer-25 windows on this macOS, so menu bar item visibility **cannot be verified programmatically** — Control Center hosts status items out of its reach. Any future claim that the icon is visible has to come from a person looking at the menu bar. A crowded menu bar can also hide an item that is genuinely visible, which no app-side code can fix.
- Next: owner confirms the icon on screen. If a mascot is ever stranded again with no icon, the mascot panel itself still opens a menu on click, including Quit — that is the standing fallback.

### 2026-08-03 — Menu bar removal is keyed to the bundle identifier

- Objective: find why the pawprint was still absent after the app took ownership of its `NSStatusItem` with `isVisible = true`.
- Result: **a menu bar removal is remembered against the bundle identifier, in a system store outside the app's preferences, and nothing the app does escapes it.** One binary was built twice, changing only `PRODUCT_BUNDLE_IDENTIFIER`. Under `com.mrshine09.dockpetprobe` the pawprint appears in the menu bar. Under `com.mrshine09.desktopmascot` it never appears — with the preferences domain emptied, `NSStatusItem VisibleCC DockPetMenuBarItem = 1`, and the item created and `isVisible` true in both. Everything else was identical, down to the compiled binary.
- Ruled out along the way, each by direct test, so no future session repeats them:
  - The SF Symbol: `pawprint.fill` resolves to a valid 17x15 image.
  - A full menu bar: the bar has ample free space, and the notch's usable regions are x 0–562 and x 718–1280; a probe item lands at x 810.
  - A menu bar manager: none running.
  - `NSHostingMenu`: a plain `NSMenu` behaves identically.
  - The SwiftUI entry point: moving to a plain AppKit `main` changed nothing about the icon. It is kept only because it removes the `Settings`-scene placeholder.
  - The persisted keys: deleting `NSStatusItem VisibleCC Item-0`, writing the new key true, and restarting `cfprefsd` and `ControlCenter` all failed to restore it.
  - A status item window frame of `(0, 0, 33, 0)` immediately after creation is pre-layout noise, not a symptom. It reads the same in the working probe.
- Corrections to earlier claims made today:
  - The commit for the owned `NSStatusItem` and [PR #38](https://github.com/Mr-Shine09/desktop-mascot/pull/38) both imply the icon was restored. They are wrong. That change fixed the app terminating itself; the icon stayed missing. The in-source comments have been corrected rather than left to mislead.
  - A comment in `DesktopMascotApp.swift` blamed SwiftUI's scene machinery for suppressing the status item. That was disproven by the AppKit entry point making no difference, and has been rewritten.
  - `CGWindowList` cannot see status items on this macOS — zero layer-25 windows system-wide — so an absent window there is not evidence the item was never created. An earlier inference in this session leaned on that and was wrong. Use `screencapture` of the menu bar strip instead; that is what produced every reliable observation here.
- Decisions: none taken. **Open owner decision: change the bundle identifier.** It is one line in `project.yml`, is proven to work, and costs the two persisted preferences (`roaming`, `reactionSoundsMuted`) resetting once, since they live in the old domain. Provider hooks reference the helper's *path*, not the bundle identifier, so they are unaffected. The alternative is a logout or restart on the chance Control Center's state clears, which is unproven and unlikely, since the removal is designed to persist.
- Risks or blockers: **Dock Pet currently has no menu bar icon on the owner's machine.** The app runs and is controllable only by clicking a mascot, whose panel menu carries Pause, Roaming, Dismiss, and Quit. If no mascot is summoned there is no way to reach the app at all, and no way to summon one. Until the identifier changes, treat the app as reachable only while a mascot is already on screen.
- Next: owner decides on the bundle identifier. If yes, change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`, regenerate with XcodeGen, reinstall, and confirm the pawprint with a `screencapture` of the menu bar rather than by inference.

### 2026-08-05 — Menu bar icon restored by identifier change; animation loop throttled

- Objective: act on the two decisions the owner took at the start of this session — change the bundle identifier, and throttle the animation loop rather than restate the idle-CPU gate.
- **The menu bar icon is back, and this is the one claim in this entry that is proven on screen.** `PRODUCT_BUNDLE_IDENTIFIER` changed from `com.mrshine09.desktopmascot` to `com.mrshine09.dockpet`, regenerated with XcodeGen, Release-built, reinstalled to `~/Applications`, and launched with `open -g`. A `screencapture` of the menu bar strip shows the pawprint at roughly x 810 — the same slot the 2026-08-03 probe landed in. Verified by looking at the captured strip, not by `CGWindowList`, which still cannot see status items.
- What the identifier change did *not* touch, deliberately:
  - `EventSocketLocation.directoryName` still spells `com.mrshine09.desktopmascot`. It is the socket path already-installed provider hooks talk to and is now documented in-source as frozen independently of the bundle identifier. Changing it would silently break every hook installed before today.
  - `tools/install_app.sh` now quits *both* identifiers before replacing the bundle, so an old copy still running cannot hold the socket.
  - The owned `NSStatusItem` from 2026-08-03 stays. It is what stops a future stray Command-drag making the app terminate itself; the identifier change is what restores the icon. Two different fixes for two different faults — do not remove either believing the other covers it.
  - The two persisted preferences (`roaming`, `reactionSoundsMuted`) reset once, as predicted, because they lived in the old domain. Expected and accepted.
- Animation-loop throttle, implemented in `AmbientAnimationController`:
  - The ambient tick drops from a fixed 20 Hz to **12 Hz**, with transitions (summon, dismiss, drag) held at 20 Hz. The rationale is written into the source: the atlas's shortest ambient frame is 100 ms and the walk rows hold 120–140 ms, so the sprite changes about eight times a second, and a 24 pt/s walk at 12 Hz is a 2 pt step — still finer than the sprite's own frame rate. 20 Hz was oversampling both. `poof` runs frames as short as 70 ms, which is why transitions keep the old rate.
  - Timer `tolerance` is now interval/4, letting the kernel coalesce these wakeups instead of waking the CPU on their own schedule. Per-tick elapsed time is measured rather than assumed, so a late tick still moves the pet the right distance.
  - The loop now **stops entirely while the panel is occluded** — another Space, or fully covered. Transitions and drags are exempt by design: `beginDismiss` orders the panel out from its *completion* and Quit waits on that, so a dismiss whose timer stopped would never finish and the app could not be quit. Occlusion may only ever suspend the ambient loop. This is asserted in the guard and explained at both sites.
- **The throttle was measured, and it helps by roughly what the tick cut predicts — but the gate still fails.** The owner summoned a mascot and ran `powermetrics`; the loop was then sampled properly:
  - **One mascot on screen: 2.17% median, 2.21% mean, 1.47–3.27% range** (n=20, `ps -o cputime=` differenced every 15 s over 5 minutes). Down from **3.40%** median on 2026-08-02. A 36% reduction against a 40% cut in ticks, so **animation cost is very close to linear in tick rate**. The gate is <1%, so it still fails by more than 2x.
  - `powermetrics` independently confirmed the throttle is live in the installed build: **12.36 interrupt wakeups/s**, matching the 12 Hz ambient timer. Before today that would have read ~20.
  - **Energy Impact 3.70** in the same sample, against 757 for the whole machine — about half a percent of system energy, comparable to `launchd` (3.68) and `bluetoothd` (3.42), with `WindowServer` at 241 for context. This is the project's first actual power figure rather than a CPU proxy.
  - **A single 5-second `powermetrics` window is not a measurement of this workload.** Its 32.72 ms/s (3.27%) is the exact top of the 5-minute range, and reading it alone led to a wrong "no improvement" conclusion mid-session before the longer sample corrected it. Sample for minutes, not seconds.
  - Unsummoned, measured separately today: ~0.55% for the first two minutes after launch, settling to ~0.07%. No regression against the 0.40% floor.
  - The occlusion pause contributed nothing to any of these numbers, all of which were taken with a visible mascot on the active Space. It remains unmeasured and unobserved.
- Verification: 198 package tests pass, Release build succeeds, contract and classic atlas validate, installed bundle reports `CFBundleIdentifier = com.mrshine09.dockpet`. None of the throttle's behavior is covered by an automated test — the controller is app-side and the 198 tests are all package-side.
- Risks or blockers: the 12 Hz ambient rate is a **visual** change that nobody has looked at. It must be seen before it is trusted; the walk is the thing to watch, since that is where a lower rate would show as choppiness. The occlusion pause is likewise unobserved — the specific thing to check is that a mascot dismissed or quit while on another Space still completes and the app really exits.
- **Owner sign-off, same day, after the above was written:** the 12 Hz walk was watched on screen and reported moving fine, and the occlusion pause was exercised on other screens and worked. Both of the "unlooked-at" items in the risk line above are therefore closed by observation. [PR #40](https://github.com/Mr-Shine09/desktop-mascot/pull/40) is merged to `main` as `c0f3ff8`. The throttle is now visually accepted; what it does *not* do is pass the gate.
- **There is no separate Codex tick rate, and none was added.** The owner asked for the Codex mascot to be lowered to 12 Hz on the belief it was still at 20. Checked before changing anything: `ambientTickInterval` is a `private static let` on `AmbientAnimationController`, and `MascotInstance.swift:50` is the single construction site for both providers, so both mascots have always shared one rate. The only remaining 20 Hz is `transitionTickInterval`, which covers summon, dismiss, and drag for both equally and is deliberately exempt. No code change was made. The likely source of the impression is documented behavior rather than a defect: a provider with no sessions reduces to `offline`, which strolls continuously, so an idle Codex mascot is in constant motion beside a Claude mascot that sits still while working, and continuous motion reads as a faster mascot. If a future session is asked for this again, it is a **walk-speed** change (24 pt/s), not a tick-rate one.
- Next: **the <1% gate is not reachable by tick rate alone.** Getting 2.17% under 1% needs roughly another 2.2x cut, to about 5.5 Hz — below the sprite's own ~8 fps frame rate, so it would visibly degrade the animation rather than merely stop oversampling it. The remaining levers are a structural change (stop moving the `NSPanel` every tick while walking, or coalesce both mascots onto one timer, which helps only the two-mascot case) or restating the gate. Restating is the recommendation on the evidence: 2.2% CPU and 3.70 Energy Impact for a continuously animated sprite is in the same band as `launchd` and `bluetoothd` on the same machine, and the <1% figure was set before anyone had measured what an animated pet costs. Either way it is a fresh owner decision — "throttle the loop" has now been spent and delivered what it could. Still unlooked-at: the 12 Hz walk, and dismiss/quit from another Space.

### 2026-08-08 — Public-release documentation prepared

- Objective: owner intends to make the repository public. Add the files a stranger needs to clone, build, and run Dock Pet without asking, and the files GitHub expects of a public project.
- Added: root `README.md` (requirements, install, hook setup, menu reference, privacy, limitations, troubleshooting, uninstall, layout), `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `art/LICENSE.md`, `.gitattributes`, `.github/` issue templates and PR template, and `.github/workflows/ci.yml`. `.gitignore` gained `xcuserdata/`, `.swiftpm/`, and virtualenv entries. `docs/README.md` now points a user at the root README first.
- Owner decisions taken this session:
  - **Code is MIT.** The likeness concern is handled by the art license, not the code license, so the permissive option costs nothing.
  - **Art is licensed separately and restrictively** in `art/LICENSE.md`: build and run yes, reuse of the character elsewhere no, no commercial use, no training data. It covers `art/` and the generated app icon. The MIT `LICENSE` carries a pointer to it so neither can be read in isolation.
  - **The macOS-username scrub is deferred to its own change.** The owner's home-directory path appeared in 11 tracked files — the ten `art/animation/frames/*/normalization.json` provenance records plus this ledger. It leaks a real name, not a secret, and rewriting generated art metadata deserves a reviewable diff of its own. **Done 2026-08-09 — see the entry below.**
- Verified, not assumed:
  - `swift test` — 198 tests pass, matching the documented baseline.
  - `python3 tools/validate_animation_atlas.py --contract-only` and `--atlas art/animation/mascot-atlas@2x.png` both exit 0.
  - `xcodegen generate` produces no diff against the committed `.xcodeproj`, so the CI sync check passes today rather than failing on arrival.
  - The CI geometry check for the derived atlas was run locally against the real contract: both atlases are `768x1792`. It reads `contract["atlas"]["pixel_size"]`; an earlier draft invented a `sheet` key that does not exist in the file.
  - `git check-attr` confirms the PNG/WAV `binary` declarations resolve, and `git add -A --dry-run` shows no renormalization of any tracked file. A blanket `* text=auto eol=lf` rule was drafted and removed: `.gitattributes` resolves last-match-wins per attribute, so it would have silently overridden the `binary` marking on every sprite.
  - CI **ran for the first time on 2026-08-08** and found a real defect on its first attempt. See the CI entry below.
- **CI's first run exposed a latent test flake, not a documentation problem.** Recorded here because it is the most useful thing this session produced.
  - The run did not start at all until the PR's merge conflict was resolved. `pull_request` workflows execute against `refs/pull/N/merge`, which GitHub cannot compute for a conflicting PR, so the job is skipped **silently** — no error, no queued run, nothing in the UI. If CI appears not to exist on a PR, check mergeability before debugging the workflow.
  - `Validate art contract` (13 s) and `Build the app` (1 m 35 s) both passed, including the xcodegen-sync check and the bundled-resource byte comparison.
  - `Swift package tests` failed. First run: `aPayloadSplitAcrossChunksIsReadWhole` timed out at its 5-second deadline. Re-run of the same job: a **different** test in the same file failed, `anImmediatelyClosedStdinReadsAsEmptyRatherThanHanging`. A moving failure rules out an environment difference in one test and identifies a scheduling race.
  - Diagnosis: GCD thread-pool starvation created by the test helper. `makePipe` dispatched its writer to `DispatchQueue.global()` and slept on that pooled thread, while `HookPayloadReader.read` parks a second pool thread inside `handle.availableData` and blocks the test thread on a semaphore. Three blocked threads per test, 198 tests running in parallel, and a CI runner with far fewer cores than the development machine: the pool cannot grow fast enough and a writer block waits seconds for a thread. The conclusive evidence is the re-run failure — that test's writer only closes the handle, with no data and no sleeps, and it still consumed the full 5 seconds.
  - **The production reader is not at fault and was not changed.** `HookPayloadReader` blocking a pooled thread is correct for its actual use: the helper process performs one read and exits, exactly as its doc comment states. Only the test harness piles blocked work onto the shared pool.
  - Fix: `makePipe` now runs its writer on a dedicated `Thread`. Do not move it back onto a shared queue.
  - **This machine cannot verify the fix.** The suite passed locally before the fix and passes after it; a many-core Mac hides the fault entirely. Only CI can confirm it, and a single green run is weak evidence for a race — watch this file over several runs before trusting it.
- Scope deliberately not taken: no notarization, no release packaging, no `CODE_OF_CONDUCT.md`, no screenshots or a demo GIF in the README. The README has no image at all, which is the largest gap for a public project page and wants an owner-captured screenshot rather than a synthesized one.
- Documentation honesty: the README's "Current limitations" section states the failing idle-CPU gate at 2.17%, the absence of a notarized build, the unobserved Codex on-screen reaction, and the fixture-only `waiting`/`failed` states. Do not quietly drop those to make the project page look better; they are the same claims this ledger makes.
- Incidental measurement: the owner read **42.1 MB** for Dock Pet in Activity Monitor's Memory column on 2026-08-08. That column is `phys_footprint`, the same metric as the 36 MB recorded 2026-08-02, and it remains well inside the 80 MB gate. It is a single instantaneous sample with an unrecorded number of mascots on screen — it does not re-close the gate, which was already passing, and it is not a trend.
- Next: the username scrub, then an owner-captured screenshot for the README, then flip visibility and fix whatever CI reports on its first real run.

### 2026-08-09 — macOS username scrubbed from tracked files

- Objective: remove the owner's home-directory path from the repository ahead of making it public. Deferred out of the 2026-08-08 documentation change on purpose, so the art-metadata rewrite would get a diff of its own.
- Scope found by grepping the tracked tree for the owner's home-directory path: **12 tracked files**, not the 11 the previous entry recorded — the ten `art/animation/frames/*/normalization.json` records, plus `art/animation/frames/idle/authoring.json`, which the earlier count missed because it is not named `normalization.json`, plus this ledger.
- **The tools were fixed before the data, so a regeneration cannot reintroduce the leak.** `prepare_animation_frames.py` and `author_idle_frames.py` both wrote `str(path.resolve())` into their provenance records. Each now has a `repository_relative()` helper that emits a path relative to the repository root, falling back to the absolute path when the target genuinely lies outside the repository — an out-of-tree output directory is already unreproducible elsewhere, and silently hiding that would be worse than naming it. Do not change a provenance path back to an absolute one.
- Data rewrite: the absolute `/Users/<owner>/<repo>/` prefix was stripped from all eleven art records. Every path in them was inside the repository, confirmed before editing — no record referenced anything outside it.
- Ledger rewrite: the canonical source image is now `~/Mr-Shine09/source-avatar-magenta.png` (it lives outside the repository and always did), and the two historical entries that quoted the literal path now use `~/secret` and `/Users/<owner>/...`. The 2026-07-31 visibility entry keeps its original claim and gains a scrub date rather than being silently rewritten.
- Verified, not assumed:
  - Grepping the tracked tree for the username returns nothing, including this ledger. **This claim was made false once, by this very entry**, which quoted the literal path twice while describing its removal — caught during the pre-publication check on the same day and corrected. Write the placeholder, never the path: a ledger entry about a scrub is itself a tracked file.
  - **The tool fix is behavior-preserving, proven by regeneration rather than by reading.** `author_idle_frames.py` re-run into a scratch directory produced an `authoring.json` byte-identical to the committed one and four pixel-identical PNGs. `prepare_animation_frames.py` re-run for `working` produced six pixel-identical PNGs and a record differing only in `output_root` (the scratch path, correctly kept absolute as outside-repo) and `anchor_mode`.
  - **`anchor_mode` is pre-existing drift, not damage from this change.** The committed records predate that flag, so a regeneration today adds a key they do not have. It is unrelated to the scrub and was left alone; if the records are ever regenerated wholesale, expect that key to appear.
  - `swift test` — 198 tests pass. Both `validate_animation_atlas.py` invocations exit 0.
- Not done: **git history still carries the owner's real name and email on all commits**, and that is untouched. Scrubbing it means rewriting history and breaking every clone. It is a separate owner decision, and it means the username scrub does not by itself make the repository anonymous — it makes the *working tree* clean.
- Next: the README screenshot (owner capture), then watch CI go green, then flip visibility.

### 2026-08-09 — Idle-CPU gate restated, latency gate measured and closed

- **Owner decision: the idle-CPU gate is restated from `<1%` to `<3%`, plus an energy cost in the band of an ordinary background daemon.** On that gate the build passes at 2.17% median with an Energy Impact of 3.70. The decision was taken on the evidence already in this ledger and not on new measurement: cost is near-linear in tick rate, `<1%` needs ~5.5 Hz, and 5.5 Hz is below the sprite's own ~8 fps, so the only way to reach the old number was to make the animation visibly worse. The original figure predates anyone measuring what a continuously animated sprite costs.
  - **The structural levers were deliberately not spent.** Not moving the `NSPanel` every tick while walking, and coalescing both mascots onto one timer, are both still available. They were not needed to pass a restated gate, and holding them means there is something left to try if the number ever has to drop.
  - Two mascots have still **never** been measured together. Do not assume the cost is linear in mascot count; the gate is recorded against one mascot.
- **The event-to-visible-state latency gate passes at ~70 ms typical and ~122 ms worst case, against 500 ms.** Full table in `docs/QA_CHECKLIST.md`.
  - **It is a composition of measured parts, not a single stopwatch, and is written up that way.** The app has no instrumentation that timestamps a state reaching the screen, and none was added — instrumenting a production path to confirm a result already 4x inside its gate is not worth the code.
  - Measured: `dockpet-event` exec→exit **19.1 ms median, 20.9 ms max** (n=40, real installed binary, warm-up discarded), and decode + registry ingest + reduce + recompute at **0.35 ms median, 0.71 ms max** (n=2000, release build, warmed). The app-side compute is a rounding error on this path; the process spawn is the dominant real cost.
  - Derived, not measured: the wait for the next 12 Hz ambient tick (≤83.3 ms). This follows from `adopt` setting `nextFrameTime = 0` rather than drawing, so an agent-driven row swaps on the next tick. `paused` is the deliberate exception and calls `show()` directly, which is why pause feels instant.
  - **One hop is unmeasured and stays that way:** the socket read and main-actor hop between the helper's exit and the app's decode. It would have to be ~3000x larger than a kernel wakeup plausibly is to consume the 380 ms of headroom.
  - **The 0.75 s dwell can exceed the gate, by design.** A second state change inside one dwell window reaches the screen in up to ~771 ms. That is the dwell doing its job — a session flipping between working and waiting several times a second reads as a glitch if every flip is drawn. The first change after a quiet period is never delayed, because `committedAt` is `nil` until the first real commit. Do not "fix" this to make the gate look cleaner.
- Also corrected: `docs/QA_CHECKLIST.md` still recorded the **3.40%** figure from 2026-08-02 and had never been updated with the 2026-08-05 throttle result. Its "Launch at login works and is reversible" gate is now struck through and marked out of scope rather than deleted, so it is not re-opened as an oversight — there is no launch at login by owner decision (2026-07-30).
- The README's "Current limitations" entry on CPU was rewritten to match: it still gives the real 2.2% number and still says two mascots were never measured, but no longer describes the gate as unsolved. **It was not softened** — the notarization, Codex-reaction, and fixture-only `waiting`/`failed` limitations are untouched.
- **CI went green for the first time on 2026-08-09** on [PR #43](https://github.com/Mr-Shine09/desktop-mascot/pull/43): all three jobs pass, including the Swift test job that flaked on its first-ever run. [PR #44](https://github.com/Mr-Shine09/desktop-mascot/pull/44) then went green as well, so the test job has now passed **twice consecutively** after the `makePipe` dedicated-`Thread` fix. Two runs is better than one and still not proof about a scheduling race — the original failure moved between tests, so only a run of green results is evidence. Keep watching it; do not close this out on a small sample.
- Verification note: sending latency probes required delivering real events to the running app, which moved the on-screen mascot through `active`/`waiting` exactly as a provider hook would. That is the intended behavior of the path being measured, and the state settles back on its own.
- Next: the four remaining items are **owner-side, not engineering** — a README screenshot, a watched real Codex session, a Reduce Motion pass, and flipping repository visibility. Signing and notarization stay blocked on a Developer ID purchase.

### 2026-08-09 — A waiting session no longer expires while the user is thinking

- **Owner-reported defect, and the first real-provider sighting of `waiting`.** The owner watched a real Claude Code session put the mascot into `waiting`, left it, and the mascot went back to strolling while the prompt was still on screen. **This retires the "`waiting` has never been observed from a real provider" claim**, which stood in `README.md`, `CLAUDE.md`, and `docs/HANDOFF.md`; all three are corrected. `failed` is still fixture-only.
- **Two wrong diagnoses were proposed and discarded before the right one.** Recorded because the discarding is the useful part:
  - *Preview State timing out.* Ruled out: `setPreview` is sticky, there is no timer, and `overrides.preview` is checked first in the reducer. A preview persists until it is switched Off.
  - *The animation freezing on its last frame.* Plausible, because the `waiting` row ends on a `"hold"` duration — but `hold` maps to 0.5 s in `frameDuration`, and `advanceFrames` wraps with `% frames.count`. The row loops forever on a ~960 ms cycle and never stops.
  - The owner's confirmation that **Preview State was off and the session was real** is what selected between them. Asking was worth more than guessing: the first explanation offered was right about the mechanism and would have been wrong about the observation.
- **Cause:** `SessionRegistry.isExpired` applied the ordinary 120 s `heartbeatTimeout` to every non-`stopped` session. A waiting session is blocked on a human and therefore sends nothing by definition, so the registry retired the one session that was most certainly alive, the reducer saw no sessions, and the result was `offline` — which strolls.
- **Fix:** a separate `waitingTimeout`, defaulting to **1800 s**, selected in `isExpired` by activity. Deliberately **not infinite**: an agent killed mid-prompt leaves a session nothing will ever update, and showing `waiting` forever would assert something false. Half an hour is far past any human response time and still bounds that lie. The reasoning is in the source, not only here.
- **The regression tests were proven to fail without the fix.** All three were run against a temporarily reverted `isExpired`: `aWaitingSessionSurvivesLongPastTheHeartbeatTimeout` and `aWaitingSessionIsStillEventuallyExpired` both failed, and the fix restored them. A regression test that passes either way proves nothing, so this check is the point of the entry. The third test, `leavingWaitingRestoresTheOrdinaryHeartbeatTimeout`, pins that the longer deadline follows the *current activity* and is not an exemption a session keeps after the user answers.
- Verification: **201 tests pass** (198 + 3). The build initially failed to link, which is the documented `swift package clean` case — a stored property was added to a public struct. Do not debug that linker error; clean first.
- **Not fixed, deliberately, and filed instead:** a customizable sleep window, and the inertness of `ideating`. Neither is a 0.1 defect and both want an owner design decision. See the issues.
- **This is app-side behavior that has not been re-observed on screen.** The fix is proven by unit test against injected clocks; nobody has watched a real waiting session survive past two minutes in the installed build. That is a 30-minute observation and it has not been done.

### 2026-08-09 — Manual ideating raised above working

- **Owner decision, closing [issue #46](https://github.com/Mr-Shine09/desktop-mascot/issues/46).** The ladder is now `paused > failure-recent > waiting > ideating > working > success-recent > scheduled-sleep > idle/strolling > offline`.
- Why: below `working`, manual ideating was **unreachable in practice**. Any live agent session outranked it, so the menu toggle did nothing at exactly the moment someone was most likely to be watching the pet — which is what the owner reported as "no valid operation for Ideating motion." The animation existed and was effectively dead.
- **It was raised above `working` only, not to the top.** `waiting` and `failure-recent` still outrank it, deliberately: ideating is a standing preference the user set once, while those two are asking for attention right now. A preference must not hide a prompt. Both boundaries are pinned by their own tests (`waitingStillOutranksManualIdeating`, `aRecentFailureStillOutranksManualIdeating`) so a future reordering has to break something explicit.
- **Exactly one existing test asserted the old order** — `workingOutranksManualIdeating`. It was inverted and renamed rather than deleted, because the relationship still needs pinning, just in the other direction. That single failure is also the evidence the ordering was genuinely load-bearing and not merely incidental.
- Ideating still surfaces **no provider**, even while outranking a real working session that has one. It has no originating session, and inventing one would put a fabricated provider into the interface.
- Verification: **203 tests pass** (201 + 2 new boundary tests). No behavior outside the reducer changed; nothing sets a row directly.
- Corrected in the same change: the ladder is written out in four places (`README.md`, `docs/HANDOFF.md`, `docs/ARCHITECTURE.md`, and the Aggregate state reducer section above), and all four now agree. The historical ledger entry from 2026-07-29 keeps the original order — it is a record of that day, not a live claim, and a note above says so.
- **Also stale and fixed while here:** `docs/ARCHITECTURE.md` still said the animation controller "advances contract timing at 20 Hz", which stopped being true on 2026-08-05. It now states 12 Hz ambient, 20 Hz for transitions, and the occlusion pause. This is the second time a documented rate outlived the code; check this line whenever the tick changes.
- Not done: nobody has watched the reordered ideating on screen. The change is proven by unit test only.

### 2026-08-09 — The sleep schedule is user-adjustable, and switchable off

- **Owner request, closing [issue #45](https://github.com/Mr-Shine09/desktop-mascot/issues/45).** A user who works nights got a sleeping pet during their most active hours and had no way to change it.
- **The core logic needed almost nothing.** `SleepWindow` was already parameterized with correct midnight wrap-around; the whole feature was plumbing. What changed in `MascotCore` is that `MascotStateReducer.sleepWindow` became **optional**, where `nil` means no scheduled sleep at all.
  - Optional rather than a `Bool` beside the hours, so "no schedule" cannot be confused with "a schedule that happens to be empty", and a disabled schedule carries no stale hours to misread later.
  - `SleepWindow.init` now **clamps** hours into `0 ... 23` instead of trusting them. These values arrive from persisted preferences, which anything can write and which survive a downgrade; a nonsense hour must produce a usable window rather than a crash or a silently dead schedule.
- Menu: a **Sleep Schedule** submenu whose own title shows the current setting, an "Off — never sleep" entry, and two 24-hour submenus. Two full hour lists rather than a preset list, because a preset list is a guess about which schedules matter and the complete version costs nothing. Choosing an hour while sleep is off turns it back on, using the saved hours for the end the user did not touch.
- Persistence: three keys — enabled, start, end. Separate keys rather than one encoded value, so a partially written domain degrades to the default instead of failing to decode. **The hours are retained when sleep is switched off**, so turning it back on restores the user's schedule rather than the factory one. The keys keep the stale `com.mrshine09.desktopmascot.` prefix deliberately: it is meaningless inside the app's own defaults domain, and one consistent namespace beats a half-migrated one.
- **The bug this feature would most likely have shipped with, and did not:** a restored preference that never reaches the reducer. `@Published var sleepWindow = Preferences.sleepWindow` populates the menu's checkmarks, but the bridge's reducer still holds its own default, so the setting would appear to work and silently revert on every relaunch. `applicationDidFinishLaunching` now pushes the restored window into the bridge before `start()`, with a comment saying why.
- Setting the window **refreshes immediately** rather than waiting for the next tick, so moving the schedule across the current hour wakes or sleeps the pet at once. A 15-second delay would be harmless but reads as the setting not having worked.
- Hours are rendered with the locale's preferred clock format, so a 12-hour region sees "11 PM" rather than "23:00".
- Verification: **208 tests pass** (203 + 5), and the Xcode Debug build succeeds. The new tests cover a `nil` window across **all 24 hours** — not just the ones the default window excluded, which would have passed against the old behavior too — a custom night-worker window, equal hours reducing to an empty window, hour clamping, and work still interrupting a custom window.
- Documentation: five files stated 23:00–06:00 as a fixed fact (`README.md` twice, `docs/HANDOFF.md`, and this ledger twice). All now say it is the default. `README.md`, `docs/HANDOFF.md`, and `CLAUDE.md` gained the menu entry.
- **Not done:** nobody has opened the menu or watched the pet sleep on a changed schedule. Proven by unit test and a successful build only. The cheapest hands-on check is to set the sleep hour to the current hour and see the pet lie down.

### 2026-08-09 — Session close

Six changes landed as [#43](https://github.com/Mr-Shine09/desktop-mascot/pull/43), [#44](https://github.com/Mr-Shine09/desktop-mascot/pull/44), [#47](https://github.com/Mr-Shine09/desktop-mascot/pull/47), and [#48](https://github.com/Mr-Shine09/desktop-mascot/pull/48), each with its own entry above. What follows is only what is true across them and would be lost if the entries were read one at a time.

- **0.1 has no open engineering gates.** The two that were open this morning are closed: the idle-CPU gate by owner restatement, and the latency gate by first measurement. Signing and notarization remain blocked on a Developer ID purchase, which is out of scope by owner decision, not by engineering.
- **The repository went public today**, flipped by the owner. The scrub and CI, its two stated blockers, were both cleared earlier the same session.
- **Three behavior changes shipped without a single on-screen observation:** the waiting timeout, the ideating reorder, and the sleep schedule. All three are proven by unit test and a green Xcode build. This is the largest risk carried out of this session — not because any one of them is likely wrong, but because the project's own standard is that a phase is not complete on a successful build. Handoff item 31 lists the three cheapest checks.
- **Two long-standing "never observed" claims moved, and only one of them moved because of engineering.** `waiting` left fixture-only status because the owner watched it, and that observation is what exposed the expiry defect — the bug was found by looking, not by reading. `failed` and the Codex on-screen reaction are unchanged and still unproven.
- **A documentation claim was falsified by the edit that made it.** The scrub entry asserted a clean grep while quoting the scrubbed path twice, and shipped that way into a public repository before a pre-publication check caught it. `CLAUDE.md` already warned that documentation must be verified against the committed file rather than against intent; this session proved the warning is about one's own edits too, not only inherited ones.
- **Two wrong diagnoses were published to the owner before the right one.** Both were discarded by reading the code rather than by guessing harder, and the deciding fact came from asking the owner one precise question. The habit worth keeping is the question, not the analysis.
- Corrected in passing, each a case of documentation outliving code: `docs/QA_CHECKLIST.md` still carried the pre-throttle 3.40% CPU figure and an open launch-at-login gate that had been decided against on 2026-07-30; `docs/ARCHITECTURE.md` still said the animation loop runs at 20 Hz. **Both were stale for days inside files whose purpose is to be believed.**

### 2026-08-10 — The installed build was four days stale, and that is why nothing had been observed

- **Finding, and the whole point of the session.** `~/Applications/Dock Pet.app` was built on **2026-08-05**. Every one of the three behavior changes shipped on 2026-08-09 — the waiting timeout, the ideating reorder, and the sleep schedule — landed on `main` after that bundle was made. The owner was asked to observe three changes that **were not in the app they were running**, and no amount of looking would have shown them. The three checks in handoff item 31 were not merely undone; they were impossible.
- This is the same failure mode as the 2026-08-01 shared-`derivedDataPath` incident, arrived at from the other direction: there the bundle was rebuilt from the wrong branch, here it was simply never rebuilt at all. The lesson generalizes past worktrees — **`main` moving does not move the installed app, and nothing in the project notices.** Before asking for any hands-on observation, check the bundle's mtime against the commit that introduced what is to be observed.
- **Fixed by rebuilding and reinstalling from `main` at `cf6bba1`** with `tools/install_app.sh`. The binary is now dated 2026-08-10 and `strings` on it finds `Sleep Schedule:`, `Sleep Schedule: Off`, and the "never sleep" entry, so the 2026-08-09 menu is genuinely in the installed bundle rather than merely in the source tree.
- The install fell back to **ad-hoc signing**: `codesign` returned `errSecInternalComponent` for the Apple Development identity, which is the documented non-interactive-shell case the script already handles. Nothing new, and nothing to debug — run the script from an interactive terminal and answer the keychain prompt to sign with the real identity.
- **The event path was re-verified against the reinstalled build, headlessly.** `dockpet-event --provider claude-code --event active --session <opaque> --verbose` printed `sent`, which is only reached after `EventSocketClient.send` returns without throwing — so the new bundle binds and accepts on the socket that installed hooks write to. This matters because the reinstall replaces the bundle the `~/.claude/settings.json` hooks name by absolute path; the path is unchanged and still live.
- Baseline before any change: clean tree on `main`, contract and classic atlas validate, and the full package suite passes at **208 tests**, matching the 2026-08-09 count.
- **The three on-screen observations remain open as of this entry, and this session could not do them itself.** `screencapture` from this process returns a blank frame — the agent's process has no Screen Recording permission — so visual verification is an owner action. What changed is that it became *possible*. **Superseded later the same day:** the owner ran all three and all three pass; see the two entries below.
- No source, art, or contract changed today. The only repository change is this ledger entry.

### 2026-08-10 — Two of the three unobserved changes were watched on screen, and both pass

- **Owner-observed from the reinstalled build, the first time any of the 2026-08-09 behavior changes has been seen at all.**
- **Sleep schedule: pass, including persistence.** With the window set to 4 PM – 6 PM over the current hour, the pet lay down. It was still asleep on the correct schedule after Quit and relaunch — so the restored preference does reach the reducer, which is the one bug the feature was most likely to have shipped with. Both halves were checked; the relaunch half is the one worth having.
- **Ideating reorder: pass.** With a real Claude Code session working, the pet was at its computer; toggling Manual Ideating moved it to the Thinker pose with the thought cloud while that session was still running. Under the pre-2026-08-09 ladder the toggle would have done nothing there. The dwell made it about a second, as designed.
- **The test script named the wrong animation, and the ledger is where the error came from.** Item 31 said to "look for the lightbulb" when checking ideating. A cracked light bulb is **`failure`** (row 6); ideating is the Thinker pose and thought cloud. The owner reported the discrepancy rather than the instruction overriding what they saw — but a wrong marker in a check makes a pass read as a failure and a real failure read as a pass, in a project whose gates are settled by watching. **Verify an animation description against `art/animation/ATLAS.md` before writing it into a check**, the same way documentation claims are verified against the committed file.
- **A test instruction quit the app under test.** The first attempt at the ideating check used "rebuild and reinstall" as the busy work, and `install_app.sh` quits Dock Pet before replacing the bundle. The pet vanished mid-observation and that run was discarded. Busy work for an on-screen check must not touch the bundle, the socket, or the process — running the package test suite is a safe choice.
- **Waiting timeout: pass, and with it all three.** In a second Claude Code window set to **Manual** permission mode, a real approval prompt was left unanswered. The pet stopped, turned to face the user, and was **still there after three minutes** — well past the ordinary 120 s expiry that used to retire the one session most certainly alive. This is the last of the three, and the only one of them that had a real defect behind it.
- **Two setup details the test needed, both of which would have produced a false pass:** the window must be in **Manual** mode, since **Auto** decides permissions itself and may never prompt, and a bypass-permissions window never fires `Notification` at all; and the file the prompt is about must **exist**, or the agent reports it missing instead of asking. A test that never prompts looks exactly like a test that passed.

### 2026-08-10 — First session close (superseded; the session continued twice more)

**This entry closed the session and then the session did not end** — the owner went on to run the Codex observation and the four dismiss edge cases, both recorded below. It is kept in place rather than merged into the final close because its "exact next step" is what actually happened next, which is the useful part of a handoff. Read the final close at the end of the day's entries for the day's real state.

Three commits landed directly on `main` — [`8bc0653`](https://github.com/Mr-Shine09/desktop-mascot/commit/8bc0653), [`a920635`](https://github.com/Mr-Shine09/desktop-mascot/commit/a920635), [`f2797d0`](https://github.com/Mr-Shine09/desktop-mascot/commit/f2797d0) — all documentation. What follows is only what is true across the session.

- **The largest risk carried out of 2026-08-09 is closed.** All three behavior changes shipped that day with unit tests only, and all three were watched on screen today and pass: the sleep schedule (including persistence across relaunch), the ideating reorder, and the waiting timeout (held past three minutes against a real permission prompt).
- **The gap was not neglect, it was invisibility.** The installed bundle was four days stale, so the observations the ledger kept asking for could not have succeeded. Nothing in the project notices when `main` moves ahead of `~/Applications/Dock Pet.app`, and nothing does now either — the countermeasure written down is a check, not a mechanism. **If this recurs, build the mechanism** rather than adding a third warning.
- **A wrong instruction survived in the ledger for a day and was repeated once before anyone checked it.** Item 31 said to look for a lightbulb when verifying ideating; the lightbulb is `failure`. It was caught only because the owner reported what they actually saw instead of confirming what the instruction predicted. The generalization worth keeping: the project already knew documentation must be verified against the committed file, and this extends it to *checks* — an instruction that names the wrong evidence can only produce a wrong verdict, in whichever direction.
- **Three separate ways to write a check that cannot fail turned up in one afternoon**, all recorded in `docs/HANDOFF.md`: busy work that quits the app under test, a check naming the wrong animation, and conditions that never produce the state (Auto permission mode may never prompt; a missing file gets reported rather than asked about). Each converts "nothing happened" into "it passed."
- **No source, art, or contract changed.** The 208-test suite and the atlas validation were run at session start and nothing since then could have affected them.
- **Exact next step, and it was done later the same session — see the entry below.** Watch a real Codex session drive the navy mascot on screen: the last 0.1 hands-on claim. It passed, together with the first on-screen proof of per-provider attribution.
- **What that left as the next step was the four dismiss edge cases, and they were walked later the same session — see the entry below.** All four pass. What remains after them: the fixture-only `failed` state, issue #11's broader Reduce Motion coverage, the core app smoke test, the rest of the display matrix, and the README screenshot, which wants an owner capture and is now easy since every state on the project page has been seen working.

### 2026-08-10 — A real Codex session drove the navy mascot, closing the last 0.1 provider claim

- **Owner-observed, and it passes.** A real `codex` turn in this project made the **navy** mascot go to its computer, and it played the **success reaction** when the turn ended. The claim had been open since 2026-07-30 and survived being *almost* closed on 2026-08-02, when the hooks were exercised by a real turn that nobody watched.
- **Per-provider attribution was proven on screen for the first time, and it was free.** Both mascots were summoned; the **orange one strolled throughout**, unaffected by Codex's traffic. Until now that was a unit-test property of `MascotStateReducer.reduce(sessions:attributedTo:)` — the ladder applied to a narrower list. Watching one pet react while the other ignores the same event is the evidence the tests could not give.
- **The rig was checked before the owner spent a turn**, by piping a Codex-shaped payload (`{"hook_event_name":"UserPromptSubmit","session_id":…}`) into the installed helper with `--hook --provider codex`. It printed `sent active for codex`, proving payload → mapping → socket → app. This is worth repeating as a habit: it costs seconds and it partitions the failure domain in advance, so a silent pet during the real run would have been Codex's hooks rather than anything downstream. **It is a simulation and was recorded as one** — it is not the observation, and must never be cited as one.
- **The setup detail that would have quietly ruined this test:** Manual Ideating reaches **both** mascots and, since 2026-08-09, outranks `working`. Left on, the navy pet would have shown the Thinker pose regardless of what Codex did, and the run would have looked like a failure of the hooks. Checking it was part of the instructions because of that reorder — a ladder change alters what every later hands-on check has to control for.
- **What this does not close:** `failed` is still fixture-only. Neither provider reports a turn-level failure in ordinary use, so it needs a genuinely failing turn rather than a longer look.

### 2026-08-10 — The four dismiss edge cases were finally walked, and a ticked box turned out to be unearned

- **All four pass, each walked individually and narrated.** Dismissing a **paused** mascot still plays the seal and leaves, so dismiss outranks pause as `AmbientAnimationController.swift:355` intends. **Re-summoning mid-poof** brings the pet back and it *stays* — the pending hide really is cancelled rather than firing a moment later. **Reduce Motion** replaces the whole 1.1 s transition with the 0.3 s stationary fade, no seal and no smoke, and summon fades in place with no Dock portal. A **second Quit** during the farewell terminates immediately, cutting the animation off, which is the correct outcome.
- **The finding is documentary, not behavioral: these four boxes were already ticked.** `docs/QA_CHECKLIST.md` carried them as `[x]` since the 2026-08-02 blanket pass, while handoff item 16 and `docs/HANDOFF.md` both said they were unexercised. The same file's own preamble warns that 2026-08-02 was "one overall verdict rather than per-item commentary" — so the ticks came from a general "smooth", not from anyone walking these cases.
- **The outcome vindicated the ticks; the evidence behind them did not.** All four happened to pass, so nothing was actually wrong for those eight days. That is luck, and recording it as luck is the point: had one failed, a false pass would have sat in the acceptance checklist unnoticed, and the contradiction with the ledger was visible the whole time to anyone who read both files. **A tick is a claim about an observation, not about the code.**
- Why the contradiction survived: the two files disagreed in the *safe* direction. The ledger was pessimistic and the checklist optimistic, so any reader following the ledger simply redid work. A disagreement that costs nothing to ignore is one nobody resolves — which is why it lasted through several sessions that read both files.
- Fixed while here: the checklist's status header still named a live Codex session as the chief remaining gap (closed earlier the same day) and cited the **198**-test baseline, which became 208 on 2026-08-09.
- **What Reduce Motion this does *not* close:** issue #11's broader coverage. Summon and dismiss honor it; roaming and the ambient states do not, and whether they should is still an open product question rather than a bug.

### 2026-08-10 — Final session close

Eight commits landed directly on `main`, every one documentation. **No source, art, or contract changed all day.** The session began with the baseline green — clean tree, atlas and contract validated, 208 tests — and nothing since could have affected it.

- **Eight hands-on claims closed in one day**, all by the owner watching: the three 2026-08-09 behavior changes (sleep schedule with persistence, ideating over `working`, the waiting timeout), a real Codex session driving the navy mascot, and the four dismiss edge cases. **0.1 has no open hands-on claim that engineering can close.** What is left is `failed` (needs a genuinely failing turn), issue #11's Reduce Motion scope (a product question), the core smoke test and display matrix, a README screenshot, and signing (a purchase).
- **Nothing was broken. Everything found was documentation outliving its evidence, in three distinct shapes.** The installed bundle was four days stale, making three requested observations *impossible* rather than merely undone. A check in the ledger named the `failure` animation while instructing the reader to verify `ideating`. And four checklist boxes were ticked from a blanket verdict that never walked them, contradicting the ledger for eight days. **The project's rule was already "verify claims against the committed file"; today extended it to instructions and to ticks**, which are claims about observations rather than about code.
- **The recurring mechanism is worth naming: a document is trusted in proportion to how cheap it is to ignore.** The ledger and the checklist disagreed in the safe direction, so following the pessimistic one only cost rework and nobody reconciled them. The stale bundle was invisible because nothing in the project compares `main` to what is installed. Both are gaps in *feedback*, not in care — the countermeasures written down are still only checks, and if either recurs, **build the mechanism instead of adding another warning.**
- **The habit that actually caught things** was sweeping the committed file for the exact phrases a change retires, after committing. It found three stale rows in the ledger's Verification matrix that the earlier edits missed entirely, because those edits went to the snapshot and the handoff items. An edit that misses a second copy looks identical to a successful one.
- **What made the observations trustworthy** was the rig check before spending a real Codex turn: piping a Codex-shaped payload through the installed helper proved payload → mapping → socket → app in seconds, so a silent pet during the real run could only have meant Codex's hooks. Partitioning the failure domain *before* the expensive test is cheap and was recorded as a habit, not a one-off.
- **Exact next step:** the README screenshot. Every state on the project page has now been seen working, the repository is public, and the page still has no picture of the thing it describes. It needs an owner capture — `screencapture` from an agent session returns a blank frame, which this session confirmed. After that, the display matrix is the largest untouched block.

### 2026-08-10 — The README screenshot, prepared to the point where only the capture is left

- Baseline first: clean tree on [`a05bad4`](https://github.com/Mr-Shine09/desktop-mascot/commit/a05bad4), contract and classic atlas validate, **208 tests pass**, matching the count since 2026-08-09.
- **The exact next step out of the last close is an owner action, so the work available was to remove everything around it.** `docs/ASSET_PIPELINE.md` gains a "Project page screenshot" section: setup order, the region-capture command, the target path `docs/images/readme-hero@2x.png`, and the accept/reject rule. The owner's remaining part is the capture itself.
- **Three of the five setup steps are this project's own past mistakes, written forward instead of backward.** Reinstalling as busy work would quit the app mid-capture; Manual Ideating left on reaches both mascots and outranks `working`, so it would override whatever state the frame is meant to show; and a capture taken without Screen Recording permission yields a plausible PNG that is blank. Each was a finding recorded on 2026-08-10 — this is the first time one of them was spent *before* the check rather than diagnosed after it.
- **Region capture, not window capture**, and both mascots in frame. The panel is non-activating and borderless, so a window capture is a bare rectangle with no context; and two pets is the only way a still frame carries the per-provider wardrobe claim, which is the page's most distinctive one.
- **The README link is deliberately not added yet.** The repository is public, so an `![…]` pointing at a file that does not exist is worse than no picture. Link and image land in one commit.
- No source, art, or contract changed. The only repository change is documentation.
- **Exact next step:** the owner runs the capture and commits image plus link together. After that the display matrix is the largest untouched block — auto-hide, Spaces, sleep/wake, non-Retina — followed by the core app smoke test.

### 2026-08-10 — Starting the display matrix meant first discovering it was already ticked

- **The bundle check passed, so this is not another stale-install session.** `~/Applications/Dock Pet.app/Contents/MacOS/Dock Pet` is dated 2026-08-10 16:52, and every commit since is documentation, so the installed binary is current for window behavior. Handoff item 32 cost seconds and cleared the ground.
- **The matrix could not be "started" because `docs/QA_CHECKLIST.md` said it was finished.** Nine of its eleven rows were `[x]`, all from the 2026-08-02 blanket verdict — the same single "smooth" that produced the four unearned dismiss ticks found earlier today. The ledger and `docs/HANDOFF.md` had both said the display matrix was open the whole time. **This is the identical contradiction, in the identical direction, in the identical pair of files, found twice in one day.**
- **That repetition is the finding.** Earlier today the lesson was recorded as "a tick is a claim about an observation, not about the code," and the mechanism as "a document is trusted in proportion to how cheap it is to ignore." Both were written about the dismiss rows specifically. The same blanket verdict had ticked a second section, and nobody looked — because reading the pessimistic ledger only costs rework. **The 2026-08-02 verdict should be treated as suspect wherever it is the sole authority, not audited one section at a time as each becomes someone's next step.**
- **The ticks are withdrawn, and that is itself a claim.** Nothing here is known broken; it is unwitnessed, which is different, and the section now says so. Two rows keep their tick and say why: the single-Retina bottom-Dock case is exercised daily by the author, and the focus-theft row was verified separately by the `open -g` launch plus a non-activating-panel test.
- **Two rows could never have been meaningful passes.** `DockGeometry` tracks no Dock edge at all — its own doc comment records left/right placement as deliberately deferred after an edge-aware version let the mascot walk across the middle of the screen. So "Left Dock ✓" asserted a behavior the code does not have. The rows are kept, reworded to check that the *deferral* holds and the pet stays bottom-anchored, which is the real expectation.
- **Every row now names the observation that settles it**, read off the source rather than invented. Three that would otherwise produce a false pass: toggling the auto-hide *setting* changes `visibleFrame` and re-settles a default-lane pet, while the Dock merely sliding away on hover must **not** move it; unplugging the display re-clamps a manual height rather than discarding it, so a height from the 1080-tall external lands near the *top* of the 832-tall built-in — correct, and looks like a bug; and wake runs `settleAfterDrop()`, not `reposition()`, so a manual height must survive it.
- **The precondition written at the top of the section** is to drag one mascot to a manual height before walking, because roughly half the rows behave differently for a manually placed pet than a default-lane one, and a walk that never sets one exercises one branch and reports on two.
- No source, art, or contract changed. The 208-test baseline and atlas validation were run at session start.
- **Exact next step:** the owner walks the reopened rows, which is now a script rather than a category. The `@1x` row needs hardware this machine may not have; skip and record it as unavailable rather than guessing.

### 2026-08-10 — The display matrix was walked row by row, and seven rows are now earned

- **Owner-walked from the installed build the same day it was reopened**, with both mascots summoned and one dragged to a manual height so the two code paths were exercised together. **The owner reported per row rather than as one verdict, which is the entire difference from 2026-08-02** — the blanket "smooth" is what produced nine ticks nobody could stand behind.
- **Seven rows pass.** Dock auto-hide, both halves and exactly as predicted: flipping the *setting* re-settled the bottom pet while the Dock merely sliding on hover moved nothing. Left and right Dock: the pets ignored the Dock, so the deferral holds. Two displays: moving keyboard focus between them moved neither pet, so the `referenceScreen` defect has not returned. Sleep/wake and lock/unlock: both pets present afterward.
- **One row is `[~]` — walked, but the observation does not settle it.** On the unplug, the pet survived and kept its dragged height, which is the claim's main half. The *re-clamp* half only shows when the dragged height sits above the surviving display's ceiling, and nothing in the report establishes that it did. **A pass that would look identical if the feature were absent is not a pass**, so the row stays open with the missing detail named: drag near the top of the 1080-tall external before unplugging. This is the same class of error as an Auto-mode window that never prompts.
- **Full-screen Spaces passed as a test and opened a product question.** The pets remain visible *over* full-screen apps rather than being hidden by them. That is recorded as observed behavior, explicitly **not** as approval — the matrix can establish what happens and cannot establish whether it should. It needs an owner decision, and it is the first thing this walk surfaced that is not a documentation problem.
- **The `@1x` row was assumed to need hardware nobody had, and that assumption was wrong.** The owner's external display is a **Dell P2217H**, a 1920x1080 non-Retina panel. The instruction offered "skip and record it as unavailable" — which would have written a false unavailability into the checklist and closed the row by giving up. It is now the only untouched row in the matrix. **An instruction that offers an escape hatch should not assume the hatch is needed**; ask what hardware exists before writing the row off.
- **Owner preference recorded:** hands-on steps are to be written as numbered tests with explicit Expect and Fail lines and real menu titles, not handed over as a category to go verify. Stored in this session's memory, and it is what the last two walks did that the 2026-08-02 pass did not.
- No source, art, or contract changed. Documentation only.
- **Exact next step:** the `@1x` walk on the Dell P2217H, then the unplug redo with the pet dragged high. After those the matrix is complete except for the Spaces product decision.

### 2026-08-10 — The matrix finished, and the last row is the day's only real defect

- **`@1x` passes, on hardware the project had written off.** The owner's external display is a **Dell P2217H**, 1920x1080 non-Retina. The mascot renders as crisply there as on the Retina built-in, keeps its sharpness and apparent size when dragged between the two, and shows no jitter or vertical drift over ~30 s of walking. Nearest-neighbor holds at `@1x`. The row had been assumed to need hardware nobody had — nobody had asked.
- **Unplugging a display loses a dragged height, and the documentation says it does not.** Re-walked with the pet dragged near the top of the external before disconnecting: it came back to the built-in **at the bottom**. `docs/QA_CHECKLIST.md`, handoff item 9's reading of `settleAfterDrop()`, and `WindowCoordinator.screenParametersChanged`'s own comment ("re-clamped rather than reset") all assert the height survives. It does not.
- **The clamp is not even the explanation.** The owner's displays have **aligned top edges** — built-in `0,0 1280x832`, external `1280,-248 1920x1080`, both topping out at 832 — so a height near the external's top fits the built-in with no clamping required. The height was discarded, not squeezed.
- **Leading hypothesis, explicitly not established:** AppKit relocates a window off a disconnected display by itself, and `screenParametersChanged` then calls `settleAfterDrop()`, which reads `panel.frame.minY` — by that point the system's chosen position rather than the user's. If so the code adopts the relocation and stores it as `manualLaneY`, losing the height before our handler runs. Inferred from reading the source; no instrumentation yet. **The next session must not treat this as diagnosed.**
- **Do not fix it toward the documentation by reflex.** A pet reappearing at the bottom of the surviving display is arguably the better behavior — it is where the user can find it. What is unacceptable is documentation asserting a behavior the app does not have. Settle the mechanism, then let the owner choose which behavior is wanted.
- **The cheap discriminating check is written into the row:** drag a pet high on the *built-in* and change resolution or arrangement in System Settings. That posts the same notification without removing a display, so AppKit has no reason to relocate the window. Height surviving that but not the unplug confirms the hypothesis and costs no unplugging.
- **Two lessons about the instructions themselves, both from this walk.** The first unplug attempt produced "the pet stayed at its dragged position", which reads as a pass and settles nothing — the displays' aligned tops meant the height needed no clamping, so the feature working and the feature being absent look identical unless the drag starts above the surviving screen's ceiling. And the `@1x` row nearly closed as "unavailable" because the instruction offered that escape hatch without first asking what hardware existed. **A test whose pass and failure look the same is not a test, and an escape hatch is a claim too.**
- **Nine of eleven matrix rows now carry per-row owner evidence**, against nine ticked by a single blanket verdict this morning. No source, art, or contract changed; the finding is a defect report, not a fix.
- **Exact next step:** run the discriminating check above to settle the mechanism, then take the behavior question to the owner. After that the matrix is complete apart from the full-screen Spaces product decision — the pets float over full-screen apps, which is recorded as observed and not as approved.

### 2026-08-10 — The unplug defect diagnosed and fixed, and the first source change in three days

- **The discriminating check settled it in one observation.** With a pet dragged high on the *built-in* display, a resolution change **preserved** the height. Same notification, no display removed, therefore no relocation — so the trigger is AppKit moving the window off a display that disappears, not our handler mishandling the notification. Two hands-on results that differ in exactly one variable are worth more than either alone; the unplug on its own could not distinguish these.
- **Cause, and it is narrower than the hypothesis.** `screenParametersChanged` called `settleAfterDrop()`, which derives the height from `panel.frame.minY`. That is right for a drop — the frame *is* the user's intent — and wrong after a relocation, where the frame is the system's intent. **`manualLaneY` already held the user's height and was never read.** The code had the right answer in hand and threw it away.
- **Why it hid for so long:** without a relocation the frame and the remembered value are identical, so every other path — sleep/wake, resolution changes, Dismiss/Summon — looked correct, and the unit tests all drove `settleAfterDrop()` directly rather than through the notification.
- **Fix:** the handler re-clamps the stored `manualLaneY`. X still comes from the frame on purpose, since roaming rewrites it continuously and there is no remembered X to prefer.
- **The owner delegated the behavior choice and it went to "keep the height".** Reasons, in order: every document already claimed it; a dropped height already survives Dismiss/Summon and sleep/wake by the 2026-07-30 decision, so losing it only on unplug is an inconsistency rather than a design; and clamping guarantees the pet lands on screen with Reposition one click away. The alternative — bottom-on-unplug as findable — was real, and would have been a documentation-only change.
- **The regression test was verified to fail against the old handler**, at `WindowCoordinatorTests.swift:199`, height `0.0` where `200.0` was expected, before being restored. A test written after a fix that is never run against the bug is a test that cannot fail. The suite is **209**, up from 208.
- **The test's own limitation is written into it:** it moves the panel to stand in for AppKit's relocation, so it proves the handler no longer adopts a relocation — **not** that AppKit relocates the way the stand-in does. That inference came from one hands-on pair and stays an inference. The hands-on unplug must be rerun from a rebuilt install; until then the fix is unwatched, which is the state the project spent 2026-08-09 regretting.
- **First source change since 2026-08-07**, and it came out of the matrix that was ticked as complete this morning. Everything else today was documentation outliving its evidence; this is the one place where the evidence was simply missing and a real defect sat behind it.
- **Exact next step:** `tools/install_app.sh`, then redo the unplug — drag the pet near the top of the external, disconnect, and confirm it comes back at that height rather than at the bottom. Then the full-screen Spaces product decision, which is the last thing the matrix left open.

### 2026-08-11 — The unplug fix watched on screen, and the display matrix is complete

- **Owner-observed from a rebuilt install: the pet came back at the dragged height.** The bundle was checked before the result was believed — binary dated 2026-08-11 09:33, fix commit [`7a898f3`](https://github.com/Mr-Shine09/desktop-mascot/commit/7a898f3) dated the night before — so this is an observation of the fixed code, not a repeat of the stale-install trap. **That check took one `ls` and is now the third time it has mattered.**
- **The matrix is complete: eleven of eleven rows pass, every one on per-row evidence.** Twenty-four hours ago nine of them were ticked by a single blanket "smooth" that nobody could stand behind, and the section had never been walked.
- **What the walk was worth, concretely.** Nine rows were confirmed to be genuinely fine, one row (`@1x`) closed on hardware the project had written off without asking, one row could never have meant anything as written (left/right Dock, against code with no Dock-edge inference), and **one row found a real defect that had shipped and gone unnoticed** — a dragged height silently lost whenever its display was unplugged. The blanket verdict had covered all of it.
- **The unit test now has an observation behind it.** `aDisplayChangeKeepsTheDraggedHeightRatherThanASystemRelocation` moves the panel to stand in for AppKit's relocation, which proves the handler no longer adopts one but cannot prove AppKit relocates that way. The on-screen rerun is what closes that gap — **do not delete the hands-on row later as redundant with the test.**
- **The pattern worth carrying:** hands-on evidence found the defect, a second hands-on result differing in exactly one variable (resolution change versus unplug) diagnosed it, a unit test pinned the regression, and a third hands-on run confirmed the fix. Neither kind of evidence could have done that alone, and the project has spent several sessions treating them as substitutes in one direction or the other.
- **Still open from the matrix, and it is not a defect:** the pets float over full-screen apps. Recorded as observed behavior; whether it is wanted is an owner decision that has been offered twice and not yet made.
- **Exact next step:** the README screenshot, which is now the oldest open item and needs only the owner capture — the procedure is in `docs/ASSET_PIPELINE.md`. After that, the core app smoke test is the largest untouched block, and `failed` remains the one mascot state no real provider has produced.

### 2026-08-11 — Two owner decisions, and a requested feature that already shipped

- **Owner decision: the mascots float over full-screen apps and that is wanted.** This was the last thing the display matrix left open. It is now approved behavior, not an unexamined observation — do not "fix" a pet appearing over a full-screen app as a window-level bug.
- **Owner decision: the stationary pose stays the standing `idle` blink.** Asked in the course of a feature request, answered directly.
- **The requested feature already exists, and the request is evidence that it is undiscoverable.** The owner asked for an option to keep the mascot in place instead of moving around. Unchecking **Roam Along Bottom** already does exactly that: the pet holds its position, keeps animating in place, persists across relaunch under its own defaults key, and deliberately leaves reactions alone because `setRoaming` only acts when `plan.isAmbient`. Drag first, then uncheck, and it stays where it was put. **Nothing was built.** The gap was that the menu names the behavior being turned *off* rather than the mode being turned *on*, and the README described it in four words.
- **Fixed as a documentation problem, which is what it was.** The README's menu table now says what unchecking it gives you, and the "interact with the pet" list gains an explicit "to pin the pet in one spot" line. **The cheapest response to a feature request is sometimes to make the feature findable** — but only after confirming it genuinely does what was asked, which here meant reading `setRoaming` and the resting phase rather than trusting the menu title.
- **`sit-shake-right` and `sit-shake-left` (rows 11 and 12) are authored, validated, in the frozen contract, and used by nothing.** The mascot sitting on a small freestanding chair swinging a leg — the closest thing in the project to the in-place idle the request described. The only Swift naming them is `MascotState` and a test that loads them. They were offered as the stationary pose and the owner kept the standing blink.
- **That fact is now written where the next session will hit it**, in `art/animation/ATLAS.md` beside the rows themselves, with the reason and an instruction not to treat them as dead art to clean up or to wire them in without a fresh decision. **Unused authored assets look identical to an oversight**, and this project has already lost time twice to documentation that did not say why something was the way it was.
- No source changed. Documentation only, plus the two decisions.
- **Exact next step:** the README screenshot, unchanged and now the oldest open item. After that, the core app smoke test.

### 2026-08-11 — "Roam Along Bottom" became "Stay in One Place"

- **Owner request, and it closes the discoverability gap that produced a request for an existing feature.** The item now names the mode it switches *on* and is checked when the pet is stationary. The pet's own click menu follows: "Stay in One Place" / "Start Roaming Again", replacing "Stop Roaming" / "Resume Roaming".
- **The inversion is in the label only, deliberately.** `isRoaming` keeps its polarity, `setRoaming` is untouched, and the defaults key stays `com.mrshine09.desktopmascot.roaming` — name *and* meaning. **Renaming that key would silently reset every existing choice**, which is the trap `reactionSoundsMuted` already carries a rule about; the key spelling the old bundle identifier is a second reason not to touch it. Nothing about the behavior changed, so nothing needs re-testing beyond reading the menu.
- **Verified in the built binary, not just the diff.** `strings` on the Debug build finds "Stay in One Place" and "Start Roaming Again" and no "Roam Along Bottom". Worth knowing for next time: a **Debug** build puts app code in `Contents/MacOS/Dock Pet.debug.dylib`, not in the main executable, so `strings` on the executable finds nothing and looks exactly like a failed build. The handoff's advice to check a menu title with `strings` needs that caveat, and the build used its own `-derivedDataPath` per item 17.
- The rename was swept through `README.md`, `docs/HANDOFF.md`, `docs/ARCHITECTURE.md`, `docs/QA_CHECKLIST.md`, and handoff item 37. Session-log entries keep the old name: they are records of their day.
- Package suite unchanged at **209** — the change is app-target only. The app target has no tests, which is why the binary check stands in for one.
- **Exact next step:** unchanged — the README screenshot. The rename reaches the owner's screen at the next `tools/install_app.sh`; it is cosmetic, so there is no reason to reinstall before capturing.

### 2026-08-11 — Session close

Nine commits, spanning 2026-08-10 evening into 2026-08-11. **One source change** — the unplug fix — plus one cosmetic rename; everything else was documentation. The baseline was green at both ends: clean tree, contract and classic atlas validate, suite **208 → 209** with the new regression test.

- **The display matrix is closed, eleven of eleven rows, every one on per-row owner evidence.** It began the session marked complete. Nine of its rows carried ticks from the 2026-08-02 blanket verdict — the same single "smooth" that had produced four unearned dismiss ticks the day before. **The identical contradiction, in the same direction, in the same pair of files, found twice in two days**, which is what makes it a pattern rather than an incident: a document is trusted in proportion to how cheap it is to ignore, and the pessimistic ledger only ever cost rework.
- **Walking it was worth it, and the accounting is honest.** Nine rows were genuinely fine — the blanket verdict happened to be right about them. One (`@1x`) closed on hardware the project had written off without ever asking what the owner owned. Two (left/right Dock) could never have meant anything, since they asserted behavior `DockGeometry` deliberately does not have. **And one found a real defect that had shipped and gone unnoticed**, sitting under an `[x]`.
- **The defect, and the method that caught it.** A dragged height was discarded whenever its display was unplugged. `screenParametersChanged` derived the height from `panel.frame.minY` via `settleAfterDrop()` — right for a drop, wrong after AppKit relocates the window off a removed display — while the remembered `manualLaneY` sat unread. **The diagnosis came from two hands-on results differing in exactly one variable:** a resolution change preserved the height, an unplug did not. Then a unit test pinned the regression, verified to fail against the old handler before being restored, and a third hands-on run confirmed the fix on a bundle checked to be newer than the fix commit. **Neither hands-on nor automated evidence could have done that alone**, and this project has spent several sessions treating them as substitutes.
- **A feature request turned out to be a discoverability bug.** "Make the mascot stationary" already shipped: roaming off holds the pet, keeps it animating, persists, and leaves reactions alone. Nothing was built. The item was renamed **Stay in One Place** so it names the mode it switches on, with the inversion confined to the label — `isRoaming` and its defaults key are untouched, because renaming that key would silently reset every existing choice. **Confirming the feature meant reading `setRoaming` and the resting phase, not the menu title.**
- **Three decisions recorded so they stop being rediscovered:** mascots float over full-screen apps on purpose; the stationary pose stays the standing `idle` blink, which leaves atlas rows 11 and 12 authored and deliberately unused, noted beside the rows themselves; and the roaming preference key keeps its old name and polarity. **Unused assets look exactly like an oversight unless the file says why.**
- **Two traps in the instructions, both this session's own.** The first unplug check produced "the pet stayed at its dragged position", which reads as a pass and settles nothing — the owner's displays have aligned top edges, so the height needed no clamping and the feature working looked identical to the feature being absent. And the `@1x` row nearly closed as "unavailable" because the instruction offered that escape hatch without asking what hardware existed. **A test whose pass and failure look the same is not a test, and an escape hatch is a claim too.**
- **Owner preference, now standing:** hands-on work is handed over as numbered tests with explicit Expect and Fail lines and real menu titles, never as a category to go verify.
- **The app is installed and running** from `~/Applications`, rebuilt 2026-08-11 09:51, ad-hoc signed, with the new menu verified in the binary by `strings`. Nothing is on screen until the owner summons a mascot — `install_app.sh` quits the previous instance.
- **Exact next step: the README screenshot.** It is the oldest open item, needs only the owner's capture, and the procedure is written in `docs/ASSET_PIPELINE.md` — setup order, region-capture command, target path, accept/reject rule. Do not add the `![…]` link before the image file exists; the repository is public. After that, the core app smoke test is the largest untouched block.

### 2026-08-11 — Two owner-reported defects, and a third found while fixing them

**The session was closed above and then continued.** These are real entries after that close; the close was not rewritten, per handoff item 19.

- **Reported: clicking one mascot froze both.** Cause: `Timer.scheduledTimer` installs into `.default` run-loop mode only, and while any `NSMenu` tracks — the pet's click menu or the menu bar's — the run loop is in `NSEventTrackingRunLoopMode`, where a `.default` timer does not fire. Every mascot animates from that one path, so both stopped for as long as either menu was open. **Fixed** by constructing the timer and adding it to `RunLoop.main` in `.common` modes. This was never a mascot-coupling bug, which is what it looked like from the outside.
- **Reported: Stay in One Place applied to both mascots.** It did: `setRoaming` looped over every mascot and wrote one app-wide key. **Owner decision — it is now per mascot.** Presence and placement were already per mascot, so an app-wide roaming flag was the odd one out; Pause and Manual Ideating stay app-wide on purpose.
- **The rename is what exposed it.** "Roam Along Bottom" described a global behavior and read as one. "Stay in One Place" reads as a property of a pet, and it sat in a menu that names the mascot for Dismiss — so the label made a pre-existing scope mismatch feel like a new bug. **Renaming a control changes what users expect it to be scoped to.**
- **Found while fixing, not reported: the restored roaming preference never reached the animation controller.** It populated the menu's checkmark and nothing else, so a pet saved as stationary would stroll again after every relaunch while the menu insisted otherwise. **This is exactly the trap handoff item 30 records the sleep schedule dodging** — a restored preference that reaches the menu but not the thing it controls. The project had written that lesson down and the same bug was live in the next setting along. Each mascot now gets its restored value at creation.
- **Migration is one-way and deliberate.** A provider with no key of its own falls back to the old app-wide `Key.roaming`, which is read forever and never written again. Writing both would create two sources of truth for one question. The fallback must not be deleted as tidying: it silently resets a saved choice.
- **Owner-verified on screen, all three:** only Codex stationary while Claude strolled; the other pet kept animating with a menu open; and both settings survived quit and relaunch. **The third is the one with no other evidence** — the relaunch bug was found by reading, and a unit test for it would have to fake the app's startup sequence.
- **No test covers either fix.** Run-loop modes and `NSMenu` tracking are not reachable from the package's test target, and the preference-restoration path lives in `AppDelegate.applicationDidFinishLaunching`. Recorded as a gap rather than papered over with a test that asserts something easier. The suite stays at **209**.
- **Exact next step:** the README screenshot, still. **Capture from this agent process now works**, contradicting handoff item 33 as written on 2026-08-10: a probe returned a real 2560x1664 image with content where the day before it returned a blank frame. The item is corrected to say *probe, do not assume*, in both directions. The probe caught the owner's Claude Code window, this conversation, and a sidebar of their other session titles, and was deleted rather than kept — **a capture succeeding is not the same as a capture being safe to publish**, and this one is destined for a public repository. The remaining blocker is only that the desktop has to be staged, which needs the owner: summoning is a menu-bar click with no CLI behind it.

### 2026-08-11 — The README screenshot, taken and in place

- **The oldest open item on the project is closed.** `docs/images/readme-hero@2x.png`, 900x370, sits under "What it looks like" with a caption naming what is happening: the orange Claude mascot at its computer typing against a live session, the navy Codex mascot strolling past the Dock because it has nothing to report. Image and link landed in one commit, as the procedure required.
- **It was taken by this session, not the owner**, which the plan said was impossible. `screencapture` returned a real frame; handoff item 33 was written on one day's evidence and had already lapsed. **The lesson is the probe, not the verdict** — check that a capture has content before believing either answer, in both directions.
- **The real obstacle was never permission, it was what else was on screen.** The first frame contained a personal photo in the owner's Dock, on its way to a public repository. **No crop could remove it**: the navy mascot was standing to the right of it, so any crop that lost the photo lost the pet. The owner removed the item and the retake was clean. Nothing was published without them seeing the frame first.
- **The retake is better than the first for a reason nobody planned:** the navy mascot was caught mid-stride, one foot forward, so it reads as walking rather than standing about. The frame now carries both halves of the page's central claim — one pet reacting to its agent, the other visibly unaffected — which is the same thing the 2026-08-10 Codex observation proved on screen, in a still.
- **The state was driven by the bundled helper rather than a real turn**, one `dockpet-event --event active`. That is a legitimate way to pose a screenshot and it is written into the procedure; it is **not** evidence of anything, and it must never be cited as an observation. The real-session evidence for this behavior already exists and is dated 2026-07-30 and 2026-08-10.
- **A misread caught by looking properly:** in the downscaled preview of the first frame a shape in the wallpaper read as a third mascot. Checking at full resolution, and locating the pets by pixel search rather than by eye, showed two. **Verify a capture at native resolution — a preview is lossy in exactly the way that invents detail.**
- The procedure in `docs/ASSET_PIPELINE.md` is now a record of how rather than an open task, corrected where the run contradicted it, and it carries the helper command.
- **Nothing is pushed.** The commit is local; publishing the picture to the public repository remains the owner's action.
- **Exact next step:** the core app smoke test, now the largest untouched block in `docs/QA_CHECKLIST.md`. After that, `failed` is the one mascot state no real provider has produced, and issue #11's Reduce Motion scope is a product question rather than a defect.

### 2026-08-11 — Chat apps can drive the ideating pose, built but not yet seen working

- **Owner request:** the mascots never reacted to ordinary chat use, only to Claude Code and Codex CLI sessions, so a long afternoon in the Claude or ChatGPT desktop app left the pet strolling as though nothing were happening.
- **Scope was settled before any code:** desktop apps only. Detecting `claude.ai` or `chatgpt.com` in a browser means reading the active tab's URL, which is the user's browsing history and the line this project has refused to cross since the first session. The cost is honest partial coverage, and `README.md` says so under Current limitations rather than implying chat is detected generally.
- **The signal is the frontmost application's bundle identifier**, matched against a two-entry allowlist. No window titles, no accessibility tree, no screen contents, nothing typed, no permission prompt, nothing stored, nothing sent. Every other app maps to `nil` and is never named. `ChatApp.identifiers` is a fixed list rather than a pattern, because "anything containing `claude`" would match this project's own builds.
- **ChatGPT's desktop app really ships as `com.openai.codex`**, verified on this machine. It looks like a mistake and is not one; a comment says so, since the obvious "correction" matches nothing.
- **Frontmost rather than running**, with a 2 s linger. A chat app parked behind an editor all day is not someone thinking, and treating it as such would leave the pet ideating permanently for anyone who never quits apps.
- **The ladder gained a second, weaker ideating rung**, below `working` and below the success reaction, above scheduled sleep. Manual ideating keeps its 2026-08-09 place above `working`, and the distinction is the point: a menu toggle is a deliberate statement, a frontmost app is a guess that cannot tell composing a prompt from re-reading an old conversation. The ladder is written in four files and all four were updated.
- **The owner's clarification changed the rule, and ranking alone would have shipped a daily annoyance.** The Claude desktop app hosts *both* the chat and Claude Code behind one bundle identifier. Ranking below `working` covered a turn in flight, but left the quiet gaps between turns showing a Thinker pose at someone who was not chatting. The rule is now that **a provider with any live session ignores the chat signal entirely** — hooks are the authority whenever they are speaking — and sessions expiring on the ordinary timeout hands the behavior back with no extra machinery.
- **The first hands-on attempt was contaminated, and the contamination is instructive.** The owner tested while talking to Claude Code *in the app under test*. Nine hook events are installed including `PostToolUse`, so every command the agent ran refreshed the `claude-code` session and the signal correctly stood down for the entire test. The reported "nothing happened while chatting" and "occasionally it thinks, then strolls" are the same mechanism seen from both sides: the occasional poses were the real gaps where the session had expired. **A test run through the agent whose absence the test requires cannot pass**, and this belongs with the three false-pass shapes already recorded on 2026-08-10.
- **Deliberately not tuned yet.** The suppression window is session expiry (120 s) because that was the convenient default rather than a considered choice; a dedicated shorter window would make the pose appear sooner after the agent goes quiet. The owner chose to run a clean test first and decide from what they see, which is the right order.
- **Still open: whether the feature should default on.** It currently does. `README.md`'s privacy section previously claimed "no process inspection", and that sentence has been rewritten rather than left standing — this is a new category of observation, however narrow, and the honest move was to describe it precisely and give it a switch.
- Ten new tests covering the rung, the suppression rule, per-provider attribution, sleep interruption, and the allowlist — including that `com.example.claude-notes` does not match, which a substring check would have caught. Suite **209 → 219**. Neither the observer nor the menu is unit-testable from the package target; recorded as a gap.
- **Exact next step:** the owner runs the clean test — no Claude Code activity for two minutes, then chat in the Claude app — and the QA rows in `docs/QA_CHECKLIST.md` record the result. ChatGPT is deliberately second; one provider at a time was the owner's call.

### 2026-08-11 — A founding promise reversed, a real signal found, and nothing yet observed

- **Owner decision, taken with the alternatives on the table: read the chat window.** The frontmost-app version shipped earlier today was watched and rejected — "awkward and unsync" — and it deserved to be. It could not see a response start or finish, so the pose ran continuously while a human read and typed. The owner wants the pose to track the response: think from Enter, keep thinking while the answer streams, fist-pump when it lands, wait when input is needed. **None of that is reachable from outside the window.** The options offered were revert to manual, keep the rough proxy switched off, or cross the line deliberately; the owner chose to cross it.
- **This reverses "no accessibility permissions", which `README.md` promised from the first session.** It is recorded as a reversal of a founding principle, not as a feature. Two obligations were accepted with it and both are honored: read the **minimum** that answers the question, and make the failure **visible**, because a UI-string match fails silently.
- **The probe was built before the feature, and that ordering paid for itself.** Claude is Electron, and Chromium builds its accessibility tree lazily, so nobody could know whether a usable marker existed. The answer: while a response streams, exactly one element carries `AXSubrole=AXDocumentArticle` with `AXDescription=Currently streaming message`; when it lands the same element reads `Message 10 of 10` and gains a `Retry` button. **One element, one attribute, present once and then not at all** — far cleaner than the timing heuristics that would have been the fallback.
- **The first probe run produced a report that looked complete and was useless.** A depth cap of 18 stopped the walk at 41 nodes sitting at depth 17 — Electron nests roughly fifteen `AXGroup` levels before any content, so the tree was cut off just above the conversation. **A truncated tree is indistinguishable from an app that exposes nothing**, and the wrong conclusion was one report away.
- **The probe's redaction rule leaked, and this is the most important thing on this page.** It reported control *titles* on the assumption that a label is interface structure while static text is content. Claude puts a summary of the conversation in a **button title**, so a description of what the owner was discussing landed in a file and was read by this session. Nothing was published or committed, and the reports were deleted — but the promise was wrong before it was broken. `ChatActivityWatcher` therefore fetches only `AXRole`, `AXSubrole`, `AXDescription`, and `AXChildren`, and its documentation says in as many words that adding `AXTitle` would not be a tightening but a different program.
- **An instruction with a footgun in it destroyed one capture.** The owner was told to take two reports and rename between them; they clicked both first, so the second overwrote the first and the survivor was renamed "generating" while holding the finished state. **The fix was to remove the step, not to explain it better** — reports are timestamped now and cannot collide.
- **Then the feature did nothing, twice, for two different reasons.** The first: the owner was talking to Claude Code *in the app under test*, and the rule at the time suppressed the chat signal whenever any session was live, so nothing could appear. **The suppression rule was then removed** — it earned its place when the signal was "an app is frontmost" and could not tell chat from Claude Code, but the streaming marker is a fact about the chat window, and suppressing on any live session made the feature unreachable for everyone who uses Claude Code at all, which is precisely this app's audience. Ordering still protects the important case: a **working** agent outranks a generating chat, an **idle** session no longer blocks it. The second attempt after that change has not happened.
- **The diagnostic line was strengthened for the same reason it exists.** It said "granted", which is as useful as silence when the pose fails: it could not distinguish a renamed marker, an observer that never attached, and a signal that arrived and lost. It now reports what the watcher believes — `generating`, `open and quiet`, `app not running`.
- **Default changed to off.** It was on while it read a bundle identifier and nothing else. A feature that asks for Accessibility permission must be opted into, especially in an app whose selling point is that it cannot learn anything about you — and an unproven default is how an entire install comes to look broken.
- **Cost is tied to the app's activity rather than to a clock:** an `AXObserver` on layout changes, throttled to one bounded search per 0.75 s, with a 1 Hz re-check *only* while a response is believed to be in flight, since the change that ends a stream is the last one and nothing follows it to prompt another look.
- **Three states are wired: generating, completed, open. `waiting` is not** — no marker for it was ever captured, so a chat awaiting input looks like one that finished. ChatGPT is unwired by owner choice, one provider at a time.
- Suite **209 → 223**. The watcher, the probe, and the AX walk are not reachable from the package test target; recorded as a gap rather than covered by a test that asserts something easier.
- **Nothing here has been seen working.** That is the honest state at close, it is written into `README.md`'s limitations and the new QA section, and the feature ships off by default because of it.
- **Exact next step:** the third hands-on attempt. Enable the menu item, grant Accessibility (re-granting is needed after every reinstall — the grant is keyed to the signature and these builds are ad-hoc signed), then **read the `Chat Detection (Experimental)` line while a response streams**. `Claude chat: generating` with a strolling pet means the fault is downstream in the reducer or the animation; `open and quiet` means the marker no longer matches and Claude has renamed it. That one line decides which half to debug.

### 2026-08-11 — Session close

Twelve commits. The day began with the display matrix marked complete and ended with a founding privacy promise deliberately reversed, which is a wider span than any previous session in this ledger.

- **Shipped and proven on screen:** the display matrix closed at eleven of eleven rows on per-row evidence, including a real defect it found — dragged heights discarded when a display was unplugged, diagnosed from two hands-on results differing in one variable, fixed, and re-watched. The README screenshot is in place and pushed. `Stay in One Place` is per mascot, and the menu no longer freezes every pet.
- **Shipped and not proven:** chat lifecycle detection, off by default, never once observed working. The gap between those two lists is the whole reason this ledger exists.
- **The recurring shape of the day was documentation and instructions outliving their evidence**, in five distinct forms: ticks from a blanket verdict that nobody walked; a capture instruction with an overwrite footgun; a probe whose redaction rule was wrong about where content lives; a depth cap that made a populated tree look empty; and a suppression rule that survived the signal it was written for. **Only the last is a code defect. The rest are ways of being confidently wrong about what was already checked.**
- **What worked repeatedly: probe before building, and check the bundle before believing.** The accessibility probe cost one build and prevented a state machine founded on an assumption. The `ls` on the installed binary has now mattered three times. Both are cheap, and both partition the failure domain before the expensive step.
- **Two false-pass shapes were added to the collection**, both from testing the chat feature *through* Claude Code: a test run through the very agent whose absence it requires, and a signal whose suppression made success and absence identical. These join the three recorded on 2026-08-10.
- **Nothing is pushed since the screenshot.** The accessibility work is local and unverified, which is where it belongs until someone watches it.
- **Exact next step:** the third chat-detection attempt, reading the diagnostic line during a stream. If it still fails, the ChatGPT provider and the `waiting` marker both wait behind it — there is no point widening a signal that has not been seen working once.

## Next-session handoff

1. Read this file in full.
2. Treat `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` as the frozen base; never present another native tall variant as viable.
3. Treat atlas revision 6 as the geometry/timing contract: 16 rows, `768x1792`. `mascot-atlas@2x.png` is the classic navy wardrobe, worn by the **Codex** mascot, and `mascot-atlas-codex@2x.png` is its deterministic orange derivative, worn by the **Claude** mascot since the 2026-08-01 swap — the filename predates it and is stale, not wrong about the pixels. It carried sunglasses until 2026-08-02, when the owner rejected them; the two wardrobes now differ only in the hoodie and the sleeping blanket, and the derivative is pixel-identical to the classic atlas above the neck. Row 15 is the eight-frame `poof` smoke cloud and row 14 the four-frame `hand-sign` dismiss seal. `poof` is the only row that is not the character and is pixel-identical across both atlases; the hanging row remains at index 13 with a `(48, 4)` grip anchor.
4. Establish the repository state with `git status --short --branch`, `gh pr list`, and `git branch -a`. Note that `git branch -r --merged main` is **not** a safe way to decide what is merged here: every PR is squash-merged, so a merged branch's tip is never an ancestor of `main`, and the command has reported branches merged minutes earlier as unmerged. Run `tools/list_merged_branches.sh`, which cross-references the remote refs against GitHub's merge record and flags branches that moved after their PR merged. This item deliberately no longer names a revision or a PR number. It did until 2026-07-31, and the claim went stale three times — the last time within minutes, because the commit that corrected it was merged immediately after. A hash here is invalidated by the very next merge, so it was removed rather than corrected again.
5. Treat the current presentation as `96x112` points with a 10-point transparent Dock inset. Revisions 5 and 6 append rows inside the existing cell geometry; they change nothing about the cell, the anchors, or any earlier row.
6. Ask the owner to test dragging from several body points and verify that the raised hand remains under the cursor while the body swings left/center/right. Since 2026-07-30 also verify what happens *after* the drop: the mascot must carry on roaming at the height it landed at, keep that spot across Dismiss/Summon and reopen, and return to the bottom lane only via Reposition. Retain the broader click, reopen, relaunch, and display-matrix QA. The full list is in `docs/QA_CHECKLIST.md`.
7. Preserve the honest capability boundary. **Both providers are now observed live end to end on screen** — Claude Code since 2026-07-30, and Codex on 2026-08-10, when a real turn drove the navy mascot to its computer and through the success reaction while the orange mascot was unaffected. Codex's command-shape defect was fixed on 2026-08-02 and its seven hooks are installed, trusted, and Active. `waiting` was observed 2026-08-09. **`failed` is the one state still fixture-only**, because neither provider reports a turn-level failure in ordinary use; it needs a genuinely failing turn, not a longer look. Before 2026-08-10 this item warned against promoting a successful-but-unwatched hook run into visual QA — the warning is retired because the watching finally happened, not because the standard relaxed.
8. Treat `EventEnvelope` as the privacy boundary and `EventDecoder` as fail-closed. Do not widen the envelope, relax the `SessionID` charset, or copy payload text into an error without a recorded product decision. `AgentSession` and `EventPipelineDiagnostics` extend the same boundary and must gain no new field either — in particular, do not surface transport rejection *reasons* in the interface, since they are derived from bytes a caller controls. Keep the two clocks separate as well: wall-clock `occurredAt` orders events inside one session, monotonic `Uptime` drives expiry and reactions, and both stay caller-injected so fixtures remain deterministic. On the transport side, keep the helper's flag set closed, keep the session value hashed inside the helper, keep the `getpeereid` same-user check, and keep the socket path derived rather than passed in.
9. `DockGeometry` computes a bottom-anchored origin and has no Dock-edge inference at all. Do not reintroduce left/right Dock-aware placement without a fresh owner decision; it is future scope, not a bug to quietly fix back in. The one sanctioned exception to bottom anchoring lives in `WindowCoordinator`: `settleAfterDrop()` adopts the height the user dropped the mascot at, `hasManualPlacement` reports it, and `reposition()` is what discards it. Roaming is no longer a proxy for "the user placed this themselves" — dragging leaves roaming on — so do not reach for `isRoaming` to answer that question. `MascotVisibleState` remains the single typed source of visible state, and `AmbientAnimationController` has no `setPaused`/`setIdeating` of its own. Keep it that way: anything that wants to change what the pet is doing must go through the reducer, never by setting a row directly. Anything that wants to *accompany* an animation hangs off `onStateAppeared`, which fires after the selector's dwell, rather than off reduced state.
10. Do not mistake direct `open` activation for automatic panel focus theft; the verified background launch (`open -g`) left ChatGPT/Codex frontmost. Do not use `open -j`, which intentionally hides the app.
11. Merge and branch-delete commands are sometimes refused for the assistant by the auto-mode permission classifier and sometimes allowed; the outcome is not predictable in advance. If one is denied, hand the owner the exact command to run in their own terminal rather than retrying it or working around the denial.
12. The app **is** installed durably at `~/Applications/Dock Pet.app` by `tools/install_app.sh` ([PR #22](https://github.com/Mr-Shine09/desktop-mascot/pull/22)), ad-hoc signed with the nested helper signed first, and survives reboot. Relaunching is `open -g "$HOME/Applications/Dock Pet.app"`, not a rebuild. Two things still hold: the build is **not notarized**, so it is trustworthy only on the machine that built it and cannot be given to anyone else without a Developer ID certificate; and there is no launch-at-login by owner decision, so nothing starts it for you. `install_app.sh` will find and *attempt* any Apple Development identity in the local keychain before falling back to ad-hoc — set `CODESIGN_IDENTITY=-` to skip that lookup entirely.
13. More than one agent session may be working in this repository at the same time, sharing one working tree. Before committing, run `git status --short --branch` and confirm every staged file is yours; stash and rebranch rather than bundling another session's work into your commit.
14. The animation speed control was **deferred out of 0.1** by owner decision on 2026-08-01. It is no longer an open question or a blocker.
15. **Fixed 2026-08-02.** `aDropPastAnEdgeIsClampedBackIntoView` no longer fails with a second display attached; the full 198-test suite passed five consecutive runs on a two-display machine. The earlier entry said the test failed *whenever* a second display was attached and was "not a flaky test"; both halves were wrong. It was intermittent — it passed in isolation and under some filters, and failed under others — because `NSWindow.screen` is nil for a panel dropped clear of every display, and the old `NSScreen.main` fallback resolves to whichever display holds **keyboard focus**. `WindowCoordinator.referenceScreen` now prefers the display the panel was last genuinely on, falling back to the nearest display and only then to `NSScreen.main`. Do not reintroduce a focus-dependent fallback.
16. The dismiss transition, the quit farewell, the two transition cues, drag-and-drop, and the app icon were **owner-approved on 2026-08-01 from the installed `~/Applications` build, happy path only.** **The four edge cases — Reduce Motion, re-summon mid-poof, dismiss-while-paused, and the second-Quit escape hatch — were each walked on 2026-08-10 and each passed.** The warning this item used to carry, "do not promote *the owner liked it* into *the edge cases pass*", is retired as a live claim and kept as a lesson: `docs/QA_CHECKLIST.md` had them ticked from the 2026-08-02 blanket verdict the whole time, contradicting this very item, and they were ticked before anyone walked them. They turned out fine, which is luck rather than method.
17. **Give every worktree its own `-derivedDataPath`.** It is shared mutable state: on 2026-08-01 a background session rebuilt the Debug bundle from `main` while the owner tested a feature branch, producing a four-feature false bug report. Check `Contents/Resources/` before trusting any hands-on test.
18. The menu bar item is an **app-owned `NSStatusItem`**, not a SwiftUI `MenuBarExtra`, since 2026-08-03. A `MenuBarExtra` obeys the visibility macOS remembers, and a stray Command-drag off the menu bar made the app terminate itself ~0.1 s into every launch with no icon and no crash report. Do not convert it back. The icon went missing because a removal is keyed to the **bundle identifier**, in a system store the app cannot reach. **Resolved 2026-08-05** by changing `PRODUCT_BUNDLE_IDENTIFIER` to `com.mrshine09.dockpet` (owner decision); the pawprint is confirmed on screen by `screencapture`. Do not revert the identifier, and do not remove the owned status item believing the identifier change covers it — they fix two different faults. `EventSocketLocation.directoryName` deliberately still spells the old identifier: it is the socket path installed hooks use. Verify the icon with `screencapture` of the menu bar strip — `CGWindowList` cannot see status items. To check a **menu title** with `strings`, note that a Debug build puts the app's code in `Contents/MacOS/<name>.debug.dylib` rather than in the main executable, so running `strings` on the executable finds nothing and is indistinguishable from a failed build.
19. Update this ledger before ending the next session. **Write the close last, and if the session continues afterwards, do not rewrite it** — 2026-08-10 has a superseded close in the middle of its entries for exactly this reason, kept because its "exact next step" is what genuinely happened next.
20. Use `CLAUDE.md` and `docs/HANDOFF.md` as the maintainer onboarding entry points; keep them synchronized when architecture, commands, or asset contracts materially change.
21. Wardrobe is a fixed property of a mascot, not a selection. There is one mascot per provider (2026-08-01): **Claude wears orange, Codex wears classic navy**, via `MascotFashion.worn(by:)` — not via `MascotVisibleState.providers`, which no longer selects anything. This is the reverse of the mapping used earlier on 2026-08-01, so `mascot-atlas-codex@2x.png` holds the *Claude* wardrobe; the filename is stale and must not be "corrected" by flipping the mapping. Since 2026-08-02 there are no sunglasses: the hoodie and the sleeping blanket are the only differences. Both are settled: the orange wardrobe was owner-approved on screen 2026-08-02, and a live Codex run drove the navy one on 2026-08-10, with the orange mascot visibly unaffected by Codex's traffic — the first on-screen evidence that per-provider attribution works, rather than a unit-test property of `reduce(sessions:attributedTo:)`.
22. The ambient animation loop runs at **12 Hz**, owner-verified on screen 2026-08-05 as moving fine, with the occlusion pause verified on other screens the same day. Both mascots share one rate — `ambientTickInterval` is a `private static let` and `MascotInstance.swift:50` is the only construction site — so there is no per-provider tick rate to change, and a request to "slow the Codex mascot" is a walk-speed question, not a tick one. An idle provider's mascot strolls continuously by design, which is what makes it look busier than a working one. Transitions stay at 20 Hz and are exempt from the occlusion pause, because `beginDismiss` orders the panel out from its completion and Quit waits on that.
23. **The idle-CPU gate was restated to `<3%` on 2026-08-09 by owner decision and now passes** at 2.17% median with one mascot (n=20 over 5 min) and an Energy Impact of 3.70. It is settled — do not re-open it as a failure. The old `<1%` was unreachable by tick rate: cost is near-linear in ticks, so it needed ~5.5 Hz, below the sprite's own ~8 fps. The structural levers (stop moving the `NSPanel` every tick while walking; coalesce both mascots onto one timer, which only helps the two-mascot case) were deliberately **not** spent and remain available if the number ever has to drop. Two mascots have still never been measured; do not assume the cost is linear in mascot count. Sample for minutes — a single 5-second `powermetrics` window landed on the top of the range and produced a wrong conclusion on 2026-08-05.
24. **The latency gate passes and is closed:** ~70 ms typical, ~122 ms worst case, against 500 ms, measured 2026-08-09. It is a composition of measured parts, not one stopwatch, because nothing in the app timestamps a state reaching the screen — the table and its caveats are in `docs/QA_CHECKLIST.md`. Two things a future session must not misread: the socket-read hop is deliberately unmeasured (it cannot plausibly matter against 380 ms of headroom), and the 0.75 s dwell **can** push a second change inside one dwell window past 500 ms **on purpose**. The dwell is what stops a working/waiting flip storm from looking like a glitch; do not shorten it to make a number look better.
25. **The repository is public as of 2026-08-09** and both original blockers are closed: the username scrub landed and CI is green. The eleven art provenance records carry repository-relative paths, and the two tools that write them emit relative paths, so a regeneration cannot reintroduce the leak — do not "fix" a provenance path back to an absolute one. **When writing about the scrub, write the placeholder, never the path:** the scrub's own ledger entry quoted the literal home directory twice while describing its removal, and asserted in the same breath that a grep found nothing. It was caught only by a pre-publication check, after the repository was already public. **Git history still carries the owner's real name and email on every commit**, untouched, so public is not anonymous — that is a separate decision and it cannot be undone without breaking every clone. The project page **has its screenshot as of 2026-08-11** — `docs/images/readme-hero@2x.png`, a real capture of the running app with both mascots, taken by an agent session after the owner staged the desktop. The first frame had to be discarded: it caught a personal photo in the Dock that no crop could exclude without also losing a mascot.
26. **CI's first run on 2026-08-08 exposed a real flake, now fixed and green six consecutive runs (2026-08-09).** `makePipe` in `HookPayloadReaderTests.swift` dispatched its blocking writer to `DispatchQueue.global()`, which starves on a low-core runner and timed out a *different* pipe test each run — a moving failure, which is what identified it as a scheduling race rather than one bad test. The writer now runs on a dedicated `Thread`; do not move it back onto a shared queue. The production `HookPayloadReader` was **not** at fault and was not changed. This machine cannot verify the fix — the suite passed both before and after it — so CI is the only evidence, and six runs is reassuring rather than conclusive. Note that a `pull_request` workflow runs against `refs/pull/N/merge` and is skipped **silently** while the PR conflicts: if CI appears not to exist on a PR, check mergeability before debugging the workflow.
27. Keep the README's "Current limitations" section honest. It names the absence of a notarized build and the fixture-only `failed` state, and those must not be softened to make the project page look better. The section has been corrected twice rather than left stale, both times in the direction of *good* news, which is the easier kind to forget: on 2026-08-09 the idle-CPU gate became **restated and passing** and `waiting` stopped being fixture-only, and on 2026-08-10 the **unobserved Codex on-screen reaction was removed entirely**, because a real Codex turn drove the navy mascot. A limitation that has been fixed is as stale as one that has been softened.
28. **A waiting session no longer expires after the ordinary 120 s.** `SessionRegistryLimits.waitingTimeout` (1800 s) is selected by activity in `SessionRegistry.isExpired`. A blocked agent sends nothing while it waits, so the ordinary quiet-means-gone rule retired the one session most certainly alive and the mascot strolled away from a live permission prompt. It is deliberately **not** infinite: an agent killed mid-prompt would otherwise leave the pet asserting `waiting` forever. Do not collapse this back into one timeout.
29. **Manual ideating outranks `working` since 2026-08-09**, but still sits below `waiting` and `failure-recent` — a standing preference must not hide something asking for attention. The full ladder is written out in **four** files (`README.md`, `docs/HANDOFF.md`, `docs/ARCHITECTURE.md`, and the Aggregate state reducer section above); a reorder has to update all four. Ledger entries dated before 2026-08-09 describe the old order and are records of their own day, not errors.
30. **Scheduled sleep is user-adjustable and switchable off.** `MascotStateReducer.sleepWindow` is now `SleepWindow?`, where `nil` means never sleep; `SleepWindow.init` clamps hours into `0 ... 23` because the values arrive from preferences that anything can write. Three defaults keys hold enabled/start/end, and the hours are retained while sleep is off so re-enabling restores the user's schedule. **The trap here, avoided once and easy to reintroduce:** a restored preference that populates the menu's checkmarks but never reaches the reducer looks like it works and silently reverts on relaunch. `applicationDidFinishLaunching` pushes the window into the bridge before `start()`.
31. **All three of the 2026-08-09 behavior changes were observed on screen on 2026-08-10 and all three pass** — the waiting timeout (held past three minutes against a real Manual-mode permission prompt), the ideating reorder (Thinker pose while a real session worked), and the sleep schedule (lay down, and survived relaunch). They shipped on 2026-08-09 proven by unit test and a green build only, and that gap is closed; the history is kept because the *way* it was closed is the reusable part. **They were not merely undone until 2026-08-10 — they were impossible**, because the installed bundle predated all three changes; it was reinstalled from `main` that day and only then could the checks exercise the real code. The three checks, should any of them ever need rerunning: set the sleep hour to the current hour and watch the pet lie down, then relaunch and confirm it is still asleep on that schedule; toggle Manual Ideating while an agent is running and look for the **Thinker pose and thought cloud**; leave a real permission prompt unanswered for more than two minutes and confirm the pet stays put. **This item said "look for the lightbulb" until 2026-08-10, which is the `failure` marker, not ideating** — a cracked light bulb is row 6. An instruction naming the wrong animation makes a correct pass look like a failure and a real failure look like a pass; check a described animation against `art/animation/ATLAS.md` before putting it in a test script.
32. **The installed app does not follow `main`.** `~/Applications/Dock Pet.app` changes only when someone runs `tools/install_app.sh`, and nothing warns that it has fallen behind; on 2026-08-10 it was four days and three behavior changes stale. Before requesting or trusting any hands-on observation, compare the bundle binary's mtime against the commit that introduced the behavior, and confirm the feature is really in the binary (`strings` on the executable is enough for a menu title). This is the non-worktree twin of the shared-`derivedDataPath` incident in item 17.
33. **An agent process may or may not be able to see the screen — probe, do not assume.** On 2026-08-10 `screencapture` from this process returned a blank frame (no Screen Recording permission) and that was recorded as a fixed limitation. **On 2026-08-11 the same command returned a real 2560x1664 capture with content**, so the limitation had lapsed. The durable rule is the check, not the verdict: capture, then confirm the image has content (size plus distinct-colour count is enough) before believing either answer. **A capture that succeeds is not automatically safe to use** — the 2026-08-11 probe caught the owner's Claude Code window, this conversation, and a sidebar of their other session titles, and it was deleted rather than kept. Anything destined for the public repository needs the desktop staged first.
34. **The README screenshot is done (2026-08-11).** `docs/images/readme-hero@2x.png` is in place and linked. What is worth keeping from how it went: the capture itself was possible from an agent session, staging the desktop was not; the blocking risk was **what else was on screen** rather than permissions, since a personal photo in the Dock could not be cropped out without losing the mascot standing beside it; and the frame was verified at native resolution, because a downscaled preview invented a third mascot out of wallpaper. The original guidance, kept for reference: `docs/ASSET_PIPELINE.md` → "Project page screenshot" carries the setup order, the region-capture command, the target path `docs/images/readme-hero@2x.png`, and the accept/reject rule. Three of its five setup steps exist because of mistakes this project already made: reinstalling mid-capture would quit the app under test (item 32), Manual Ideating left on would override the state being shown (item 29), and a blank capture from a process without Screen Recording permission looks like a real PNG (item 33). **Do not add the `![…]` link to `README.md` before the image file exists** — the repository is public and a broken image is worse than no picture.
35. **Unplugging a display used to lose a mascot's dragged height; fixed 2026-08-10, and the fix has not been watched on screen yet.** `screenParametersChanged` derived the height from `panel.frame.minY` via `settleAfterDrop()` — correct for a drop, where the frame is the user's intent, wrong after AppKit relocates the window off a removed display, where it is the system's. The remembered `manualLaneY` went unread. The handler now re-clamps the stored value; X still comes from the frame because roaming rewrites it and there is no remembered X. `aDisplayChangeKeepsTheDraggedHeightRatherThanASystemRelocation` covers it and was confirmed to fail against the old handler. **Re-walked on screen 2026-08-11 from a rebuilt install and it passes** — the pet came back at the dragged height, with the bundle verified newer than the fix commit first. The unit test stands in for AppKit's relocation and cannot by itself prove AppKit behaves like the stand-in; the on-screen rerun is what closes that gap, so do not delete it as redundant with the test.
36. **Two settled owner decisions from 2026-08-11.** The mascots **float over full-screen apps on purpose** — approved, not merely observed, so it is not a window-level bug to fix. And **`sit-shake-right`/`sit-shake-left` (atlas rows 11 and 12) are deliberately unused**: authored, validated, inside the frozen contract, selected by nothing. They were offered as the stationary pose and the owner kept the standing `idle` blink. The note lives beside the rows in `art/animation/ATLAS.md`. Do not delete them as dead art, and do not wire them in without a fresh decision.
37. **"Make the mascot stay in one place" is an existing feature, not a gap — and the menu now says so.** Ticking **Stay in One Place** holds the pet where it is, keeps it animating in place, persists across relaunch, and leaves reactions alone because `setRoaming` acts only when `plan.isAmbient`. It was requested as new work on 2026-08-11 because the item was then called **Roam Along Bottom**, naming what is switched *off* rather than the mode switched *on*; the owner renamed it the same day. **The inversion is in the label only.** `isRoaming` keeps its polarity and its defaults key `…desktopmascot.roaming` keeps its name and meaning — renaming the key would silently reset every existing choice, the same trap the `reactionSoundsMuted` key carries. The pet's own click menu reads "Stay in One Place" / "Start Roaming Again". **Check whether a requested feature already exists before building it — by reading the code that would implement it, not the menu title.**
38. **Chat lifecycle detection reads the Claude window through the accessibility API, by owner decision on 2026-08-11, reversing this project's "no accessibility permissions" promise.** It is **off by default** and **has never been observed working**. What must not be undone by accident:
    - **Only four attributes are ever fetched** — `AXRole`, `AXSubrole`, `AXDescription`, `AXChildren`. Adding `AXTitle` or `AXValue` starts reading the conversation: Claude puts a summary of the discussion in a *button title*, which the diagnostic probe learned by leaking one into a file.
    - **The marker is `AXDescription == "Currently streaming message"`** on an `AXDocumentArticle`, verified 2026-08-11. It is an English UI string with no stability guarantee; when it changes the pet silently stops reacting, which is why the menu reports what the detector believes rather than merely whether permission was granted.
    - **There is no suppression by live session.** That rule existed for the frontmost-app signal, which could not tell chat from Claude Code in one bundle identifier. It made the feature unreachable for anyone running Claude Code and was removed; ordering alone protects the real case, since `working` outranks a generating chat while an idle session does not block it.
    - **`waiting` is unimplemented** — no marker captured — and **ChatGPT is unwired**, by owner choice of one provider at a time. Do not widen the signal before it has been seen working once.
    - **Accessibility must be re-granted after every reinstall**, because the grant is keyed to the code signature and these builds are ad-hoc signed. A test that "fails" right after an install is usually this.
    - `ChatAccessibilityProbe` and the `Chat Detection (Experimental)` menu are temporary scaffolding. Remove them once the feature is proven or abandoned — not before, because they are the only way to tell the two apart.

## Documentation sources

- [Official Codex hooks documentation](https://learn.chatgpt.com/docs/hooks)
- [Official Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Instagram reference post](https://www.instagram.com/p/DbV-I14FKJ2/?img_index=3)
