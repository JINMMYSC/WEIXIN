# ClawBase Phase 1 execution plan

Date: 2026-09-14

## Build and validation sequence

1. Keep `work/v14-signed-device` based on the verified remote baseline until the ClawBase change is committed.
2. Generate only the isolated `ClawBase` Xcode project.
3. Run the static contract verifier before Xcode compilation.
4. Build the Host + Keyboard for Simulator as a compile gate.
5. Build Release for generic iOS with code signing disabled.
6. Validate the built Host/Keyboard bundle identifiers, package types, 3.0.1/build 2, keyboard extension point, principal class, language, open-access declaration, ASCII/RTL flags, and exactly one embedded extension.
7. Package an unsigned diagnostic IPA.
8. Import the signing identity into an ephemeral keychain and decode Host/Keyboard profiles into an ephemeral directory.
9. Validate exact profile identities, Team ID, App Group, distribution `get-task-allow`, and allowed keychain groups.
10. Construct minimal entitlements, sign Keyboard first, sign Host last, verify profiles and final code signatures.
11. Upload complete ClawBase logs on every run and upload the signed IPA only on success.
12. Inspect the CI-produced IPA metadata and SHA-256. Do not resign it after download.
13. Real-device acceptance: install directly over ClawTalk 3.0.0, launch Host, add keyboard, display keyboard, type/switch across apps without crash.
14. Only after real-device acceptance, begin Phase 2 code migration.

## Failure handling

On a failed ClawBase workflow, read the first causal error from the failing job. Make the smallest correction that addresses that cause, append the result to `CI_FIX_LOG.md`, commit/push once, and rerun through the normal branch push trigger. Do not make speculative multi-fix batches.

## Evidence required at the Phase 1 handoff

- branch name
- full commit SHA
- GitHub Actions run URL
- signed artifact name
- signed IPA SHA-256
- static/runtime validation results
- exact remaining real-device checks
