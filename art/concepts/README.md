# Mascot native-grid concept comparison

Generated and reviewed on 2026-07-28 from the owner's canonical avatar:
`/Users/oaksoekhant/Mr-Shine09/source-avatar-magenta.png`.

These are direction-finding concepts, not production animation frames. The source concepts were generated with the built-in image-generation workflow on a removable green background. The project tool at `tools/prepare_pixel_concept.swift` then fits each character to its native grid using nearest-neighbor sampling, enforces binary alpha, maps the result to the approved 12-color palette, and produces an 8x light/dark QA sheet.

## Concept A — 32x32

- Generated source: `mascot-32-concept-chroma.png`
- Transparent enlarged source: `mascot-32-concept.png`
- Native sprite: `mascot-32-native.png`
- Light/dark QA: `mascot-32-review-8x.png`

Strengths: smallest footprint, strong hair silhouette, toy-like charm.

QA concern: the square glasses collapse into a broad horizontal light band at native size, leaving too little room for sparkling eyes, a dizzy expression, or a readable waiting pose.

## Concept B — 40x40 v2

- Generated source: `mascot-40-concept-v2-chroma.png`
- Transparent enlarged source: `mascot-40-concept-v2.png`
- Native sprite: `mascot-40-native-v2.png`
- Light/dark QA: `mascot-40-review-8x-v2.png`

Strengths: retains the compact chibi silhouette while preserving separate glasses/eyes, hair asymmetry, white garment panels, and limb gaps. The eight extra pixels materially improve the planned emotional poses.

Earlier recommendation: select 40x40 v2 for the 0.1 production grid. The owner later chose the taller first 40x40 direction as the primary style and retained this compact chibi as the fallback. See `../production/README.md`.

## Tall experiment, later revived by owner selection

The first 40x40 direction (`mascot-40-concept-chroma.png`, `mascot-40-concept.png`, `mascot-40-native.png`, and `mascot-40-review-8x.png`) became tall and human-proportioned. It was initially excluded from the grid comparison because it did not hold proportions constant, but the owner explicitly ranked this aesthetic first on 2026-07-28. It is now the primary production direction; the compact 40x40 v2 remains the fallback.

## Final generation prompts

### 32x32

```text
Use case: style-transfer. Asset type: a 32x32 logical-pixel macOS Dock mascot concept, displayed enlarged with nearest-neighbor square pixels. Use the provided person only as identity/outfit reference. Create exactly one complete friendly full-body chibi pixel mascot in a neutral stroll-ready pose, centered and fully visible. Preserve only the strongest identity anchors: large asymmetric tousled black hair silhouette, square black glasses, warm medium skin, navy pullover with bold white side panels, wide light-gray trousers, navy shoes. Use hard grid-aligned square clusters, selective dark outline, no antialiasing, no gradients, no texture noise, and at most 12 subject colors. Perfectly uniform flat #00FF00 chroma-key background edge to edge; do not use that green in the subject. No logo or crest, no briefcase, no text, no symbols, no watermark, no shadow, no floor, no reflection. Do not imitate Claude's orange block mascot. Prioritize silhouette and readability at a true 32x32 native size.
```

### 40x40 v2

```text
Use case: style-transfer. Asset type: revised 40x40 logical-pixel macOS Dock mascot concept, displayed enlarged with nearest-neighbor square pixels. Input image 1 is the person's identity and outfit reference. Input image 2 is the approved direction for compact chibi proportions and overall sprite language; preserve that same head-to-body ratio and friendly toy-like silhouette. Create exactly one complete full-body 40x40-grid alternative—not a tall human-proportioned character. The head including hair should occupy roughly 40 percent of character height. Use the extra eight pixels only to improve the square black glasses, asymmetric hair, limb separation, and animation readability. Preserve: large asymmetric tousled black hair, unmistakable square black glasses with two light lens/eye pixels, warm medium skin, navy pullover with bold white side panels, loose light-gray trousers, navy shoes. Neutral stroll-ready stance, centered, fully visible, feet on one baseline. Pixel rules: visibly coarse hard grid-aligned square clusters; selective dark outline; no antialiasing, gradients, texture noise, or tiny details; at most 12 subject colors. Background: perfectly flat uniform #00FF00 chroma-key edge to edge; never use that green in the character. No logo/crest, briefcase, text, symbols, watermark, shadow, floor, reflection, or Claude orange block-creature styling.
```
