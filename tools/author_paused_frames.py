#!/usr/bin/env python3
"""Author the two-frame paused intro/hold from approved idle cells."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


EXPECTED_BASE_SHA256 = "954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6"


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
    idle_half_blink = Image.open(frames_root / "idle" / "idle-01.png").convert("RGBA")
    idle_neutral = Image.open(frames_root / "idle" / "idle-00.png").convert("RGBA")
    expected_size = tuple(contract["atlas"]["cell_pixel_size"])
    if idle_half_blink.size != expected_size or idle_neutral.size != expected_size:
        raise ValueError("approved idle cell size does not match the atlas contract")

    output_dir = frames_root / "paused"
    output_dir.mkdir(parents=True, exist_ok=True)
    idle_half_blink.save(output_dir / "paused-00.png")
    idle_neutral.save(output_dir / "paused-01.png")

    report = {
        "state": "paused",
        "method": "approved-idle-cell-reuse",
        "source_base_sha256": EXPECTED_BASE_SHA256,
        "frame_count": 2,
        "frame_notes": [
            "approved idle half-blink settles the pose",
            "exact approved idle neutral frame is held with the timer stopped",
        ],
    }
    (output_dir / "authoring.json").write_text(json.dumps(report, indent=2) + "\n")
    print("authored 2 identity-preserving paused frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
