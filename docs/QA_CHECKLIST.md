# QA checklist

Use this as an evidence checklist, not as a claim that every item currently passes.

**Status 2026-08-02.** The owner completed the two-mascot, wardrobe, display-matrix,
drag, and dismiss-edge-case passes from the installed `~/Applications` build and
reported them smooth. That was one overall verdict rather than per-item
commentary. The automated baseline was re-run the same day.

**Updated 2026-08-10.** A live Codex session drove the navy mascot on screen and
the four dismiss edge cases were each walked, so neither is a gap any more.
What remains unticked below is genuinely untested: the core app smoke test,
the sound-toggle persistence items, icon sizes, and the future release gates.
`@1x` was walked on 2026-08-10 and passes. `failed` is the only mascot state
never produced by a real provider.

**Also updated 2026-08-10.** The window/display matrix was reopened — all but
two of its rows had been ticked by that same blanket verdict — and then walked
row by row the same day. **All eleven rows now pass on per-row evidence**, the
last of them on 2026-08-11. **The unplug row found the
only behavioral defect of the day** — a dragged height was lost when its display
was disconnected — and it was diagnosed, fixed, and re-walked on screen. Every
row in the matrix now carries per-row owner evidence.

## Automated baseline

- [x] `git diff --check` passes.
- [x] Atlas contract validates.
- [x] Complete atlas validates. The classic atlas passes outright. The orange atlas is reported as three colors outside the frozen palette, which is **expected for that file alone**: they are exactly the three shades declared in `tools/author_codex_fashion_atlas.py`, verified by set difference against the classic atlas, and it removes no palette color.
- [ ] Every changed frame row validates.
- [x] Full QA sheets and motion previews are regenerated after atlas changes.
- [x] Swift package tests pass (current baseline: **208** as of 2026-08-09; original handoff baseline: 10).
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

Owner ran summon, dismiss, and quit on 2026-08-01 and approved the result: the
happy path. **The four edge cases below — Reduce Motion, re-summon mid-poof,
dismiss-while-paused, and the second Quit — were each walked individually on
2026-08-10 and each passed.** Until that day they carried ticks from the
2026-08-02 blanket verdict while the ledger recorded them as unexercised, which
is the contradiction the run resolved. The outcome vindicated those ticks; the
evidence behind them did not — a tick that outruns its observation is a false
pass waiting to happen, and this one sat unnoticed for eight days. Anything
still unticked is an edge case nobody has exercised, not a known failure.

- [x] Dismiss plays the ninja seal: hands lift, palms join, two finger pairs rise.
- [x] The seal is finished and held before the smoke starts, not cut off by it.
- [x] The smoke is visibly pixel art in the mascot's own style, not a soft blur.
- [x] The smoke covers the whole mascot, feet included, at its densest.
- [x] The cloud never opens a hole over the middle where the mascot was standing.
- [x] The mascot is never seen fading in the open — it is gone when the smoke clears.
- [x] The smoke clears completely; no haze is left behind on the desktop.
- [x] Total transition feels quick rather than something to wait through.
- [x] **Quit** plays the same farewell, then the app actually terminates.
- [x] Reduce Motion replaces the whole thing with a short stationary fade, no seal and no smoke. *(walked 2026-08-10; summon also fades in place, with no Dock portal.)*
- [x] Re-summoning part-way through the poof brings the mascot back rather than hiding it a moment later. *(walked 2026-08-10; the pet stayed, so the pending hide really is cancelled.)*
- [x] Dismissing a paused mascot still plays the transition. *(walked 2026-08-10; the frozen pet played the seal and left, so dismiss outranks pause as intended.)*
- [x] A second Quit during the farewell terminates immediately. *(walked 2026-08-10; the animation was cut off, which is the correct outcome — quitting must never wait on it.)*
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

**Reopened 2026-08-10.** Every row below except the first and last was ticked
from the 2026-08-02 blanket verdict — the same single "smooth" that ticked the
four dismiss edge cases nobody had walked. That precedent is recorded in the
ledger: *a tick is a claim about an observation, not about the code.* The ticks
are therefore withdrawn rather than trusted. Nothing here is known to be broken;
it is unwitnessed, which is a different thing. The ledger and `docs/HANDOFF.md`
have both said "the rest of the display matrix" remained open the whole time, so
this section was the optimistic half of a disagreement, in the same direction as
the dismiss one.

The two-display arrangement on the owner's machine is built-in `0,0 1280x832`
plus external `1280,-248 1920x1080`. Only the drop-clamp fix was genuinely
exercised against it, on 2026-08-02.

**Before walking any row:** confirm `~/Applications/Dock Pet.app`'s binary is
newer than the last commit that changed window behavior (handoff item 32), and
do not run `tools/install_app.sh` mid-walk — it quits the app. Summon both
mascots and drag one to a manual height, since half these rows behave
differently for a manually placed pet than for a default-lane one.

Each row names what to expect, because a row that only says "check it" cannot
distinguish a pass from nothing happening.

**Walked the same day, 2026-08-10, and this time the ticks are earned.** The
owner walked the reopened rows from the installed build with both mascots
summoned and one dragged to a manual height, and reported per row rather than as
one verdict — which is the whole difference from 2026-08-02. **Every row has now been
walked and every row passes**, including the `@1x` row that was assumed to need
hardware nobody had. The tenth — unplugging a display — found a real defect,
which was diagnosed, fixed, and re-walked on screen from a rebuilt install.

- [x] Single Retina display, bottom Dock. Exercised continuously since the
  prototype and daily by the author; this one is genuinely earned.
- [x] **Bottom Dock, auto-hide toggled in System Settings.** Owner-walked
  2026-08-10, both halves, and both as predicted. Two distinct
  observations, and they must not be confused. Toggling the *setting* changes
  `visibleFrame` and posts `didChangeScreenParameters`, so a default-lane pet
  re-settles: with the Dock shown it stands on the Dock's top edge, with
  auto-hide on it drops flush to the screen's bottom edge (the 10 pt visual
  inset is clamped away by `DockGeometry`). The Dock merely *sliding* away on
  hover does not change `visibleFrame`, so the pet must **not** move then. A
  manually placed pet keeps its height through both.
- [x] **Left Dock** — owner-walked 2026-08-10; the pets ignored the Dock and
  stayed bottom-anchored, so the deferral holds. expect the pet to stay bottom-anchored and unaffected.
  `DockGeometry` tracks no Dock edge at all, by decision; the file says so in
  its own doc comment. This row can never have been a meaningful pass, and it
  is a check that the deferral holds, not that placement follows the Dock.
- [x] **Right Dock** — same expectation, walked in the same pass and same result.
- [x] **Two displays with different backing scales.** Owner-walked 2026-08-10:
  moving keyboard focus between displays did not move either pet, so the
  focus-following defect has not returned. The pet stays on the
  display it was summoned or dropped on and roams within that display's bounds.
  It must not jump displays when keyboard focus moves to the other one — that
  was a real defect, fixed 2026-08-02 in `referenceScreen`, and moving focus
  back and forth is what would resurrect it.
- [x] **Unplugging the display the mascot is on. Defect found, diagnosed, fixed,
  and re-walked on screen — 2026-08-10 into 2026-08-11.**
  - **What was observed originally:** with the pet dragged near the top of the
    external display and the display then disconnected, it returned to the
    built-in display at the *bottom*. Clamping did not explain it — the owner's
    displays have aligned top edges, so the height fit untouched.
  - **The discriminating check settled the mechanism.** Changing resolution with
    a pet dragged high on the built-in **preserved** the height: same
    notification, no display removed, no relocation. Two hands-on results
    differing in one variable are what isolated it.
  - **Cause:** `screenParametersChanged` called `settleAfterDrop()`, which
    derives the height from `panel.frame.minY`. Right for a drop, where the
    frame is the user's intent; wrong after AppKit relocates the window off a
    removed display, where it is the system's. The remembered `manualLaneY` was
    never read.
  - **Fix:** the handler re-clamps the stored `manualLaneY`. X still comes from
    the frame, since roaming rewrites it and there is no remembered X to prefer.
    Regression test
    `aDisplayChangeKeepsTheDraggedHeightRatherThanASystemRelocation`, confirmed
    to fail against the old handler before being restored.
  - **Re-walked from a rebuilt install and passes:** the pet came back at the
    dragged height. The bundle was verified newer than the fix commit before the
    result was believed, so this is not a repeat of the stale-install trap. The
    unit test's stand-in for AppKit's relocation is now backed by an on-screen
    observation rather than standing alone.
- [x] **Full-screen Spaces and ordinary Spaces.** Owner-walked 2026-08-10: the
  pets stayed visible over full-screen apps rather than being hidden by them,
  and no focus was stolen. **Owner decision 2026-08-11: this is wanted — the
  pets float over full-screen apps and it stays that way.** Do not "fix" a pet
  appearing over a full-screen app; it is the approved behavior, not a window
  level bug.
- [x] **Display sleep/wake and laptop sleep/wake.** Owner-walked 2026-08-10;
  both pets present after wake. `NSWorkspace.didWake` is
  wired to the same handler as a screen-parameter change, so expect the pet
  present and correctly placed on wake. Watch specifically for a manual height
  surviving, since wake runs `settleAfterDrop()` rather than `reposition()`.
- [x] Screen lock/unlock. Owner-walked 2026-08-10; both pets present after
  unlock.
- [x] **Non-Retina `@1x` behavior. Owner-walked 2026-08-10 on a Dell P2217H**
  (1920x1080, non-Retina). The mascot renders as crisply as on the Retina
  built-in, stays sharp and the same apparent size when dragged between the two
  displays, and the walk cycle shows no jitter or vertical drift over ~30 s.
  Nearest-neighbor rendering holds at `@1x`. Note for anyone re-reading the
  history: this row was assumed to need hardware nobody had, which was simply
  never checked.
- [x] No app focus theft during timer/state changes. Verified separately: the
  background launch (`open -g`) left ChatGPT/Codex frontmost, and the panel is
  non-activating by construction with a test covering it.

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
