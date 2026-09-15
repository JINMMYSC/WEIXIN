# Phase 14 Visual Convergence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the first ten high-information light-mode scenes reproducibly measurable and correct the shared 26-key, keyboard-theme, Host home, and Display Settings surfaces toward WeChat Input 3.5.3 on iPhone 15 Pro Max.

**Architecture:** Keep extracted bundle layouts immutable and add a tested resolved-layout layer for state- and viewport-dependent frames. Store visual evidence selection in a validated Phase 14 manifest, render the Host home and Display Settings through focused SwiftUI views, and use the existing visual-diff tool for paired device evidence.

**Tech Stack:** Swift 6, SwiftUI, XCTest, Python 3, Pillow, NumPy, FFmpeg, XcodeGen, GitHub Actions.

## Global Constraints

- Target device is iPhone 15 Pro Max at 430 x 932 pt and 3x scale.
- Target OS is iOS 26.2.1; package deployment floor remains iOS 15.
- Target reference is WeChat Input 3.5.3.
- Work continues on `work/v14-phase13-static-delta`; `main` is not replaced.
- Preserve Host App, Keyboard, Share, Widget, Voice/Live Activity targets and existing App Group behavior.
- Do not commit original user recordings, absolute user paths, credentials, signing identities, certificates, or provisioning profiles.
- Dark mode and scenes outside `01`, `02`, `04`, `06`, `07`, `08`, `10`, `14`, `23`, and `27` remain outside this phase.
- A scene cannot pass without `REF`, `REP`, diff artifacts, and review JSON.

---

### Task 1: Add the reproducible Phase 14 reference manifest

**Files:**
- Create: `ReverseEngineering/Phase14/reference_capture_manifest.json`
- Create: `Tools/extract_phase14_reference_frames.py`
- Create: `Tools/tests/test_extract_phase14_reference_frames.py`
- Modify: `Tools/verify_v14_pre_ci.py`

**Interfaces:**
- Consumes: a caller-supplied video root and FFmpeg executable.
- Produces: `load_manifest(path: Path) -> dict`, `validate_manifest(manifest: dict) -> list[str]`, and one 1290 x 2796 PNG per manifest capture.

- [ ] **Step 1: Write the failing manifest tests**

```python
class ManifestTests(unittest.TestCase):
    def test_manifest_has_exact_phase14_ids(self):
        manifest = load_manifest(MANIFEST)
        self.assertEqual(
            [c["id"] for c in manifest["captures"]],
            ["01", "02", "04", "06", "07", "08", "10", "14", "23", "27"],
        )

    def test_manifest_is_portable_and_valid(self):
        manifest = load_manifest(MANIFEST)
        self.assertEqual(validate_manifest(manifest), [])
        for capture in manifest["captures"]:
            self.assertFalse(Path(capture["video"]).is_absolute())
            self.assertEqual(capture["expectedPixels"], [1290, 2796])

    def test_duplicate_id_is_rejected(self):
        manifest = load_manifest(MANIFEST)
        manifest["captures"].append(dict(manifest["captures"][0]))
        self.assertIn("duplicate capture id: 01", validate_manifest(manifest))
```

- [ ] **Step 2: Run the test and verify RED**

Run: `python -m unittest Tools.tests.test_extract_phase14_reference_frames -v`  
Expected: FAIL because `extract_phase14_reference_frames` and the manifest do not exist.

- [ ] **Step 3: Add the ten-entry manifest**

Use this schema for every entry:

```json
{
  "formatVersion": 1,
  "targetVersion": "3.5.3",
  "device": "iPhone 15 Pro Max",
  "os": "iOS 26.2.1",
  "captures": [
    {
      "id": "01",
      "scene": "keyboard26-light",
      "video": "视频8/IMG_1263_part_008.mp4",
      "timestampSeconds": 130.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "English 26-key idle; geometry proxy only because Chinese 26 canonical state is absent",
      "eligibleForStrictReview": false
    },
    {
      "id": "02",
      "scene": "keyboard9-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 10.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Chinese nine-key candidates visible",
      "eligibleForStrictReview": true
    },
    {
      "id": "04",
      "scene": "symbol-cn-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 30.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Chinese symbol grid visible",
      "eligibleForStrictReview": true
    },
    {
      "id": "06",
      "scene": "emoji-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 60.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Emoji grid visible",
      "eligibleForStrictReview": true
    },
    {
      "id": "07",
      "scene": "clipboard-light",
      "video": "视频5/IMG_1263_part_005_part_003.mp4",
      "timestampSeconds": 25.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Clipboard list visible",
      "eligibleForStrictReview": true
    },
    {
      "id": "08",
      "scene": "handwriting-light",
      "video": "视频8/IMG_1263_part_008.mp4",
      "timestampSeconds": 100.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Handwriting canvas with written character and candidates",
      "eligibleForStrictReview": true
    },
    {
      "id": "10",
      "scene": "voice-listening-light",
      "video": "视频8/IMG_1263_part_008.mp4",
      "timestampSeconds": 222.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Voice-to-text listening page active",
      "eligibleForStrictReview": true
    },
    {
      "id": "14",
      "scene": "plus-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 80.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Plus feature grid visible",
      "eligibleForStrictReview": true
    },
    {
      "id": "23",
      "scene": "settings-home-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 100.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 420, 210, 210]],
      "state": "Host settings home two-column grid at top",
      "eligibleForStrictReview": true
    },
    {
      "id": "27",
      "scene": "settings-display-light",
      "video": "视频1/IMG_1263_part_001.mp4",
      "timestampSeconds": 200.0,
      "expectedPixels": [1290, 2796],
      "excludeMasks": [[1080, 140, 210, 210]],
      "state": "Display settings page top",
      "eligibleForStrictReview": true
    }
  ]
}
```

The `01` frame is deliberately marked measurement-only: it is a clean 26-key geometry reference but not the required Chinese 26-key state. The evidence gate must keep scene `01` incomplete until a canonical Chinese frame is supplied.

- [ ] **Step 4: Implement validation and extraction**

```python
def load_manifest(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))

def validate_manifest(manifest: dict) -> list[str]:
    errors: list[str] = []
    ids: set[str] = set()
    for capture in manifest.get("captures", []):
        capture_id = str(capture.get("id", ""))
        if capture_id in ids:
            errors.append(f"duplicate capture id: {capture_id}")
        ids.add(capture_id)
        if Path(str(capture.get("video", ""))).is_absolute():
            errors.append(f"absolute video path: {capture_id}")
        if capture.get("expectedPixels") != [1290, 2796]:
            errors.append(f"unexpected dimensions: {capture_id}")
    return errors
```

The CLI accepts `--video-root`, `--manifest`, `--output`, and `--ffmpeg`. It invokes FFmpeg with `-ss`, `-frames:v 1`, and `-compression_level 3`, then verifies the PNG dimensions with Pillow. It exits non-zero on missing media, invalid timestamp, extraction failure, or wrong dimensions.

- [ ] **Step 5: Run the test and verify GREEN**

Run: `python -m unittest Tools.tests.test_extract_phase14_reference_frames -v`  
Expected: 3 tests pass.

- [ ] **Step 6: Add manifest validation to the pre-CI verifier**

Import `load_manifest` and `validate_manifest`, validate `ReverseEngineering/Phase14/reference_capture_manifest.json`, and emit `Phase14 reference manifest: 10 captures` on success. Do not require the user-owned MP4 files in CI.

- [ ] **Step 7: Run the repository verifier**

Run: `python Tools/verify_v14_pre_ci.py`  
Expected: exit 0 and the Phase 14 manifest success line.

- [ ] **Step 8: Commit**

```bash
git add ReverseEngineering/Phase14/reference_capture_manifest.json Tools/extract_phase14_reference_frames.py Tools/tests/test_extract_phase14_reference_frames.py Tools/verify_v14_pre_ci.py
git commit -m "test: add phase14 reference capture manifest"
```

### Task 2: Add tested light palette and resolved keyboard geometry contracts

**Files:**
- Create: `Sources/WeTypeReplicaCore/Phase14VisualContract.swift`
- Create: `Tests/WeTypeReplicaCoreTests/Phase14VisualContractTests.swift`
- Modify: `Sources/WeTypeReplicaCore/ThemeTokens.swift`

**Interfaces:**
- Produces: `WTPhase14Palette353`, `WTResolvedKeyFrame353`, and `WTKeyboardGeometryResolver353.resolve(layout:viewportWidth:)`.
- Consumes: `WTKeyboardLayout`, `WTKeyboardItem`, `WTRect`, and `WTRGBAHex` from the existing Core model.

- [ ] **Step 1: Write failing palette tests**

```swift
func testMeasuredLightPalette() {
    XCTAssertEqual(WTPhase14Palette353.keyboardBackground, "#DDDEE2")
    XCTAssertEqual(WTPhase14Palette353.normalKey, "#FFFFFF")
    XCTAssertEqual(WTPhase14Palette353.grayKey, "#AFB4BD")
    XCTAssertEqual(WTPhase14Palette353.accent, "#1FC085")
    XCTAssertEqual(WTPhase14Palette353.hostBackground, "#E2F1F0")
}
```

- [ ] **Step 2: Write failing 26-key geometry tests**

```swift
func testT26BottomRowMatchesMeasured430PointContract() throws {
    let result = WTKeyboardGeometryResolver353.resolve(
        layout: WTLayouts353.t26Pinyin,
        viewportWidth: 430
    )
    let frames = Dictionary(uniqueKeysWithValues: result.map { ($0.id, $0.frame) })
    XCTAssertEqual(try XCTUnwrap(frames["KEY_123"]).width, 74.7, accuracy: 1.5)
    XCTAssertEqual(try XCTUnwrap(frames["KEY_,"]).width, 31.3, accuracy: 1.5)
    XCTAssertEqual(try XCTUnwrap(frames["KEY_SPACE"]).width, 149.0, accuracy: 1.5)
    XCTAssertEqual(try XCTUnwrap(frames["KEY_CHANGE"]).width, 34.3, accuracy: 1.5)
    XCTAssertEqual(try XCTUnwrap(frames["KEY_RETURN"]).width, 80.0, accuracy: 1.5)
}

func testResolvedT26BottomRowIsOrderedAndNonOverlapping() {
    let frames = WTKeyboardGeometryResolver353.resolve(layout: WTLayouts353.t26Pinyin, viewportWidth: 430)
        .filter { ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"].contains($0.id) }
        .sorted { $0.frame.x < $1.frame.x }
    XCTAssertEqual(frames.map(\.id), ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"])
    for pair in zip(frames, frames.dropFirst()) {
        XCTAssertLessThanOrEqual(pair.0.frame.x + pair.0.frame.width, pair.1.frame.x)
    }
}
```

- [ ] **Step 3: Write the nine-key regression test**

```swift
func testT9MeasuredGeometryDoesNotRegress() throws {
    let result = WTKeyboardGeometryResolver353.resolve(layout: WTLayouts353.t9Pinyin, viewportWidth: 430)
    let key2 = try XCTUnwrap(result.first { $0.id == "KEY_2" })
    XCTAssertEqual(key2.frame.width, 83.7, accuracy: 1.5)
    XCTAssertEqual(key2.frame.height, 49.3, accuracy: 1.5)
}
```

- [ ] **Step 4: Run tests and verify RED**

Run: `swift test --filter Phase14VisualContractTests`  
Expected: FAIL because the Phase 14 contract types do not exist.

- [ ] **Step 5: Implement the value types and resolver**

```swift
public enum WTPhase14Palette353 {
    public static let keyboardBackground = "#DDDEE2"
    public static let normalKey = "#FFFFFF"
    public static let grayKey = "#AFB4BD"
    public static let accent = "#1FC085"
    public static let hostBackground = "#E2F1F0"
}

public struct WTResolvedKeyFrame353: Equatable, Sendable {
    public let id: String
    public let frame: WTRect
}

public enum WTKeyboardGeometryResolver353 {
    public static func resolve(layout: WTKeyboardLayout, viewportWidth: Double) -> [WTResolvedKeyFrame353] {
        let scale = viewportWidth / layout.baseSize.width
        let raw = layout.items.compactMap { item -> WTResolvedKeyFrame353? in
            guard let rect = item.rect else { return nil }
            return .init(id: item.id, frame: .init(x: rect.x * scale, y: rect.y, width: rect.width * scale, height: rect.height))
        }
        guard layout.items.contains(where: { $0.id == "KEY_Q" }), viewportWidth == 430 else { return raw }
        return resolveT26BottomRow(in: raw)
    }
}
```

Implement `resolveT26BottomRow(in:)` with explicit measured widths, 5 pt outer insets, and equal calculated gaps. Preserve raw y and height. Omit resource-only bottom-row entries `KEY_EMOTION`, `KEY_SWITCH`, and `KEY_At` from the resolved 3.5.3 row.

- [ ] **Step 6: Point light theme tokens to the measured values**

Set only the light members of `WTTheme353.keyboardBackground`, `normalBackground`, `grayBackground`, and `accent` to the Phase 14 values. Preserve existing dark members unchanged.

- [ ] **Step 7: Run tests and verify GREEN**

Run: `swift test --filter Phase14VisualContractTests`  
Expected: all Phase 14 contract tests pass.

- [ ] **Step 8: Run all Core tests**

Run: `swift test`  
Expected: all included `WeTypeReplicaCoreTests` pass with zero failures.

- [ ] **Step 9: Commit**

```bash
git add Sources/WeTypeReplicaCore/Phase14VisualContract.swift Sources/WeTypeReplicaCore/ThemeTokens.swift Tests/WeTypeReplicaCoreTests/Phase14VisualContractTests.swift
git commit -m "feat: add measured phase14 visual contracts"
```

### Task 3: Render the resolved 26-key layout in the keyboard extension

**Files:**
- Modify: `iOSOverlay/WTKeyboardCanvasView.swift`
- Modify: `iOSOverlay/WTKeyboardRuntime.swift`
- Modify: `Tools/verify_v14_pre_ci.py`

**Interfaces:**
- Consumes: `WTKeyboardGeometryResolver353.resolve(layout:viewportWidth:)`.
- Produces: final key frames used by `WTKeyboardCanvasView` for both drawing and hit testing.

- [ ] **Step 1: Add a failing static integration assertion**

Add to `verify_v14_pre_ci.py`:

```python
canvas = read("iOSOverlay/WTKeyboardCanvasView.swift")
require(canvas, "WTKeyboardGeometryResolver353.resolve(")
require(canvas, "resolvedFrameByID")
require_absent(canvas, "ForEach(layout.items, id: \\.id)")
```

- [ ] **Step 2: Run verifier and verify RED**

Run: `python Tools/verify_v14_pre_ci.py`  
Expected: FAIL because the canvas still iterates raw layout frames.

- [ ] **Step 3: Resolve frames once per viewport**

Inside `GeometryReader`, create:

```swift
let resolvedFrames = WTKeyboardGeometryResolver353.resolve(
    layout: layout,
    viewportWidth: Double(proxy.size.width * runtime.keyboardAdjustment.widthScale)
)
let resolvedFrameByID = Dictionary(uniqueKeysWithValues: resolvedFrames.map { ($0.id, $0.frame) })
let visibleItems = layout.items.filter { resolvedFrameByID[$0.id] != nil }
```

Render `visibleItems`, obtain each frame from `resolvedFrameByID`, and use that same frame for `.frame`, `.position`, popup source rectangles, and hit targets. Do not keep a second raw-rectangle hit-testing path.

- [ ] **Step 4: Run verifier and Core tests**

Run: `python Tools/verify_v14_pre_ci.py`  
Expected: exit 0.  
Run: `swift test`  
Expected: zero failures.

- [ ] **Step 5: Commit**

```bash
git add iOSOverlay/WTKeyboardCanvasView.swift iOSOverlay/WTKeyboardRuntime.swift Tools/verify_v14_pre_ci.py
git commit -m "feat: render resolved 26-key geometry"
```

### Task 4: Rebuild the Host home as the observed two-column card surface

**Files:**
- Create: `iOSApp/WTHostHome353View.swift`
- Modify: `iOSApp/WTReplicaApp.swift`
- Modify: `Tests/WeTypeReplicaCoreTests/HostAppSurfaceTests.swift`
- Modify: `Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift`

**Interfaces:**
- Produces: `WTHostHomeCard353`, `WTHostHomeCatalog353.cards`, and `WTHostHome353View`.
- Consumes: existing `WTSettingsDestination`, measured setup glyph geometry, and established navigation destinations.

- [ ] **Step 1: Write failing card-catalog tests**

```swift
func testPhase14HomeCardOrderMatchesReference() {
    XCTAssertEqual(WTHostHomeCatalog353.cards.map(\.title), [
        "布局和显示", "按键效果", "定制工具栏", "辅助输入",
        "跨设备粘贴传送", "剪贴板", "键盘管理", "语音转文字",
        "拼写 Plus", "单机模式"
    ])
}

func testPhase14HomeGridContract() {
    XCTAssertEqual(WTHostHomeCatalog353.outerMargin, 20)
    XCTAssertEqual(WTHostHomeCatalog353.columnSpacing, 14)
    XCTAssertEqual(WTHostHomeCatalog353.cardCornerRadius, 16)
    XCTAssertEqual(WTHostHomeCatalog353.backgroundHex, "#E2F1F0")
}
```

- [ ] **Step 2: Run tests and verify RED**

Run: `swift test --filter HostAppSurfaceTests`  
Expected: FAIL because `WTHostHomeCatalog353` does not exist.

- [ ] **Step 3: Implement the Core card catalog**

```swift
public struct WTHostHomeCard353: Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let assetFamily: String
    public let destination: String
}

public enum WTHostHomeCatalog353 {
    public static let outerMargin = 20.0
    public static let columnSpacing = 14.0
    public static let cardCornerRadius = 16.0
    public static let backgroundHex = "#E2F1F0"
    public static let cards: [WTHostHomeCard353] = [
        .init(title: "布局和显示", subtitle: "表情键、数字键盘、候选字、高度调节等", assetFamily: "icon_layout", destination: "displaySetting"),
        .init(title: "按键效果", subtitle: "声音、触感、按键气泡", assetFamily: "icon_app_setup_vibration", destination: "keystrokeEffect"),
        .init(title: "定制工具栏", subtitle: "收起键盘等常用功能固定在工具栏", assetFamily: "icon_app_setup_customize_toolbar", destination: "toolbarCustomization"),
        .init(title: "辅助输入", subtitle: "智能加空格、模糊拼音、英文首字母大写等", assetFamily: "icon_app_setup_keyboard", destination: "auxiliaryInput"),
        .init(title: "跨设备粘贴传送", subtitle: "隔空传文件、文字、图片跨设备粘贴、词库同步", assetFamily: "icon_app_setup_multiple_devices", destination: "multiDevice"),
        .init(title: "剪贴板", subtitle: "快速使用复制内容", assetFamily: "icon_clipboard", destination: "clipboard"),
        .init(title: "键盘管理", subtitle: "全键盘、九宫格、手写、五笔、双拼、笔画输入", assetFamily: "icon_app_setup_keyboard", destination: "keyboardManagement"),
        .init(title: "语音转文字", subtitle: "设置语音免跳转方式", assetFamily: "icon_app_setup_voice", destination: "voice"),
        .init(title: "拼写 Plus", subtitle: "智能拼写、表情、颜文字等智能推荐", assetFamily: "icon_app_setup_pluslogo", destination: "plus"),
        .init(title: "单机模式", subtitle: "无需联网，纯本地使用", assetFamily: "icon_app_setup_air", destination: "experiments")
    ]
}
```

- [ ] **Step 4: Run catalog tests and verify GREEN**

Run: `swift test --filter HostAppSurfaceTests`  
Expected: all Host surface tests pass.

- [ ] **Step 5: Implement the dedicated home view**

`WTHostHome353View` uses a `ScrollView`, a `LazyVGrid` with two flexible columns and 14 pt spacing, 20 pt horizontal padding, a flat `Color(wtHex: "#E2F1F0")` background, and white 16 pt-radius cards. Each card exposes `host.home.card.<assetFamily>` as its accessibility identifier. Remove horizontal feature banners and the generic single-column section stack from the selected root route.

- [ ] **Step 6: Route the app root to the dedicated home view**

Replace the current root `WTSettingsAppView()` construction in `WTReplicaApp.swift` with `WTHostHome353View()`. Preserve environment objects and URL/deep-link handling.

- [ ] **Step 7: Run Core tests and pre-CI verification**

Run: `swift test`  
Expected: zero failures.  
Run: `python Tools/verify_v14_pre_ci.py`  
Expected: exit 0.

- [ ] **Step 8: Commit**

```bash
git add Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift Tests/WeTypeReplicaCoreTests/HostAppSurfaceTests.swift iOSApp/WTHostHome353View.swift iOSApp/WTReplicaApp.swift
git commit -m "feat: match the 3.5.3 host home grid"
```

### Task 5: Replace generic Display Settings Form with a measured surface

**Files:**
- Create: `iOSApp/WTDisplaySettings353View.swift`
- Modify: `iOSApp/WTSettingsAppView.swift`
- Modify: `Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift`
- Modify: `Tests/WeTypeReplicaCoreTests/HostAppSurfaceTests.swift`

**Interfaces:**
- Produces: `WTDisplaySettingsCatalog353.sections` and `WTDisplaySettings353View`.
- Consumes: existing App Group preference keys and `WTSettingsDestination.displaySetting`.

- [ ] **Step 1: Write failing surface-model tests**

```swift
func testDisplaySettingsUsesObservedRowOrder() {
    XCTAssertEqual(WTDisplaySettingsCatalog353.sections.flatMap(\.rows).map(\.title), [
        "表情键", "数字键盘", "候选字", "键盘高度", "拼音显示位置"
    ])
}

func testDisplaySettingsRowsHaveStableIdentifiers() {
    let ids = WTDisplaySettingsCatalog353.sections.flatMap(\.rows).map(\.id)
    XCTAssertEqual(Set(ids).count, ids.count)
}
```

- [ ] **Step 2: Run tests and verify RED**

Run: `swift test --filter HostAppSurfaceTests`  
Expected: FAIL because the Display Settings catalog does not exist.

- [ ] **Step 3: Implement the catalog and dedicated view**

Create explicit row models for the observed categories and preserve the existing keys:

```swift
public enum WTDisplaySettingsCatalog353 {
    public static let sections: [WTDisplaySettingsSection353] = [
        .init(id: "keyboard", rows: [
            .init(id: "emojiKey", title: "表情键", preferenceKey: "wt.display.emoji"),
            .init(id: "numberKeyboard", title: "数字键盘", preferenceKey: "wt.display.number9"),
            .init(id: "candidate", title: "候选字", preferenceKey: "wt.display.candidate")
        ]),
        .init(id: "layout", rows: [
            .init(id: "height", title: "键盘高度", preferenceKey: "wt.display.keyboardHeight"),
            .init(id: "pinyinPosition", title: "拼音显示位置", preferenceKey: "wt.display.pinyinPosition")
        ])
    ]
}
```

Render through a `ScrollView` and explicit white rounded groups on `#F0F0F0`; control row heights, dividers, labels, trailing values, and toggles directly. Add accessibility identifiers `host.display.<row-id>`.

- [ ] **Step 4: Route only `.displaySetting` to the dedicated view**

At the navigation construction point, return `WTDisplaySettings353View()` for `.displaySetting`; retain `WTSettingsDetailView` for other destinations. Remove the `.displaySetting` generic `Form` case only after the dedicated route compiles.

- [ ] **Step 5: Run tests and verification**

Run: `swift test --filter HostAppSurfaceTests`  
Expected: all tests pass.  
Run: `python Tools/verify_v14_pre_ci.py`  
Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
git add Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift Tests/WeTypeReplicaCoreTests/HostAppSurfaceTests.swift iOSApp/WTDisplaySettings353View.swift iOSApp/WTSettingsAppView.swift
git commit -m "feat: add measured display settings surface"
```

### Task 6: Add masked paired visual comparison and strict review records

**Files:**
- Modify: `Tools/measure_visual_diff.py`
- Create: `Tools/tests/test_measure_visual_diff.py`
- Create: `ReverseEngineering/Phase14/README.md`

**Interfaces:**
- Extends: `measure_visual_diff.py` with `--mask-manifest`, `--scene-id`, overlay output, and `review.json`.
- Produces: `metrics.json`, `absolute_difference.png`, `rgba_difference.png`, `overlay.png`, and `review.json`.

- [ ] **Step 1: Write failing mask and strict-evidence tests**

```python
def test_masked_pixels_are_excluded_from_metrics(self):
    metrics = compare_images(reference, replica, masks=[(8, 8, 4, 4)], threshold=12)
    self.assertEqual(metrics["excluded_pixel_count"], 16)
    self.assertEqual(metrics["pixels_over_threshold_fraction"], 0.0)

def test_review_is_incomplete_without_both_images(self):
    review = build_review(scene_id="01", reference=reference, replica=None, metrics=None)
    self.assertEqual(review["status"], "incomplete")
    self.assertIn("REP", review["missing"])
```

- [ ] **Step 2: Run tests and verify RED**

Run: `python -m unittest Tools.tests.test_measure_visual_diff -v`  
Expected: FAIL because `compare_images` and `build_review` do not exist.

- [ ] **Step 3: Extract reusable comparison functions**

Move pixel comparison from `main()` into `compare_images(reference, replica, masks, threshold)`. Set masked pixels aside before calculating MAE, RMSE, exact fraction, threshold fraction, and difference bounds. Record `excluded_pixel_count` and `measured_pixel_count`.

- [ ] **Step 4: Add overlay and review output**

Create a 50% alpha overlay with `Image.blend(a, b, 0.5)`. `build_review` returns `incomplete` unless both images and metrics exist; otherwise it returns `needs-review` by default. The tool never marks a scene `pass` automatically.

- [ ] **Step 5: Run tests and verify GREEN**

Run: `python -m unittest Tools.tests.test_measure_visual_diff -v`  
Expected: all tests pass.

- [ ] **Step 6: Document the exact Phase 14 artifact tree**

```text
Phase6Evidence/01-keyboard26-light/
  REF-01-keyboard26-light.png
  REP-01-keyboard26-light.png
  overlay.png
  absolute_difference.png
  rgba_difference.png
  metrics.json
  review.json
```

Repeat the same naming rule for the other nine selected IDs. Document that AssistiveTouch masks are exclusions and cannot cover keyboard or Host UI pixels.

- [ ] **Step 7: Commit**

```bash
git add Tools/measure_visual_diff.py Tools/tests/test_measure_visual_diff.py ReverseEngineering/Phase14/README.md
git commit -m "test: add masked phase14 visual reviews"
```

### Task 7: Run full CI, package the signed IPA, and prepare device capture

**Files:**
- Modify: `CI_FIX_LOG.md`
- Modify only if required by compiler evidence: files touched in Tasks 1–6

**Interfaces:**
- Consumes: the six committed implementation tasks.
- Produces: green Core/static/Xcode target results, signed Host + Keyboard IPA, artifact URL, SHA-256, and a ten-scene `REP` capture checklist.

- [ ] **Step 1: Run all locally available checks**

Run: `python -m unittest discover -s Tools/tests -v`  
Expected: zero failures.  
Run: `python Tools/verify_v14_pre_ci.py`  
Expected: exit 0.  
Run where Swift is available: `swift test`  
Expected: zero failures.

- [ ] **Step 2: Push the complete Phase 14 source commits**

Verify the remote is `https://github.com/JINMMYSC/WEIXIN.git`, then push only `work/v14-phase13-static-delta`. Do not rewrite history or push to `main`.

- [ ] **Step 3: Trigger and inspect the existing iOS workflow**

Confirm Core tests, XcodeGen, Host, Keyboard, Share, Widget, Voice/Live Activity, device build, signing, packaging, and artifact upload. If a run fails, use the first causal error and make the smallest behavior-preserving fix.

- [ ] **Step 4: Record completion evidence**

Append the final full commit SHA, Actions run URL, target/test results, artifact name, IPA SHA-256, and remaining device-only capture step to `CI_FIX_LOG.md`.

- [ ] **Step 5: Commit any evidence-log update and verify the follow-up run**

```bash
git add CI_FIX_LOG.md
git commit -m "docs: record phase14 build evidence"
git push origin work/v14-phase13-static-delta
```

The final workflow run must be green and expose the signed Host + Keyboard IPA artifact before reporting the build complete.

- [ ] **Step 6: Capture the ten replica scenes on device**

Install the new IPA on the target iPhone, disable AssistiveTouch, use the same host context and text state, and capture `REP` for `01`, `02`, `04`, `06`, `07`, `08`, `10`, `14`, `23`, and `27`. Run the masked comparison tool for each scene and leave every result `needs-review` until visually inspected.

## Plan Self-Review

- Every design requirement in Phase 14 maps to a task above.
- Dark mode and special-host work remain explicitly excluded.
- Core geometry is tested before the keyboard renderer changes.
- Host catalogs are tested before SwiftUI construction.
- No task weakens the 79-scene evidence gate.
- The plan contains no repository credentials, signing material, absolute user recording path, or private token.
- Runtime rendering, hit testing, popup anchoring, and visual measurement share the same resolved frames.

