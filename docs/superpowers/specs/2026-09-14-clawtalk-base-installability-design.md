# ClawTalk-derived ClawBase installability design

Date: 2026-09-14
Branch: `work/v14-signed-device`
Repository: `JINMMYSC/WEIXIN`

## Goal

Phase 1 exists only to prove an installable iOS Host + custom Keyboard Extension package before Replica V14 functionality is migrated. The package must directly replace the already-installed ClawTalk 3.0.0 because it intentionally uses the same application identities, but it must use a higher version: 3.0.1 build 2.

Success is not defined by a green CI run alone. Success requires the CI-produced IPA, without any phone-side or third-party resigning, to install over ClawTalk 3.0.0 on the target iPhone and to launch the Host, allow the keyboard to be added, display the keyboard, and survive cross-app use.

## Identity contract

- Host bundle ID: `app.lgm.7517`
- Keyboard bundle ID: `app.lgm.7517.123`
- Apple Team ID: `X5G6AN3DYX`
- Shared App Group: `group.7518554`
- Marketing version: `3.0.1`
- Build: `2`
- Keyboard extension point: `com.apple.keyboard-service`
- Keyboard principal class: `HamsterKeyboard.HamsterKeyboardInputViewController`
- Primary language: `zh-Hans`
- Requests open access: `true`

## Scope boundary

ClawBase is an isolated two-target XcodeGen project under `ClawBase/`. Phase 1 intentionally does not import `WeTypeReplicaCore`, `iOSOverlay`, `iOSShared`, `iOSServices`, `HamsterBridge`, Replica panels, Rime, AI, speech, translation, widgets, Share Extension, Live Activity, or other V14 functionality.

`JINMMYSC/CLAW` is reference-only. No code, branch, workflow, history, or artifact in CLAW is modified by this work. All new source, CI, validation, and documentation lives in `JINMMYSC/WEIXIN`.

## Signing contract

The GitHub Actions job obtains the certificate and two provisioning profiles only from repository secrets. It decodes them into an ephemeral directory and keychain on the macOS runner.

The signing script must:

1. Validate Host and Keyboard profiles against their exact application identifiers and Team ID.
2. Validate both profiles contain `group.7518554`.
3. Build a minimal target entitlement set rather than copying the profile entitlement dictionary wholesale.
4. Embed the Keyboard profile and sign the Keyboard first.
5. Embed the Host profile and sign the Host last.
6. Verify the embedded profiles are unchanged.
7. Re-read signed entitlements and require the expected five-key set.
8. Run strict Keyboard and deep Host codesign verification.
9. Re-validate bundle IDs, version/build, keyboard extension metadata, and extension count.
10. Produce `ClawBase-3.0.1-2-signed.ipa` and its SHA-256.

Raw certificates, profile contents, and passwords must never be committed or printed.

## Phase gate

Phase 2 may begin only after the user confirms the unmodified CI IPA installs on the real device and the minimal Host + Keyboard checks pass. Until then, Phases 2-7 may produce analysis, mappings, test matrices, and documentation only.
