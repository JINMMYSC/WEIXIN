# Phase 3 composition / segmentation contract

CLAW TALK Phase 3 is pinned to librime commit `08dd95f5d9282346f0d4a3e8fc6b20811dc3d063` through LibrimeKit.

The public C API exposed by that revision provides `RimeComposition` with:

- `length`
- `cursor_pos`
- `sel_start`
- `sel_end`
- `preedit`

It does **not** expose the engine's internal `Composition` segment list through `RimeContext`. In other words, this pinned public C API does not expose explicit internal segmentation boundaries.

Therefore the production bridge currently exposes only real public composition metadata: preedit text, composition length, cursor position and selection start/end. These values must never be described as explicit Rime segment boundaries.

Phase 3 may only claim real segmentation after one of the following is implemented and tested:

1. a pinned public librime C API that explicitly exposes segment boundaries; or
2. a separately reviewed public adapter/API with stable segment semantics and no private Tencent/WeChat dependency.

Until then, explicit segmentation parity is an open external/backend capability gate, not a fabricated completed feature.
