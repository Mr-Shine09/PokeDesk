# Mascot asset and atlas pipeline

## Authoritative assets

| Asset | Role | Rule |
| --- | --- | --- |
| `art/references/owner-selected-fallback-chibi.png` | selected visual reference | Preserve for provenance |
| `art/production/mascot-base-chibi-40pt-at2x-80px-final.png` | frozen production base | Never regenerate or replace implicitly |
| `art/animation/atlas-contract.json` | machine-readable geometry/timing/palette contract | Update first for a recorded revision |
| `art/animation/frames/<state>/` | normalized production cells | Inputs to deterministic assembly |
| `art/animation/mascot-atlas@2x.png` | app-consumed atlas | Generated output; never hand-patch alone |
| `art/animation/mascot-atlas@2x.manifest.json` | per-frame hashes | Regenerate with atlas |
| `art/animation/qa/` | contact sheets, silhouettes, GIFs | Regenerate for visual review |

The original owner source path in `DesktopMascot.md` is external to the repository. Current production work must start from the promoted in-repository frozen base.

## Revision 3 contract

- Atlas: `768x1568` RGBA PNG
- Grid: 8 columns × 14 rows
- Cell: `96x112` backing pixels (`48x56` logical points in the original contract)
- App presentation: `96x112` points, giving the cell a deliberate 2x visual presentation
- Ground anchor: `(48, 102)` top-origin
- Hanging grip: `(48, 4)` top-origin
- Guard: opaque pixels within `x=4...91`, `y=4...107`
- Alpha: only 0 or 255; transparent RGB must be zero
- Palette: exactly the 12 colors declared in the contract
- Interpolation: nearest neighbor

Read `art/animation/ATLAS.md` for row order, durations, intent, and frame-level acceptance rules.

## Standard atlas rebuild

```bash
python3 tools/assemble_animation_atlas.py
python3 tools/validate_animation_atlas.py --atlas art/animation/mascot-atlas@2x.png
python3 tools/render_animation_qa.py \
  --states offline idle working ideating waiting success failure sleeping paused \
           walk-right walk-left sit-shake-right sit-shake-left hanging \
  --full-contract \
  --scale 4
```

Then run package tests and the unsigned app build because the runtime crop and resource embedding are part of atlas acceptance.

## Generated strip normalization

Generated raster art is a source candidate, not a production frame. Use a perfectly flat chroma-key background and inspect identity before promotion.

Grounded/effect pose example:

```bash
python3 tools/prepare_animation_frames.py \
  --strip art/animation/sources/<state>-row.png \
  --state <state> \
  --frames <count> \
  --bounds-mode guard
```

Hanging uses the dedicated top anchor:

```bash
python3 tools/prepare_animation_frames.py \
  --strip art/animation/sources/hanging-row.png \
  --state hanging \
  --frames 6 \
  --bounds-mode guard \
  --anchor-mode hanging
```

Validate a changed row before assembly:

```bash
python3 tools/validate_animation_atlas.py \
  --frames-root art/animation/frames \
  --states <state>
```

## Art acceptance

Reject a candidate if any of these fail:

- dark asymmetric hair, square glasses, navy/white torso, gray trousers, and navy shoes remain recognizable at native size;
- silhouette and scale do not pop between frames;
- palette, alpha, guard, anchor, and transparent RGB validate;
- light and dark 1x contact sheets are readable;
- 8x nearest-neighbor inspection shows no noise, fringe, smoothing, or accidental detached components;
- motion GIF shows no baseline/grip drift, temporal reversal, sliding contact, or loop teleport;
- runtime crop matches the corresponding frame PNG;
- owner approves any material new visual direction.

## Revision discipline

Do not overwrite an owner-approved atlas behavior casually. A new row, geometry change, palette change, or anchor model requires:

1. an explicit owner request or recorded product decision;
2. contract and `ATLAS.md` revision;
3. normalized frames and deterministic assembly;
4. complete automated and visual QA;
5. runtime integration/tests;
6. a dated `DesktopMascot.md` entry.

