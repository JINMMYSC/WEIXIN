# V12 Remaining gaps — CI remains final

1. **Concrete Hamster/librime adapter on the exact selected public revision** — V12 now defines commit-drain + mode switching + context/select/delete/reset semantics, but exact wrapper symbols still need the real source/Xcode revision.
2. **Same-device 100-probe IME capture** — candidate ranking, segmentation, learning, fuzzy Pinyin, T9, Shuangpin, Wubi and stroke behavior must be measured against WeType 3.5.3 and converted into compatibility rules only where mismatches are observed.
3. **Same-device 79-case visual/video calibration** — baseline, safe area, shadow, popup geometry, gesture thresholds and animation curves still require original/replica captures on the same iPhone.
4. **Production providers** — AI/rewrite, translation, cloud candidates, hot words, GIF/sticker and BookVideo need app-owned production endpoints; Tencent-private backend/model results are not reproduced.
5. **Recognition parity** — Vision handwriting and Apple Speech remain clean-room fallbacks, not Tencent recognizers.
6. **Transfer deployment policy** — payload encryption is now implemented for paired devices; final product still needs an explicit policy for mandatory pairing, key rotation/revocation, background transfer limits and Apple export-compliance review.
7. **Share Extension device regression** — the lifecycle/staging bug is fixed statically, but Photos large video, package/file-provider URLs, low disk, extension timeout, cancellation and retry still need iPhone testing.
8. **Live Activity visual calibration** — lifecycle/deep-link/state handling are implemented; exact Dynamic Island/live-activity appearance still needs device capture against 3.5.3.
9. **Runtime regression matrix** — Spotlight, secure fields, low-memory extension restart, landscape, dark mode, English→number→return, return-key variants, host field transition and residual composition.
10. **CI / Xcode / signing / IPA** — intentionally deferred to the final stage. This remains the point where actual iOS SDK type checking, extension embedding, signing and IPA export are proven.
