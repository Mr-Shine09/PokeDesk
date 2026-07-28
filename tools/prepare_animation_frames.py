#!/usr/bin/env python3
"""Create the frozen anchor frame or normalize a generated row into atlas cells."""

from __future__ import annotations

import argparse
from collections import Counter, deque
import json
from pathlib import Path

from PIL import Image


def rgb_from_hex(value: str) -> tuple[int, int, int]:
    value = value.removeprefix("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))


def image_from_pixels(size: tuple[int, int], pixels: list[tuple[int, int, int, int]]) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    image.putdata(pixels)
    return image


def normalize_transparency(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    return Image.new("RGBA", rgba.size, (0, 0, 0, 0)) if not rgba.getbbox() else image_from_pixels(
        rgba.size,
        [(red, green, blue, alpha) if alpha else (0, 0, 0, 0) for red, green, blue, alpha in rgba.get_flattened_data()],
    )


def sample_key(image: Image.Image) -> tuple[int, int, int]:
    rgb = image.convert("RGB")
    width, height = rgb.size
    border = []
    border.extend(rgb.crop((0, 0, width, 1)).get_flattened_data())
    border.extend(rgb.crop((0, height - 1, width, height)).get_flattened_data())
    border.extend(rgb.crop((0, 0, 1, height)).get_flattened_data())
    border.extend(rgb.crop((width - 1, 0, width, height)).get_flattened_data())
    return Counter(border).most_common(1)[0][0]


def color_distance_squared(first: tuple[int, int, int], second: tuple[int, int, int]) -> int:
    return sum((left - right) ** 2 for left, right in zip(first, second))


def remove_border_key(image: Image.Image, tolerance: int) -> Image.Image:
    rgb = image.convert("RGB")
    width, height = rgb.size
    key = sample_key(rgb)
    limit = tolerance * tolerance
    background = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def eligible(x: int, y: int) -> bool:
        return not background[y * width + x] and color_distance_squared(rgb.getpixel((x, y)), key) <= limit

    for x in range(width):
        for y in (0, height - 1):
            if eligible(x, y):
                background[y * width + x] = 1
                queue.append((x, y))
    for y in range(height):
        for x in (0, width - 1):
            if eligible(x, y):
                background[y * width + x] = 1
                queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        for next_x, next_y in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= next_x < width and 0 <= next_y < height and eligible(next_x, next_y):
                background[next_y * width + next_x] = 1
                queue.append((next_x, next_y))

    pixels = []
    for index, color in enumerate(rgb.get_flattened_data()):
        pixels.append((0, 0, 0, 0) if background[index] else (*color, 255))
    return image_from_pixels(rgb.size, pixels)


def keep_significant_components(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    alpha = rgba.getchannel("A")
    seen: set[tuple[int, int]] = set()
    components: list[list[tuple[int, int]]] = []
    for y in range(height):
        for x in range(width):
            if alpha.getpixel((x, y)) == 0 or (x, y) in seen:
                continue
            component: list[tuple[int, int]] = []
            queue = deque([(x, y)])
            seen.add((x, y))
            while queue:
                point = queue.popleft()
                component.append(point)
                px, py = point
                for neighbor in ((px - 1, py), (px + 1, py), (px, py - 1), (px, py + 1)):
                    nx, ny = neighbor
                    if 0 <= nx < width and 0 <= ny < height and neighbor not in seen and alpha.getpixel(neighbor):
                        seen.add(neighbor)
                        queue.append(neighbor)
            components.append(component)
    if not components:
        raise ValueError("frame contains no foreground component")
    largest_size = max(len(component) for component in components)
    minimum_size = max(4, round(largest_size * 0.005))
    retained = {
        point
        for component in components
        if len(component) >= minimum_size
        for point in component
    }
    pixels = []
    for y in range(height):
        for x in range(width):
            pixels.append(rgba.getpixel((x, y)) if (x, y) in retained else (0, 0, 0, 0))
    return image_from_pixels(rgba.size, pixels)


def quantize_to_palette(image: Image.Image, palette: list[tuple[int, int, int]]) -> Image.Image:
    pixels = []
    for red, green, blue, alpha in image.convert("RGBA").get_flattened_data():
        if alpha == 0:
            pixels.append((0, 0, 0, 0))
            continue
        nearest = min(palette, key=lambda color: color_distance_squared((red, green, blue), color))
        pixels.append((*nearest, 255))
    return image_from_pixels(image.size, pixels)


def create_anchor(contract: dict, contract_path: Path, output: Path) -> None:
    source = contract["source_base"]
    base_path = (contract_path.parent / source["path"]).resolve()
    base = normalize_transparency(Image.open(base_path))
    cell = Image.new("RGBA", tuple(contract["atlas"]["cell_pixel_size"]), (0, 0, 0, 0))
    cell.alpha_composite(base, tuple(source["cell_offset"]))
    output.parent.mkdir(parents=True, exist_ok=True)
    cell.save(output)


def process_strip(contract: dict, strip_path: Path, state: str, frame_count: int, output_root: Path, tolerance: int) -> None:
    source = Image.open(strip_path).convert("RGB")
    slot_width = source.width / frame_count
    extracted: list[Image.Image] = []
    bounds: list[tuple[int, int, int, int]] = []
    for index in range(frame_count):
        left = round(index * slot_width)
        right = round((index + 1) * slot_width)
        slot = source.crop((left, 0, right, source.height))
        keyed = keep_significant_components(remove_border_key(slot, tolerance))
        bbox = keyed.getchannel("A").getbbox()
        if bbox is None:
            raise ValueError(f"{state} frame {index} is empty after key removal")
        extracted.append(keyed.crop(bbox))
        bounds.append(bbox)

    normal_left, normal_top, normal_right, normal_bottom = contract["bounds"]["normal_body_inclusive"]
    maximum_width = normal_right - normal_left + 1
    maximum_height = normal_bottom - normal_top + 1
    scale = min(
        maximum_width / max(image.width for image in extracted),
        maximum_height / max(image.height for image in extracted),
    )
    if scale <= 0:
        raise ValueError("invalid shared row scale")

    palette = [rgb_from_hex(value) for value in contract["pixel_rules"]["palette_hex"]]
    anchor_x = contract["anchor"]["x"]
    baseline_y = contract["anchor"]["baseline_y"]
    cell_size = tuple(contract["atlas"]["cell_pixel_size"])
    destination = output_root / state
    destination.mkdir(parents=True, exist_ok=True)
    for index, image in enumerate(extracted):
        resized = image.resize(
            (max(1, round(image.width * scale)), max(1, round(image.height * scale))),
            Image.Resampling.NEAREST,
        )
        quantized = quantize_to_palette(resized, palette)
        cell = Image.new("RGBA", cell_size, (0, 0, 0, 0))
        x = round(anchor_x - quantized.width / 2)
        y = baseline_y - quantized.height + 1
        cell.alpha_composite(quantized, (x, y))
        cell.save(destination / f"{state}-{index:02d}.png")

    report = {
        "state": state,
        "source": str(strip_path.resolve()),
        "frames": frame_count,
        "source_slot_bounds": bounds,
        "shared_scale": scale,
        "output_root": str(destination.resolve()),
    }
    (destination / "normalization.json").write_text(json.dumps(report, indent=2) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", type=Path, default=Path("art/animation/atlas-contract.json"))
    parser.add_argument("--anchor-output", type=Path)
    parser.add_argument("--strip", type=Path)
    parser.add_argument("--state")
    parser.add_argument("--frames", type=int)
    parser.add_argument("--output-root", type=Path, default=Path("art/animation/frames"))
    parser.add_argument("--key-tolerance", type=int, default=48)
    args = parser.parse_args()

    contract_path = args.contract.resolve()
    contract = json.loads(contract_path.read_text())
    if args.anchor_output:
        create_anchor(contract, contract_path, args.anchor_output.resolve())
        print(f"wrote anchor fixture: {args.anchor_output.resolve()}")
        return 0
    if not (args.strip and args.state and args.frames):
        parser.error("pass --anchor-output, or pass --strip, --state, and --frames")
    row = next((item for item in contract["rows"] if item["state"] == args.state), None)
    if row is None:
        parser.error(f"state is not in the contract: {args.state}")
    if row["frames"] != args.frames:
        parser.error(f"frame count does not match contract: expected {row['frames']}")
    process_strip(contract, args.strip.resolve(), args.state, args.frames, args.output_root.resolve(), args.key_tolerance)
    print(f"wrote {args.frames} normalized {args.state} frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
