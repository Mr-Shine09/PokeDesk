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
- [x] A **real Codex session** drives the navy mascot on screen — **owner-observed 2026-08-10**. The navy mascot went to its computer and played the success reaction at the end of the turn, and the orange mascot was unaffected throughout, which is also the first on-screen evidence of per-provider attribution. Check Manual Ideating is off before rerunning this: it reaches both mascots and outranks `working`, so it masks the whole test.

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

Energy and memory were measured for the first time on 2026-08-02 from the
installed build, sampling cumulative CPU time every 15 s for 11 minutes.

- [ ] Reduce Motion behavior passes.
- [x] **Idle CPU median below 3% over ten minutes, with an energy cost in the
  band of an ordinary background daemon. PASSES: 2.17% median, 2.21% mean,
  1.47–3.27% range** with one mascot on screen (n=20 over 5 min), and an
  **Energy Impact of 3.70** against 757 for the whole machine — comparable to
  `launchd` (3.68) and `bluetoothd` (3.42), with `WindowServer` at 241 for
  scale. With no mascot summoned the same build sits at 0.40% median, so the
  cost is the animation loop, not the event path or the menu-bar item.

  **This gate was restated on 2026-08-09 by owner decision.** It was `<1%`, and
  it failed twice: 3.40% median on 2026-08-02, then 2.17% on 2026-08-05 after
  the loop was throttled to 12 Hz with an occlusion pause. Cost is very close to
  linear in tick rate — a 40% cut in ticks bought a 36% cut in CPU — so `<1%`
  needs roughly 5.5 Hz, which is **below the sprite's own ~8 fps** and would
  visibly degrade the animation rather than merely stop oversampling it. The
  original figure was set before anyone had measured what a continuously
  animated sprite costs. The remaining structural levers (not moving the
  `NSPanel` every tick while walking; coalescing both mascots onto one timer)
  were left unspent and are still available if the number ever needs to drop.

  Still true and still unmeasured: **two mascots have never been measured
  together**, so do not assume the cost is linear in mascot count. Sample for
  minutes — a single 5-second `powermetrics` window landed on the top of the
  range and produced a wrong conclusion on 2026-08-05.
- [x] Memory below 80 MB after ten minutes with no transition growth trend.
  `phys_footprint` 36 MB, peak 37 MB, 48 KB swapped. RSS reads 81 MB but is
  dominated by shared framework pages; `phys_footprint` is what Activity Monitor
  reports as Memory and is the honest figure. No growth trend: RSS fell from
  88.7 MB to 80.9 MB across the window.
- [x] **Local event-to-visible-state latency below 500 ms. PASSES with about 4x
  headroom: ~70 ms typical, ~122 ms worst case.** Measured 2026-08-09 against
  the installed build with the app running and listening.

  This is a **composition of measured parts, not one stopwatch** — the app has
  no instrumentation that timestamps a state reaching the screen, and none was
  added for a measurement this far inside the gate:

  | Stage | Median | Worst observed |
  | --- | --- | --- |
  | `dockpet-event` exec → exit (spawn, connect, write) | 19.1 ms | 20.9 ms |
  | Socket read → main-actor hop | *not measured* | see below |
  | Decode + registry ingest + reduce + recompute | 0.35 ms | 0.71 ms |
  | Wait for the next 12 Hz ambient tick to swap the row | ~41.7 ms | 83.3 ms |
  | One compositor frame | ~8 ms | ~16.7 ms |
  | **Total** | **~69 ms** | **~122 ms** |

  The helper figure is n=40 against the real installed binary, discarding a
  warm-up run. The compute figure is n=2000 in release, warmed. The tick figure
  is arithmetic, not a measurement: `adopt` sets `nextFrameTime = 0` rather than
  drawing, so an agent-driven row swaps on the next ambient tick. `paused` is
  the exception and calls `show()` directly, which is deliberate.

  The unmeasured hop is a single kernel wakeup on a socket plus one main-actor
  hop. It is not separately measured, and it does not need to be: it would have
  to be **3000x** larger than plausible to consume the 380 ms of headroom.

  **One case exceeds the gate on purpose.** `AnimationSelector` holds a state
  change for a 0.75 s minimum dwell if the previous change committed less than
  that ago, so a second change inside one dwell window reaches the screen in up
  to ~771 ms. That is the dwell doing its job — sessions flip between working
  and waiting several times a second while tools run, and showing every flip
  reads as a glitch, not as information. The first change after a quiet period
  is never delayed: `committedAt` is `nil` until the first real commit. Do not
  "fix" this to pass the gate.
- [ ] ~~Launch at login works and is reversible.~~ **Out of scope by owner
  decision, 2026-07-30.** There is no launch at login, deliberately; the mascot
  appears only when summoned. This line is kept rather than deleted so a future
  reader does not re-open it as an oversight.
- [ ] Hardened runtime and signing configured.
- [ ] Notarized build installs on a clean account.
- [ ] Install, upgrade, and uninstall instructions verified.
- [ ] Privacy-safe diagnostics reviewed.
