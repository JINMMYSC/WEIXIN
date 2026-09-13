# V8 Remaining hard gaps

1. **macOS/Xcode real build + signing** — Host App / Keyboard / Share / Widget must be compiled with a real iOS SDK and installed.
2. **Concrete Hamster revision conformance** — map the selected public Hamster revision's active librime wrapper/session methods into `WTHamsterRimeSessionProtocol`.
3. **IME black-box parity capture** — WeType's Tencent `wxime` is not librime. V8 now includes a 30-probe corpus and comparator; the remaining step is to capture reference snapshots on a real iPhone, then expand to T9, shuangpin, Wubi, stroke, learning/correction and add compatibility shims only for measured mismatches.
4. **Same-device screenshot/video calibration** — feed measured baselines, insets, shadows, corner radii, popup geometry and animation curves into calibration tokens.
5. **Secondary icon pass** — 36 `Image(systemName:)` usages remain in iOSOverlay secondary panels/empty states; redraw only after measuring corresponding original geometry.
6. **Provider parity** — speech, translation, AI/rewrite, cloud candidate, hot words, GIF/sticker and BookVideo content need production providers; results will not be Tencent-private service results.
7. **Transfer security/control plane** — V8 has resume/SHA-256/HMAC but still uses plain TCP and local Bonjour, not the original secure Tencent P2P dispatch/bound-device backend. Add TLS/Noise-like encryption before production.
8. **Recognition parity** — Vision handwriting and Apple Speech are fallbacks, not original WeType recognizers/models.
9. **WeChat handoff** — use only public/legally available integration; private WeChat send interfaces are not reproduced.
10. **Regression matrix** — Notes, Messages/WeChat-like fields, Spotlight, return-key variants, secure fields, landscape, dark mode, low memory, extension restart, English→number→return and residual composition.
