# V11 Remaining gaps — CI intentionally left last

1. **Concrete Hamster/librime production adapter** — Debug now has a preview engine, but Release still needs the selected public Hamster revision or direct librime session wired into `WTHamsterRimeSessionProtocol`.
2. **Same-device 100-probe IME capture** — candidate ranking/segmentation/personalization/T9/shuangpin/Wubi/stroke differences still need original-vs-replica iPhone captures and compatibility profile generation.
3. **Same-device 79-case UI/video calibration** — safe-area, baseline, shadow, key popup geometry, gesture threshold and animation timing still require same-iPhone screenshots/high-frame-rate video.
4. **Production providers** — AI/rewrite, translation, cloud candidate, hot words, GIF/sticker, BookVideo content still need app-owned endpoints; they will not reproduce Tencent-private backends.
5. **Recognition parity** — Vision handwriting and Apple Speech remain fallback recognizers, not Tencent models.
6. **Transfer production security** — current pairing/resume/SHA-256/HMAC/ACK flow still needs encrypted transport before production.
7. **Share-extension exact activation/edge cases** — large files, package URLs, Photos/video and cancellation/retry need iPhone regression.
8. **Live Activity visual calibration** — target and lifecycle are now present, but Dynamic Island/live-activity appearance still needs device capture against 3.5.3.
9. **Runtime regression matrix** — Spotlight, secure fields, low-memory extension restart, landscape, dark mode, English→number→return, residual composition.
10. **CI / Xcode / signing / IPA** — intentionally deferred to the final stage as requested. This is where iOS SDK type-checking, actual extension embedding, signing and final IPA export happen.
