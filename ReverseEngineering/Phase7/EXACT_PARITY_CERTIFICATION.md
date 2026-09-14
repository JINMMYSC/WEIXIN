# Exact WeChat parity certification

This layer is intentionally stricter than the Phase 1–7 engineering/build/signing regression.

A successful engineering CI proves that the declared app, keyboard, engine, panel, lifecycle, UI-structure, build and signing contracts passed. It does **not** prove that the replica is exactly identical to WeChat IME 3.5.3.

Exact certification is fail-closed and requires both evidence sets:

1. Phase 3 behavior evidence: all 122 matrix cases must have real-device `wechat-ime` observations and corresponding real-device replica observations. `Tools/compare_phase3_blackbox.py` must report zero mismatches.
2. Phase 6 visual evidence: all 79 required same-device, same-host, same-orientation, same-appearance, same-text-state original-vs-replica capture pairs must exist with uncropped raw-pixel metrics and pass `Tools/verify_phase6_exact_evidence.py`.

Current evidence files deliberately start empty. Missing observations are never inferred, synthesized or marked as matched by CI.

Run `python3 Tools/verify_exact_wechat_parity.py` only after the real-device evidence has been populated. The manual GitHub workflow `.github/workflows/exact-parity-certification.yml` runs the same fail-closed certification.

The final release must not be described as “一模一样” until this certification passes.
