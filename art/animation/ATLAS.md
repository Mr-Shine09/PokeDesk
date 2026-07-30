# Desktop Mascot animation atlas contract

Status: revision 4 replaces the sit-shake ledges with owner-requested freestanding chairs on 2026-07-29. Revision 3 added the cursor-hanging drag row. This is the app-integration contract.

The machine-readable source of truth is [`atlas-contract.json`](atlas-contract.json). If this document and the JSON disagree, stop and reconcile them before producing or loading art.

## Geometry

- Production atlas: `mascot-atlas@2x.png`, RGBA PNG, `768x1568` pixels.
- Grid: 8 columns by 14 rows, row-major, with no gutters or margins.
- Cell: `96x112` backing pixels (`48x56` macOS points on a 2x display).
- Character footprint: the approved `80x80`-pixel body canvas remains `40x40` points. The larger cell reserves room for poses and the approved ideating effect; it does not enlarge the mascot.
- Cell coordinates use a top-left origin. Pixel ranges are inclusive unless stated otherwise.
- Shared anchor: `(48, 102)` in cell coordinates. This is the horizontal character center and ground baseline.
- Hanging grip anchor: `(48, 4)` in cell coordinates. Hanging frames keep an opaque raised-hand pixel at this fixed point; the app maps it to panel point `(48, 108)` in AppKit's bottom-left coordinate system so it remains under the cursor.
- Frozen-base placement: place the approved `80x80` base canvas at `(8, 25)`. Its current opaque foot pixels then end on baseline `y=102`.
- Normal grounded poses keep the lowest supporting foot, chair, computer, or blanket pixel on `y=102`. Airborne decorative pixels may not redefine the baseline.
- All opaque pixels stay within the four-pixel cell guard: `x=4...91`, `y=4...107`. Nothing may touch or cross a cell edge.
- Body art normally remains inside `x=8...87`, `y=25...102`. State-relevant effects and wider poses may use the guard-safe region.
- The ideating cloud may occupy the upper effect area, but its two rising pixels must visually connect the thought to the character. No text, punctuation, UI, or unrelated detached decoration is allowed.
- Frames never scale, rotate, blur, or interpolate the character. Author every pose at native backing resolution and render with nearest-neighbor sampling on integer backing-pixel boundaries.

The frozen source is `../production/mascot-base-chibi-40pt-at2x-80px-final.png`, SHA-256 `954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6`. Do not regenerate, resample, redraw, or substitute it when starting a row.

## Row order and playback

Unused cells after a row's final frame are fully transparent with zero RGB. Durations are initial values and may only change through a recorded contract revision plus motion QA.

| Row | State | Frames | Playback | Durations in milliseconds | Motion intent |
| ---: | --- | ---: | --- | --- | --- |
| 0 | `offline` | 4 | loop | `500, 500, 500, 700` | Quiet unavailable pose with a slow blink while a short rising `Z` trail appears and disappears; do not recolor the mascot. |
| 1 | `idle` | 4 | loop | `420, 140, 180, 660` | Calm standing pause/blink used between stroll segments and as the reduced-motion ambient pose. |
| 2 | `working` | 6 | loop | `140, 140, 140, 140, 140, 220` | Seated at one tiny computer, with focused hand/shoulder typing motion and no readable screen content. |
| 3 | `ideating` | 6 | loop | `260, 180, 220, 260, 180, 420` | Seated Thinker pose; two rising pixels lead to one compact cloud that appears, changes once, disappears, and repeats. |
| 4 | `waiting` | 4 | intro-hold | `140, 140, 180, hold` | Turn toward the user and raise one hand while a compact clock ticks above the head, then hold the last frame. It must not read as a repeated wave. |
| 5 | `success` | 6 | once-hold | `100, 100, 120, 140, 180, hold` | Sparkling eyes, one quick fist pump, and bounded stars/sparkles above the head, then hold the delighted final pose until the reducer's 3-second reaction ends. |
| 6 | `failure` | 6 | loop | `140, 140, 180, 140, 140, 220` | Brief confused/dizzy reaction with a compact visibly cracked light bulb above the head. |
| 7 | `sleeping` | 6 | loop | `360, 360, 360, 520, 360, 360` | Stable sleeping silhouette under one blanket while a rising `Z` trail appears and disappears with the subtle breath. |
| 8 | `paused` | 2 | intro-hold | `140, hold` | Settle into a still neutral pose and stop the frame timer on the last frame. |
| 9 | `walk-right` | 6 | loop | `140, 120, 140, 120, 140, 120` | Right-facing contact, down, passing, up cadence with alternating feet and no floor effects. |
| 10 | `walk-left` | 6 | loop | `140, 120, 140, 120, 140, 120` | Left-facing equivalent. A mirror is allowed only if glasses, hair, clothing, light direction, and temporal frame order remain correct. |
| 11 | `sit-shake-right` | 6 | loop | `220, 180, 220, 180, 220, 360` | Ambient right-facing chair pose: sit on a small freestanding chair and casually swing one lower leg while the torso and chair stay stable. |
| 12 | `sit-shake-left` | 6 | loop | `220, 180, 220, 180, 220, 360` | Mirrored left-facing chair pose with temporal order preserved. |
| 13 | `hanging` | 6 | loop | `160, 160, 220, 160, 160, 220` | One raised hand grips the cursor anchor while the body, free arm, and legs swing left through center to right; no ledge, rope, cursor art, or ground contact. |

`hold` is not a millisecond value: the controller displays that frame until the visible state changes. `intro-hold` and `once-hold` play frames `0...n-1` exactly once; neither restarts while the state remains unchanged.

## Palette and alpha

All frames use only transparency plus the frozen 12-color subject palette:

`#111219`, `#122F68`, `#B5B6B8`, `#3E3D43`, `#FFBE4B`, `#25252B`, `#7E8085`, `#0D234E`, `#F6F3E4`, `#E18B30`, `#A75221`, `#1B428B`.

- Alpha is binary: only `0` or `255`.
- Fully transparent pixels have RGB `(0, 0, 0)`.
- No antialiasing, semitransparent fringe, chroma spill, shadow, glow, smear, or single-pixel noise.
- Props and effects reuse the frozen palette. The computer, blanket, cloud, `Z` trail, clock, stars, bulb, and freestanding chair do not introduce new colors.
- The identity anchors remain readable in every applicable frame: asymmetric dark hair, separate square glasses/lenses, navy torso with white side panels, gray trousers, and navy shoes.

Intentional detached effects are limited to the owner-requested offline/sleeping `Z` trails, waiting clock, success stars/sparkles, failure bulb, and the existing ideating cloud. They must stay inside the guard, remain legible at native size, and never overlap the face.

## Frame acceptance rules

Each frame must pass in isolation and in motion:

1. It occupies the declared cell and never crosses the four-pixel guard.
2. Its anchor does not drift. Grounded contact frames land on `y=102`; seated and sleeping props use that same ground reference.
3. The body scale and head/body proportions do not pop between frames. Pose changes are authored, not geometric transforms of one source.
4. Both lenses remain distinguishable when the face is visible. Limb separation keeps at least one clear pixel where the pose depends on it.
5. The state reads within one second at the intended 40-point body size on both light and dark backgrounds.
6. Walk loops alternate feet, preserve temporal order, avoid foot sliding during contact, and loop without a teleport.
7. Working, ideating, waiting, success, failure, sleeping, and offline remain visually distinct; only the approved `Z` trails may use letterforms.
8. First frames of `idle`, `sleeping`, `waiting`, and `paused` are acceptable static Reduced Motion substitutions. Reduced Motion never scales or rapidly flashes the panel.
9. `sit-shake-right` and `sit-shake-left` keep the chair back, seat, legs, hip, torso, head, and supporting leg stable; only the raised lower leg swings.
10. `hanging` keeps an opaque hand pixel fixed at `(48, 4)` while the body swings beneath it; neither foot touches the ground and no cliff, ledge, rope, or cursor is drawn.

Repair the smallest failing scope: one frame, then one row, and only then a broader redraw. Identity drift is a blocker even if automated checks pass.

## Required QA artifacts

Before owner review, produce:

- `qa/contact-sheet-backing-1x-light.png` and `qa/contact-sheet-backing-1x-dark.png`: every cell at one image pixel per backing pixel.
- `qa/contact-sheet-inspection-8x-light.png` and `qa/contact-sheet-inspection-8x-dark.png`: integer nearest-neighbor inspection sheets.
- One motion preview per row using the declared timings.
- A silhouette-only contact sheet.
- Validator output showing dimensions, row occupancy, palette, binary alpha, transparent-RGB cleanup, guards, and baseline checks.
- An in-app Retina capture showing the `80x80` body canvas at `40x40` points.

The dedicated `@1x` asset remains an explicit experiment. It must be authored and reviewed separately; never create it by silently smoothing or downsampling `mascot-atlas@2x.png`. Issue #3 may finish Retina production while recording the `@1x` experiment as a follow-up only if the owner accepts that release boundary.

## Production sequence

1. Copy the frozen base into row 1 frame 0 at the declared placement; this establishes the anchor fixture.
2. Produce and review `idle`, `walk-right`, and `walk-left` first. Directional gait and identity must pass before props obscure the body.
3. Produce `working`, `ideating`, and `waiting`.
4. Produce `success`, `failure`, `sleeping`, `offline`, and `paused`.
5. Apply the owner-directed effect revision and add the two directional sit-shake ambient clips.
6. Add the revision 3 cursor-hanging row with its separate top grip anchor.
7. Apply revision 4 by replacing the sit-shake ledge with one stable freestanding chair, then derive the left row by mirroring without reversing time.
8. Assemble the atlas deterministically, run `tools/validate_animation_atlas.py`, render contact sheets and previews, and repair only failing rows.
9. Obtain owner review before closing issue #3 merely because the atlas is structurally valid.
