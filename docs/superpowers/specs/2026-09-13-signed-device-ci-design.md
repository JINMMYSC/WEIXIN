# Signed Device CI Design

## Goal

Add a signing-only CI path on `work/v14-signed-device` that produces an installable Host + Keyboard diagnostic IPA without changing the verified unsigned V14 baseline on `work/v14-ci`.

The signed artifact must use separate provisioning profiles for the two independently signed bundles:

- Host App: `app.lgm.7517`
- Keyboard Extension: `app.lgm.7517.123`
- Shared App Group: `group.7518554`
- Team ID: `X5G6AN3DYX`

The workflow must never commit, print, or upload raw signing secrets.

## Architecture

Create a separate signed-device workflow and signing script instead of adding signing branches to the existing unsigned workflow. The existing `ios-unsigned-ci.yml` remains the authoritative build/compile regression gate.

The signed-device workflow will:

1. Check out `work/v14-signed-device`.
2. Install XcodeGen.
3. Build the existing Host + Keyboard sideload diagnostic package without signing.
4. Import the distribution certificate from GitHub Actions Secrets into an ephemeral keychain.
5. Decode the Host and Keyboard provisioning profiles from GitHub Actions Secrets into temporary runner files.
6. Copy the Keyboard profile into `WeTypeReplicaKeyboard.appex/embedded.mobileprovision`.
7. Derive signing entitlements from that Keyboard profile and sign the Keyboard executable/bundle first.
8. Copy the Host profile into `WeTypeReplicaApp.app/embedded.mobileprovision`.
9. Derive signing entitlements from the Host profile and sign the Host app last.
10. Verify the final signatures and identifiers before packaging.
11. Package and upload the signed IPA plus a redacted validation log.
12. Delete the ephemeral keychain and temporary signing files even when the job fails.

## Secret Inputs

The repository will reference secret names only. Secret values stay outside git and outside logs.

Required secrets:

- `WT_SIGNING_P12_BASE64`
- `WT_SIGNING_P12_PASSWORD`
- `WT_HOST_PROFILE_BASE64`
- `WT_KEYBOARD_PROFILE_BASE64`

The two provisioning profiles and P12 can be populated from the user's existing local signing materials. The P12 password must come from a legitimate known source; the workflow must not guess or brute-force it.

## Signing Order and Entitlements

The Keyboard Extension and Host App are separate code-signing units. The workflow must never reuse one provisioning profile for both bundles.

Required order:

1. Sign `WeTypeReplicaKeyboard.appex` with the Keyboard provisioning profile.
2. Sign `WeTypeReplicaApp.app` with the Host provisioning profile.

For each bundle, the workflow extracts the provisioning profile's `Entitlements` dictionary and uses it as the codesign entitlements input. This avoids silently signing a bundle with the other bundle's `application-identifier`.

## Hard Validation Gates

The job fails before artifact upload unless all of the following are true:

- Host `CFBundleIdentifier` is `app.lgm.7517`.
- Keyboard `CFBundleIdentifier` is `app.lgm.7517.123`.
- Host embedded profile has `application-identifier = X5G6AN3DYX.app.lgm.7517`.
- Keyboard embedded profile has `application-identifier = X5G6AN3DYX.app.lgm.7517.123`.
- Both profiles contain `group.7518554` in `com.apple.security.application-groups`.
- `codesign -d --entitlements :-` for Host and Keyboard reports the matching application identifiers and App Group.
- `codesign --verify --deep --strict` succeeds for the final Host bundle.
- The final app contains exactly the intended Keyboard extension for this diagnostic package.

The validation log may report identifiers, profile names, UUIDs, and hashes, but it must not print certificate private material, P12 content, provisioning file content, or secret values.

## Failure Handling

A failed signing/import/verification step stops the job immediately. The CI repair loop uses the first causal error, makes the smallest fix, commits to `work/v14-signed-device`, and reruns until the signed artifact is produced and passes all validation gates.

The ephemeral keychain and decoded secret files are removed in an `always()` cleanup step.

## Success Criteria

The task is complete when:

- the signed-device workflow is green on `work/v14-signed-device`;
- the signed IPA artifact is present;
- the artifact passes the Host/Keyboard identifier, profile, App Group, and codesign gates;
- the final branch commit, Actions run URL, artifact name, and IPA SHA-256 are recorded;
- the only remaining step is installation and Keyboard Runtime Validation on the provisioned iPhone.
