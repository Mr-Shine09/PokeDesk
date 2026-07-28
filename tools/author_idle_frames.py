#!/usr/bin/env python3
"""Author the four-frame idle blink from the exact frozen base sprite."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


EXPECTED_BASE_SHA256 = "954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6"
WHITE = (246, 243, 228, 255)
SKIN = (255, 190, 75, 255)
OUTLINE = (17, 18, 25, 255)

LENS_HIGHLIGHTS = {
    (32, 21), (33, 21),
    (31, 22), (32, 22),
    (31, 23), (32, 23),
    (31, 24), (32, 24),
    (40, 21),
    (39, 22),
    (39, 23),
    (39, 24),
}
BLINK_LINE = {(31, 23), (32, 23), (39, 23)}


def verify_base(path: Path, image: Image.Image) -> None:
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest != EXPECTED_BASE_SHA256:
        raise ValueError(f"frozen base hash mismatch: {digest}")
    if image.size != (80, 80):
        raise ValueError(f"frozen base size mismatch: {image.size}")
    for point in LENS_HIGHLIGHTS:
        if image.getpixel(point) != WHITE:
            raise ValueError(f"unexpected lens pixel at {point}: {image.getpixel(point)}")


def half_blink(base: Image.Image) -> Image.Image:
    frame = base.copy()
    for point in LENS_HIGHLIGHTS:
        if point[1] >= 23:
            frame.putpixel(point, SKIN)
    for point in BLINK_LINE:
        frame.putpixel(point, OUTLINE)
    return frame


def full_blink(base: Image.Image) -> Image.Image:
    frame = base.copy()
    for point in LENS_HIGHLIGHTS:
        frame.putpixel(point, SKIN)
    for point in BLINK_LINE:
        frame.putpixel(point, OUTLINE)
    return frame


def place_in_cell(sprite: Image.Image, cell_size: tuple[int, int], offset: tuple[int, int]) -> Image.Image:
    cell = Image.new("RGBA", cell_size, (0, 0, 0, 0))
    cell.alpha_composite(sprite, offset)
    return cell


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--output-dir", type=Path, default=Path("art/animation/frames/idle"))
    args = parser.parse_args()

    contract_path = args.contract.resolve()
    contract = json.loads(contract_path.read_text())
    source = contract["source_base"]
    base_path = (contract_path.parent / source["path"]).resolve()
    base = Image.open(base_path).convert("RGBA")
    verify_base(base_path, base)

    sprites = [base.copy(), half_blink(base), full_blink(base), base.copy()]
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    cell_size = tuple(contract["atlas"]["cell_pixel_size"])
    offset = tuple(source["cell_offset"])
    for index, sprite in enumerate(sprites):
        place_in_cell(sprite, cell_size, offset).save(output_dir / f"idle-{index:02d}.png")

    report = {
        "state": "idle",
        "method": "native-pixel-lens-interior-edit",
        "source_base": str(base_path),
        "source_sha256": EXPECTED_BASE_SHA256,
        "frame_count": 4,
        "cell_offset": offset,
        "identity_invariants": [
            "silhouette unchanged",
            "glasses outline unchanged",
            "hair unchanged",
            "clothing unchanged",
            "anchor and baseline unchanged",
        ],
        "frame_notes": [
            "exact frozen base",
            "half blink; lower lens interiors only",
            "full blink; lens interiors only",
            "exact frozen base",
        ],
    }
    (output_dir / "authoring.json").write_text(json.dumps(report, indent=2) + "\n")
    print("authored 4 identity-preserving idle frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

