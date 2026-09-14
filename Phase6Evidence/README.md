# Phase 6 same-device parity evidence

This directory is intentionally empty until real-device captures are supplied. Static UI checks do **not** count as visual parity.

For each of the 79 IDs in `WTVisualParityStarterManifest`, keep:

- `reference/<case-id>.png` (or `.mov` / `.mp4`): observed WeChat Input 3.5.3 on the reference iPhone.
- `replica/<case-id>.png` (or `.mov` / `.mp4`): the matching CLAW/WeType build on the **same iPhone**, same host app, orientation, appearance and text state.
- `reviews/<case-id>.json`: review metadata.

Minimal review record:

```json
{
  "target_version": "3.5.3",
  "same_device": true,
  "status": "pass",
  "notes": "geometry, colors, font baselines, hit regions and transition match the reference capture"
}
```

`python3 Tools/verify_phase6_evidence.py` reports progress without blocking engineering builds.
`python3 Tools/verify_phase6_evidence.py --strict` is the final release gate and fails unless all 79 cases have both captures and a same-device pass record.

Image pairs can additionally be measured with `Tools/measure_visual_diff.py`. Dynamic cases should keep video evidence where a still image cannot demonstrate gesture thresholds or animation behavior.
