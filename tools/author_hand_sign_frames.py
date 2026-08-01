#!/usr/bin/env python3
"""Author the dismiss hand-sign row from the approved idle standing cell.

The pose is a two-handed ninja seal: elbows out, forearms angled in, palms
joined at the chest with two fingers extended upward. It is built by removing
the idle arms and redrawing them, so the head, torso, trousers, and shoes come
through untouched from the approved cell and the identity cannot drift.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


EXPECTED_BASE_SHA256 = "954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6"

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (17, 18, 25, 255)
SLEEVE = (18, 47, 104, 255)
SLEEVE_SHADE = (13, 35, 78, 255)
SKIN = (255, 190, 75, 255)
SKIN_SHADE = (225, 139, 48, 255)

# Columns the idle arms and hands occupy, and the rows they span. Everything
# outside this band belongs to the head, torso core, trousers, or shoes and is
# preserved exactly.
ARM_ROWS = range(64, 84)
LEFT_ARM_COLUMNS = range(28, 38)
RIGHT_ARM_COLUMNS = range(57, 69)

SHOULDER_LEFT = (37, 63)
SHOULDER_RIGHT = (57, 63)
CENTER_X = 47

# One entry per frame: where the hands sit, how far the seal fingers extend, and
# how far the elbows swing out. Frame 0 lifts from the hips, frame 1 brings the
# palms together, frame 2 forms the seal, and frame 3 is the held pose the smoke
# poof covers.
#
# The limbs are deliberately thin and the elbows stay close to the idle
# silhouette. A wider arm reads as a navy slab at this size and buries the white
# torso side panels, which are an identity anchor.
LIMB_THICKNESS = 3
POSES = (
    {"hands": ((40, 76), (54, 76)), "fingers": 0, "elbow_out": 2},
    {"hands": ((47, 72),), "fingers": 2, "elbow_out": 3},
    {"hands": ((47, 69),), "fingers": 5, "elbow_out": 4},
    {"hands": ((47, 68),), "fingers": 6, "elbow_out": 4},
)


def clean_transparency(image: Image.Image) -> Image.Image:
    pixels = [pixel if pixel[3] else TRANSPARENT for pixel in image.convert("RGBA").get_flattened_data()]
    output = Image.new("RGBA", image.size, TRANSPARENT)
    output.putdata(pixels)
    return output


def thick_line(start: tuple[int, int], end: tuple[int, int], thickness: int) -> set[tuple[int, int]]:
    """Stamps a square brush along a line, so limbs stay chunky and aliasing-free."""
    (x0, y0), (x1, y1) = start, end
    steps = max(abs(x1 - x0), abs(y1 - y0), 1)
    radius = thickness // 2
    points: set[tuple[int, int]] = set()
    for step in range(steps + 1):
        x = round(x0 + (x1 - x0) * step / steps)
        y = round(y0 + (y1 - y0) * step / steps)
        for dx in range(-radius, thickness - radius):
            for dy in range(-radius, thickness - radius):
                points.add((x + dx, y + dy))
    return points


BLOB_TOP_OFFSET = -3
CLASPED_PROFILE = (3, 4, 4, 4, 4, 3, 2)
SINGLE_PROFILE = (2, 3, 3, 3, 2, 2, 1)


def hand_blob(center: tuple[int, int], wide: bool) -> set[tuple[int, int]]:
    cx, cy = center
    profile = CLASPED_PROFILE if wide else SINGLE_PROFILE
    points: set[tuple[int, int]] = set()
    for offset, half in enumerate(profile):
        y = cy + BLOB_TOP_OFFSET + offset
        for dx in range(-half, half + 1):
            points.add((cx + dx, y))
    return points


def seal_fingers(center: tuple[int, int], length: int) -> set[tuple[int, int]]:
    """Two raised finger pairs either side of a one-pixel gap."""
    if length <= 0:
        return set()
    _, cy = center
    bottom = cy + BLOB_TOP_OFFSET - 1
    points: set[tuple[int, int]] = set()
    for x in (CENTER_X - 2, CENTER_X - 1, CENTER_X + 1, CENTER_X + 2):
        for y in range(bottom - length + 1, bottom + 1):
            points.add((x, y))
    return points


def erase_arms(image: Image.Image) -> None:
    for y in ARM_ROWS:
        for columns in (LEFT_ARM_COLUMNS, RIGHT_ARM_COLUMNS):
            for x in columns:
                image.putpixel((x, y), TRANSPARENT)


def restore_torso_outline(image: Image.Image) -> None:
    """Re-darkens the torso edge the removed arms used to provide.

    Derived from whatever survives the erase rather than hard-coded, because the
    white side panels sit at a different column on almost every row.
    """
    for y in ARM_ROWS:
        opaque = [x for x in range(24, 74) if image.getpixel((x, y))[3]]
        if not opaque:
            continue
        left, right = min(opaque), max(opaque)
        if image.getpixel((left, y))[:3] != OUTLINE[:3]:
            image.putpixel((left - 1, y), OUTLINE)
        if image.getpixel((right, y))[:3] != OUTLINE[:3]:
            image.putpixel((right + 1, y), OUTLINE)


def compose_pose(image: Image.Image, pose: dict) -> None:
    hands = pose["hands"]
    elbow_out = pose["elbow_out"]
    wide = len(hands) == 1
    elbow_y = max(hand[1] for hand in hands) + 6

    sleeve: set[tuple[int, int]] = set()
    skin: set[tuple[int, int]] = set()

    left_hand = hands[0]
    right_hand = hands[-1]
    left_elbow = (SHOULDER_LEFT[0] - elbow_out, elbow_y)
    right_elbow = (SHOULDER_RIGHT[0] + elbow_out, elbow_y)

    # Wrists meet the palms from below and outside, so the forearms never lie
    # flat across the chest.
    sleeve |= thick_line(SHOULDER_LEFT, left_elbow, LIMB_THICKNESS)
    sleeve |= thick_line(left_elbow, (left_hand[0] - 4, left_hand[1] + 2), LIMB_THICKNESS)
    sleeve |= thick_line(SHOULDER_RIGHT, right_elbow, LIMB_THICKNESS)
    sleeve |= thick_line(right_elbow, (right_hand[0] + 4, right_hand[1] + 2), LIMB_THICKNESS)

    for hand in hands:
        skin |= hand_blob(hand, wide)
    skin |= seal_fingers(hands[0], pose["fingers"])

    limb = sleeve | skin
    outline = {
        (x + dx, y + dy)
        for x, y in limb
        for dx in (-1, 0, 1)
        for dy in (-1, 0, 1)
        if (x + dx, y + dy) not in limb
    }

    for point in outline:
        image.putpixel(point, OUTLINE)
    for point in sleeve - skin:
        # A darker lower edge keeps the forearm from reading as a flat slab.
        below = (point[0], point[1] + 1)
        image.putpixel(point, SLEEVE_SHADE if below in outline else SLEEVE)
    for point in skin:
        image.putpixel(point, SKIN)

    if wide and pose["fingers"] > 0:
        # The seam where the palms meet, running the full height of the cluster,
        # is what separates it into two hands rather than one mitten.
        cy = hands[0][1]
        top = cy + BLOB_TOP_OFFSET - pose["fingers"]
        for y in range(top, cy + BLOB_TOP_OFFSET + len(CLASPED_PROFILE)):
            image.putpixel((CENTER_X, y), OUTLINE)
        for y in range(cy - 1, cy + 2):
            image.putpixel((CENTER_X - 3, y), SKIN_SHADE)
            image.putpixel((CENTER_X + 3, y), SKIN_SHADE)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    args = parser.parse_args()

    contract_path = args.contract.resolve()
    contract = json.loads(contract_path.read_text())
    source = contract["source_base"]
    base_path = (contract_path.parent / source["path"]).resolve()
    digest = hashlib.sha256(base_path.read_bytes()).hexdigest()
    if digest != EXPECTED_BASE_SHA256:
        raise ValueError(f"frozen base hash mismatch: {digest}")

    frames_root = args.frames_root.resolve()
    idle = Image.open(frames_root / "idle" / "idle-00.png").convert("RGBA")
    if idle.size != tuple(contract["atlas"]["cell_pixel_size"]):
        raise ValueError("approved idle cell size does not match the atlas contract")

    output_dir = frames_root / "hand-sign"
    output_dir.mkdir(parents=True, exist_ok=True)

    for index, pose in enumerate(POSES):
        frame = idle.copy()
        erase_arms(frame)
        restore_torso_outline(frame)
        compose_pose(frame, pose)
        clean_transparency(frame).save(output_dir / f"hand-sign-{index:02d}.png")

    report = {
        "state": "hand-sign",
        "method": "approved-idle-cell-with-redrawn-arms",
        "source_base_sha256": EXPECTED_BASE_SHA256,
        "body_source": "idle/idle-00.png",
        "frame_count": len(POSES),
        "frame_notes": [
            "hands lift from the hips with the elbows swinging out",
            "palms meet at the lower chest and the seal fingers start to rise",
            "seal formed at the chest with both finger pairs extended",
            "held seal, the frame the dismiss smoke covers",
        ],
    }
    (output_dir / "authoring.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"authored {len(POSES)} identity-preserving hand-sign frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
