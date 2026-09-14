# Phase 2 V14 UI migration — slice 1

Date: 2026-09-14
Branch: `work/v14-clawbase-ui`
Base: `d5f8d0a1ca613d6a42328df5be09d38b44ae6096`

## Gate satisfied

The Phase 1 CI-signed `ClawBase-3.0.1-2-signed.ipa` was installed on the real device and the Host app launched successfully. The proven installability identity is therefore frozen: Host `app.lgm.7517`, Keyboard `app.lgm.7517.123`, App Group `group.7518554`, version/build `3.0.1 (2)`, two targets, Keyboard-first signing and Host-last signing.

## Slice 1 scope

Migrate only the first V14 keyboard UI region into ClawBase:

- keyboard extension shell / SwiftUI host;
- candidate bar and composition row;
- measured WeType 3.5.3 26-key pinyin geometry;
- dynamic light/dark keyboard palette already extracted in V14;
- clean-room glyphs required by the candidate bar;
- deterministic `WTPreviewIMEEngine` for visual and interaction smoke tests;
- real document-proxy insert/delete/space/return/candidate selection and next-keyboard wiring.

The Preview Engine remains a temporary UI migration backend and is not the final Hamster/librime implementation.

## Deliberately excluded from slice 1

Do not compile into this ClawBase slice yet:

- `iOSServices`;
- `HamsterBridge`;
- the full `WTKeyboardInputViewController` service binding;
- the full `WTPanelRootView` and later panels;
- Host settings migration;
- speech, network providers, device sync, share/widget/live-activity targets.

Those enter only after this slice again produces an installable signed IPA and passes a real-device regression.

## Acceptance

1. Static CI contract preserves all Phase 1 bundle/signing/installability identities.
2. Simulator and unsigned device build succeed.
3. Signed validation succeeds with the existing two provisioning profiles.
4. CI uploads the signed IPA.
5. On device, CLAW TALK can be selected as a keyboard and shows the V14 candidate bar plus the 26-key pinyin surface.
6. Typing `nihao` through the Preview Engine shows the deterministic candidate `你好`; selecting it commits into the host app.
7. Globe/next-keyboard, delete, space and return do not crash.
