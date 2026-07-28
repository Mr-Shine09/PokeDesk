#!/usr/bin/env python3
"""Derive a directional animation by mirroring cells without reversing time."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageOps


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    parser.add_argument("--source-state", required=True)
    parser.add_argument("--destination-state", required=True)
    parser.add_argument("--frames", type=int, required=True)
    parser.add_argument("--decision-note", required=True)
    args = parser.parse_args()

    source_dir = args.frames_root / args.source_state
    destination_dir = args.frames_root / args.destination_state
    source_paths = [source_dir / f"{args.source_state}-{index:02d}.png" for index in range(args.frames)]
    missing = [path for path in source_paths if not path.exists()]
    if missing:
        parser.error(f"missing source frames: {', '.join(str(path) for path in missing)}")

    destination_dir.mkdir(parents=True, exist_ok=True)
    for index, source_path in enumerate(source_paths):
        source = Image.open(source_path).convert("RGBA")
        ImageOps.mirror(source).save(destination_dir / f"{args.destination_state}-{index:02d}.png")

    report = {
        "state": args.destination_state,
        "derivation": "per-frame-horizontal-mirror",
        "source_state": args.source_state,
        "frame_order_preserved": True,
        "decision_note": args.decision_note,
    }
    (destination_dir / "normalization.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"derived {args.frames} {args.destination_state} frames without reversing temporal order")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
