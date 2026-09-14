# Phase 7 Release Status

This document is the release truth source for the ClawBase Host + Keyboard build.

## Release identity

- Host: `app.lgm.7517`
- Keyboard: `app.lgm.7517.123`
- App Group: `group.7518554`
- Team: `X5G6AN3DYX`
- Version/build: `3.0.1 (2)`
- Signed packaging scope: Host + Keyboard Extension

## Phase 1–7 engineering gates

1. Phase 1 — installable Host + Keyboard identity/signing contract.
2. Phase 2 — keyboard/Host UI surface integration and extracted 3.5.3 geometry/style contracts.
3. Phase 3 — pinned public librime input engine, pinyin/T9/double-pinyin/Wubi/stroke/settings/user-data contracts and black-box stimulus matrix.
4. Phase 4 — panel/service state matrix, Host handoff, speech/image/quick-send routes and fallback/error states.
5. Phase 5 — Host/Keyboard App Group convergence, lifecycle heartbeat, memory-pressure persistence and transient-file cleanup.
6. Phase 6 — 79-case structural/runtime geometry/style gates plus same-device raw-pixel calibration pipeline.
7. Phase 7 — full regression, Xcode build, dual-profile signing, codesign verification, release digest and explicit remaining-difference inventory.

## External evidence still required before claiming exact WeChat parity

- The Phase 3 matrix contains 122 reference stimuli, but real-device WeChat IME reference observations must be captured rather than invented.
- Phase 6 requires 79 same-device original-vs-replica capture pairs. The repository currently tracks the evidence manifest separately; a static/geometry CI pass is not pixel-identity proof.
- Existing Widget/Share/Control-Center/Live-Activity source surfaces are audited, but the final CI-signed package intentionally embeds only the Keyboard extension because the signing pipeline currently has Host + Keyboard provisioning profiles only. Extra extension targets must not be embedded without their own profiles/entitlements.

## Release reporting rule

不得用“相似度百分比”冒充完成度。CI success means the declared engineering/build/signing contracts passed. It does not replace missing same-device visual evidence or missing original-app black-box observations.

Every final report must enumerate any remaining externally verifiable differences instead of assigning a fabricated similarity percentage.
