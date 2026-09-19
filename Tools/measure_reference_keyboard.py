#!/usr/bin/env python3
"""Measure keyboard key rows from a 1290 x 2796 WeChat Input 3.5.3 reference frame.

The Phase 14 geometry contract in `Sources/WeTypeReplicaCore/Phase14VisualContract.swift`
was derived with this measurement. Frame captures stay outside the repository, so this tool
takes a caller-supplied PNG and prints the key geometry in points (3 px = 1 pt).
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

import numpy as np
from PIL import Image

SCALE = 3.0
BACKGROUND = (0xDD, 0xDE, 0xE2)
WHITE_KEY = (0xFF, 0xFF, 0xFF)
GRAY_KEY = (0xAF, 0xB4, 0xBD)
MIN_ROW_PIXELS = 20
ROW_DENSITY = 0.45
COLUMN_COVERAGE = 0.6


def _matches(rgb: np.ndarray, colour: tuple[int, int, int], tolerance: int) -> np.ndarray:
    target = np.array(colour, dtype=np.int16)
    # Works for both (height, width) images and flat (pixel, channel) samples.
    return np.abs(rgb - target).max(axis=-1) <= tolerance


def find_key_rows(rgb: np.ndarray) -> list[tuple[int, int]]:
    """Rows of the frame that are dominated by key caps rather than keyboard background."""
    background = _matches(rgb, BACKGROUND, 6)
    density = (~background).sum(axis=1)
    width = rgb.shape[1]
    rows: list[tuple[int, int]] = []
    start = None
    for y, count in enumerate(density):
        solid = count > width * ROW_DENSITY
        if solid and start is None:
            start = y
        elif not solid and start is not None:
            if y - start >= MIN_ROW_PIXELS:
                rows.append((start, y - 1))
            start = None
    if start is not None and len(density) - start >= MIN_ROW_PIXELS:
        rows.append((start, len(density) - 1))
    return rows


def find_keys_in_row(rgb: np.ndarray, row: tuple[int, int]) -> list[tuple[int, int]]:
    """Horizontal runs of key caps inside one row, merged across anti-aliased seams."""
    top, bottom = row
    strip = rgb[top:bottom + 1]
    background = _matches(strip, BACKGROUND, 6)
    coverage = (~background).sum(axis=0)
    threshold = (bottom - top + 1) * COLUMN_COVERAGE
    runs: list[list[int]] = []
    start = None
    for x, count in enumerate(coverage):
        solid = count > threshold
        if solid and start is None:
            start = x
        elif not solid and start is not None:
            runs.append([start, x - 1])
            start = None
    if start is not None:
        runs.append([start, len(coverage) - 1])
    merged: list[list[int]] = []
    for run in runs:
        if merged and run[0] - merged[-1][1] <= 3:
            merged[-1][1] = run[1]
        else:
            merged.append(run)
    return [(start, end) for start, end in merged if end - start > 4]


def classify_key(rgb: np.ndarray, row: tuple[int, int], run: tuple[int, int]) -> str:
    top, bottom = row
    start, end = run
    sample = rgb[top + 6:bottom - 5, start + 4:end - 3].reshape(-1, 3)
    if sample.size == 0:
        return "unknown"
    white = _matches(sample, WHITE_KEY, 8).mean()
    gray = _matches(sample, GRAY_KEY, 8).mean()
    return "white" if white >= gray else "gray"


def measure(rgb: np.ndarray) -> dict:
    rows = []
    for row in find_key_rows(rgb):
        keys = []
        for run in find_keys_in_row(rgb, row):
            keys.append({
                "x": round(run[0] / SCALE, 2),
                "width": round((run[1] - run[0] + 1) / SCALE, 2),
                "kind": classify_key(rgb, row, run),
            })
        rows.append({
            "y": round(row[0] / SCALE, 2),
            "height": round((row[1] - row[0] + 1) / SCALE, 2),
            "keys": keys,
        })
    return {"size": [rgb.shape[1], rgb.shape[0]], "rows": rows}


def load_frame(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        return np.asarray(image.convert("RGB"), dtype=np.int16)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("frame", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not args.frame.is_file():
        print(f"missing frame: {args.frame}", file=sys.stderr)
        return 1
    result = measure(load_frame(args.frame))
    payload = json.dumps(result, ensure_ascii=False, indent=2)
    if args.output:
        args.output.write_text(payload + "\n", encoding="utf-8")
    print(payload)
    return 0


if __name__ == "__main__":
    sys.exit(main())
