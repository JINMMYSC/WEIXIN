#!/usr/bin/env python3
"""Measure same-device screenshot differences for WeType 3.5.3 calibration.

Usage:
  python3 Tools/measure_visual_diff.py original.png replica.png --out ReverseEngineering/V8/diff

The tool never OCRs screenshots. It compares raw pixels, writes metrics.json and a grayscale
absolute-difference image. For meaningful numbers, capture both keyboards on the same iPhone,
in the same host app, orientation, appearance, and text state.
"""
from __future__ import annotations
import argparse, json, math
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops


def parse_crop(s: str | None):
    if not s:
        return None
    parts = [int(x) for x in s.split(",")]
    if len(parts) != 4:
        raise SystemExit("--crop must be x,y,width,height")
    x, y, w, h = parts
    return (x, y, x + w, y + h)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("original")
    ap.add_argument("replica")
    ap.add_argument("--out", required=True)
    ap.add_argument("--crop", help="x,y,width,height before comparison")
    ap.add_argument("--threshold", type=float, default=12.0, help="8-bit mean-channel difference threshold")
    ap.add_argument("--resize-replica", action="store_true")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    a = Image.open(args.original).convert("RGBA")
    b = Image.open(args.replica).convert("RGBA")
    crop = parse_crop(args.crop)
    if crop:
        a = a.crop(crop)
        b = b.crop(crop)
    if a.size != b.size:
        if args.resize_replica:
            b = b.resize(a.size, Image.Resampling.LANCZOS)
        else:
            raise SystemExit(f"image size mismatch: original={a.size}, replica={b.size}; pass --resize-replica only for rough diagnostics")

    aa = np.asarray(a, dtype=np.int16)[..., :3]
    bb = np.asarray(b, dtype=np.int16)[..., :3]
    delta = np.abs(aa - bb).astype(np.float32)
    per_pixel = delta.mean(axis=2)
    mse = float(np.mean((aa.astype(np.float32) - bb.astype(np.float32)) ** 2))
    rmse = math.sqrt(mse)
    mae = float(delta.mean())
    threshold_fraction = float(np.mean(per_pixel > args.threshold))
    exact_fraction = float(np.mean(per_pixel == 0))

    ys, xs = np.where(per_pixel > args.threshold)
    bbox = None if len(xs) == 0 else [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1]

    metrics = {
        "size": list(a.size),
        "crop": list(crop) if crop else None,
        "mae_0_255": round(mae, 4),
        "rmse_0_255": round(rmse, 4),
        "exact_pixel_fraction": round(exact_fraction, 6),
        "pixels_over_threshold_fraction": round(threshold_fraction, 6),
        "threshold": args.threshold,
        "difference_bbox": bbox,
    }
    (out / "metrics.json").write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n")

    # Grayscale diff keeps the artifact useful without implying semantic color meaning.
    diff_gray = np.clip(per_pixel, 0, 255).astype(np.uint8)
    Image.fromarray(diff_gray, mode="L").save(out / "absolute_difference.png")
    ImageChops.difference(a, b).save(out / "rgba_difference.png")
    print(json.dumps(metrics, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
