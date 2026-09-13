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
