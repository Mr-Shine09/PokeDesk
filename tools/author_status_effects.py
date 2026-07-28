#!/usr/bin/env python3
"""Add the owner-approved native-pixel status effects without redrawing bodies."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw


TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (17, 18, 25, 255)
WHITE = (246, 243, 228, 255)
YELLOW = (255, 190, 75, 255)
GRAY = (181, 182, 184, 255)

Z_POINTS = {
    (0, 0), (1, 0), (2, 0), (3, 0),
    (2, 1), (1, 2),
    (0, 3), (1, 3), (2, 3), (3, 3),
}
STAR_POINTS = {
    (2, 0), (2, 1),
    (0, 2), (1, 2), (2, 2), (3, 2), (4, 2),
    (2, 3), (2, 4),
}


def clean_transparency(image: Image.Image) -> Image.Image:
    pixels = [pixel if pixel[3] else TRANSPARENT for pixel in image.convert("RGBA").get_flattened_data()]
    output = Image.new("RGBA", image.size, TRANSPARENT)
    output.putdata(pixels)
    return output


def clear_effect_area(image: Image.Image, through_y: int) -> Image.Image:
    output = clean_transparency(image)
    ImageDraw.Draw(output).rectangle((0, 0, output.width - 1, through_y), fill=TRANSPARENT)
    return output


def outlined_cluster(
    image: Image.Image,
    points: set[tuple[int, int]],
    origin: tuple[int, int],
    fill: tuple[int, int, int, int],
) -> None:
    ox, oy = origin
    translated = {(ox + x, oy + y) for x, y in points}
    outline = {
        (x + dx, y + dy)
        for x, y in translated
        for dx in (-1, 0, 1)
        for dy in (-1, 0, 1)
        if (x + dx, y + dy) not in translated
    }
    for point in outline:
        image.putpixel(point, OUTLINE)
    for point in translated:
        image.putpixel(point, fill)


def add_z_trail(image: Image.Image, count: int, positions: list[tuple[int, int]]) -> None:
    for index, position in enumerate(positions[:count]):
        outlined_cluster(image, Z_POINTS, position, WHITE if index != 1 else GRAY)


def add_clock(image: Image.Image, hand_index: int) -> None:
    draw = ImageDraw.Draw(image)
    draw.ellipse((40, 4, 56, 20), fill=OUTLINE)
    draw.ellipse((42, 6, 54, 18), fill=WHITE)
    draw.rectangle((47, 20, 49, 23), fill=OUTLINE)
    center = (48, 12)
    endpoints = ((48, 7), (53, 12), (48, 17), (43, 12))
    draw.line((center, endpoints[hand_index % len(endpoints)]), fill=OUTLINE, width=2)
    draw.point(center, fill=YELLOW)


def add_success_sparkles(image: Image.Image, frame_index: int) -> None:
    sequences = (
        (),
        ((66, 15),),
        ((66, 15), (76, 7)),
        ((62, 8), (74, 14), (84, 5)),
        ((62, 8), (79, 9)),
        ((62, 8), (74, 14), (84, 5)),
    )
    for index, origin in enumerate(sequences[frame_index]):
        outlined_cluster(image, STAR_POINTS, origin, WHITE if index == 1 else YELLOW)


def add_broken_bulb(image: Image.Image, frame_index: int) -> None:
    draw = ImageDraw.Draw(image)
    fill = WHITE if frame_index in (1, 4) else YELLOW
    draw.ellipse((41, 4, 55, 18), fill=OUTLINE)
    draw.ellipse((43, 6, 53, 16), fill=fill)
    draw.rectangle((45, 16, 51, 19), fill=OUTLINE)
    draw.rectangle((46, 20, 50, 22), fill=GRAY)
    draw.line(((49, 5), (46, 10), (50, 12), (47, 17)), fill=OUTLINE, width=2)
    if frame_index in (1, 4):
        draw.point((38, 10), fill=YELLOW)
        draw.point((58, 8), fill=WHITE)


def load_body_frames(directory: Path, state: str, count: int, effect_top: int) -> list[Image.Image]:
    frames = []
    for index in range(count):
        path = directory / f"{state}-{index:02d}.png"
        image = clear_effect_area(Image.open(path).convert("RGBA"), effect_top - 1)
        bounds = image.getchannel("A").getbbox()
        if bounds is None or bounds[1] < effect_top:
            raise ValueError(f"{state} frame {index} body enters reserved effect area: {bounds}")
        frames.append(image)
    return frames


def save_frames(directory: Path, state: str, frames: list[Image.Image], report: dict) -> None:
    for index, image in enumerate(frames):
        clean_transparency(image).save(directory / f"{state}-{index:02d}.png")
    report = {"state": state, "frame_count": len(frames), **report}
    (directory / "effects.json").write_text(json.dumps(report, indent=2) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--frames-root", type=Path, default=Path("art/animation/frames"))
    args = parser.parse_args()
    root = args.frames_root.resolve()

    offline_dir = root / "offline"
    offline_body = load_body_frames(offline_dir, "offline", 2, 25)
    offline = [offline_body[0].copy(), offline_body[1].copy(), offline_body[0].copy(), offline_body[1].copy()]
    for frame, count in zip(offline, (0, 1, 2, 3)):
        add_z_trail(frame, count, [(65, 18), (75, 11), (85, 5)])
    save_frames(offline_dir, "offline", offline, {"effect": "rising-Z-trail", "body_frames": [0, 1, 0, 1]})

    sleeping_dir = root / "sleeping"
    sleeping_body = load_body_frames(sleeping_dir, "sleeping", 4, 64)
    sleeping_map = [0, 1, 2, 3, 2, 1]
    sleeping = [sleeping_body[index].copy() for index in sleeping_map]
    for frame, count in zip(sleeping, (0, 1, 2, 3, 2, 1)):
        add_z_trail(frame, count, [(58, 54), (69, 42), (81, 29)])
    save_frames(sleeping_dir, "sleeping", sleeping, {"effect": "rising-and-fading-Z-trail", "body_frames": sleeping_map})

    waiting_dir = root / "waiting"
    waiting = load_body_frames(waiting_dir, "waiting", 4, 25)
    for index, frame in enumerate(waiting):
        add_clock(frame, index)
    save_frames(waiting_dir, "waiting", waiting, {"effect": "clock", "hand_sequence": ["12", "3", "6", "9"]})

    success_dir = root / "success"
    success = load_body_frames(success_dir, "success", 6, 25)
    for index, frame in enumerate(success):
        add_success_sparkles(frame, index)
    save_frames(success_dir, "success", success, {"effect": "stars-and-sparkles", "bounded_above_head": True})

    failure_dir = root / "failure"
    failure = load_body_frames(failure_dir, "failure", 6, 25)
    for index, frame in enumerate(failure):
        add_broken_bulb(frame, index)
    save_frames(failure_dir, "failure", failure, {"effect": "broken-light-bulb", "crack_visible": True})

    print("authored offline, sleeping, waiting, success, and failure effects")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
