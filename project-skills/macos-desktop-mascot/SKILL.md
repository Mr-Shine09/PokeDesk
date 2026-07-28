---
name: macos-desktop-mascot
description: Design, implement, review, or debug a native macOS desktop or Dock-edge mascot using Swift, SwiftUI, and AppKit. Use for transparent floating windows, menu-bar controls, multi-display positioning, Dock avoidance, click-through behavior, animation timing, launch-at-login, accessibility, reduced motion, energy usage, signing, notarization, and packaging.
---

# macOS Desktop Mascot

Build the mascot as a polite macOS citizen: visible when useful, inexpensive when idle, and never able to trap input.

## Architecture Defaults

- Use a SwiftUI app shell with AppKit window control where SwiftUI lacks the required behavior.
- Render the pet in a borderless transparent `NSPanel` or carefully configured `NSWindow`.
- Keep state acquisition, state reduction, animation selection, and window positioning in separate components.
- Use a menu-bar item for pause, visibility, behavior mode, launch-at-login, diagnostics, and quit.
- Persist only user preferences and coarse diagnostic state by default.

## Window Invariants

- Never activate the app merely because the mascot animates.
- Keep the mascot above ordinary windows only at the least intrusive window level that satisfies the design.
- Support click-through by default; enable hit testing only for explicit interactions.
- Provide a reliable menu-bar escape hatch even if the mascot window is off-screen.
- Recompute placement when screens, scale factors, Dock orientation, or visible frames change.
- Avoid private APIs and do not inject into the Dock, Terminal, Codex, Claude, or other processes.

## Interaction and Accessibility

- Respect Reduce Motion by substituting fades or low-motion poses.
- Provide pause and hide controls.
- Avoid covering the pointer, text insertion point, Dock targets, notifications, and critical controls.
- Keep optional cursor-following disabled by default and bound its speed and distance.
- Announce status through the menu-bar UI; do not make the animated window a noisy accessibility element.

## Performance Gate

- Stop frame timers when fully hidden or static.
- Decode sprite assets once and reuse them.
- Prefer event-driven state changes over high-frequency process polling.
- Coalesce repeated status updates and apply a short debounce to prevent visual thrashing.
- Measure idle CPU and memory on a release build before calling the app ready.

## Release Gate

Verify on supported macOS versions, Retina and non-Retina scaling where available, left/right/bottom Dock positions, auto-hide, multiple displays, full-screen Spaces, sleep/wake, agent crashes, and app relaunch. Complete signing, hardened runtime, notarization, privacy copy, and uninstall instructions before public distribution.
