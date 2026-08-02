#!/usr/bin/env python3
"""Render the Dock Pet app icon set from the frozen mascot base.

The icon is a headshot of the same character the atlas is built from, so it is
cropped straight out of the frozen production base rather than redrawn. Sizes at
64px and above land on an exact integer scale of the source pixels and use
nearest-neighbor, keeping the grid crisp. The 16px and 32px variants cannot hold
that grid at all, so they are resampled from the 1024px master; a nearest
neighbor version of them is illegible rather than faithful.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


EXPECTED_BASE_SHA256 = "954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6"

# Head, glasses, hair, and the top of the navy collar, in frozen-base pixels.
HEAD_CROP = (21, 0, 60, 38)

MASTER = 1024
# Apple's icon grid: the rounded shape sits inside a margin, it does not fill the
# canvas.
SHAPE_INSET = 100
CORNER_RADIUS = 185
HEAD_WIDTH_AT_MASTER = 624

# Both from the frozen 12-color palette, so the icon and the mascot read as one
# thing.
BACKGROUND_TOP = (246, 243, 228)
BACKGROUND_BOTTOM = (255, 190, 75)

# One entry per macOS slot. Sizes are in pixels; the point size and scale are
# what the asset catalog records.
SLOTS = (
    (16, "16x16", "1x"),
    (32, "16x16", "2x"),
    (32, "32x32", "1x"),
    (64, "32x32", "2x"),
    (128, "128x128", "1x"),
    (256, "128x128", "2x"),
    (256, "256x256", "1x"),
    (512, "256x256", "2x"),
    (512, "512x512", "1x"),
    (1024, "512x512", "2x"),
)


def rounded_mask(size: int, inset: int, radius: int) -> Image.Image:
    """Draws the shape oversized and shrinks it, so the corners are not jagged."""
    supersample = 4
    mask = Image.new("L", (size * supersample, size * supersample), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (
            inset * supersample,
            inset * supersample,
            (size - inset) * supersample - 1,
            (size - inset) * supersample - 1,
        ),
        radius=radius * supersample,
        fill=255,
    )
    return mask.resize((size, size), Image.LANCZOS)


def vertical_gradient(size: int) -> Image.Image:
    gradient = Image.new("RGB", (1, size))
    for y in range(size):
        blend = y / max(1, size - 1)
        gradient.putpixel(
            (0, y),
            tuple(
                round(top + (bottom - top) * blend)
                for top, bottom in zip(BACKGROUND_TOP, BACKGROUND_BOTTOM)
            ),
        )
    return gradient.resize((size, size), Image.BILINEAR)


def render(size: int, head: Image.Image) -> Image.Image:
    scale = size / MASTER
    inset = round(SHAPE_INSET * scale)
    radius = round(CORNER_RADIUS * scale)
    head_width = round(HEAD_WIDTH_AT_MASTER * scale)
    factor, remainder = divmod(head_width, head.width)
    if remainder or factor < 1:
        raise ValueError(f"size {size} does not land on an integer head scale")

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shape = vertical_gradient(size).convert("RGBA")
    shape.putalpha(rounded_mask(size, inset, radius))

    # A soft contact shadow, so the icon sits on light Finder backgrounds the way
    # a stock macOS icon does.
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow.paste((17, 18, 25, 90), (0, 0), rounded_mask(size, inset, radius))
    shadow = shadow.filter(ImageFilter.GaussianBlur(max(1, size / 96)))
    canvas.alpha_composite(shadow, (0, max(1, round(size / 100))))
    canvas.alpha_composite(shape)

    scaled = head.resize((head.width * factor, head.height * factor), Image.NEAREST)
    canvas.alpha_composite(
        scaled,
        ((size - scaled.width) // 2, (size - scaled.height) // 2 + round(size / 64)),
    )
    return canvas


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base",
        type=Path,
        default=Path("art/production/mascot-base-chibi-40pt-at2x-80px-final.png"),
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("DesktopMascot/App/Assets.xcassets/AppIcon.appiconset"),
    )
    args = parser.parse_args()

    base_path = args.base.resolve()
    digest = hashlib.sha256(base_path.read_bytes()).hexdigest()
    if digest != EXPECTED_BASE_SHA256:
        raise ValueError(f"frozen base hash mismatch: {digest}")

    head = Image.open(base_path).convert("RGBA").crop(HEAD_CROP)
    if head.getchannel("A").getbbox() is None:
        raise ValueError("head crop is empty")

    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    master = render(MASTER, head)

    images = []
    written: dict[str, str] = {}
    for size, point_size, scale in SLOTS:
        filename = f"icon-{size}.png"
        path = output_dir / filename
        if filename not in written:
            try:
                icon = render(size, head)
            except ValueError:
                # Below 64px the source grid cannot survive; resample the master.
                icon = master.resize((size, size), Image.LANCZOS)
            icon.save(path)
            written[filename] = hashlib.sha256(path.read_bytes()).hexdigest()
        images.append({"filename": filename, "idiom": "mac", "scale": scale, "size": point_size})

    contents = {"images": images, "info": {"author": "xcode", "version": 1}}
    (output_dir / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")

    catalog_root = output_dir.parent
    (catalog_root / "Contents.json").write_text(
        json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n"
    )

    print(f"rendered {len(written)} app icon images into {output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
