# Xcode integration (V6)

This folder turns the clean-room overlay into concrete Xcode targets on a Mac.

## Targets

- `WeTypeReplicaApp` — host/settings app.
- `WeTypeReplicaKeyboard` — custom keyboard extension.
- `WeTypeReplicaShare` — share extension / quick-send entry.
- `WeTypeReplicaWidget` — normal widget target.
- `WeTypeReplicaVoiceWidget` — voice-entry widget target.

The checked-in identifiers are placeholders. Change `PRODUCT_BUNDLE_IDENTIFIER`, `DEVELOPMENT_TEAM`, and `WT_APP_GROUP_ID` in `Config.xcconfig` before signing.

The keyboard target must have `RequestsOpenAccess = YES` only if network/App Group operations are enabled by the user. The overlay itself remains functional without cloud providers.

## Hamster/Rime handoff

`WTHamsterRimeSessionAdapter` is now typed. Conform the Rime session/controller owned by the Hamster revision to `WTHamsterRimeSessionProtocol`; no UI code needs to import Hamster internals. See `Templates/HamsterSessionConformanceTemplate.swift`.

## Validation boundary

Linux CI can validate Swift syntax and the Core package. Real SDK compilation, signing, App Group access, keyboard privacy behavior and extension memory limits still require macOS/Xcode/iPhone.
