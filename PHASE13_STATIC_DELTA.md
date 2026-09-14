# Phase 13 — WeChat Input Method 3.5.3 static parity delta

Target: clean-room reproduction of user-observable WeChat Input Method 3.5.3 behavior and presentation.

## Fixed in this phase

- Package marketing version aligned from 3.0.1 to 3.5.3.
- Package build version aligned to 3.5.3.
- Widget extension display name aligned to 微信输入法.
- Voice Live Activity extension display name aligned to 语音输入.

## Confirmed aligned / structurally covered

- Host display name 微信输入法.
- Keyboard display name 微信输入法.
- Share extension display name 隔空传送.
- Keyboard extension point is com.apple.keyboard-service.
- Keyboard PrimaryLanguage is zh-Hans and RequestsOpenAccess is true.
- Host minimum iOS target is 15.1.
- Keyboard minimum iOS target is 15.1.
- Host embeds four extensions in the unsigned package topology: keyboard, share, widget, voice activity.
- Host SetupMain uses the observed 14-entry order and routes into V14 detail settings.
- Existing static gates cover the 79-case structural matrix and extracted runtime geometry.

## Remaining static/package deltas

### P0 — blocks a true full-package validation

1. The latest integration CI was cancelled during the four-extension unsigned Xcode build. Re-run and finish the build to prove that all four extensions coexist in one produced IPA.
2. Share / Widget / VoiceActivity provisioning profiles are not available in the current signing configuration. A fully signed four-extension IPA cannot be produced until those three extension profiles are supplied.
3. Same-device original-reference evidence is still missing: visual parity has not been proven against real 3.5.3 screenshots/video and IME output probes have no captured original results.

### P1 — visible UI / interaction differences still to close

1. SetupMain icons currently use independently rendered semantic glyphs positioned using extracted geometry. They do not yet reproduce the original icon artwork pixel-for-pixel. Replace with independently recreated clean-room vector assets after reference capture.
2. Host app icon asset catalog is not present in ClawBase/Host. Add an independently recreated app icon set and bind it as the primary app icon.
3. Original bundle contains a custom WE-Regular font. It must not be copied. Use a licensed/system replacement and calibrate text metrics against captures.
4. Key popup, long-press popup, shadows, corner radii, text metrics and animation timing are structurally modeled but still require same-device video measurement for pixel/timing parity.
5. Gesture thresholds have a centralized WT353GestureModel, but WTKeyboardCanvasView still contains duplicated literal thresholds. Wire the shipping key-cap gesture path to WT353GestureModel so one calibrated source controls swipe, long-press glide and delete gestures.
6. Several Host detail-page buttons remain placeholders/no-op and need deterministic local behavior where observable (system settings jump, clipboard clear, reset defaults, local device management/migration states).

### P1 — IME behavior differences

1. Current engine is Rime/librime based, not Tencent wxime. Candidate ordering, segmentation, composition, prediction, punctuation and commit behavior must be calibrated from black-box 3.5.3 outputs.
2. Phase 11 analyzer can classify deltas but cannot invent original outputs. Capture the original 122-probe matrix on device and feed it to the analyzer.
3. Candidate compatibility logic may safely reorder candidates already produced locally; it must not synthesize Tencent-only private data.

### P2 — advanced / ecosystem differences

1. Original package contains Metadata.appintents and richer widget/app-intent integration. Replica needs independently implemented AppIntent surfaces if they are user-observable in 3.5.3.
2. Original package contains RNBundles and other app resources. Only reproduce user-observable screens/functions; do not copy private bundles.
3. Original keyboard bundle is much larger because it contains proprietary imeData/model assets. Replica intentionally uses independent Rime resources, so package size will remain different unless clean-room models/resources are added.
4. Local transfer protocol is an independent _wtreplica._tcp implementation, not Tencent's private protocol. Match user-visible transfer workflow only.
5. Book/video/rich-content provider path is now pluggable but still depends on a user-controlled provider; it does not reproduce Tencent private backend content.

## Internal differences intentionally not copied

- Tencent bundle identifiers.
- Tencent private class names / executables.
- Tencent fonts, image assets, model files, dictionaries, private endpoints and transfer protocol.

These are not required for a clean-room user-observable replica and must remain independently implemented.
