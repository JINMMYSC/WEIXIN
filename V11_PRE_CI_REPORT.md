# V11 pre-CI report

V11 intentionally stops before remote CI and performs every currently available local gate first.

## Passed gates
- `swift test`: 64/64
- `swiftc -parse`: 92 Swift files
- `plutil -lint`: 5 plist + 5 entitlement files
- XcodeGen YAML structural load: 5 targets
- Host app embeds Keyboard / Share / Widget / Voice Activity
- `verify_no_system_symbols.py`: pass
- `verify_v11_pre_ci.py`: pass
- `verify_v10_integration.py`: pass

## Release boundary
`WTKeyboardInputViewController.makeIMEEngine()` uses `WTPreviewIMEEngine` only in Debug. Release returns no engine until the real Hamster/librime adapter is attached. This is deliberate so a debug smoke build cannot accidentally be mistaken for the final Chinese IME.
