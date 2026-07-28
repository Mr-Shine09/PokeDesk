#!/usr/bin/env python3
"""Derive walk-left by mirroring each approved walk-right cell without reversing time."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageOps


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    parser.add_argument("--confirm-identity-safe", action="store_true")
    parser.add_argument("--decision-note", required=True)
    args = parser.parse_args()
    if not args.confirm_identity_safe:
        parser.error("pass --confirm-identity-safe after visual review")

    source_dir = args.frames_root / "walk-right"
    destination_dir = args.frames_root / "walk-left"
    source_paths = sorted(source_dir.glob("walk-right-*.png"))
    if len(source_paths) != 6:
        parser.error(f"expected 6 walk-right frames, found {len(source_paths)}")
    destination_dir.mkdir(parents=True, exist_ok=True)
    for index, source_path in enumerate(source_paths):
        source = Image.open(source_path).convert("RGBA")
        ImageOps.mirror(source).save(destination_dir / f"walk-left-{index:02d}.png")

    report = {
        "state": "walk-left",
        "derivation": "per-frame-horizontal-mirror",
        "source_state": "walk-right",
        "frame_order_preserved": True,
        "identity_safe_confirmed": True,
        "decision_note": args.decision_note,
    }
    (destination_dir / "normalization.json").write_text(json.dumps(report, indent=2) + "\n")
    print("derived 6 walk-left frames without reversing temporal order")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

