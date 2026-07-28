# Production mascot base

Owner direction locked on 2026-07-28:

1. Primary: `../references/owner-selected-primary-tall.png`
2. Fallback only if the primary cannot remain readable: `../references/owner-selected-fallback-chibi.png`
3. On-screen target: `40x40` macOS points
4. Retina artwork: `80x80` pixels at `@2x`

The tall primary is feasible at the selected 40-point footprint. A 40-point square on a Retina display has an 80x80-pixel backing surface; treating it as only 40 source pixels was an implementation mistake that destroyed the face and silhouette.

## Artifacts

- `mascot-base-tall-40-source-chroma.png`: built-in ImageGen source on green.
- `mascot-base-tall-40-source.png`: transparent enlarged source.
- `mascot-base-tall-40pt-at2x-80px.png`: current 80x80 Retina candidate for a 40x40-point window.
- `mascot-base-tall-40pt-at2x-review-8x.png`: current light/dark QA sheet.

The current candidate uses binary alpha and the project's 12-color palette while retaining the selected tall proportions. It is derived from the owner-selected primary concept, not from the rejected hand-drawn replacement.

## Rejected 40-source-pixel experiment

The following files are evidence only and must never be consumed by the app, atlas, or animation workflow:

- `mascot-base-tall-40-native-draft.png`
- `mascot-base-tall-40-native.png`
- `mascot-base-tall-40-native-final.png`
- `mascot-base-tall-40-review-8x-draft.png`
- `mascot-base-tall-40-review-8x.png`
- `mascot-base-tall-40-review-8x-final.png`
- `tools/hand_clean_tall_base.swift`

Owner QA rejected the result on 2026-07-28. Root cause: the pipeline confused macOS points with backing pixels, then attempted to invent facial detail after destructive reduction. Retain these files only until the corrected art direction is accepted and the historical record no longer needs them.

## Rejected experiment's built-in ImageGen prompt

```text
Use case: precise-object-edit. Asset type: production-direction source for a true 40x40 logical-pixel macOS Dock mascot. Input image 1 is the primary and authoritative design. Preserve its taller miniature proportions, long wide-leg gray trousers, relaxed asymmetric stance, navy-and-white pullover, navy shoes, hairstyle, and mature friendly personality. Input image 2 is only a readability reference for the head: borrow its thicker square glasses, larger separated eye/lens pixels, and simplified high-contrast face construction. Do not copy its short chibi body proportions. Primary request: redraw Image 1 as an animation-ready tall miniature that can survive reduction to exactly 40x40 pixels. Keep the body tall, but make the head and square glasses about 15 percent larger than Image 1 so the glasses remain unmistakable at native size. Keep at least one logical-pixel gap between the legs and between each arm and torso where possible. Use a neutral stroll-ready stance with both hands visible and no hand in a pocket. Pixel rules: visibly coarse grid-aligned square clusters, no antialiasing, no gradients, no smooth shading, no texture noise, at most 12 subject colors, consistent top-left lighting, selective dark outline. Background: perfectly flat, uniform #00FF00 chroma-key edge to edge. Do not use that green in the subject. Preserve: asymmetric black hair mass, thick square black glasses with two light lens pixels, warm medium skin, navy torso, bold white side panels, wide light-gray trousers, navy shoes. Remove: belt details, zipper below one pixel, trouser texture, logos, crest, briefcase, text, symbols, shadow, floor, reflection, watermark. Do not turn the body into a large-headed chibi. Do not imitate Claude's orange block mascot.
```

## Current Retina reproduction

```sh
swift tools/prepare_pixel_concept.swift \
  art/concepts/mascot-40-concept.png 80 \
  art/production/mascot-base-tall-40pt-at2x-80px.png \
  art/production/mascot-base-tall-40pt-at2x-review-8x.png
```
