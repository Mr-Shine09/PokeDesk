# Claude Code project instructions

Welcome, Mr. C. This file is the mandatory entry point for work on Dock Pet.

## Start every session

1. Read [`docs/HANDOFF.md`](docs/HANDOFF.md).
2. Read the current snapshot and next-session handoff in [`DesktopMascot.md`](DesktopMascot.md). Read the full ledger before changing scope, architecture, art, or product behavior.
3. Run `git status --short --branch` before editing. Never discard an unfamiliar modification or untracked file.
4. Run the baseline checks in [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).
5. Select the smallest open gate from the ledger and state what evidence will prove it complete.

## Non-negotiable project rules

- This is a native macOS 14+ SwiftUI/AppKit accessory app. Do not replace it with Electron, a browser overlay, Dock injection, or private APIs.
- Preserve privacy: never read or store prompts, transcripts, source code, tool arguments/output, repository paths, tokens, or screen content. Agent integrations accept only coarse lifecycle events.
- Preserve the frozen character identity in `art/production/mascot-base-chibi-40pt-at2x-80px-final.png`. Do not revive rejected tall variants.
- Treat `art/animation/atlas-contract.json` as the machine-readable geometry/timing contract. Revision 6 is 8 columns by 16 rows, `768x1792`, with `96x112` backing-pixel cells. `mascot-atlas@2x.png` is the classic Claude/no-provider wardrobe; `mascot-atlas-codex@2x.png` is its deterministic orange/sunglasses derivative. Rows 14 and 15 are the dismiss `hand-sign` seal and `poof` smoke cloud; `poof` is pixel-identical across wardrobes.
- Render sprites with nearest-neighbor interpolation. Production alpha is binary. The classic atlas remains within the frozen 12-color palette; the Codex derivative may add only the three orange shades declared in `tools/author_codex_fashion_atlas.py`.
- The hanging row has a distinct top grip at atlas coordinate `(48, 4)`, mapped to AppKit panel point `(48, 108)`. Do not ground-align it.
- Keep the mascot non-activating and retain a menu-bar escape hatch for summon/dismiss, pause, and quit.
- Dragging is a placement gesture only: it never changes roaming. The mascot roams at whatever height it was dropped at (owner decision, 2026-07-30), and Reposition is the only way back to the default bottom lane. Do not restore lane-snapping on drop without a fresh owner decision.
- The mascot appears only when summoned. Launching the app must never put one on screen, and there is no launch-at-login by owner decision (2026-07-30).
- Summon and dismiss are both transitions, not instant state changes. Summon opens the Dock portal; dismiss plays the `hand-sign` seal and the `poof` smoke, and the panel is ordered out only when `beginDismiss`'s completion fires (owner request, 2026-08-01). Do not hide the panel synchronously from `setVisible(false)`.
- Quit plays the same farewell when a mascot is on screen (owner request, 2026-08-01), but quitting must stay reliable: a second Quit terminates immediately, an unsummoned mascot skips it, and `isQuitting` blocks a summon from cancelling it. Never make quitting depend on an animation completing.
- Four cues exist — `success`, `failure`, `summon`, `dismiss` — all synthesized by `tools/author_sound_effects.py`. One menu toggle silences all of them. The persisted key is still `reactionSoundsMuted`; do not rename it, or every existing choice silently resets.
- XcodeGen owns `DesktopMascot.xcodeproj`. Change `project.yml`, then regenerate; do not make durable project-file-only edits.
- Dock Pet reflects real Claude Code activity, observed 2026-07-30 from a live session. Two limits still hold: **Codex has never been run live** (it shares the adapter, which is inference, not evidence), and `waiting` and `failed` are fixture-covered but have never been seen from a real provider. Do not describe either as proven.
- Provider wardrobe selection consumes `MascotVisibleState.providers` and must not become a second animation-state path: Claude/no-provider/manual is classic, Codex is orange/sunglasses, and Codex wins the accent when both providers contribute while diagnostics name both.
- Update `DesktopMascot.md` at the end of every implementation session with decisions, evidence, risks, and the exact next step.

## Current priority

0. Owner hands-on QA begins with the new Codex orange/sunglasses wardrobe, then the display matrix. All four sound cues (success, failure, summon, dismiss), the dismiss/quit transition, drag-and-drop, and the app icon were all owner-approved on 2026-08-01 from the installed `~/Applications` build. The animation speed control was deferred out of 0.1 by owner decision the same day. Codex has still never driven the app live, and `waiting`/`failed` remain fixture-only, so do not describe them as proven.
2. Give every worktree its own `-derivedDataPath`. It is shared mutable state, and on 2026-08-01 a background session rebuilt the Debug bundle from `main` while the owner tested a feature branch — four features looked broken that were simply not in the launched app. Before trusting any hands-on test, list the bundle's `Contents/Resources/`.
3. Verify documentation claims against the committed file, not against an edit script's output. Several ledger rows were reported updated on 2026-07-30 and were not — a string replacement whose target does not match fails silently. `git show HEAD:<file> | grep` is the check that would have caught it.
4. Keep `MascotVisibleState` the single source of what the pet is doing. Anything that wants to change the animation goes through the reducer, never by setting an atlas row directly.

Detailed procedures:

- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — build, run, test, and repository workflow
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — components, state flow, and invariants
- [`docs/ASSET_PIPELINE.md`](docs/ASSET_PIPELINE.md) — sprite sources, atlas generation, and QA
- [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md) — automated and hands-on acceptance checks
