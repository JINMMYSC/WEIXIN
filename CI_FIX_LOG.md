# CI repair log

## Baseline

- Source: `WeTypeReplicaOverlay_v14.zip`, supplied by the user on 2026-09-13.
- Pre-CI evidence inherited from V14: 87 Core tests, 121 parsed Swift files, and 10 plist/entitlement files.
- Existing Mac validation gap: `XcodeIntegration/validate_on_mac.sh` omitted `WeTypeReplicaVoiceActivity` and did not produce a device build or IPA.

## CI changes before the first run

- Added one repeatable Mac entry point that runs Core tests, XcodeGen, all five simulator schemes, an unsigned device build, IPA packaging, SHA-256 reporting, and embedded-extension listing.
- Added a GitHub Actions workflow on `macos-15` with unconditional complete-log upload and successful-build IPA/app upload.
- Added `WeTypeReplicaVoiceActivity` to the existing Mac validation matrix.
- Replaced the inherited `ios-build.yml`, which omitted Voice Activity and artifact packaging, with the complete unsigned workflow so pushes do not start two competing build matrices.

## Real Xcode runs

### Run 1 — failed before compilation

- Run: `34745214999`
- Error: `env: bash\r: No such file or directory` while launching `XcodeIntegration/ci_unsigned_build.sh`.
- Root cause: the V14 archive was prepared on Windows without a Git attributes policy, so shell scripts reached the macOS runner with CRLF line endings.
- Fix: enforce LF for shell scripts and other source/config text through `.gitattributes`; verify the staged shell-script bytes before creating each CI archive.

### Run 2 — Share Extension actor isolation

- Run: `34745437051`
- Error: `WTQuickSendShareViewController.swift:137:15: call to main actor-isolated instance method 'stop()' in a synchronous nonisolated context`.
- Root cause: Swift treats `deinit` as nonisolated, while `WTQuickSendShareModel` and its `stop()` method are isolated to the main actor.
- Fix: stop discovery and hosting from `viewDidDisappear(_:)`, which inherits the controller's main actor isolation; keep `deinit` limited to synchronous temporary-file cleanup.

## Signed-device dual-profile repair

- Verified unsigned baseline remains `work/v14-ci` at `00e3cc3a09b83946e728d7431b310d5ae5c2afd6` with successful run `34753946196`.
- Verified Host+Keyboard diagnostic baseline remains `work/v14-signed-device` at `fec044bdec7d37b0e3f33647481b52baf146a9cc` with successful run `34757975913`.
- Device-install blocker reproduced from the phone-signed IPA: the outer Host bundle kept `CFBundleIdentifier=app.lgm.7517`, but its embedded provisioning profile and actual signing entitlements were replaced with the Keyboard identity `X5G6AN3DYX.app.lgm.7517.123`.
- Root cause: the phone-side signer applied one provisioning profile to both independently signed bundles, overwriting the Host profile during final resigning.
- CI repair: add an isolated signed-device workflow, import the signing identity into an ephemeral keychain, apply the Keyboard profile to `WeTypeReplicaKeyboard.appex`, sign the Keyboard first, apply the Host profile to `WeTypeReplicaApp.app`, sign the Host last, and fail before upload unless both profile and codesign entitlements match their exact application identifiers and `group.7518554`.
- First registration attempt exposed a GitHub Actions constraint: a brand-new `workflow_dispatch` workflow that exists only on `work/v14-signed-device` is not addressable through the Actions workflow API because it is absent from the default branch. The signed workflow therefore uses a `push` trigger restricted exactly to `work/v14-signed-device`, preserving branch isolation without modifying `main`.
- Signing certificate, P12 password, and raw provisioning files remain outside git and are supplied only through GitHub Actions Secrets.
- Signed run `34765997833` reached real signing: secret validation, XcodeGen, unsigned build, and ephemeral signing identity/profile preparation all passed. The first causal signing-step error was `XcodeIntegration/ci_signed_device_package.sh: /bin/cmp: No such file or directory`; macOS exposes `cmp` at `/usr/bin/cmp`, so the profile-integrity checks were corrected to use that path.
- Signed run `34768092373` then passed dual-profile codesign and artifact validation, but the resulting IPA was still rejected by the iPhone installer. Follow-up inspection verified that the imported signing certificate is present in both provisioning profiles, the registered device UDID is present in both profiles, and both profiles remain valid through 2027-07-15. The remaining signing difference was that the script copied each profile's entire Entitlements dictionary into the code signature, including many capabilities the Host/Keyboard targets never request. A regression gate now forbids wholesale profile entitlement copying; the signing script instead builds a minimal target entitlement set (application/team identifiers, distribution get-task-allow, one App Group, and one default keychain group) and verifies the post-sign entitlement key set exactly.
- Signed run `34769620646` also passed after entitlement minimization but was still rejected by the device. Inspecting the actual IPA payload exposed the first install-structure defect: `WeTypeReplicaKeyboard.appex/Info.plist` contained only Xcode's generic bundle metadata and had lost the entire `NSExtension` dictionary (`com.apple.keyboard-service`, principal class, open-access flag, and primary language). The checked-in plist still contained those keys; XcodeGen's target `info:` generation was rewriting that file before the build. The project now wires every checked-in plist through `INFOPLIST_FILE` with `GENERATE_INFOPLIST_FILE=NO`, and the unsigned packaging gate fails unless the built Keyboard plist contains the exact keyboard extension point, principal class, open-access declaration, and `zh-Hans` primary language.
- Run `34771700650` proved that the final Keyboard plist now preserves the extension metadata: the unsigned package gate passed. Signing then exited before codesign because the checked-in plists had never declared the standard bundle keys that XcodeGen's generated plist had previously supplied, so `CFBundleIdentifier` was absent when the signing script read it. The checked-in Host and extension plists now explicitly include the standard executable/identifier/package/version keys with build-setting expansion, the project defines one shared marketing/build version, and the unsigned package gate now validates Host/Keyboard identifiers, executable names, package types, and matching versions before signing.
