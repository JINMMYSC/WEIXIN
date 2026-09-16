# Phase 14 visual evidence

Phase 14 compares same-device captures from WeChat Input 3.5.3 and WeTypeReplica on iPhone 15 Pro Max.

Each selected scene uses this artifact tree:

```text
Phase6Evidence/01-keyboard26-light/
  REF-01-keyboard26-light.png
  REP-01-keyboard26-light.png
  overlay.png
  absolute_difference.png
  rgba_difference.png
  metrics.json
  review.json
```

Apply the same naming rule to scenes `02`, `04`, `06`, `07`, `08`, `10`, `14`, `23`, and `27`.

AssistiveTouch rectangles from `reference_capture_manifest.json` are exclusion masks only. They must never cover keyboard or Host UI pixels.

`review.json` is fail-closed: missing REF, REP, metrics, or a canonical strict reference produces `incomplete`. A complete comparison starts at `needs-review`; tooling never marks a scene `pass` automatically.

Scene `01` remains geometry-only because the current source capture is English 26-key. It is not eligible for strict Chinese 26-key review until a canonical Chinese frame is supplied.
