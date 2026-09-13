# Phase 2-7 read-only preparation lanes

Date: 2026-09-14
Gate: no Phase 2-7 implementation enters ClawBase until Phase 1 passes real-device installation.

## B — Phase 2 V14 UI migration mapping

Prepare a dependency map for `WeTypeReplicaCore`, `iOSOverlay`, `iOSShared`, `iOSServices`, and `HamsterBridge` into the ClawBase Keyboard target. Migration order after the gate: keyboard shell and safe area, candidate bar, 26-key layout, nine-key layout, English, numbers/symbols, toolbar/control center, input scheme controls, one-hand/floating/size modes, dark mode, landscape. Use Preview Engine first. Each coherent region gets an installable IPA regression before the next region.

## C — Phase 3 Hamster/librime engine adaptation

Inventory the existing `WTHamsterRimeSessionProtocol` boundary and all call sites. After Phase 1, pin a public Hamster/librime revision, implement a real session adapter, and cover key → composition → segmentation → candidates → paging → select → commit → delete/backspace → space/return → reset. Prepare at least 100 black-box comparison cases covering full pinyin, nine-key, double pinyin, Wubi, stroke, Chinese/English, simplified/traditional, fuzzy pinyin, and user dictionary behavior. Do not copy Tencent private dictionaries, models, or services.

## D — Phase 4 panel gap inventory

Maintain a panel-by-panel capability matrix for Emoji, clipboard, phrases, symbols, handwriting, speech, translation, AI, polishing, correction, trending words, GIF/stickers, custom emoji, images, BookVideo, character decomposition, stroke filters, quick send, device sync/transfer, toolbar ordering, and quick settings. Every panel needs loading, empty, permission-denied, offline, failure, retry, and fallback states where applicable.

## E — Phase 5 Host and system-extension migration mapping

Map existing `iOSApp` settings and system extensions to the final Host architecture: onboarding, input settings/schemes, appearance/size, dictionaries, clipboard/phrases, AI/speech/translation, privacy/open access, device transfer/trusted devices, Share Extension, Widget, Control Center, Voice/Live Activity. All shared storage must converge on `group.7518554`; Keyboard memory use remains a hard constraint.

## F — Phase 6 visual/behavior calibration matrix

Convert the existing 79 visual checks into reproducible screenshot/video comparisons. Track dimensions, spacing, corner radii, colors, shadows, fonts/baselines, candidate bar, key popups, long press, gestures, animations, hit regions and thresholds, landscape, dark mode, cutouts/safe areas, input-type variations, and return-key states. Acceptance is evidence-based diffing, not subjective similarity.

## G — Phase 7 stability/CI/release matrix

Prepare tests for extension termination/recreation, low memory, background recovery, cross-app switching, offline/slow network, denied permissions, open-access disabled, Core tests, replay tests, Swift parsing, all final Xcode targets, unsigned packaging, Keyboard-first signing, Host-last signing, entitlement validation, signed IPA verification, and continuous real-device functional/visual/performance typing regressions. Final release evidence must list remaining differences explicitly rather than assigning a percentage-complete estimate.
