#!/usr/bin/env python3
"""Generate Dock Pet's success and failure cues as deterministic chiptune WAVs.

Why synthesis rather than sourced audio: the mascot is authored pixel by pixel
from committed tooling, and its sound should come from the same place. Recorded
or downloaded audio would add a licensing question and a binary nobody in this
repository can regenerate or explain. Everything here is a square wave, an
envelope, and a note list, so a reviewer can read what the cue does before
playing it, and re-running this script reproduces the files byte for byte.

Square waves are deliberate: they are the timbre of the 8-bit era the sprite
belongs to, and they stay legible at low volume over a laptop speaker.

    python3 tools/author_sound_effects.py

Writes art/audio/success.wav, failure.wav, summon.wav, and dismiss.wav.
"""

from __future__ import annotations

import argparse
import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
# Well below full scale. This plays unprompted whenever an agent turn ends, so
# it has to read as a notification chime rather than an alert.
PEAK = 0.22

# Equal temperament from A4, so the note names below stay readable.
def note(name: str) -> float:
    steps = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    letter, accidental, octave = name[0], name[1:-1], int(name[-1])
    semitone = steps[letter] + (1 if accidental == "#" else -1 if accidental == "b" else 0)
    return 440.0 * (2 ** (semitone / 12 + (octave - 4)))


def square(frequency: float, seconds: float, duty: float = 0.5) -> list[float]:
    """One square-wave tone with a short fade in and an exponential decay.

    The fade removes the click a hard edge produces at the start of a sample;
    the decay is what makes a stack of tones read as one plucked cue instead of
    a chord held flat.
    """
    count = int(SAMPLE_RATE * seconds)
    samples = []
    attack = max(1, int(SAMPLE_RATE * 0.004))
    for index in range(count):
        phase = (index * frequency / SAMPLE_RATE) % 1.0
        value = 1.0 if phase < duty else -1.0
        progress = index / count
        envelope = math.exp(-3.2 * progress)
        if index < attack:
            envelope *= index / attack
        samples.append(value * envelope)
    return samples


def silence(seconds: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * seconds)


def success_cue() -> list[float]:
    """A rising major arpeggio that lands on the octave: unmistakably 'done'."""
    samples: list[float] = []
    for name, duration in (("C5", 0.075), ("E5", 0.075), ("G5", 0.075)):
        samples += square(note(name), duration, duty=0.5)
    # The last note is longer and thinner, so the cue resolves rather than stops.
    samples += square(note("C6"), 0.30, duty=0.25)
    return samples


def failure_cue() -> list[float]:
    """Two descending detuned tones. Low and buzzing, but not an error klaxon.

    The point is 'that turn did not finish cleanly', not 'your machine is on
    fire', so it stays short and avoids the harsh dissonance of a true alarm.
    """
    samples: list[float] = []
    for name, duration in (("G3", 0.14), ("D#3", 0.26)):
        base = square(note(name), duration, duty=0.5)
        # A slightly detuned second voice; the beating between them is what
        # makes the cue sound wrong on purpose.
        detuned = square(note(name) * 1.012, duration, duty=0.5)
        samples += [(a + b) / 2 for a, b in zip(base, detuned)]
    return samples


def noise(seconds: float, seed: int, decay: float, smoothing: float) -> list[float]:
    """Deterministic white noise through a one-pole lowpass, with a fast decay.

    A linear congruential generator rather than `random`, so the bytes are
    reproducible across Python versions the way the rest of this file is. The
    lowpass is what turns a hiss into a "pff" — unfiltered noise reads as
    static, not as air moving.
    """
    count = int(SAMPLE_RATE * seconds)
    state = seed
    previous = 0.0
    samples = []
    attack = max(1, int(SAMPLE_RATE * 0.002))
    for index in range(count):
        state = (state * 1_103_515_245 + 12_345) % (1 << 31)
        white = (state / (1 << 30)) - 1.0
        previous += smoothing * (white - previous)
        envelope = math.exp(-decay * index / count)
        if index < attack:
            envelope *= index / attack
        samples.append(previous * envelope)
    return samples


def summon_cue() -> list[float]:
    """A quick rising run: the portal opening and something arriving through it.

    Thin duty cycle and short steps, so it reads as a sparkle rather than as the
    success fanfare, which is a rising arpeggio in the same register.
    """
    samples: list[float] = []
    for name in ("G4", "C5", "E5", "G5", "C6"):
        samples += square(note(name), 0.045, duty=0.125)
    samples += square(note("E6"), 0.18, duty=0.125)
    return samples


def dismiss_cue() -> list[float]:
    """A smoke-bomb puff: a filtered noise burst over a short downward blip.

    Noise carries the poof; the falling tone under it gives the burst a body so
    it does not read as a click on small speakers.
    """
    burst = noise(0.34, seed=20_260_801, decay=5.5, smoothing=0.35)
    body: list[float] = []
    for name, duration in (("A4", 0.05), ("D4", 0.07)):
        body += square(note(name), duration, duty=0.5)
    body += [0.0] * max(0, len(burst) - len(body))
    return [0.72 * a + 0.28 * b for a, b in zip(burst, body)]


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    peak = max((abs(value) for value in samples), default=1.0) or 1.0
    frames = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, value / peak * PEAK)) * 32_767))
        for value in samples
    )
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(frames)
    print(f"wrote {path} ({len(samples) / SAMPLE_RATE:.2f}s, {len(frames)} bytes)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-root",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "art" / "audio",
    )
    arguments = parser.parse_args()
    write_wav(arguments.output_root / "success.wav", success_cue() + silence(0.02))
    write_wav(arguments.output_root / "failure.wav", failure_cue() + silence(0.02))
    write_wav(arguments.output_root / "summon.wav", summon_cue() + silence(0.02))
    write_wav(arguments.output_root / "dismiss.wav", dismiss_cue() + silence(0.02))


if __name__ == "__main__":
    main()
