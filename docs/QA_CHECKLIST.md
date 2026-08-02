# QA checklist

Use this as an evidence checklist, not as a claim that every item currently passes.

**Status 2026-08-02.** The owner completed the two-mascot, wardrobe, display-matrix,
drag, and dismiss-edge-case passes from the installed `~/Applications` build and
reported them smooth. That was one overall verdict rather than per-item
commentary. The automated baseline was re-run the same day. What remains
unticked below is genuinely untested — chiefly a live Codex session driving its
mascot on screen, the sound-toggle persistence items, icon sizes, `@1x`
behavior, and the future release gates.

## Automated baseline

- [x] `git diff --check` passes.
- [x] Atlas contract validates.
- [x] Complete atlas validates. The classic atlas passes outright. The orange atlas is reported as three colors outside the frozen palette, which is **expected for that file alone**: they are exactly the three shades declared in `tools/author_codex_fashion_atlas.py`, verified by set difference against the classic atlas, and it removes no palette color.
- [ ] Every changed frame row validates.
- [x] Full QA sheets and motion previews are regenerated after atlas changes.
- [x] Swift package tests pass (current baseline: 198; original handoff baseline: 10).
  - The former `aDropPastAnEdgeIsClampedBackIntoView` exception was **fixed on 2026-08-02**; the suite passes in full with a second display attached. Do not reinstate the exception.
- [x] Release Xcode build succeeds (`tools/install_app.sh`, 2026-08-02).
- [x] Built atlas hash matches workspace atlas — both atlases byte-identical in the installed bundle.
- [x] Built JSON contract byte-matches workspace contract.

## Provider fashion and two-mascot acceptance

Owner ran the full hands-on pass on 2026-08-02 from the installed
`~/Applications` build and reported every item below smooth. That report was a
single overall verdict, not per-item commentary, so treat these as owner-accepted
rather than individually narrated.

There is **one mascot per provider**: Claude wears orange, Codex wears classic
navy. Wardrobe is fixed per mascot via `MascotFashion.worn(by:)`, not selected
from reduced state. Sunglasses were removed on 2026-08-02; the wardrobes differ
only in the hoodie and the sleeping blanket.

- [x] Orange atlas is byte-reproducible from `tools/author_codex_fashion_atlas.py`.
- [x] Every orange frame preserves the classic frame's dimensions and alpha silhouette.
- [x] The `poof` effect row is pixel-identical across both atlases.
- [x] Claude's mascot wears orange and Codex's wears classic navy.
- [x] Diagnostics retain both provider names when both are present.
- [x] Orange/white top is readable at native size on light and dark desktop backgrounds.
- [x] Gray trousers and navy shoes visibly match the classic mascot.
- [x] No stray navy remains on a raised sleeve in `success`, `waiting`, or while dragging.
- [x] The sleeping blanket is orange for Claude and navy for Codex.
- [x] Summoning both mascots places them side by side rather than stacked.
- [x] Each mascot's menu names the mascot that was clicked.
- [x] Dismissing one mascot leaves the other animating and in place.
- [x] Each mascot's dragged position is remembered independently across Dismiss/Summon.
- [x] A real Claude Code task animates the orange mascot while the navy one strolls.
- [x] One completed task plays a single success cue, not one per mascot.
- [x] Quitting with both on screen poofs both, then terminates.
- [ ] A **real Codex session** drives the navy mascot on screen. Its hooks are installed, trusted, and were exercised by a real turn on 2026-08-02, but nobody has watched the mascot respond. Still the last unproven provider claim.

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

- [x] Drag can begin from head, torso, and lower-body pixels.
- [x] On threshold crossing, animation switches immediately to `hanging`.
- [x] Raised hand remains visually attached to the cursor throughout movement.
- [x] Body swings left/center/right and both feet remain off the ground.
- [x] No cliff, ledge, rope, cursor art, shadow, or ground is visible.
- [x] Snap to the overhead grip feels acceptable to the owner.
- [x] Dropping leaves roaming on and the mascot carries on walking from where it landed.
- [x] The mascot roams horizontally at the height it was dropped at, not at the bottom lane.
- [x] A drop near any screen edge is clamped back into view rather than stranded, and returns to the display it came from rather than jumping to another.
- [x] The dropped position survives Dismiss/Summon, application reopen, and toggling roaming off and on.
- [x] Reposition on Current Display returns the mascot to the default bottom lane.

## Dismiss transition acceptance

Owner ran summon, dismiss, and quit on 2026-08-01 and approved the result. Only
the happy path was walked; everything still unticked below is an edge case
nobody has exercised, not a known failure.

- [x] Dismiss plays the ninja seal: hands lift, palms join, two finger pairs rise.
- [x] The seal is finished and held before the smoke starts, not cut off by it.
- [x] The smoke is visibly pixel art in the mascot's own style, not a soft blur.
- [x] The smoke covers the whole mascot, feet included, at its densest.
- [x] The cloud never opens a hole over the middle where the mascot was standing.
- [x] The mascot is never seen fading in the open — it is gone when the smoke clears.
- [x] The smoke clears completely; no haze is left behind on the desktop.
- [x] Total transition feels quick rather than something to wait through.
- [x] **Quit** plays the same farewell, then the app actually terminates.
- [x] Reduce Motion replaces the whole thing with a short stationary fade, no seal and no smoke.
- [x] Re-summoning part-way through the poof brings the mascot back rather than hiding it a moment later.
- [x] Dismissing a paused mascot still plays the transition.
- [x] A second Quit during the farewell terminates immediately.
- [ ] Quitting with no mascot summoned terminates at once, with no transition.
- [ ] Summoning during a quit does not keep the app alive.
- [ ] The transition reads on both light and dark desktop backgrounds.

## Sound acceptance

Owner heard all four cues on 2026-08-01 and approved them. The summon and
dismiss cues were heard first; the reaction cues (success and failure) were
confirmed working from the installed build later the same day.

- [x] Summon plays its rising cue as the portal opens.
- [x] Dismiss plays its poof cue on the burst, not at the start of the seal.
- [ ] The summon cue is distinguishable from the success cue, which is also a rising run.
- [ ] Neither transition cue is startling at system volume.
- [ ] Under Reduce Motion both cues still play, even though the visuals are reduced.
- [ ] The single Sounds toggle silences all four cues, and the choice survives relaunch.
- [ ] A previously silenced install stays silenced after this update.

## App icon acceptance

Owner confirmed the icon from the installed `~/Applications/Dock Pet.app` on
2026-08-01. The previous attempt looked at the July 30 install, which had no
icon; the current build shows the mascot headshot.

- [x] The icon shows the mascot headshot in Finder, Get Info, and the Applications folder.
- [ ] Pixel edges are crisp at 128pt and above.
- [ ] The 16pt and 32pt sizes are legible rather than mush.
- [ ] The icon reads on both light and dark Finder backgrounds.

## Reaction cue acceptance

- [x] Success plays the sparkle row and its cue together, neither ahead of the other.
- [x] Failure plays the cracked-bulb row and its cue together.
- [x] Both cues are audible over a laptop speaker without being startling.
- [ ] Back-to-back turns restart the cue rather than overlapping into a drone.
- [ ] Reaction Sounds off silences both, and the choice survives relaunch.
- [ ] A dismissed mascot makes no sound.

## Window/display matrix

Owner completed this matrix on 2026-08-02 except where noted. The multi-display
clamp fix landed the same day; only the two-display arrangement on the owner's
machine (built-in `0,0 1280x832` plus external `1280,-248 1920x1080`) was
exercised.

- [x] Single Retina display, bottom Dock: initial prototype pass completed.
- [x] Bottom Dock with auto-hide on/off.
- [x] Left Dock.
- [x] Right Dock.
- [x] Multiple displays with different scales.
- [x] Move between displays, including unplugging a display with a mascot on it.
- [x] Full-screen Spaces and ordinary Spaces.
- [x] Display sleep/wake and laptop sleep/wake.
- [x] Screen lock/unlock.
- [ ] Non-Retina or deliberately authored `@1x` behavior.
- [x] No app focus theft during timer/state changes.

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
