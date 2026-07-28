# Animation production status

The atlas contract is frozen in `ATLAS.md` and `atlas-contract.json`.

## Current owner-review candidate

- `frames/walk-right/` — six normalized right-walk frames.
- `frames/walk-left/` — per-frame mirror derivation of the right row with temporal order preserved.
- `sources/walk-right-row.png` — grounded generated source retained for reproducibility.
- `qa/contact-sheet-candidate.png` — light/dark directional review sheet.
- `qa/silhouette-sheet-candidate.png` — directional silhouettes.
- `qa/previews/walk-right.gif` and `qa/previews/walk-left.gif` — contract-timed motion previews.

The directional rows passed deterministic checks and internal visual QA on 2026-07-28. They remain candidates until the owner accepts them.

## Incomplete rows

`frames/idle/idle-00.png` is only the exact frozen-base anchor fixture. It is not a complete four-frame idle row. Two generated idle rows and one single-blink repair were rejected because they changed the approved identity; their images were not admitted to the project.

No other state row has entered production. Do not assemble or integrate a partial atlas.

## Verification

```bash
python3 tools/validate_animation_atlas.py --contract-only
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states walk-right walk-left
```

