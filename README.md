# Dock Pet

A tiny pixel-art mascot that lives at the bottom of your Mac's screen and shows,
at a glance, what your coding agent is doing.

When Claude Code or Codex starts working, the pet sits down at a little computer
and types. When a turn finishes, it does a fist pump. When something fails, it
gets dizzy. The rest of the time it strolls back and forth along the bottom of
your screen, and on a schedule you set it curls up and sleeps.

Dock Pet is a native macOS menu-bar accessory app. It never activates over your
work, never appears until you summon it, and never reads a single character of
your prompts, code, or terminal output.

> **Status: 0.1, source-only.** Dock Pet is feature-complete and used daily by
> its author, but there is no signed, notarized download. You build it yourself
> from this repository — see [Install](#install). Known rough edges are listed
> under [Current limitations](#current-limitations).

---

## Table of contents

- [What it looks like](#what-it-looks-like)
- [Requirements](#requirements)
- [Install](#install)
- [Connect it to your agent](#connect-it-to-your-agent)
- [Using it](#using-it)
- [Privacy](#privacy)
- [Current limitations](#current-limitations)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [Repository layout](#repository-layout)
- [Contributing](#contributing)
- [License](#license)

---

## What it looks like

![Two pixel-art mascots along the bottom of a macOS desktop: the orange Claude
mascot sits at a small computer typing while the navy Codex mascot strolls past
the Dock](docs/images/readme-hero@2x.png)

The orange mascot is reacting to a live Claude Code session — sitting at its
computer, typing. The navy one has no Codex session to report on, so it carries
on strolling. Each pet only ever reacts to its own provider.

There is one mascot per provider, and each has its own wardrobe:

| Provider | Wardrobe |
| --- | --- |
| Claude Code | Orange and white top |
| Codex | Navy and white top |

Each mascot reacts only to its own provider's sessions, so you can run both at
once and tell them apart. Neither appears on its own — you summon each one from
the menu bar.

The states the pet can show:

| State | What you see |
| --- | --- |
| Working | Sits at a small computer and types |
| Ideating | Thinker pose with a looping thought cloud. Set by hand from the menu, or automatically while the Claude or ChatGPT desktop app is frontmost |
| Waiting | Stops, turns toward you, and raises a hand |
| Success | Sparkling eyes and one quick fist pump |
| Failure | A short confused, dizzy stumble |
| Chilling / offline | Strolls along the bottom of the screen |
| Sleeping | Sleeps under a blanket during the scheduled sleep window, 23:00–06:00 by default and adjustable from the menu |
| Paused | Stands still |

When several sessions are active at once, they reduce deterministically in this
priority order:

```text
paused > failure > waiting > manual ideating > working > success > chat ideating > sleep > idle > offline
```

## Requirements

- **macOS 14.4 or later.** This is a hard floor; the menu bar uses
  `NSHostingMenu`, which does not exist before 14.4.
- **Xcode 16 or later**, with a Swift 6 toolchain. Install it from the App Store
  and run it once so the command line tools are registered.
- Apple Silicon or Intel. Both work.

Only needed if you plan to change the artwork or regenerate assets:

- **Python 3** with [Pillow](https://pillow.readthedocs.io/) — `pip3 install Pillow`
- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** — `brew install xcodegen`.
  Required only if you edit `project.yml`; the generated Xcode project is
  committed, so a plain build does not need it.

Dock Pet has no third-party runtime dependencies and makes no network requests.

## Install

```bash
git clone https://github.com/Mr-Shine09/desktop-mascot.git
cd desktop-mascot
./tools/install_app.sh
```

The script builds a Release configuration, signs it, and installs it to
`~/Applications/Dock Pet.app`. That path is durable across reboots, which
matters because the agent hooks you configure below point at an absolute path.

**On signing:** the script uses a real Developer certificate if it finds one in
your keychain and falls back to ad-hoc signing otherwise. Ad-hoc is fine — the
app is trusted because *you* built it on *this* machine. It also means the app
cannot be copied to someone else's Mac; they need to build their own. There is
no notarized build because notarization requires a paid Apple Developer Program
certificate.

If `codesign` fails with `errSecInternalComponent`, run the script from an
interactive Terminal window rather than an IDE or an agent session — it needs to
be able to show you a keychain prompt.

Launch it:

```bash
open -g ~/Applications/Dock\ Pet.app
```

`-g` starts it in the background so it does not steal focus. A paw print appears
in your menu bar. **Nothing appears on screen yet** — that is deliberate.
Summoning is always manual.

Dock Pet does not install a login item and does not launch at login. If you want
it running after a restart, add `~/Applications/Dock Pet.app` to
**System Settings → General → Login Items** yourself.

## Connect it to your agent

Dock Pet listens for lifecycle events from your coding agent over a private,
per-user Unix socket. You wire that up with your agent's hook configuration.

**Dock Pet never edits your agent's config files.** It prints a snippet and you
paste it. A tool that silently rewrites the settings of the thing you actually
work in is a bad neighbor.

1. Click the paw print in the menu bar.
2. Open **Agent Hook Setup**.
3. Click **Copy Claude Code Setup** or **Copy Codex Setup**.
4. Paste into the right file:
   - Claude Code → `~/.claude/settings.json`
   - Codex → `~/.codex/hooks.json`
5. **Merge, don't replace.** If the file already has a `hooks` object, fold the
   new events into it. The snippet is not a whole settings file.
6. Restart your agent session. Codex will also ask you to trust each new hook.

You can get the same snippet from the command line:

```bash
'/Users/YOUR_NAME/Applications/Dock Pet.app/Contents/MacOS/dockpet-event' --print-hooks --provider claude-code
```

To check that events are arriving, open the menu again and look at the
`Event socket:` and `Reduced state:` lines. Or send one by hand:

```bash
'/Users/YOUR_NAME/Applications/Dock Pet.app/Contents/MacOS/dockpet-event' --provider claude-code --event active --session demo --verbose
```

The mascot should sit down at its computer. Note that a session expires after
120 seconds of silence, so a `completed` sent long after its `active` is ignored
as belonging to an unknown session.

The hook helper is built to be harmless: it exits `0` for every outcome except a
malformed command line, including when Dock Pet is not running at all. A hook
must never fail or stall your real agent session.

## Using it

Click the menu bar paw print:

| Item | What it does |
| --- | --- |
| **Summon / Dismiss ⟨mascot⟩** | One entry per provider. Each is independent |
| **Pause** | Freezes animation for both mascots |
| **Manual Ideating** | Forces the thinking pose — for ordinary chats that emit no hooks |
| **Think While Claude Is Answering** | Makes the Claude mascot think while the Claude desktop app is producing a response, and fist-pump when it lands. Needs Accessibility permission; see [Privacy](#privacy) for exactly what it reads |
| **Chat Detection (Experimental)** | Grants the permission, reports what the detector currently sees, and writes a diagnostic report. Temporary, while the feature is being proven |
| **Sounds** | Mutes all four cues (success, failure, summon, dismiss) |
| **⟨mascot⟩ Stays in One Place** | One entry per mascot, next to its Summon. Checked, that pet stops strolling and stays exactly where it is, still animating in place — drag it somewhere first and it stays there, across relaunches. Unchecked (the default), it roams. The two mascots are independent |
| **Reposition on Current Display** | Returns the pet to the default bottom lane |
| **Sleep Schedule** | Sets the hours the pet sleeps, or switches scheduled sleep off entirely |
| **Preview State** | Forces any animation without needing a real agent. Good for a first look |
| **Agent Hook Setup** | Copies the config snippet described above |
| **Quit Dock Pet** | Plays the farewell, then quits |

You can also interact with the pet directly:

- **Click or right-click** it for Pause, Stay in One Place, Dismiss, and Quit.
  Stay in One Place here affects only the pet you clicked.
- **Drag** it anywhere, at any time. It grabs on with one hand while you drag.
  Dropping is placement only — it keeps roaming, at whatever height you let go
  at. Use **Reposition** to send it back to the bottom.
- **To pin a pet in one spot**, drag it where you want it and tick **Stay in
  One Place** — from its own click menu, or from its entry in the menu bar. It
  stays put and keeps its idle animation, and still reacts to your agent
  normally, since working, waiting, and the rest are stationary poses anyway.
  Each mascot is set independently, and the choice survives relaunch.

Summoning and dismissing are animated: the pet steps out of a portal at the
Dock, and on dismiss it forms a two-handed seal and vanishes in a puff of smoke.
If you have **Reduce Motion** enabled in System Settings, both become simple
fades instead.

## Privacy

Dock Pet is built so that it *cannot* learn anything interesting about you, not
merely so that it promises not to.

- **No network access.** No accounts, no servers, no telemetry, no update check.
- **No content, ever.** Hooks send only a lifecycle event name. Prompts,
  transcripts, source code, file paths, tool arguments, tool output, and
  repository names are never read and never stored.
- **Session IDs are hashed** inside the hook helper before they leave the
  process. Every payload key other than `hook_event_name` and `session_id` is
  dropped without being inspected.
- **No private APIs**, and no injection into the macOS Dock.
- **Chat detection is the one thing that looks beyond hooks, it is off unless
  you turn it on, and it needs a permission.** This is a deliberate exception to
  everything above, not an oversight — the honest description is worth reading
  before you enable it:
  - It asks macOS for the **bundle identifier of the frontmost application**,
    compared against a two-entry allowlist (the Claude and ChatGPT desktop
    apps). No other app is ever named.
  - With **Accessibility** permission granted, it reads **one attribute on one
    element** of the Claude window — the accessibility description that says a
    message is currently streaming. That is how the pet knows a response
    started and finished.
  - It never reads message text, your prompts, window titles, documents,
    browser tabs, or anything you type. Nothing is stored, logged, or sent.
  - **Accessibility permission is powerful**, and macOS is right to ask before
    granting it. Dock Pet uses it for the single check above; if you would
    rather not grant it, leave the feature off and use **Manual Ideating**,
    which is what the app did before this existed.
- **The socket is yours alone** — a Unix-domain socket under your own user's
  directory, not a TCP port.
- **Nothing is written outside the app's own preferences.** Dock Pet does not
  modify your agent's configuration files.

## Current limitations

Stated plainly, because you are about to build this yourself:

- **Idle CPU is around 2.2%** with one mascot on screen — about the same energy
  cost as `launchd` or `bluetoothd` on the same machine. The animation loop runs
  at 12 Hz and stops entirely when the pet is hidden behind a window. It is a
  continuously animated sprite, so it is not free; if that bothers you, dismiss
  the pet and the cost drops to roughly 0.4%. Two mascots on screen at once have
  never been measured.
- **No notarized download.** Build from source; see above.
- **No launch at login.** Add it manually if you want it.
- **The `failed` state has never been observed from a real provider run** — it
  works, and it is covered by tests and by **Preview State**, but no one has
  watched a genuine agent session produce it. `waiting` was first seen from a
  real Claude Code session on 2026-08-09, and both providers have now been
  watched driving their own mascot on screen — Codex on 2026-08-10.
- **The display matrix was walked on 2026-08-10** — Dock auto-hide, left/right
  Dock, two displays, full-screen Spaces, sleep/wake, lock/unlock, and
  non-Retina rendering all work, as does unplugging a display with a mascot on
  it — which used to lose a dragged height and no longer does.
- **Reduce Motion** is honored for the summon and dismiss transitions; broader
  coverage is still open.
- **Chat detection is new, and off by default.** It was watched working on
  2026-08-11 — a streaming response put the mascot in the Thinker pose, and the
  finished response drew the success reaction — but that is one run, and these
  limits still apply:
  - **The Claude desktop app only — and ChatGPT does not need it.** The ChatGPT
    desktop app is the Codex app, so its turns already arrive as ordinary hook
    events and drive the Codex mascot through the full working/success
    lifecycle, with no accessibility permission involved. Browser tabs never
    will be covered — detecting `claude.ai` in a browser means reading the
    active tab's URL, which is your browsing history.
  - **`waiting` is not implemented.** A chat that needs your input looks the
    same as one that finished.
  - **It hangs on one English UI string.** Detection matches Claude's
    accessibility label for a streaming message. If an app update renames it,
    the pet simply stops reacting, with nothing to say why — check the
    **Chat Detection (Experimental)** menu, which reports what the detector
    currently sees. Automatic detection is deferred until there is a signal
  that does not require snooping.
- **The pet does not avoid your cursor or UI controls** while roaming.

## Troubleshooting

**No paw print in the menu bar.**
Check that the process is running with `pgrep -fl "Dock Pet"`. If it is running
and there is still no icon, you may have previously dragged the icon out of the
menu bar — macOS remembers that against the app's bundle identifier, in a store
the app cannot reach, and it cannot be undone from inside the app. Reset the
menu bar layout in System Settings, or file an issue.

**The pet never appears.**
That is correct until you summon it. Menu bar → **Summon**.

**Nothing reacts when my agent runs.**
In order: confirm the hook snippet landed in the right file and merged with any
existing `hooks` object; confirm the path in the snippet matches where the app
actually is (a rebuild into a different location invalidates it); restart the
agent session; for Codex, confirm the hooks show as trusted and Active. Then
check the `Event socket:` line in the menu — it should say the listener is
bound — and send a manual event with the `dockpet-event` command above to
isolate whether the problem is the app or the hook.

**My code change seems to do nothing.**
`open -g` sends a reopen event to an already-running process instead of
relaunching it, so you are testing the old binary. Quit first:

```bash
osascript -e 'quit app id "com.mrshine09.dockpet"'
```

**The build fails, or tests fail right after I add a property to a public struct.**
Run `swift package clean` in `Packages/DesktopMascotKit` — the incremental build
can keep a stale module with the old memory layout and produce convincing
nonsense.

**Tests pass in the morning and fail at night.**
One test fixture family reduces against the 23:00–06:00 sleep window. A fixture
that uses the real clock instead of an injected instant will do exactly this.

## Uninstall

```bash
osascript -e 'quit app id "com.mrshine09.dockpet"'
rm -rf ~/Applications/Dock\ Pet.app
defaults delete com.mrshine09.dockpet
```

Then remove the Dock Pet entries from `~/.claude/settings.json` and
`~/.codex/hooks.json` by hand. Dock Pet did not write them, so it does not
remove them.

## Repository layout

```text
DesktopMascot/App/           SwiftUI app shell, menu bar, ambient controller
Packages/DesktopMascotKit/   Core, animation, window, and transport modules,
                             plus the dockpet-event helper executable
art/production/              The frozen base mascot — do not replace
art/animation/               Atlas contract, source frames, atlases, QA output
art/audio/                   Synthesized WAV cues
tools/                       Deterministic art build and validation scripts
project.yml                  XcodeGen source of truth for the Xcode project
docs/                        Build, architecture, asset, and QA documentation
DesktopMascot.md             The authoritative project ledger and history
```

Deeper reading:

- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — build, test, run, and workflow
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — components and state flow
- [`docs/ASSET_PIPELINE.md`](docs/ASSET_PIPELINE.md) — how the sprite atlas is made
- [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md) — the acceptance matrix
- [`DesktopMascot.md`](DesktopMascot.md) — every decision, and why

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md)
first — this project has a few hard invariants (the character identity is
frozen, the privacy boundary is not negotiable, and the Xcode project is
generated rather than hand-edited) that will save you a wasted pull request.

Security issues: see [`SECURITY.md`](SECURITY.md).

## License

**Code** is [MIT](LICENSE).

**Artwork and audio are not.** The mascot depicts the project owner and is
licensed separately and restrictively — you may build and run Dock Pet, but you
may not reuse the character elsewhere. See [`art/LICENSE.md`](art/LICENSE.md).
