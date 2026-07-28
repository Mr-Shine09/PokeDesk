#!/usr/bin/env python3
"""Render deterministic contact sheets and motion previews for available atlas rows."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw


LIGHT = (245, 245, 245, 255)
DARK = (28, 30, 34, 255)


def load_frames(frames_root: Path, state: str, count: int) -> list[Image.Image]:
    paths = [frames_root / state / f"{state}-{index:02d}.png" for index in range(count)]
    missing = [path for path in paths if not path.exists()]
    if missing:
        raise FileNotFoundError(f"missing {state} frames: {', '.join(str(path) for path in missing)}")
    return [Image.open(path).convert("RGBA") for path in paths]


def composite(frame: Image.Image, background: tuple[int, int, int, int], scale: int) -> Image.Image:
    tile = Image.new("RGBA", frame.size, background)
    tile.alpha_composite(frame)
    return tile.resize((frame.width * scale, frame.height * scale), Image.Resampling.NEAREST)


def render_contact_sheet(rows: list[tuple[dict, list[Image.Image]]], output: Path, scale: int) -> None:
    cell_width, cell_height = rows[0][1][0].size
    label_width = 120
    columns = max(len(frames) for _, frames in rows)
    row_height = cell_height * scale
    sheet = Image.new("RGBA", (label_width + columns * cell_width * scale, len(rows) * row_height * 2), DARK)
    draw = ImageDraw.Draw(sheet)
    for row_index, (spec, frames) in enumerate(rows):
        for background_index, background in enumerate((LIGHT, DARK)):
            y = (row_index * 2 + background_index) * row_height
            draw.rectangle((0, y, label_width, y + row_height), fill=background)
            label_color = (20, 20, 20, 255) if background == LIGHT else (245, 245, 245, 255)
            draw.text((8, y + 8), spec["state"], fill=label_color)
            for column, frame in enumerate(frames):
                sheet.alpha_composite(composite(frame, background, scale), (label_width + column * cell_width * scale, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def render_contract_sheet(
    rows: list[tuple[dict, list[Image.Image]]],
    output: Path,
    scale: int,
    background: tuple[int, int, int, int],
    columns: int,
) -> None:
    cell_width, cell_height = rows[0][1][0].size
    label_width = 120
    sheet = Image.new(
        "RGBA",
        (label_width + columns * cell_width * scale, len(rows) * cell_height * scale),
        background,
    )
    draw = ImageDraw.Draw(sheet)
    label_color = (20, 20, 20, 255) if background == LIGHT else (245, 245, 245, 255)
    for row_index, (spec, frames) in enumerate(rows):
        y = row_index * cell_height * scale
        draw.text((8, y + 8), spec["state"], fill=label_color)
        for column, frame in enumerate(frames):
            sheet.alpha_composite(
                composite(frame, background, scale),
                (label_width + column * cell_width * scale, y),
            )
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def render_silhouettes(rows: list[tuple[dict, list[Image.Image]]], output: Path, scale: int) -> None:
    cell_width, cell_height = rows[0][1][0].size
    columns = max(len(frames) for _, frames in rows)
    sheet = Image.new("RGBA", (columns * cell_width * scale, len(rows) * cell_height * scale), (255, 255, 255, 255))
    for row_index, (_, frames) in enumerate(rows):
        for column, frame in enumerate(frames):
            alpha = frame.getchannel("A")
            silhouette = Image.new("RGBA", frame.size, (0, 0, 0, 0))
            silhouette.paste((0, 0, 0, 255), mask=alpha)
            silhouette = silhouette.resize((cell_width * scale, cell_height * scale), Image.Resampling.NEAREST)
            sheet.alpha_composite(silhouette, (column * cell_width * scale, row_index * cell_height * scale))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def render_previews(rows: list[tuple[dict, list[Image.Image]]], output_dir: Path, scale: int) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for spec, frames in rows:
        rendered = [composite(frame, DARK, scale).convert("P", palette=Image.Palette.ADAPTIVE) for frame in frames]
        durations = [1000 if value == "hold" else value for value in spec["durations_ms"]]
        rendered[0].save(
            output_dir / f"{spec['state']}.gif",
            save_all=True,
            append_images=rendered[1:],
            duration=durations,
            loop=0,
            disposal=2,
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    parser.add_argument("--output-dir", type=Path, default=Path("art/animation/qa"))
    parser.add_argument("--states", nargs="+", required=True)
    parser.add_argument("--scale", type=int, default=4)
    parser.add_argument("--full-contract", action="store_true")
    args = parser.parse_args()

    contract = json.loads(args.contract.read_text())
    specs = {row["state"]: row for row in contract["rows"]}
    unknown = [state for state in args.states if state not in specs]
    if unknown:
        parser.error(f"states not in contract: {', '.join(unknown)}")
    rows = [(specs[state], load_frames(args.frames_root, state, specs[state]["frames"])) for state in args.states]
    render_contact_sheet(rows, args.output_dir / "contact-sheet-candidate.png", args.scale)
    render_silhouettes(rows, args.output_dir / "silhouette-sheet-candidate.png", args.scale)
    render_previews(rows, args.output_dir / "previews", args.scale)
    if args.full_contract:
        expected_states = [row["state"] for row in contract["rows"]]
        if args.states != expected_states:
            parser.error("--full-contract requires every state in contract row order")
        columns = contract["atlas"]["columns"]
        for background_name, background in (("light", LIGHT), ("dark", DARK)):
            render_contract_sheet(
                rows,
                args.output_dir / f"contact-sheet-backing-1x-{background_name}.png",
                1,
                background,
                columns,
            )
            render_contract_sheet(
                rows,
                args.output_dir / f"contact-sheet-inspection-8x-{background_name}.png",
                8,
                background,
                columns,
            )
    print(f"rendered QA for {', '.join(args.states)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
