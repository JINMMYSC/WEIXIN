# V13 Remaining gaps — CI remains final

1. **Concrete Hamster/librime adapter on the selected public revision** — V13 contract now includes commit drain, input-mode switch, candidate page metadata/page-up/page-down, select/delete/reset. Exact wrapper symbols still need the real Hamster source revision under Xcode/macOS.
2. **Same-device 100-probe IME capture** — candidate ranking, segmentation, learning, fuzzy Pinyin, T9, Shuangpin, Wubi and stroke behavior still need WeType 3.5.3 reference snapshots and compatibility rules only for measured differences.
3. **Same-device 79-case visual/video calibration** — safe-area offsets, text baseline, key shadow, key popup geometry, long-press gesture threshold and animation curves require original/replica capture on the same iPhone model.
4. **Production providers** — AI/rewrite, translation, cloud candidates, hot words, GIF/sticker and BookVideo need app-owned endpoints. Tencent-private backend/model results are not reproduced.
5. **Recognition parity** — Vision handwriting and Apple Speech are clean-room fallbacks; candidate ordering/recognition timing will not be identical to Tencent models without a separate recognizer.
6. **Transfer production policy** — payload AEAD + pairing already exist; device trust/revocation policy, background transfer limits, large-file iPhone stress testing and export-compliance review remain.
7. **Share Extension device regression** — V13 has staging, cancellation, failed-item retry and resumability, but Photos large video, package/file-provider URLs, low-disk, extension timeout and abrupt host cancellation still need device testing.
8. **Low-memory runtime regression** — session persistence/cache shedding is implemented; iOS keyboard extension eviction/relaunch still needs on-device verification.
9. **Live Activity exact appearance** — lifecycle is implemented, but Dynamic Island/live-activity typography, spacing and timing still need same-device capture.
10. **Runtime regression matrix** — Spotlight, secure fields, landscape, dark mode, return-key variants, host field transition, English→number→return and residual composition remain device gates.
11. **CI / Xcode / signing / IPA** — intentionally deferred to the final stage as requested. This is where real iOS SDK type checking, target embedding, entitlements, signing and IPA export are finally proven.
