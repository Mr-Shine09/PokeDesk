#!/usr/bin/env python3
"""Author the Codex orange-fashion atlas from the frozen mascot atlas.

This is deliberately a semantic palette edit, not a regenerated character:
the alpha silhouette, pose geometry, trousers, shoes, props, effects, anchors,
and timing all remain byte-for-byte identical. Only shirt-colored pixels near
the face are recolored, and the interior of each existing lens is filled solid
dark to turn the spectacles into opaque sunglasses.
"""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

from PIL import Image, ImageDraw


TRANSPARENT = (0, 0, 0, 0)
SKIN_COLORS = {
    (255, 190, 75, 255),
    (225, 139, 48, 255),
    (167, 82, 33, 255),
}
SHIRT_RECOLOR = {
    (18, 47, 104, 255): (238, 103, 35, 255),
    (13, 35, 78, 255): (176, 65, 20, 255),
    (27, 66, 139, 255): (255, 142, 55, 255),
}
LENS_SOURCE = (246, 243, 228, 255)
LENS_DARK = (37, 37, 43, 255)
OUTLINE = (17, 18, 25, 255)
# What a lens interior can be made of. Filling only the white pixels left the
# grey lens tints and the skin behind the glass visible, so the eye still read
# through the shades. The greys are also the trousers and the props, which is
# why the fill below is bounded to each lens rather than run over the face.
LENS_INTERIOR = SKIN_COLORS | {
    LENS_SOURCE,
    LENS_DARK,
    (181, 182, 184, 255),
    (126, 128, 133, 255),
    (62, 61, 67, 255),
}
# What marks a pixel as lens rather than face. The lit white is only part of it:
# the top row of a lens is drawn in the two mid greys, and seeding from white
# alone left that row light. The darkest grey is deliberately excluded — it is
# also hair shading, and seeding from it pulled the fill up into the fringe.
LENS_SEED = {LENS_SOURCE, (181, 182, 184, 255), (126, 128, 133, 255)}

# The celebration row draws sparkle eyes as dark pixels on light lenses. Flat
# dark sunglasses erase that expression, so `success` gets its own treatment.
CELEBRATION_STATES = {"success"}


def connected_components(
    image: Image.Image,
    accepted: set[tuple[int, int, int, int]],
) -> list[list[tuple[int, int]]]:
    pixels = image.load()
    remaining = {
        (x, y)
        for y in range(image.height)
        for x in range(image.width)
        if pixels[x, y] in accepted
    }
    components: list[list[tuple[int, int]]] = []
    while remaining:
        seed = remaining.pop()
        component = [seed]
        queue = deque([seed])
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)):
                point = (x + dx, y + dy)
                if point in remaining:
                    remaining.remove(point)
                    component.append(point)
                    queue.append(point)
        components.append(component)
    return components


def bbox(points: list[tuple[int, int]]) -> tuple[int, int, int, int]:
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return min(xs), min(ys), max(xs), max(ys)


def recolor_frame(
    frame: Image.Image,
    state: str,
    celebration_eyes: str = "dark",
    lens_fallback: set[tuple[int, int]] | None = None,
    eyewear: str = "clear",
) -> tuple[Image.Image, dict[str, int], set[tuple[int, int]]]:
    result = frame.copy().convert("RGBA")
    if state == "poof":
        return result, {"shirt_pixels": 0, "lens_pixels": 0}, set()

    skin_components = connected_components(result, SKIN_COLORS)
    if not skin_components:
        raise ValueError(f"{state}: no face-sized skin component found")

    # The face is the largest skin-colored component. Hands remain separate
    # behind the dark outline, including the raised hand in the hanging row.
    face = max(skin_components, key=len)
    left, top, right, bottom = bbox(face)
    face_center_x = (left + right) // 2
    pixels = result.load()

    shirt_pixels = 0
    # `sleeping` used to be skipped entirely, which left the Claude mascot
    # asleep under a navy blanket in an orange hoodie (owner report
    # 2026-08-02). Lying down, no shoes are visible — the blanket, the tucked
    # sleeve, and the collar are the only navy left — so the ground-line shoe
    # guard below is not applied to it.
    if True:
        # Every navy pixel in the frame is a candidate. An earlier version
        # bounded the search to a rectangle starting below the chin, which
        # silently excluded any sleeve raised above the shoulders: the
        # celebration fist-pump, the waiting wave, and the whole hanging row
        # kept a navy arm on an orange hoodie. Props use gray/black, so they
        # cannot be recolored by this exact-palette edit.
        components = connected_components(result, set(SHIRT_RECOLOR))

        # Shoes use the same navy palette but are separated from the shirt by
        # gray trousers. Classify by how far below the face a component starts.
        # Most shirt pixels reach the shoulders, but a raised arm can sever the
        # hoodie: in `hand-sign` the crossed forearms cut off the lower hem, and
        # in `working`/`hanging` a few hem slivers detach the same way. Across
        # all 92 frames of the source art those orphans start at most 19 rows
        # below the face while the nearest shoe starts at 21, so the split is
        # unambiguous — but it is measured, not structural, hence the assertion
        # below.
        alpha = result.getchannel("A").getbbox()
        sprite_bottom = alpha[3] - 1 if alpha else result.height - 1
        for component in components:
            if min(y for _, y in component) > bottom + 19:
                continue
            # A shoe rests on the sprite's ground line; the hoodie never does.
            # If that ever stops holding, the measured split above has drifted
            # and the lower outfit is about to be recolored.
            if state != "sleeping" and max(y for _, y in component) >= sprite_bottom - 2:
                raise ValueError(
                    f"{state}: shirt mask reached the ground line and would "
                    f"recolor a shoe; the face-distance split needs re-measuring"
                )
            for x, y in component:
                pixels[x, y] = SHIRT_RECOLOR[pixels[x, y]]
                shirt_pixels += 1

    # Existing square glasses already establish the correct shape. Turning the
    # light pixels inside their frames dark makes them sunglasses without moving
    # or redrawing the face. The lens interior is filled solid: an earlier
    # version kept one light highlight per lens, which at native size read as a
    # visible eye behind the glass rather than as a glint, and the celebration
    # row went further and drew a light sparkle on the lens. Both are gone —
    # the lenses are now opaque, and only the dark rim separates them from the
    # hair. Lens interiors sit on either side of the nose. Some blink frames
    # replace every light lens pixel with skin, so a pure color replacement
    # would make the sunglasses disappear every other frame; the masks below
    # accept skin as well and remain stable across head positions.
    if eyewear == "clear":
        # Owner decision 2026-08-02: the orange wardrobe keeps the character's
        # ordinary glasses. Only the hoodie separates the two mascots now. The
        # sunglasses treatment below is still reachable with --eyewear
        # sunglasses, and is the only reason the lens machinery is kept.
        return result, {"shirt_pixels": shirt_pixels, "lens_pixels": 0}, set()

    if state in CELEBRATION_STATES and celebration_eyes == "no-shades":
        # The mascot pushes the shades up for the win: the lenses stay as the
        # classic light spectacles, so the sparkle eyes read unchanged.
        return result, {"shirt_pixels": shirt_pixels, "lens_pixels": 0}, set()

    # The lit lens interior is the mask. Searching only the top of the face
    # keeps the white hoodie drawstrings and any open mouth out of it; the one
    # extra row past the halfway mark is there because the walking pose drops
    # the lens just below it, and without it that frame kept a lit lens.
    #
    # This replaced a pair of hard-coded x windows measured either side of the
    # face centre, which silently assumed a front-facing head: in the profile
    # sit-shake and walk poses the far lens fell outside the window and stayed
    # white while the near lens went dark, leaving the mascot with one glass eye.
    # Keying off the lens pixels themselves handles any head angle, and covers
    # one lens or two without needing to know which pose it is looking at.
    # Widen the window a few pixels past the skin bounding box: the outer edge
    # of a lens can sit just outside it, since the glasses overhang the cheek in
    # profile poses. Clipping to the box left a single white column on the far
    # lens in every sit-shake frame.
    face_upper = top + (bottom - top) // 2 + 1
    lens = [
        (x, y)
        for y in range(top, face_upper + 1)
        for x in range(max(0, left - 3), min(result.width - 1, right + 3) + 1)
        if pixels[x, y] in LENS_SEED
    ]

    if not lens:
        # Blink frames replace every lit lens pixel with skin, so there is
        # nothing to key off. The caller re-runs these with the mask from a
        # neighbouring frame of the same row: the pose is identical and only the
        # eyes have shut, so those coordinates are still the lens. The estimate
        # this replaced spread over a fixed window either side of the face and
        # darkened a patch of cheek beyond the glasses.
        if lens_fallback is None:
            return result, {"shirt_pixels": shirt_pixels, "lens_pixels": 0}, set()
        lens = [point for point in sorted(lens_fallback) if pixels[point] in LENS_INTERIOR]

    # Grow each lens from its lit pixels out to the rim. The seeds alone are not
    # the whole interior: grey lens tints and skin sit behind the glass, and
    # leaving them lit meant the eye still read through the shades. The flood
    # cannot cross the dark rim, and is boxed to two pixels around its own seeds
    # so a gap in the rim cannot spill the fill across the face or the trousers.
    lens_pixels = 0
    lens_mask: set[tuple[int, int]] = set()
    remaining = set(lens)
    while remaining:
        seed = remaining.pop()
        group = [seed]
        queue = deque([seed])
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                point = (x + dx, y + dy)
                if point in remaining:
                    remaining.remove(point)
                    group.append(point)
                    queue.append(point)

        # Stay on the rows the lit pixels occupy. Allowing the flood to grow
        # vertically let it slip under the rim and darken a patch of cheek.
        rows = {y for _, y in group}
        filled = set(group)
        queue = deque(group)
        while queue:
            x, y = queue.popleft()
            for dx, dy in ((-1, 0), (1, 0)):
                nx = x + dx
                if not (0 <= nx < result.width) or y not in rows:
                    continue
                if (nx, y) in filled or pixels[nx, y] not in LENS_INTERIOR:
                    continue
                filled.add((nx, y))
                queue.append((nx, y))

        # A lens interior is a handful of pixels. Anything larger means the fill
        # walked through a gap in the rim, so keep only the lit pixels instead.
        if len(filled) > len(group) + 8:
            filled = set(group)

        for x, y in filled:
            pixels[x, y] = LENS_DARK
            lens_pixels += 1
        lens_mask |= filled

    if shirt_pixels == 0 and state not in {"sleeping", "poof"}:
        raise ValueError(f"{state}: semantic shirt mask selected no pixels")
    return result, {"shirt_pixels": shirt_pixels, "lens_pixels": lens_pixels}, lens_mask


def render_contact_sheet(
    atlas: Image.Image,
    rows: list[dict],
    output: Path,
    cell_width: int,
    cell_height: int,
) -> None:
    scale = 4
    gap = 8
    label_width = 132
    sheet_width = label_width + atlas.width * scale
    sheet_height = len(rows) * (cell_height * scale + gap) + gap
    sheet = Image.new("RGBA", (sheet_width, sheet_height), (246, 243, 228, 255))
    draw = ImageDraw.Draw(sheet)
    for index, row in enumerate(rows):
        y = gap + index * (cell_height * scale + gap)
        draw.text((8, y + 4), row["state"], fill=(17, 18, 25, 255))
        strip = atlas.crop((0, index * cell_height, atlas.width, (index + 1) * cell_height))
        strip = strip.resize((strip.width * scale, strip.height * scale), Image.Resampling.NEAREST)
        sheet.alpha_composite(strip, (label_width, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=Path("art/animation/mascot-atlas@2x.png"))
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--output", type=Path, default=Path("art/animation/mascot-atlas-codex@2x.png"))
    parser.add_argument("--qa", type=Path, default=Path("art/animation/qa/contact-sheet-codex-fashion-4x.png"))
    parser.add_argument(
        "--eyewear",
        choices=("clear", "sunglasses"),
        default="clear",
        help=(
            "clear keeps the character's ordinary glasses (owner decision "
            "2026-08-02); sunglasses fills each lens interior solid dark."
        ),
    )
    parser.add_argument(
        "--celebration-eyes",
        choices=("dark", "no-shades"),
        default="dark",
        help="Whether the success row keeps opaque shades or shows the classic light spectacles.",
    )
    args = parser.parse_args()

    contract = json.loads(args.contract.read_text())
    cell_width, cell_height = contract["atlas"]["cell_pixel_size"]
    rows = contract["rows"]
    source = Image.open(args.source).convert("RGBA")
    output = source.copy()
    report: dict[str, list[dict[str, int]]] = {}

    for row in rows:
        row_index = row["index"]
        state = row["state"]
        report[state] = []
        boxes: list[tuple[int, int, int, int]] = []
        results: list[list] = []
        for frame_index in range(row["frames"]):
            box = (
                frame_index * cell_width,
                row_index * cell_height,
                (frame_index + 1) * cell_width,
                (row_index + 1) * cell_height,
            )
            frame = source.crop(box)
            recolored, counts, mask = recolor_frame(
                frame, state, args.celebration_eyes, eyewear=args.eyewear
            )
            boxes.append(box)
            results.append([recolored, counts, mask])

        # Blink frames carry no lit lens to key off. Give them the mask from the
        # nearest frame in the same row that did have one — same pose, shut eyes,
        # so the lens is in the same place — and redo just those frames.
        masked = [i for i, (_, _, mask) in enumerate(results) if mask]
        if masked:
            for index, (_, _, mask) in enumerate(results):
                if mask:
                    continue
                donor = min(masked, key=lambda other: (abs(other - index), other))
                results[index] = list(
                    recolor_frame(
                        source.crop(boxes[index]),
                        state,
                        args.celebration_eyes,
                        lens_fallback=results[donor][2],
                        eyewear=args.eyewear,
                    )
                )
        elif args.eyewear != "clear" and state not in {"sleeping", "poof"}:
            # Every other row must land its sunglasses somewhere. With clear
            # eyewear no row produces a mask, which is the expected outcome.
            raise ValueError(f"{state}: no frame in the row produced a lens mask")

        for box, (recolored, counts, _) in zip(boxes, results):
            output.paste(recolored, box)
            report[state].append(counts)

    # Pixel geometry and transparency are invariants, not visual judgments.
    source_alpha = source.getchannel("A").tobytes()
    output_alpha = output.getchannel("A").tobytes()
    if source_alpha != output_alpha:
        raise ValueError("Codex fashion edit changed the atlas alpha silhouette")
    if output.size != source.size:
        raise ValueError("Codex fashion edit changed atlas dimensions")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    output.save(args.output, optimize=True)
    render_contact_sheet(output, rows, args.qa, cell_width, cell_height)
    report_path = args.output.with_suffix(".authoring.json")
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    print(f"wrote {args.output}")
    print(f"wrote {args.qa}")
    print(f"wrote {report_path}")


if __name__ == "__main__":
    main()
