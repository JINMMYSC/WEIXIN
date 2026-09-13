# V12 pre-CI report

CI is intentionally deferred. V12 exhausts additional checks and implementation work that can be completed in the current environment.

## Passed gates

- `swift test`: **72/72**
- all Swift files: `swiftc -parse` pass
- plist + entitlements: `plutil -lint` pass
- `verify_v11_pre_ci.py`: pass
- `verify_v12_pre_ci.py`: pass
- transfer protocol V3 contract: pass
- IME commit-drain / space / input-mode propagation tests: pass
- Share App Group + staged-provider + await-send contract: pass
- Live Activity lifecycle/deep-link contract: pass

## Production boundary that remains intentionally unclaimed

No macOS/Xcode/iOS SDK compile has been performed in this environment. No signing or IPA installation has been claimed. `WTPreviewIMEEngine` remains Debug-only; Release still requires the concrete Hamster/librime adapter.
