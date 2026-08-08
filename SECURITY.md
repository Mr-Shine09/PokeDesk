# Security policy

## Supported versions

Dock Pet is at 0.1 and is distributed as source only. Security fixes land on
`main`. There are no maintained release branches, and there is no auto-update
mechanism — you get fixes by pulling and rebuilding.

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Use GitHub's private vulnerability reporting:
<https://github.com/Mr-Shine09/desktop-mascot/security/advisories/new>

Please include:

- What the vulnerability lets an attacker do.
- The steps to reproduce it, and your macOS version.
- Whether it requires local code execution as the same user, or less than that.

You should get an acknowledgement within a week. This is a personal project
maintained by one person, so please allow reasonable time for a fix before
disclosing publicly.

## Scope

Dock Pet's attack surface is small by design, but these areas are worth
scrutiny and reports about them are welcome:

- **The local event socket.** A Unix-domain socket under the current user's
  directory. Anything that lets a *different* user, or a sandboxed process that
  should not have it, reach that socket is in scope.
- **The event decoder** (`Packages/DesktopMascotKit/Sources/MascotCore/`). It
  parses untrusted framed input. Crashes, unbounded allocation, or hangs from a
  malformed, oversized, or reordered frame are in scope.
- **The hook payload reader** (`MascotTransport/HookPayloadReader.swift`). It
  reads JSON on stdin inside the user's real agent session. Anything that makes
  it hang, block, or fail non-zero is in scope, because that would stall or
  break the user's actual work.
- **Privacy boundary violations.** Any path by which prompt text, transcripts,
  source code, tool arguments, tool output, repository paths, or screen content
  could reach Dock Pet's process, its preferences, its logs, or the socket. The
  session identifier must be hashed before it leaves the hook helper. A leak
  here is a security bug, not a feature request.
- **Code signing and bundle integrity.** Anything in `tools/install_app.sh` that
  would let a modified helper be loaded by a signed bundle.

## Out of scope

- **The app is not notarized and is ad-hoc signed** when no Developer ID
  certificate is available. This is a known, documented limitation, not a
  vulnerability — see the README. Notarization requires a paid Apple Developer
  Program certificate.
- **An attacker who already has local code execution as your user** can write
  to your agent's hook configuration, your socket, and your Applications folder
  regardless of Dock Pet. Dock Pet does not defend against that, and no macOS
  accessory app can.
- **Idle CPU usage.** Known and tracked, but a performance issue rather than a
  denial of service.
- **Hooks not firing** because the configured path is stale. That is a
  missing-install problem; the README covers it.

## What Dock Pet does not do

Useful context when assessing a report. Dock Pet makes no network requests, uses
no private APIs, requests no accessibility or screen recording permissions,
installs no login item or launch agent, runs no XPC service, and never writes to
any file outside its own preferences domain. The bundled `dockpet-event` helper
is a plain executable that runs only when your agent invokes it, sends one
event, and exits.

If you observe Dock Pet doing any of those things, that itself is the report —
please send it.
