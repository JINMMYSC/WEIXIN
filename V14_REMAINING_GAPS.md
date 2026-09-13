# V14 Remaining gaps — CI intentionally stays last

1. **Concrete Hamster/librime conformance** — V14 now supports schema/options/properties via `WTRimeBackendProfile`, but the selected public Hamster revision's real wrapper symbols still need macOS/Xcode source integration.
2. **Same-device 100-probe IME reference capture** — Tencent `wxime` ranking, segmentation, personalization, fuzzy Pinyin, T9, Shuangpin, Wubi and stroke need real WeType 3.5.3 snapshots before compatibility rules can be honestly tuned.
3. **Same-device 79-case visual/video calibration** — safe-area/baseline/shadow/popup/gesture threshold/animation timing still require original + replica capture on the same iPhone.
4. **Production providers** — AI/rewrite, translation, cloud candidate, hot words, GIF/sticker and BookVideo need app-owned production endpoints; Tencent-private backends/models are not reproduced.
5. **Recognition parity** — Vision handwriting and Apple Speech remain clean-room fallbacks and will differ in ranking/timing from WeType's models.
6. **Per-device cryptographic revocation** — V14 now persists authenticated device history and local revoke/remove state, but the shared pairing-code transport cannot selectively invalidate one remote device. Production needs per-device keys/control-plane policy.
7. **Share Extension device stress** — retry cap/cancel/staging/resume exist; Photos large-video, file-provider/package URLs, low-disk, abrupt host termination and real extension time budget still need iPhone regression.
8. **Low-memory runtime regression** — presentation-cache shedding and mode persistence are implemented; real iOS extension eviction/relaunch behavior still needs device proof.
9. **Live Activity exact appearance** — lifecycle exists; Dynamic Island typography/spacing/timing still needs same-device measurement.
10. **Runtime matrix** — Spotlight, secure fields, landscape, dark mode, return-key variants, English→number→return and residual composition remain device gates.
11. **CI / Xcode / signing / IPA** — intentionally deferred to final stage by user request. This will prove iOS SDK type checking, target embedding, entitlements, signing and IPA export.
