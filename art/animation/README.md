# Animation production status

The revision 3 atlas contract is defined in `ATLAS.md` and `atlas-contract.json`.

## Approved rows

- `frames/walk-right/` — six normalized right-walk frames.
- `frames/walk-left/` — per-frame mirror derivation of the right row with temporal order preserved.
- `frames/idle/` — four native idle frames: exact base, half blink, full blink, exact base.
- `frames/working/` — six seated typing frames with a stable computer and chair.
- `frames/ideating/` — six seated Thinker frames with the contracted cloud cycle.
- `frames/waiting/` — four intro-hold frames that raise one hand once and hold.

These six rows passed deterministic checks, internal visual QA, and owner review on 2026-07-28.

## Revision 3 candidate

- `frames/offline/` — four bowed-pose frames with a rising/disappearing `Z` trail.
- `frames/sleeping/` — six blanket-breathing frames with a rising/fading `Z` trail.
- `frames/waiting/` — the approved raised-hand body with a ticking clock above the head.
- `frames/success/` — the fist-pump reaction with bounded stars and sparkles above the head.
- `frames/failure/` — the confused/dizzy reaction with a cracked light bulb above the head.
- `frames/paused/` — two deterministic approved-idle frame reuses ending in a static hold.
- `frames/sit-shake-right/` and `frames/sit-shake-left/` — two six-frame directional Dock-corner ambient clips with one dangling leg swinging.
- `frames/hanging/` — six cursor-hanging frames with a fixed raised-hand grip and a left/center/right pendulum swing, with no cliff or ledge.
- `mascot-atlas@2x.png` — complete structurally validated `768x1568` revision 3 candidate atlas.
- `qa/contact-sheet-backing-1x-{light,dark}.png` and `qa/contact-sheet-inspection-8x-{light,dark}.png` — full contract review sheets.
- `qa/silhouette-sheet-candidate.png` and `qa/previews/` — full silhouette and contract-timed motion review.

The requested effects, two corner-sit clips, and expanded atlas passed deterministic validation, internal native-size visual QA, and owner review on 2026-07-28.

Reproduction order for revised reaction rows is normalize body frames, apply any body-pose repair, then run `tools/author_status_effects.py`. The effect authoring step is idempotent and preserves every body pixel below the reserved upper effect area.

## Rejected idle path

Two generated idle rows and one generated single-blink repair were rejected because they changed the approved identity; their images were not admitted to the project. With owner authorization, the production idle row was authored directly at native resolution. Frames 0 and 3 preserve every frozen-base pixel; frames 1 and 2 change only the lens interiors.

Revision 2 is frozen for app integration. Do not change row order, timing, geometry, or pixels without a recorded revision 3 decision.

## Verification

```bash
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states offline idle working ideating waiting success failure sleeping paused walk-right walk-left sit-shake-right sit-shake-left hanging
```
