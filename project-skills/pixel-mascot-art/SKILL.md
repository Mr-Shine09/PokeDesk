---
name: pixel-mascot-art
description: Reduce detailed character art into a tiny, readable, animation-ready pixel mascot and define its sprite constraints. Use for pixel avatars, desktop pets, dock mascots, sprite sheets, animation states, palette reduction, silhouette design, nearest-neighbor scaling, and visual QA at small native sizes.
---

# Pixel Mascot Art

Preserve identity through silhouette and a few signature cues, not miniature detail.

## Establish the Native Grid

1. Choose one logical canvas before drawing. Default to `32x32` for dock-scale mascots; test `24x24` only for simpler bodies and `48x48` when a face must remain expressive.
2. Draw and animate at native resolution.
3. Preview only with integer nearest-neighbor scaling.
4. Keep every animation frame on the same baseline, origin, and bounding box.

## Reduce Identity

Rank source features before drawing:

- silhouette: hair mass, head/body ratio, stance
- face anchor: glasses, eyes, or another single high-contrast cue
- palette anchor: one dominant garment color and one accent
- motion anchor: a characteristic posture or prop

Keep at most three anchors in the smallest sprite. Remove logos, seams, fabric texture, fingers, and face shading unless they remain legible at 1x.

## Pixel Rules

- Use a limited palette, usually 8–16 colors including outline and transparency.
- Prefer clustered pixels over single-pixel noise.
- Use one consistent light direction.
- Avoid semitransparent edge pixels in production sprites.
- Keep outlines selective; do not wrap every interior form in black.
- Reserve at least one clear pixel gap between limbs when the pose depends on separation.
- Validate dark and light desktop backgrounds.

## Animation Rules

- Idle: 2–4 frames, subtle breath or blink.
- Walk: 4–6 frames per direction, readable contact and passing poses.
- Work: 4–6 frames, unmistakable focused action without readable text.
- Sleep: 2–4 frames, stable resting silhouette; detached effects are optional and must stay sparse.
- Chill: 2–4 frames, distinct from idle through posture.
- Success/failure/waiting: short one-shot reaction followed by a stable loop.

Prefer pose changes to decorative motion marks. A frame must remain recognizable when isolated from the loop.

## QA Gate

Before approval, inspect:

1. a 1x contact sheet on both light and dark backgrounds;
2. an integer-scaled preview for discussion;
3. silhouette-only thumbnails;
4. a motion preview for foot sliding, jitter, and baseline drift;
5. palette consistency and transparent-pixel cleanup.

Reject the sprite if identity depends on details visible only when enlarged.
