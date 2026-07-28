#!/usr/bin/env python3
"""Validate the frozen Desktop Mascot atlas contract and an optional PNG atlas."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

from PIL import Image


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def parse_hex(value: str) -> tuple[int, int, int]:
    value = value.removeprefix("#")
    if len(value) != 6:
        raise ValueError(f"invalid RGB hex value: {value!r}")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))


def validate_contract(contract_path: Path) -> tuple[dict, list[str]]:
    errors: list[str] = []
    try:
        contract = json.loads(contract_path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        return {}, [f"cannot read contract: {exc}"]

    atlas = contract.get("atlas", {})
    columns = atlas.get("columns")
    rows = atlas.get("rows")
    cell_size = atlas.get("cell_pixel_size")
    atlas_size = atlas.get("pixel_size")
    if not all(isinstance(value, int) and value > 0 for value in (columns, rows)):
        fail("atlas rows and columns must be positive integers", errors)
    if not (isinstance(cell_size, list) and len(cell_size) == 2 and all(isinstance(value, int) and value > 0 for value in cell_size)):
        fail("cell_pixel_size must contain two positive integers", errors)
    if not (isinstance(atlas_size, list) and len(atlas_size) == 2 and all(isinstance(value, int) and value > 0 for value in atlas_size)):
        fail("pixel_size must contain two positive integers", errors)
    if not errors and atlas_size != [columns * cell_size[0], rows * cell_size[1]]:
        fail("atlas pixel_size does not equal grid multiplied by cell size", errors)

    row_specs = contract.get("rows", [])
    if len(row_specs) != rows:
        fail("row specification count does not match atlas rows", errors)
    states: set[str] = set()
    for expected_index, row in enumerate(row_specs):
        if row.get("index") != expected_index:
            fail(f"row {expected_index} has a non-contiguous index", errors)
        state = row.get("state")
        if not isinstance(state, str) or not state:
            fail(f"row {expected_index} has no state", errors)
        elif state in states:
            fail(f"duplicate state: {state}", errors)
        states.add(state)
        frames = row.get("frames")
        durations = row.get("durations_ms")
        if not isinstance(frames, int) or not 1 <= frames <= columns:
            fail(f"row {expected_index} frame count is outside the atlas width", errors)
        if not isinstance(durations, list) or len(durations) != frames:
            fail(f"row {expected_index} duration count does not match its frames", errors)
        elif any(value != "hold" and (not isinstance(value, int) or value <= 0) for value in durations):
            fail(f"row {expected_index} contains an invalid duration", errors)

    palette = contract.get("pixel_rules", {}).get("palette_hex", [])
    try:
        parsed_palette = {parse_hex(value) for value in palette}
    except (TypeError, ValueError) as exc:
        fail(str(exc), errors)
        parsed_palette = set()
    if len(parsed_palette) != 12:
        fail("the frozen palette must contain 12 unique RGB colors", errors)

    return contract, errors


def validate_source_base(contract_path: Path, contract: dict, errors: list[str]) -> None:
    source = contract["source_base"]
    source_path = (contract_path.parent / source["path"]).resolve()
    try:
        payload = source_path.read_bytes()
    except OSError as exc:
        fail(f"cannot read frozen source base: {exc}", errors)
        return
    digest = hashlib.sha256(payload).hexdigest()
    if digest != source["sha256"]:
        fail(f"frozen source base hash mismatch: {digest}", errors)
    with Image.open(source_path) as image:
        if list(image.size) != source["pixel_size"]:
            fail(f"frozen source base size mismatch: {image.size}", errors)


def validate_atlas(atlas_path: Path, contract: dict, errors: list[str]) -> None:
    atlas_spec = contract["atlas"]
    cell_width, cell_height = atlas_spec["cell_pixel_size"]
    columns = atlas_spec["columns"]
    allowed_palette = {parse_hex(value) for value in contract["pixel_rules"]["palette_hex"]}
    allowed_alpha = set(contract["pixel_rules"]["alpha_values"])
    transparent_rgb = tuple(contract["pixel_rules"]["transparent_rgb"])
    left, top, right, bottom = contract["bounds"]["opaque_guard_inclusive"]

    try:
        image = Image.open(atlas_path).convert("RGBA")
    except OSError as exc:
        fail(f"cannot read atlas: {exc}", errors)
        return
    if list(image.size) != atlas_spec["pixel_size"]:
        fail(f"atlas size mismatch: {image.size}", errors)
        return

    pixels = list(image.get_flattened_data())
    alpha_values = {pixel[3] for pixel in pixels}
    if not alpha_values <= allowed_alpha:
        fail(f"atlas contains unsupported alpha values: {sorted(alpha_values - allowed_alpha)}", errors)
    opaque_colors = {pixel[:3] for pixel in pixels if pixel[3] == 255}
    unexpected_colors = opaque_colors - allowed_palette
    if unexpected_colors:
        fail(f"atlas contains {len(unexpected_colors)} colors outside the frozen palette", errors)
    if any(pixel[:3] != transparent_rgb for pixel in pixels if pixel[3] == 0):
        fail("fully transparent atlas pixels retain non-zero RGB", errors)

    for row in contract["rows"]:
        row_index = row["index"]
        for column in range(columns):
            x0 = column * cell_width
            y0 = row_index * cell_height
            cell = image.crop((x0, y0, x0 + cell_width, y0 + cell_height))
            alpha = cell.getchannel("A")
            bounds = alpha.getbbox()
            used = column < row["frames"]
            if used and bounds is None:
                fail(f"{row['state']} frame {column} is empty", errors)
            if not used and bounds is not None:
                fail(f"{row['state']} unused cell {column} is not transparent", errors)
            if bounds is not None:
                cell_left, cell_top, cell_right, cell_bottom = bounds
                if cell_left < left or cell_top < top or cell_right - 1 > right or cell_bottom - 1 > bottom:
                    fail(f"{row['state']} frame {column} crosses the opaque guard: {bounds}", errors)


def validate_frame_rows(frames_root: Path, states: list[str], contract: dict, errors: list[str]) -> None:
    specs = {row["state"]: row for row in contract["rows"]}
    allowed_palette = {parse_hex(value) for value in contract["pixel_rules"]["palette_hex"]}
    allowed_alpha = set(contract["pixel_rules"]["alpha_values"])
    transparent_rgb = tuple(contract["pixel_rules"]["transparent_rgb"])
    cell_size = tuple(contract["atlas"]["cell_pixel_size"])
    left, top, right, bottom = contract["bounds"]["opaque_guard_inclusive"]
    baseline_y = contract["anchor"]["baseline_y"]
    grounded_states = {"offline", "idle", "working", "ideating", "waiting", "success", "failure", "sleeping", "paused", "walk-right", "walk-left"}
    for state in states:
        spec = specs.get(state)
        if spec is None:
            fail(f"unknown frame state: {state}", errors)
            continue
        directory = frames_root / state
        expected_paths = [directory / f"{state}-{index:02d}.png" for index in range(spec["frames"])]
        for index, path in enumerate(expected_paths):
            if not path.exists():
                fail(f"missing {state} frame {index}: {path}", errors)
                continue
            image = Image.open(path).convert("RGBA")
            if image.size != cell_size:
                fail(f"{state} frame {index} size mismatch: {image.size}", errors)
                continue
            pixels = list(image.get_flattened_data())
            alpha_values = {pixel[3] for pixel in pixels}
            if not alpha_values <= allowed_alpha:
                fail(f"{state} frame {index} contains unsupported alpha", errors)
            if {pixel[:3] for pixel in pixels if pixel[3] == 255} - allowed_palette:
                fail(f"{state} frame {index} contains colors outside the frozen palette", errors)
            if any(pixel[:3] != transparent_rgb for pixel in pixels if pixel[3] == 0):
                fail(f"{state} frame {index} retains RGB under transparency", errors)
            bounds = image.getchannel("A").getbbox()
            if bounds is None:
                fail(f"{state} frame {index} is empty", errors)
                continue
            cell_left, cell_top, cell_right, cell_bottom = bounds
            if cell_left < left or cell_top < top or cell_right - 1 > right or cell_bottom - 1 > bottom:
                fail(f"{state} frame {index} crosses the opaque guard: {bounds}", errors)
            if state in grounded_states and cell_bottom - 1 != baseline_y:
                fail(f"{state} frame {index} misses baseline y={baseline_y}: {bounds}", errors)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--atlas", type=Path, help="optional assembled atlas PNG")
    parser.add_argument("--frames-root", type=Path, help="optional root containing normalized state frame folders")
    parser.add_argument("--states", nargs="+", help="states to validate under --frames-root")
    parser.add_argument("--contract-only", action="store_true", help="validate metadata and frozen base only")
    args = parser.parse_args()

    contract_path = args.contract.resolve()
    contract, errors = validate_contract(contract_path)
    if contract:
        validate_source_base(contract_path, contract, errors)
    if args.atlas and not args.contract_only and contract:
        validate_atlas(args.atlas.resolve(), contract, errors)
    if args.frames_root and contract:
        if not args.states:
            fail("pass --states with --frames-root", errors)
        else:
            validate_frame_rows(args.frames_root.resolve(), args.states, contract, errors)
    if not args.contract_only and not args.atlas and not args.frames_root:
        fail("pass --atlas, pass --frames-root with --states, or use --contract-only", errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    validated = ["contract"]
    if args.atlas:
        validated.append("atlas")
    if args.frames_root:
        validated.append("frame rows")
    mode = ", ".join(validated)
    print(f"OK: {mode} validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
