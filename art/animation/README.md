# Animation production status

The atlas contract is frozen in `ATLAS.md` and `atlas-contract.json`.

## Current owner-review candidate

- `frames/walk-right/` — six normalized right-walk frames.
- `frames/walk-left/` — per-frame mirror derivation of the right row with temporal order preserved.
- `frames/idle/` — four native idle frames: exact base, half blink, full blink, exact base.
- `sources/walk-right-row.png` — grounded generated source retained for reproducibility.
- `qa/contact-sheet-candidate.png` — light/dark directional review sheet.
- `qa/silhouette-sheet-candidate.png` — directional silhouettes.
- `qa/previews/walk-right.gif` and `qa/previews/walk-left.gif` — contract-timed motion previews.

The directional rows passed deterministic checks and internal visual QA on 2026-07-28. The owner then authorized continuation after reviewing their previews. The idle row passed deterministic and internal visual QA and awaits owner review.

## Rejected idle path

Two generated idle rows and one generated single-blink repair were rejected because they changed the approved identity; their images were not admitted to the project. With owner authorization, the production idle row was authored directly at native resolution. Frames 0 and 3 preserve every frozen-base pixel; frames 1 and 2 change only the lens interiors.

No other state row has entered production. Do not assemble or integrate a partial atlas.

## Verification

```bash
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states idle walk-right walk-left
```
