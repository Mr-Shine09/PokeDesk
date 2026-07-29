# Development guide

## Requirements

- macOS with Xcode supporting Swift 6
- macOS 14+ deployment target
- Python 3 with Pillow for art tools
- XcodeGen when `project.yml` changes
- Git access to the private `Mr-Shine09/desktop-mascot` repository when publishing is authorized

No runtime network dependency is intended.

## Repository layout

```text
DesktopMascot/App/                  SwiftUI app shell and ambient controller
Packages/DesktopMascotKit/         Swift package: core, animation, and window modules
art/production/                    frozen base mascot
art/animation/                     contract, sources, frames, atlas, and QA output
tools/                             deterministic art build/validation scripts
project.yml                        XcodeGen source of truth
DesktopMascot.md                   authoritative living project ledger
docs/                              takeover/runbook documentation
```

## Safe session start

```bash
git status --short --branch
git log --oneline --decorate -12
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png
```

The worktree may contain owner or prior-developer work. Never use `git reset --hard`, `git clean`, or checkout commands that discard files unless the owner explicitly requests the exact destructive action.

## Run package tests

From `Packages/DesktopMascotKit`:

```bash
CLANG_MODULE_CACHE_PATH=/private/tmp/mac-dock-pet-clang-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/mac-dock-pet-swiftpm-cache \
swift test
```

Expected handoff baseline: 10 Swift Testing tests pass. A higher count is fine; a lower count requires investigation.

## Generate the Xcode project

Only required after changing `project.yml`, adding/removing app source files, dependencies, resources, or build settings:

```bash
xcodegen generate
```

Review the generated `DesktopMascot.xcodeproj/project.pbxproj` diff. Do not hand-edit the project as the sole durable change.

## Build the app

```bash
xcodebuild \
  -project DesktopMascot.xcodeproj \
  -scheme DesktopMascot \
  -configuration Debug \
  -derivedDataPath /private/tmp/DesktopMascotDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The unsigned app is written to:

```text
/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app
```

Launch in the background so Dock Pet does not intentionally activate over the current app:

```bash
open -g '/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app'
```

Do not use `open -j`; it intentionally launches hidden and can make lifecycle debugging confusing.

## Verify bundled resources

```bash
shasum -a 256 \
  art/animation/mascot-atlas@2x.png \
  '/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app/Contents/Resources/mascot-atlas@2x.png'

cmp \
  art/animation/atlas-contract.json \
  '/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app/Contents/Resources/atlas-contract.json'
```

Both atlas hashes must match and `cmp` must exit successfully.

## Before committing

```bash
git diff --check
git status --short
```

Run tests proportionate to the change:

- Core/event logic: package tests plus new fixtures.
- Window behavior: package tests, unsigned build, and relevant manual matrix.
- Atlas/art: contract, frame-row, atlas validation, QA rendering, package crop test, and unsigned build.
- Project/resource changes: regenerate Xcode project and inspect bundled resources.

Commit generated project and atlas outputs with their source definitions in the same intentional change. Do not push or open-source the private repository without explicit owner direction.

## Common failure modes

- SwiftPM cannot write `~/.cache`: use the `/private/tmp` cache environment shown above or allow the tool appropriate local cache access.
- Xcode build embeds stale art: confirm `project.yml` resource entries, rebuild, and compare hashes.
- Wrong atlas row appears: JSON row indices are top-origin; `SpriteAtlas` must crop using `row.index * cellHeight` without vertical inversion.
- Hidden app seems impossible to reopen: Hide leaves the accessory process alive; reopening must invoke `applicationShouldHandleReopen`. Quit is separate.
- Mascot slides instead of walks: verify runtime crop equality and that animation direction matches horizontal movement.
- Drag artwork appears detached from cursor: preserve the hanging atlas grip `(48, 4)` to AppKit panel point `(48, 108)` mapping.

