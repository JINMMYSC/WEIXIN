# V9 UI / behavior parity delta

V9 closes two gaps that were still explicitly visible in V8: shipping UI no longer uses SF Symbol placeholders, and the black-box IME corpus is no longer limited to 26-key pinyin.

## Closed in V9

- Replaced every `Image(systemName:)` / `systemImage:` usage in shipping `iOSOverlay`, `iOSApp`, and `iOSExtensions` sources with independently drawn clean-room semantic glyphs. Static verifier reports **0** remaining SF Symbol placeholder calls.
- Added shared `iOSShared/WTSemanticGlyph.swift` to App / Keyboard / Share / Widget targets.
- Expanded observable IME parity corpus from **30 to 100** probes, now covering pinyin, segmentation, ranking, fuzzy pinyin, long phrases, mixed English, T9, shuangpin, Wubi86, stroke, learning/personalization, and correction.
- Added repeat/select metadata so learning tests can measure candidate-rank changes across repeated commits rather than only one-shot output.
- Added **57 same-device visual capture cases across 26 surface families**, including light/dark, 26-key, 9-key, candidate expand, key popup, long press, return-key host semantics, one-handed mode, landscape, Spotlight, secure fields, Share Extension and Widget.

## Still prevents an honest “identical” claim

1. Real Xcode/iOS SDK build, signing, App Group and extension runtime have not been executed in this Linux environment.
2. The exact public Hamster source revision still needs to be checked out on macOS and mapped to `WTHamsterRimeSessionProtocol`; no newer closed App Store class names are assumed.
3. The 100-probe reference capture must be recorded on the same iPhone against WeType 3.5.3, then compared to the replica and used to drive compatibility shims.
4. The 57 visual cases need same-device screenshots / high-frame-rate recordings so baseline, safe-area, shadows, popup geometry and animation timing can be measured instead of estimated.
5. Tencent-private online services and recognizers remain provider-equivalent, not Tencent-identical: cloud candidate, AI/rewrite, translation, voice, hot words, GIF/sticker, BookVideo, handwriting model.
6. Transfer transport still needs production security hardening beyond pairing HMAC/integrity before shipping.
7. Full iPhone regression remains mandatory: Notes, WeChat-like text fields, Spotlight, secure fields, landscape, dark mode, low-memory extension restart, English→number→return, residual composition, and return-key variants.
