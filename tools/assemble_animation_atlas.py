#!/usr/bin/env python3
"""Assemble normalized state cells into the frozen production atlas."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    parser.add_argument("--output", type=Path, default=Path("art/animation/mascot-atlas@2x.png"))
    args = parser.parse_args()

    contract = json.loads(args.contract.read_text())
    frames_root = args.frames_root.resolve()
    atlas_size = tuple(contract["atlas"]["pixel_size"])
    cell_width, cell_height = contract["atlas"]["cell_pixel_size"]
    atlas = Image.new("RGBA", atlas_size, (0, 0, 0, 0))
    frame_hashes: dict[str, str] = {}

    for row in contract["rows"]:
        state = row["state"]
        for column in range(row["frames"]):
            path = frames_root / state / f"{state}-{column:02d}.png"
            if not path.exists():
                raise FileNotFoundError(f"missing atlas frame: {path}")
            cell = Image.open(path).convert("RGBA")
            if cell.size != (cell_width, cell_height):
                raise ValueError(f"cell size mismatch for {path}: {cell.size}")
            atlas.alpha_composite(cell, (column * cell_width, row["index"] * cell_height))
            frame_hashes[str(path.relative_to(frames_root))] = hashlib.sha256(path.read_bytes()).hexdigest()

    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output)
    manifest = {
        "asset": output.name,
        "pixel_size": list(atlas.size),
        "contract": str(args.contract),
        "frames_root": str(args.frames_root),
        "frame_sha256": frame_hashes,
    }
    output.with_suffix(".manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"assembled atlas: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
