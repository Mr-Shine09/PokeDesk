# Animation production status

The atlas contract is frozen in `ATLAS.md` and `atlas-contract.json`.

## Approved rows

- `frames/walk-right/` — six normalized right-walk frames.
- `frames/walk-left/` — per-frame mirror derivation of the right row with temporal order preserved.
- `frames/idle/` — four native idle frames: exact base, half blink, full blink, exact base.

The directional and idle rows passed deterministic checks, internal visual QA, and owner review on 2026-07-28.

## Current owner-review candidates

- `frames/working/` — six seated typing frames with a stable computer and chair.
- `frames/ideating/` — six seated Thinker frames with the contracted two-pixel/cloud/change/disappear cycle.
- `frames/waiting/` — four intro-hold frames that turn front, raise one hand once, and hold.
- `sources/working-row.png`, `sources/ideating-row.png`, and `sources/waiting-row.png` — grounded generated sources retained for reproducibility.
- `qa/contact-sheet-candidate.png` — all approved and candidate rows on light/dark backgrounds.
- `qa/silhouette-sheet-candidate.png` — all approved and candidate row silhouettes.
- `qa/previews/` — contract-timed motion previews for every produced row.

The new group passed deterministic validation and internal native-size visual QA on 2026-07-28. It remains unapproved until owner review.

## Rejected idle path

Two generated idle rows and one generated single-blink repair were rejected because they changed the approved identity; their images were not admitted to the project. With owner authorization, the production idle row was authored directly at native resolution. Frames 0 and 3 preserve every frozen-base pixel; frames 1 and 2 change only the lens interiors.

No later state row has entered production. Do not assemble or integrate a partial atlas.

## Verification

```bash
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states idle working ideating waiting walk-right walk-left
```
