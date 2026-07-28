# Animation production status

The atlas contract is frozen in `ATLAS.md` and `atlas-contract.json`.

## Approved rows

- `frames/walk-right/` — six normalized right-walk frames.
- `frames/walk-left/` — per-frame mirror derivation of the right row with temporal order preserved.
- `frames/idle/` — four native idle frames: exact base, half blink, full blink, exact base.
- `frames/working/` — six seated typing frames with a stable computer and chair.
- `frames/ideating/` — six seated Thinker frames with the contracted cloud cycle.
- `frames/waiting/` — four intro-hold frames that raise one hand once and hold.

These six rows passed deterministic checks, internal visual QA, and owner review on 2026-07-28.

## Current owner-review candidates

- `frames/success/` — six once-hold frames with lens sparkles and one fist-pump peak.
- `frames/failure/` — six confused/dizzy posture frames with detached generated symbols removed.
- `frames/sleeping/` — four grounded blanket-breathing frames without text effects.
- `frames/offline/` — two subdued bowed-pose blink frames without recoloring.
- `frames/paused/` — two deterministic approved-idle frame reuses ending in a static hold.
- `mascot-atlas@2x.png` — complete structurally validated `768x1232` candidate atlas.
- `qa/contact-sheet-backing-1x-{light,dark}.png` and `qa/contact-sheet-inspection-8x-{light,dark}.png` — full contract review sheets.
- `qa/silhouette-sheet-candidate.png` and `qa/previews/` — full silhouette and contract-timed motion review.

The final five rows and assembled atlas passed deterministic validation and internal native-size visual QA on 2026-07-28. They remain unapproved until owner review.

## Rejected idle path

Two generated idle rows and one generated single-blink repair were rejected because they changed the approved identity; their images were not admitted to the project. With owner authorization, the production idle row was authored directly at native resolution. Frames 0 and 3 preserve every frozen-base pixel; frames 1 and 2 change only the lens interiors.

Do not integrate the candidate atlas into the app until owner review freezes the final five rows.

## Verification

```bash
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states offline idle working ideating waiting success failure sleeping paused walk-right walk-left
```
