#!/usr/bin/env python3
"""Masked same-device visual comparison for Phase 14."""
from __future__ import annotations
import argparse, json, math
from pathlib import Path
import numpy as np
from PIL import Image, ImageChops


def parse_crop(value: str | None):
    if not value:
        return None
    x, y, w, h = [int(v) for v in value.split(",")]
    return (x, y, x + w, y + h)


def compare_images(reference, replica, masks=None, threshold=12.0):
    a = np.asarray(reference.convert("RGBA"), dtype=np.int16)[..., :3]
    b = np.asarray(replica.convert("RGBA"), dtype=np.int16)[..., :3]
    if a.shape != b.shape:
        raise ValueError(f"image shape mismatch: {a.shape} != {b.shape}")
    valid = np.ones(a.shape[:2], dtype=bool)
    excluded = 0
    for x, y, w, h in masks or []:
        x0, y0 = max(0, x), max(0, y)
        x1, y1 = min(valid.shape[1], x + w), min(valid.shape[0], y + h)
        if x1 > x0 and y1 > y0:
            valid[y0:y1, x0:x1] = False
    excluded = int(valid.size - valid.sum())
    delta = np.abs(a - b).astype(np.float32)
    per_pixel = delta.mean(axis=2)
    measured = int(valid.sum())
    if measured == 0:
        raise ValueError("all pixels are masked")
    channel_values = delta[valid]
    mae = float(channel_values.mean())
    rmse = math.sqrt(float(np.mean((a.astype(np.float32)[valid] - b.astype(np.float32)[valid]) ** 2)))
    exact = float(np.mean(per_pixel[valid] == 0))
    over = float(np.mean(per_pixel[valid] > threshold))
    flagged = (per_pixel > threshold) & valid
    ys, xs = np.where(flagged)
    bbox = None if len(xs) == 0 else [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1]
    return {
        "size": list(reference.size),
        "mae_0_255": round(mae, 4),
        "rmse_0_255": round(rmse, 4),
        "exact_pixel_fraction": round(exact, 6),
        "pixels_over_threshold_fraction": round(over, 6),
        "threshold": threshold,
        "difference_bbox": bbox,
        "excluded_pixel_count": excluded,
        "measured_pixel_count": measured,
    }


def build_review(scene_id, reference=None, replica=None, metrics=None, strict_eligible=True):
    missing = []
    if reference is None: missing.append("REF")
    if replica is None: missing.append("REP")
    if metrics is None: missing.append("metrics")
    if not strict_eligible: missing.append("canonical-reference")
    return {
        "scene_id": scene_id,
        "status": "incomplete" if missing else "needs-review",
        "missing": missing,
        "strict_eligible": bool(strict_eligible),
    }


def load_scene_masks(path: str | None, scene_id: str | None):
    if not path or not scene_id:
        return [], True
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    capture = next((c for c in data.get("captures", []) if str(c.get("id")) == scene_id), None)
    if capture is None:
        raise SystemExit(f"scene id not found in manifest: {scene_id}")
    masks = [tuple(int(v) for v in box) for box in capture.get("excludeMasks", [])]
    return masks, bool(capture.get("eligibleForStrictReview", True))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("original")
    ap.add_argument("replica")
    ap.add_argument("--out", required=True)
    ap.add_argument("--crop")
    ap.add_argument("--threshold", type=float, default=12.0)
    ap.add_argument("--resize-replica", action="store_true")
    ap.add_argument("--mask-manifest")
    ap.add_argument("--scene-id")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    reference = Image.open(args.original).convert("RGBA")
    replica = Image.open(args.replica).convert("RGBA")
    crop = parse_crop(args.crop)
    if crop:
        reference, replica = reference.crop(crop), replica.crop(crop)
    if reference.size != replica.size:
        if args.resize_replica:
            replica = replica.resize(reference.size, Image.Resampling.LANCZOS)
        else:
            raise SystemExit(f"image size mismatch: original={reference.size}, replica={replica.size}")

    masks, strict_eligible = load_scene_masks(args.mask_manifest, args.scene_id)
    metrics = compare_images(reference, replica, masks=masks, threshold=args.threshold)
    metrics["crop"] = list(crop) if crop else None
    (out / "metrics.json").write_text(json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    aa = np.asarray(reference, dtype=np.int16)[..., :3]
    bb = np.asarray(replica, dtype=np.int16)[..., :3]
    per_pixel = np.abs(aa - bb).astype(np.float32).mean(axis=2)
    Image.fromarray(np.clip(per_pixel, 0, 255).astype(np.uint8), mode="L").save(out / "absolute_difference.png")
    ImageChops.difference(reference, replica).save(out / "rgba_difference.png")
    Image.blend(reference, replica, 0.5).save(out / "overlay.png")

    review = build_review(
        scene_id=args.scene_id or "unspecified",
        reference=reference,
        replica=replica,
        metrics=metrics,
        strict_eligible=strict_eligible,
    )
    (out / "review.json").write_text(json.dumps(review, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"metrics": metrics, "review": review}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
