#!/usr/bin/env python3
"""Author the dismiss smoke-poof row as native pixel art.

The first version of this effect was code-rendered SwiftUI circles with a
Gaussian blur, following the summon portal. The owner asked for it pixelated to
match the mascot, and a blur cannot be pixelated after the fact — so the cloud
is authored here on the atlas grid instead, in the frozen palette, and plays as
a normal sprite row.

The cloud starts nearly full size. A smoke bomb is instant, and a cloud that
grows from a point leaves the mascot visible through smoke too thin to hide it.
Later frames billow, drift upward, and open holes rather than getting bigger.
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from PIL import Image


TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (17, 18, 25, 255)
RIM = (126, 128, 133, 255)
MID = (181, 182, 184, 255)
CORE = (246, 243, 228, 255)

CELL = (96, 112)
GUARD = (4, 4, 91, 107)
CENTER = (48, 62)

# Lobe layout at full size, as (dx, dy, radius) from CENTER. Many small
# perimeter lobes rather than a few large ones: the union's outline is what
# makes this read as a cloud, and a handful of big circles merges into one
# potato. Sized to cover the whole mascot — hair at y=25 through shoes at
# y=103 — not just the torso.
LOBES = (
    (0, 4, 24),
    (-19, -10, 18),
    (19, -8, 18),
    (-17, 20, 17),
    (18, 22, 17),
    (0, -30, 18),
    (0, 32, 16),
    (-27, 4, 13),
    (27, 6, 13),
    (13, -26, 13),
    (-14, -24, 13),
    (-24, 22, 12),
    (25, 24, 12),
    (14, 34, 12),
    (-15, 32, 12),
)

# One entry per frame: overall scale, how far the cloud has drifted upward, a
# rotation of the lobe ring that makes it churn, and how far the lobes push
# apart as it dissipates.
#
# Nothing punches holes through the middle. An earlier version did, and hard
# round gaps in a cloud read as slices of cheese; worse, they are exactly where
# the mascot was standing. The cloud breaks up from its edges instead, and the
# layer's opacity fade finishes the job.
FRAMES = (
    {"scale": 0.88, "rise": 0, "churn": 0.00, "spread": 1.00},
    {"scale": 0.96, "rise": 1, "churn": 0.18, "spread": 1.00},
    {"scale": 1.00, "rise": 2, "churn": 0.36, "spread": 1.00},
    {"scale": 1.00, "rise": 4, "churn": 0.54, "spread": 1.02},
    {"scale": 0.99, "rise": 7, "churn": 0.72, "spread": 1.06},
    {"scale": 0.97, "rise": 10, "churn": 0.90, "spread": 1.11},
    {"scale": 0.94, "rise": 14, "churn": 1.08, "spread": 1.17},
    {"scale": 0.90, "rise": 18, "churn": 1.26, "spread": 1.24},
)


def placed_lobes(spec: dict) -> list[tuple[float, float, float]]:
    scale, rise, churn, spread = spec["scale"], spec["rise"], spec["churn"], spec["spread"]
    # Rotating the ring is what makes consecutive frames read as one churning
    # cloud rather than as the same shape scaled.
    angle = churn * 0.30
    lobes = []
    for dx, dy, radius in LOBES:
        rotated_x = dx * math.cos(angle) - dy * math.sin(angle)
        rotated_y = dx * math.sin(angle) + dy * math.cos(angle)
        lobes.append((
            CENTER[0] + rotated_x * scale * spread,
            CENTER[1] + rotated_y * scale * spread - rise,
            radius * scale,
        ))
    return lobes


def render(spec: dict) -> Image.Image:
    """Shades each lobe by its own roundness, not by the union's.

    This is what separates a cloud from a blob: every puff keeps a bright centre
    and a gray edge, so overlapping puffs still read as distinct volumes. A
    single depth field over the union flattens them into one mass.
    """
    lobes = placed_lobes(spec)
    left, top, right, bottom = GUARD

    field: dict[tuple[int, int], float] = {}
    for cx, cy, radius in lobes:
        for y in range(max(top, int(cy - radius) - 1), min(bottom, int(cy + radius) + 1) + 1):
            for x in range(max(left, int(cx - radius) - 1), min(right, int(cx + radius) + 1) + 1):
                distance = math.hypot(x - cx, y - cy)
                if distance <= radius:
                    depth = 1 - distance / radius
                    if depth > field.get((x, y), 0):
                        field[(x, y)] = depth

    image = Image.new("RGBA", CELL, TRANSPARENT)
    for (x, y), depth in field.items():
        on_edge = any(
            (x + dx, y + dy) not in field
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
        )
        if on_edge:
            color = OUTLINE
        elif depth < 0.17:
            color = RIM
        elif depth < 0.44:
            color = MID
        else:
            color = CORE
        image.putpixel((x, y), color)
    return image


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    args = parser.parse_args()

    output_dir = args.frames_root.resolve() / "poof"
    output_dir.mkdir(parents=True, exist_ok=True)

    for index, spec in enumerate(FRAMES):
        frame = render(spec)
        bounds = frame.getchannel("A").getbbox()
        if bounds is None:
            raise ValueError(f"poof frame {index} is empty")
        frame.save(output_dir / f"poof-{index:02d}.png")

    report = {
        "state": "poof",
        "method": "authored-native-pixel-cloud",
        "frame_count": len(FRAMES),
        "palette": ["#111219", "#7E8085", "#B5B6B8", "#F6F3E4"],
        "frame_notes": [
            "burst, already near full size so nothing shows through",
            "expanding",
            "full size",
            "churning",
            "churning and drifting upward",
            "lobes starting to separate",
            "breaking up from the edges",
            "loosest; the layer fade finishes the disappearance",
        ],
    }
    (output_dir / "authoring.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"authored {len(FRAMES)} poof frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
