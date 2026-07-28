#!/usr/bin/env python3
"""Repair the success one-shot so its fist-pump peak becomes a stable hold."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil


EXPECTED_SOURCE_HASHES = {
    "success-03.png": "21052959b1f602e1cdc031802c8fd23fc5546ac8380e757dad1e507cb79d78c0",
    "success-04.png": "38d2013947bbe824a6749feeb772f0cd4f35b3f79bbed495270de4baf0be0b29",
    "success-05.png": "0ed1a7b3a17a8029e4eb1fc95d6973409d6d8040c5c53017176ad865304ce281",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--row-dir", type=Path, default=Path("art/animation/frames/success"))
    args = parser.parse_args()

    row_dir = args.row_dir.resolve()
    peak = row_dir / "success-03.png"
    settling = row_dir / "success-04.png"
    hold = row_dir / "success-05.png"
    peak_hash = digest(peak)
    if peak_hash != EXPECTED_SOURCE_HASHES[peak.name]:
        raise ValueError(f"unexpected success peak frame: {peak_hash}")

    already_repaired = digest(settling) == peak_hash and digest(hold) == peak_hash
    if not already_repaired:
        for path in (settling, hold):
            actual = digest(path)
            expected = EXPECTED_SOURCE_HASHES[path.name]
            if actual != expected:
                raise ValueError(f"unexpected generated success frame {path.name}: {actual}")
        shutil.copyfile(peak, settling)
        shutil.copyfile(peak, hold)

    report = {
        "state": "success",
        "method": "freeze-generated-pump-peak",
        "source_peak": peak.name,
        "source_peak_sha256": peak_hash,
        "replaced_frames": [settling.name, hold.name],
        "reason": "prevent a down-up motion from reading as a second fist pump",
    }
    (row_dir / "repair.json").write_text(json.dumps(report, indent=2) + "\n")
    print("repaired success frames 4 and 5 as a stable peak hold")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
