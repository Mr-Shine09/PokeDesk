# Production mascot base

Owner direction locked on 2026-07-28:

1. Primary: `../references/owner-selected-primary-tall.png`
2. Fallback only if the primary cannot remain readable: `../references/owner-selected-fallback-chibi.png`
3. Native production grid: `40x40`

The tall primary is feasible. It requires deterministic hand-cleaning at native size because a direct downscale removes the glasses and facial separation.

## Artifacts

- `mascot-base-tall-40-source-chroma.png`: built-in ImageGen source on green.
- `mascot-base-tall-40-source.png`: transparent enlarged source.
- `mascot-base-tall-40-native-draft.png`: automatic 40x40 reduction retained as evidence.
- `mascot-base-tall-40-native.png`: deterministic head/glasses hand-clean intermediate.
- `mascot-base-tall-40-native-final.png`: normalized 40x40 review candidate.
- `mascot-base-tall-40-review-8x-final.png`: 8x light/dark QA sheet for owner review.

The production candidate uses binary alpha and the project's 12-color palette. Its proportions follow the tall primary, while the face borrows only the fallback's high-contrast construction: separated square glasses and isolated light lens/eye pixels.

## Final built-in ImageGen prompt

```text
Use case: precise-object-edit. Asset type: production-direction source for a true 40x40 logical-pixel macOS Dock mascot. Input image 1 is the primary and authoritative design. Preserve its taller miniature proportions, long wide-leg gray trousers, relaxed asymmetric stance, navy-and-white pullover, navy shoes, hairstyle, and mature friendly personality. Input image 2 is only a readability reference for the head: borrow its thicker square glasses, larger separated eye/lens pixels, and simplified high-contrast face construction. Do not copy its short chibi body proportions. Primary request: redraw Image 1 as an animation-ready tall miniature that can survive reduction to exactly 40x40 pixels. Keep the body tall, but make the head and square glasses about 15 percent larger than Image 1 so the glasses remain unmistakable at native size. Keep at least one logical-pixel gap between the legs and between each arm and torso where possible. Use a neutral stroll-ready stance with both hands visible and no hand in a pocket. Pixel rules: visibly coarse grid-aligned square clusters, no antialiasing, no gradients, no smooth shading, no texture noise, at most 12 subject colors, consistent top-left lighting, selective dark outline. Background: perfectly flat, uniform #00FF00 chroma-key edge to edge. Do not use that green in the subject. Preserve: asymmetric black hair mass, thick square black glasses with two light lens pixels, warm medium skin, navy torso, bold white side panels, wide light-gray trousers, navy shoes. Remove: belt details, zipper below one pixel, trouser texture, logos, crest, briefcase, text, symbols, shadow, floor, reflection, watermark. Do not turn the body into a large-headed chibi. Do not imitate Claude's orange block mascot.
```

## Reproduction

```sh
swift tools/prepare_pixel_concept.swift \
  art/production/mascot-base-tall-40-source.png 40 \
  art/production/mascot-base-tall-40-native-draft.png \
  art/production/mascot-base-tall-40-review-8x-draft.png

swift tools/hand_clean_tall_base.swift \
  art/production/mascot-base-tall-40-native-draft.png \
  art/production/mascot-base-tall-40-native.png \
  art/production/mascot-base-tall-40-review-8x.png

swift tools/prepare_pixel_concept.swift \
  art/production/mascot-base-tall-40-native.png 40 \
  art/production/mascot-base-tall-40-native-final.png \
  art/production/mascot-base-tall-40-review-8x-final.png
```
