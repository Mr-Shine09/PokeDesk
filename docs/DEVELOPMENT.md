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
Packages/DesktopMascotKit/         Swift package: core, animation, window, and transport modules
                                   plus the dockpet-event helper executable
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

Expected handoff baseline: 187 Swift Testing tests pass as of 2026-08-01. A higher count is fine; a lower count requires investigation.

If the suite fails only some of the time, check the clock before the code. One
fixture family reduces against the sleep window (23:00–06:00 local), and a
fixture that reduces against the real `Date()` instead of an injected instant
passes all day and fails all evening. Pin the instant and verify its UTC hour.

## Exercise the event helper

`dockpet-event` sends one lifecycle event to a running Dock Pet over the current
user's private socket. Since 2026-07-30 it is built as a native tool target and
copied into the app bundle, so the copy a hook should invoke is the one inside
the installed bundle:

```text
~/Applications/Dock Pet.app/Contents/MacOS/dockpet-event
```

That path is durable — `tools/install_app.sh` puts the bundle there and it
survives reboot, which is why the hooks installed into `~/.claude/settings.json`
keep working. A Debug build also produces a copy under
`/private/tmp/DesktopMascotDerivedData/...`, but that location moves whenever the
build location does, so prefer the installed bundle. The menu bar offers **Copy
Event Helper Path** for whichever copy is actually running.

For quick iteration the package copy still works and is identical in behavior:

```bash
swift run dockpet-event --provider claude-code --event active --session demo --verbose
```

The running app listens as of 2026-07-30, so with Dock Pet launched the event is
delivered and the menu bar's `Event socket:` line advances. The helper still
exits 0 when nothing is listening, so a provider hook is never failed by Dock Pet
being closed. `--verbose` sends one line to stderr; without it the helper is
silent. Usage errors exit 64.

The reduced state appears in the menu bar under `Reduced state:`, and since
2026-07-30 it also selects the animation. Sending `active` puts the pet at its
computer; `completed` plays the success reaction and returns it to strolling.
Note that a session expires after 120 seconds of silence, so a `completed` or
`waiting` sent long after its `active` is ignored as an unknown session.

## Install the provider hooks

The adapter is a mode of the helper rather than a separate script, so there is
nothing to install but configuration. Print a ready-to-paste snippet:

```bash
'/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app/Contents/MacOS/dockpet-event' --print-hooks --provider claude-code
```

Merge the result into `~/.claude/settings.json` (or `~/.codex/hooks.json` for
`--provider codex`). Dock Pet never writes those files itself.

Each hook invokes the helper with `--hook`, which reads the provider's payload on
stdin and maps `hook_event_name` onto the event vocabulary. Only
`hook_event_name` and `session_id` are read; every other key is dropped without
being inspected, and the session value is hashed before it leaves the process.

To check a mapping without configuring anything:

```bash
echo '{"hook_event_name":"Stop","session_id":"demo"}' | dockpet-event --hook --provider claude-code --verbose
```

The helper exits 0 for every outcome except a usage error: unmapped hook,
unparsable payload, Dock Pet closed, or stdin held open past its 2-second
deadline. A hook must never fail or stall the user's real agent session.

## Install durably

```bash
./tools/install_app.sh
```

Builds Release, signs the nested helper and then the bundle, and installs to
`~/Applications/Dock Pet.app`. That path survives reboots, unlike the DerivedData
build, so provider hooks configured against it keep working.

The script signs with a real identity when it can and falls back to ad-hoc
otherwise. `codesign` cannot reach a private key from a non-interactive shell
(`errSecInternalComponent`), so run the script from an interactive terminal if
you want the Apple Development identity used. Ad-hoc is sufficient for a
self-built local app; it is **not** sufficient for distribution.

Notarization needs a `Developer ID Application` certificate, which this machine
does not have. Distribution remains open work under issue #13.

## Clean up merged branches

```bash
tools/list_merged_branches.sh
```

**Do not use `git branch -r --merged main` here.** Every PR in this repository is
squash-merged, so a merged branch's tip never becomes an ancestor of `main`. On
2026-07-31 that command reported three branches merged minutes earlier as
unmerged while listing others as merged — wrong in both directions, and unsafe
for deciding what to delete.

The script classifies each remote branch against GitHub's merge record:

- `SAFE` — merged, and the tip still matches what was merged.
- `KEEP` — has an open PR.
- `REVIEW` — merged but the branch moved afterwards, or has no PR at all.
  Those later commits are not in `main`; look before deleting.

It prints the delete command and never deletes anything itself.

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

**`open -g` does not relaunch an app that is already running.** It sends a reopen
event to the existing process, so a rebuild appears to have had no effect and you
end up testing the previous binary. This has already cost one debugging session.
Always quit first:

```bash
osascript -e 'quit app id "com.mrshine09.desktopmascot"'
```

Confirm the process actually restarted before trusting what you see — the start
time must be later than the binary's build time:

```bash
ps -o pid,lstart -p $(pgrep -f "Dock Pet.app/Contents/MacOS" | head -1)
ls -la '/private/tmp/DesktopMascotDerivedData/Build/Products/Debug/Dock Pet.app/Contents/MacOS/Dock Pet'
```

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
- Tests fail in an unrelated module right after a stored property is added to a public struct: the incremental build can keep a stale module with the old layout, so a dependent target reads the struct wrongly and produces convincing nonsense — a live session reducing to `offline`, for instance. Run `swift package clean` before believing the failure. This has already cost one debugging detour.
- Xcode build embeds stale art: confirm `project.yml` resource entries, rebuild, and compare hashes.
- Wrong atlas row appears: JSON row indices are top-origin; `SpriteAtlas` must crop using `row.index * cellHeight` without vertical inversion.
- Hidden app seems impossible to reopen: Hide leaves the accessory process alive; reopening must invoke `applicationShouldHandleReopen`. Quit is separate.
- A code change appears to do nothing at runtime: the old process is probably still running, because `open -g` reopens rather than relaunches. Quit, relaunch, and compare process start time against binary build time before concluding the change is broken.
- Mascot slides instead of walks: verify runtime crop equality and that animation direction matches horizontal movement.
- Drag artwork appears detached from cursor: preserve the hanging atlas grip `(48, 4)` to AppKit panel point `(48, 108)` mapping.
