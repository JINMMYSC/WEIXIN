# V8 UI/behavior parity delta — what is still not identical

This document intentionally lists remaining differences instead of treating architecture coverage as visual completion.

## P0 — blocks an honest “一模一样” claim

1. **No real Xcode/iOS SDK build yet in this environment.** The code parses and core tests run on Linux, but Keyboard Extension/App/Share/Widget still need macOS compilation, signing and installation.
2. **Input engine behavior differs.** WeType 3.5.3 contains Tencent's proprietary `wxime` engine. The replica deliberately uses Hamster/librime plus a compatibility layer. V8 now has a 30-probe black-box corpus/comparator, but candidate ranking, segmentation, personalization, fuzzy-pinyin details and some 9-key behavior cannot be called identical until same-device reference captures are collected and matched.
3. **No same-iPhone pixel/animation capture yet.** Layout/config values are extracted, but safe-area offsets, text baselines, shadows, popup geometry and animation timing require screenshots/high-frame-rate recordings of original and replica on the same device.
4. **Private services differ.** Cloud candidates, AI/rewrite, translation, speech, hot-word feeds, GIF/sticker search and WeChat rich-content search/send use clean provider APIs, not Tencent's backends/models.

## P1 — visible/interaction differences still being closed

5. **Micro-icons:** all 22 primary keyboard tools now use independently drawn vectors sized from measured 3.5.3 geometry. Common chrome chevrons/search/close are also clean-room vectors. There are still **36** `Image(systemName:)` usages in secondary panels, so some artwork remains placeholder-equivalent rather than geometrically matched.
6. **Return key:** V8 now follows host `returnKeyType` and the original neutral/brand style split, but per-app labels/enablement and touch-style locking remain for device verification.
7. **Transfer/device sync:** V8 now has pairing code, resume, integrity and auth state, but the original Tencent bound-device/P2P dispatch control plane and secure transport are not reproduced.
8. **Handwriting:** the panel/stroke flow matches structurally, but Vision fallback recognition is not the original CJK recognizer and will produce different candidates/ordering.
9. **Voice:** host-app Speech framework bridge works structurally, but recognition model, punctuation/post-polish and return-to-keyboard timing differ from WeType's service.
10. **Host App settings/content:** all discovered product surfaces are represented, but exact copy, row ordering, illustrations, online content and account/device data still need screen-by-screen capture.
11. **WeChat rich-content handoff:** UI/provider boundary exists; actual WeChat-specific open/send behavior requires a legally available host integration and will not use private Tencent interfaces.
12. **Runtime edge cases:** secure fields, Spotlight, landscape, low-memory keyboard restarts, app-specific text traits, English→number→return and composition residual-text regressions still require iPhone testing.

## V8 deltas closed this round

- exact `WBColor.json` host palette was added alongside `style.ini` key colors;
- return-key host-context behavior was added;
- transfer-code/invite state was added;
- transfer protocol upgraded to streaming/resume/SHA-256/HMAC/final ACK;
- primary toolbar/control-center icons are no longer SF Symbol placeholders;
- high-frequency chrome arrows/search/close now use clean-room vector glyphs;
- a reproducible screenshot-diff tool was added and self-tested;
- a reproducible IME black-box corpus/comparator was added so `wxime`/librime differences can be measured instead of guessed.
