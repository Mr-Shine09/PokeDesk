# QA checklist

Use this as an evidence checklist, not as a claim that every item currently passes.

## Automated baseline

- [ ] `git diff --check` passes.
- [ ] Atlas contract validates.
- [ ] Complete atlas validates.
- [ ] Every changed frame row validates.
- [ ] Full QA sheets and motion previews are regenerated after atlas changes.
- [ ] Swift package tests pass (current baseline: 183; original handoff baseline: 10).
- [ ] Unsigned Debug Xcode build succeeds.
- [ ] Built atlas hash matches workspace atlas.
- [ ] Built JSON contract byte-matches workspace contract.

## Core app smoke test

- [ ] Background launch shows mascot without activating Dock Pet.
- [ ] Mascot is sharp, transparent, and `96x112` points.
- [ ] Feet/baseline visually align with the bottom Dock boundary without blocking Dock icons.
- [ ] Rightward movement shows `walk-right`; leftward movement shows `walk-left`.
- [ ] Contact/passing gait frames are visibly animated, not sliding.
- [ ] Offline rest appears and returns to walking.
- [ ] Menu-bar Show/Hide, Pause/Resume, Ideating, Roaming, Reposition, and Quit work.
- [ ] Clicking and right-clicking mascot open the local options menu without making the panel key/main.
- [ ] Hide followed by reopening the app restores the panel.
- [ ] Quit ends the process; a later launch starts a fresh visible instance.

## Hanging drag acceptance

- [ ] Drag can begin from head, torso, and lower-body pixels.
- [ ] On threshold crossing, animation switches immediately to `hanging`.
- [ ] Raised hand remains visually attached to the cursor throughout movement.
- [ ] Body swings left/center/right and both feet remain off the ground.
- [ ] No cliff, ledge, rope, cursor art, shadow, or ground is visible.
- [ ] Snap to the overhead grip feels acceptable to the owner.
- [ ] Dropping leaves roaming on and the mascot carries on walking from where it landed.
- [ ] The mascot roams horizontally at the height it was dropped at, not at the bottom lane.
- [ ] A drop near any screen edge is clamped back into view rather than stranded.
- [ ] The dropped position survives Dismiss/Summon, application reopen, and toggling roaming off and on.
- [ ] Reposition on Current Display returns the mascot to the default bottom lane.

## Dismiss transition acceptance

Nothing in this section has been seen on screen by anyone. It is built and unit-tested only.

- [ ] Dismiss plays the ninja seal: hands lift, palms join, two finger pairs rise.
- [ ] The seal is finished and held before the smoke starts, not cut off by it.
- [ ] The smoke covers the whole mascot, feet included, at its densest.
- [ ] The mascot is never seen fading in the open — it is gone when the smoke clears.
- [ ] The smoke clears completely; no haze is left behind on the desktop.
- [ ] Total transition feels quick rather than something to wait through.
- [ ] Reduce Motion replaces the whole thing with a short stationary fade, no seal and no smoke.
- [ ] Re-summoning part-way through the poof brings the mascot back rather than hiding it a moment later.
- [ ] Dismissing a paused mascot still plays the transition.
- [ ] Quitting during the transition does not leave an orphaned panel.
- [ ] The transition reads on both light and dark desktop backgrounds.

## App icon acceptance

- [ ] The icon shows the mascot headshot in Finder, Get Info, and the Applications folder.
- [ ] Pixel edges are crisp at 128pt and above.
- [ ] The 16pt and 32pt sizes are legible rather than mush.
- [ ] The icon reads on both light and dark Finder backgrounds.

## Reaction cue acceptance

- [ ] Success plays the sparkle row and its cue together, neither ahead of the other.
- [ ] Failure plays the cracked-bulb row and its cue together.
- [ ] Both cues are audible over a laptop speaker without being startling.
- [ ] Back-to-back turns restart the cue rather than overlapping into a drone.
- [ ] Reaction Sounds off silences both, and the choice survives relaunch.
- [ ] A dismissed mascot makes no sound.

## Window/display matrix

- [x] Single Retina display, bottom Dock: initial prototype pass completed.
- [ ] Bottom Dock with auto-hide on/off.
- [ ] Left Dock.
- [ ] Right Dock.
- [ ] Multiple displays with different scales.
- [ ] Move between displays and change primary display.
- [ ] Full-screen Spaces and ordinary Spaces.
- [ ] Display sleep/wake and laptop sleep/wake.
- [ ] Screen lock/unlock.
- [ ] Non-Retina or deliberately authored `@1x` behavior.
- [ ] No app focus theft during timer/state changes.

## Event system acceptance

- [x] Valid events decode into allowlisted fields only.
- [x] Unknown version/provider/event fails closed.
- [x] Oversized/malformed JSON cannot mutate state.
- [x] Forbidden payload fields are discarded and never logged.
- [x] Decoding the same bytes twice yields the same envelope.
- [x] Timestamp skew is evaluated against an injected clock, not the wall clock.
- [ ] Duplicates are idempotent *at the registry* (decoder-level idempotence is proven; the registry does not exist).
- [ ] Older reordered events cannot replace newer session state.
- [ ] Heartbeat expiry uses an injected monotonic clock.
- [ ] Concurrent Claude Code and Codex sessions reduce deterministically.
- [ ] Waiting clears correctly.
- [ ] Success/failure reaction windows expire correctly.
- [ ] Scheduled sleep obeys local time and is interrupted by work.
- [ ] Socket permissions restrict access to the current user.
- [ ] Helper/installer previews exact configuration changes and removes only owned entries.

## Release gates (future)

- [ ] Reduce Motion behavior passes.
- [ ] Idle CPU median below 1% over ten minutes.
- [ ] Memory below 80 MB after ten minutes with no transition growth trend.
- [ ] Local event-to-visible-state latency below 500 ms.
- [ ] Launch at login works and is reversible.
- [ ] Hardened runtime and signing configured.
- [ ] Notarized build installs on a clean account.
- [ ] Install, upgrade, and uninstall instructions verified.
- [ ] Privacy-safe diagnostics reviewed.

