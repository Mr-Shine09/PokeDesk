# Production mascot base

Owner direction reviewed on 2026-07-28:

1. Approved face and tall-body source: `../references/owner-approved-tall-face.png`
2. Reserved fallback only: `../references/owner-selected-fallback-chibi.png`
3. On-screen target: `40x40` macOS points
4. Retina artwork: `80x80` pixels at `@2x`

The owner explicitly approved the face in `owner-approved-tall-face.png` on 2026-07-28. That approval freezes the source-level hair, glasses, eyes, nose, mouth, and friendly expression. It does not automatically approve a reduced native sprite: the 80x80 `@2x` interpretation must preserve those cues at a 40x40-point Dock footprint.

## Current QA candidate

- `../references/owner-approved-tall-face.png`: exact owner-approved source with its baked checkerboard retained as approval evidence.
- `../references/owner-approved-tall-face-transparent.png`: deterministic background-cleaned source used by the production pipeline.
- `mascot-base-approved-tall-40pt-at2x-80px-v3.png`: current 80x80 Retina candidate for a 40x40-point window.
- `mascot-base-approved-tall-40pt-at2x-v3-review-8x.png`: current light/dark QA sheet.

This candidate uses binary alpha and the project's 12-color palette. It preserves every neck-down pixel from the automatic approved-source reduction while rebuilding only the face at native resolution. Its two square frames are separate, each lens owns an eye/glint, and the nose and mouth remain isolated. It remains unapproved until owner native-size QA.

## Tall-direction attempts rejected by owner QA

These files are evidence only and must never be consumed by the app, atlas, or animation workflow:

- `mascot-base-tall-40pt-at2x-80px.png`
- `mascot-base-tall-40pt-at2x-review-8x.png`
- `mascot-base-tall-40pt-at2x-80px-face-v2.png`
- `mascot-base-tall-40pt-at2x-face-v2-review-8x.png`
- `mascot-base-tall-40pt-at2x-80px-face-v3.png`
- `mascot-base-tall-40pt-at2x-face-v3-review-8x.png`
- `tools/clean_retina_face.swift`

The first corrected Retina tall reduction merged the hair, glasses, lenses, eyes, and nose into a single facial cluster. The deterministic face expansion separated pixels but produced an oversized goggle bar. A coherent regenerated tall reduction then lost one lens at native size. All three fail the identity test. The owner later approved that corrected tall-face direction; the exact approved attachment is preserved separately as `../references/owner-approved-tall-face.png`. The earlier `mascot-face-v2-imagegen-reference.png` remains supporting generation evidence rather than a production sprite.

## Approved-face native iterations

- `mascot-base-approved-tall-40pt-at2x-80px-v1.png` and its QA sheet: automatic reduction; rejected internally because the frames and eyes collapse.
- `mascot-base-approved-tall-40pt-at2x-80px-v2.png` and its QA sheet: bounded face reconstruction; rejected internally because the continuous bridge reads as a goggle bar.
- `mascot-base-approved-tall-40pt-at2x-80px-v3.png` and its QA sheet: current candidate with two independent frames and no continuous bridge.

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

## Current approved-face reproduction

```sh
swift tools/remove_checkerboard_background.swift \
  art/references/owner-approved-tall-face.png \
  art/references/owner-approved-tall-face-transparent.png

swift tools/prepare_pixel_concept.swift \
  art/references/owner-approved-tall-face-transparent.png 80 \
  art/production/mascot-base-approved-tall-40pt-at2x-80px-v1.png \
  art/production/mascot-base-approved-tall-40pt-at2x-v1-review-8x.png

swift tools/clean_approved_tall_face.swift \
  art/production/mascot-base-approved-tall-40pt-at2x-80px-v1.png \
  art/production/mascot-base-approved-tall-40pt-at2x-80px-v3.png \
  art/production/mascot-base-approved-tall-40pt-at2x-v3-review-8x.png
```

`tools/remove_checkerboard_background.swift` flood-fills only connected neutral checkerboard pixels from the canvas edges, so enclosed garment and lens whites remain intact. `tools/clean_approved_tall_face.swift` changes rows 5–15 only; rows 16–79 are verified byte-for-byte identical to the automatic approved-source reduction.

## Face-correction ImageGen prompt

The built-in image-editing workflow produced the face the owner explicitly approved on 2026-07-28. Its automatic full-body reduction lost one lens, so native cleanup remains necessary even though the source face itself is frozen.

```text
Use case: precise-object-edit. Asset type: face-correction reference for an 80x80 @2x macOS Dock pixel mascot displayed at 40x40 points. Input image 1 is the edit target and is authoritative for the full tall body, pose, clothes, silhouette, palette, transparent canvas, and pixel-art style. Image 2 is the authoritative likeness and tall adult proportion reference. Image 3 is supporting reference only for readable separated square glasses and eye construction; do not copy its chibi body. Primary request: change only the head and facial pixel construction in Image 1. Keep every pixel of the neck-down body, stance, navy-and-white pullover, gray wide-leg trousers, shoes, canvas framing, and tall proportions unchanged. Rebuild the face so the black hair fringe, two separate square glasses frames, bridge, two individual lenses/eyes, nose, and mouth are unmistakably separate clusters at native size. Put at least one warm-skin pixel row between the hair fringe and the top glasses edges. Keep a warm-skin gap between the two glasses frames except for a one-pixel bridge. Each lens must contain its own small dark eye and one tiny light glint; do not form one continuous white strip. Keep the nose below the bridge and the mouth below the nose with skin pixels separating them. Preserve asymmetric black hair and friendly mature expression. Coarse hard-edged grid-aligned pixel clusters, no antialiasing, no gradients, no smooth painterly pixels, no text, no watermark, no logo, no extra props. Background remains transparent. Avoid: merged eyebrow/glasses/eye band, white visor, cyclops face, chibi body, enlarged torso, changed limbs, changed clothes.
```
