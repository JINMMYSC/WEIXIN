#!/usr/bin/env python3
"""Extract portable Phase 14 reference frames from user-supplied recordings."""

import argparse
import json
import math
from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "ReverseEngineering" / "Phase14" / "reference_capture_manifest.json"
EXPECTED_CAPTURE_IDS = ["01", "02", "04", "06", "07", "08", "10", "14", "23", "27"]


def load_manifest(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def validate_manifest(manifest: dict) -> list[str]:
    errors: list[str] = []
    ids: set[str] = set()
    capture_ids: list[str] = []
    for capture in manifest.get("captures", []):
        capture_id = str(capture.get("id", ""))
        capture_ids.append(capture_id)
        if capture_id in ids:
            errors.append(f"duplicate capture id: {capture_id}")
        ids.add(capture_id)
        if Path(str(capture.get("video", ""))).is_absolute():
            errors.append(f"absolute video path: {capture_id}")
        if capture.get("expectedPixels") != [1290, 2796]:
            errors.append(f"unexpected dimensions: {capture_id}")
    if capture_ids != EXPECTED_CAPTURE_IDS:
        errors.append(f"unexpected Phase14 capture ids: {capture_ids}")
    return errors


def output_path(output: Path, capture: dict) -> Path:
    return output / f"{capture['id']}_{capture['scene']}.png"


def extract_capture(capture: dict, video_root: Path, output: Path, ffmpeg: str) -> Path:
    try:
        timestamp = float(capture["timestampSeconds"])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(f"invalid timestamp: {capture.get('id', '')}") from exc
    if not math.isfinite(timestamp) or timestamp < 0:
        raise ValueError(f"invalid timestamp: {capture.get('id', '')}")

    video = video_root / capture["video"]
    if not video.is_file():
        raise FileNotFoundError(f"missing media: {video}")

    frame = output_path(output, capture)
    frame.parent.mkdir(parents=True, exist_ok=True)
    command = [
        ffmpeg,
        "-y",
        "-ss",
        str(timestamp),
        "-i",
        str(video),
        "-frames:v",
        "1",
        "-compression_level",
        "3",
        str(frame),
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(f"extraction failed: {capture.get('id', '')}: {detail}")

    from PIL import Image

    with Image.open(frame) as image:
        pixels = list(image.size)
    if pixels != capture["expectedPixels"]:
        raise ValueError(
            f"wrong dimensions: {capture.get('id', '')}: "
            f"expected {capture['expectedPixels']}, got {pixels}"
        )
    return frame


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--video-root", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--ffmpeg", default="ffmpeg")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        manifest = load_manifest(args.manifest)
        errors = validate_manifest(manifest)
        if errors:
            raise ValueError("; ".join(errors))
        for capture in manifest.get("captures", []):
            print(extract_capture(capture, args.video_root, args.output, args.ffmpeg))
    except (OSError, ValueError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"Phase14 reference extraction failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
