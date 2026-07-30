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
- Treat `art/animation/atlas-contract.json` as the machine-readable art contract. Revision 3 is 8 columns by 14 rows, `768x1568`, with `96x112` backing-pixel cells.
- Render sprites with nearest-neighbor interpolation. Production alpha is binary and colors must remain within the frozen 12-color palette.
- The hanging row has a distinct top grip at atlas coordinate `(48, 4)`, mapped to AppKit panel point `(48, 108)`. Do not ground-align it.
- Keep the mascot non-activating and retain a menu-bar escape hatch for show/hide, pause, and quit.
- XcodeGen owns `DesktopMascot.xcodeproj`. Change `project.yml`, then regenerate; do not make durable project-file-only edits.
- Do not claim that roaming reflects real Claude/ChatGPT activity. The app reduces real events into `MascotVisibleState`, but no animation consumes it and no provider adapter exists, so the only source of events today is a developer running `dockpet-event` by hand.
- Update `DesktopMascot.md` at the end of every implementation session with decisions, evidence, risks, and the exact next step.

## Current priority

1. Bundle the `dockpet-event` helper inside the app so a provider hook can invoke it by path, then add the privacy-preserving Claude Code and Codex hook adapters (#8, #9). The entire downstream path — event model, strict decoder, session registry, deterministic reducer, local socket transport, the helper, the socket server running inside the app, and animation selection from `MascotVisibleState` — is implemented, tested, and owner-verified as of 2026-07-30. The input side is the only thing still missing.
2. Obtain/record owner hands-on QA for cursor hanging and the remaining display matrix (auto-hide, multiple displays, full-screen Spaces, sleep/wake). Placement is bottom-anchored only, so left/right Dock is no longer part of that matrix.
3. Keep `MascotVisibleState` the single source of what the pet is doing. Anything that wants to change the animation goes through the reducer, never by setting an atlas row directly.

Detailed procedures:

- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — build, run, test, and repository workflow
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — components, state flow, and invariants
- [`docs/ASSET_PIPELINE.md`](docs/ASSET_PIPELINE.md) — sprite sources, atlas generation, and QA
- [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md) — automated and hands-on acceptance checks

