# V9 remaining hard gaps

1. **macOS/Xcode first build + signing** — build/install Host App, Keyboard, Share and Widget with real iOS SDK; fix true API/entitlement issues.
2. **Concrete public Hamster adapter** — check out the exact public source revision on Mac, then map its live Rime context/candidate/process/select/backspace/reset calls into `WTHamsterRimeSessionProtocol`.
3. **100-probe IME reference capture** — capture WeType 3.5.3 and replica on the same iPhone; quantify T9/shuangpin/Wubi/stroke/learning/correction mismatches and add compatibility shims only for measured deltas.
4. **57-case visual/video capture** — measure safe-area, text baseline, shadows, popup geometry, corner radii and animation curves/timing on the same device.
5. **Production providers** — cloud candidate, AI/rewrite, translation, speech, hot words, GIF/sticker, BookVideo and stronger handwriting recognizer; these remain equivalent providers, not Tencent-private backends/models.
6. **Transfer production security** — current resume/SHA-256/HMAC protocol still needs encrypted transport and production-grade identity/control-plane handling.
7. **Runtime regression matrix** — secure fields, Spotlight, landscape, dark mode, return-key variants, low memory, extension restart, English→number→return, composition residual text.
