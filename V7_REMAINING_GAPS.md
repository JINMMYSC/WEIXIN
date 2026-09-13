# V7 remaining hard gaps

1. **Real macOS/Xcode SDK compile** — V7 adds a macOS GitHub Actions workflow and `XcodeIntegration/validate_on_mac.sh`, but this Linux environment still cannot execute Xcode/UIKit type checking.
2. **Concrete Hamster revision conformance** — the typed adapter boundary is stable, but the exact open-source Hamster revision still needs its concrete Rime session/controller methods mapped to `WTHamsterRimeSessionProtocol` on a checked-out source tree.
3. **iPhone visual/animation calibration** — 190 original icon families now have measured canvas and alpha-bounds geometry, but clean-room artwork and final pixels/curves still need same-device screenshot/recording measurements.
4. **Voice return-to-keyboard validation** — host-app Speech framework capture + App Group mailbox + URL route are implemented; whether the keyboard extension can open the containing app directly must be tested on-device. Widget/host launch remains a fallback.
5. **Provider endpoints** — AI, translation, cloud candidates, hot words, stickers/GIF now have concrete HTTP implementations, but production backends/credentials are intentionally not Tencent private services.
6. **Transfer hardening** — Bonjour/Network.framework works at prototype level; chunked large-file streaming, pairing/authentication, integrity verification and interrupted transfer resume remain.
7. **Regression matrix on real apps** — Notes, WeChat-like fields, Messages, Spotlight, secure text, landscape, dark mode, low-memory restart, English→number→return, and candidate commit residual-text cases require iPhone execution.
8. **Shipping clean-room icons** — V7 measures geometry and sizes SF Symbol placeholders accordingly; independent final vector artwork is still required for icon-by-icon visual parity.
