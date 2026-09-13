# WeType 3.5.3 全功能复刻实施状态 V6

V6 把 V5 的几个“下一步硬任务”合并推进：**未知 surface 判明、Hamster/Rime 真接线层、Xcode target 骨架、Finder/微信富内容 UI、可用本地 provider、真机校准基础设施**。

## 这一轮实际完成

### 1. 最后 3 个未判明 surface 已经清零

- `WBFinderView` 已通过 `WBBookVideoFinderModel`、`WBBookVideoWeChatFinderSendData`、`sendWeChatFinder:*`、`finderFeedID/finderNonceID` 和整套 `icon_bookvideo_*` 资源族确认：它属于微信富内容/视频号（BookVideo）能力。
- 新增 `WTBookVideoPanelView`、`WTBookVideoKind`、`WTBookVideoCard`、search/send provider hooks；覆盖视频号、公众号、小程序、音乐、电影、图书、百科、股票、热词、位置、问候、翻译分类。
- `WBTPListView / WBTPPlayerView` 已确认不是缺失的产品 UI，而是内部触控录制/回放调试工具。证据包括 `WBTPRecord / WBTPExporter / WBTouchRecorderDelegate / playTouchRecord / stopPlayTouchRecord / WBAppSettingsBit_Debug_RecordTouch`。V6 将其标记为 `debugOnly`，并提供 `#if DEBUG` 的 `WTDebugTouchPlaybackView`。
- Surface ledger 仍为 93 个：`implemented 62 / providerRequired 27 / xcodeValidationRequired 2 / debugOnly 2 / notYetImplemented 0`。

### 2. Hamster/Rime 接线从 closure 模板升级为 typed session adapter

新增 `WTHamsterRimeSessionProtocol` 与 `WTHamsterRimeSessionAdapter`。Hamster 当前 revision 只需要让已有 Rime session/controller 映射：

- composition
- candidates
- isComposing
- process
- selectCandidate
- deleteBackward
- reset

Overlay 本身不再需要知道 Hamster 的具体类名。`XcodeIntegration/Templates/HamsterSessionConformanceTemplate.swift` 给出最小接法。

### 3. Xcode 第一编所需结构已经准备

新增 `XcodeIntegration/`：

- host App / Keyboard Extension / Share Extension / Widget 的 XcodeGen `project.yml`
- App Group entitlements
- Keyboard / Share / App / Widget Info.plist
- keyboard principal `WTKeyboardInputViewController`
- host app `@main` 入口 `WTReplicaApp`
- Share Extension 的 `WTQuickSendShareViewController`
- WidgetKit 的语音入口 `WTWidgetBundle`

这仍然需要在 macOS/Xcode 里实际生成/编译/签名；Linux 不能冒充完成苹果 SDK 编译。

### 4. Provider 不再全部是空接口

- 新增 `WTVisionHandwritingRecognizer`：把手写 stroke clean-room 栅格化，使用 Vision 做本地识别 fallback；后续可无缝替换成专门 CJK 手写模型。
- 新增 `WTLocalCorrectionService`：使用 `UITextChecker` 提供设备本地拼写纠错 fallback。
- `WTBookVideoPanelView` 使用自己的 provider hook，不嵌入腾讯后端或原版专有资源。

### 5. 像素/动效真机校准基础层

新增 `WTVisualCalibrationProfile`，把候选栏高度、工具栏高度、圆角、popup scale、候选展开/面板转场/按键 popup/语音 pulse 时长统一收敛成可测量参数。默认值只是可运行基线；最终数值必须从真机对照视频/截图测量后覆盖，不把估值冒充 3.5.3 原始数值。

## 验证

- Core Swift Package：**30 / 30 tests passed**。
- 所有 `Sources / iOSOverlay / iOSApp / iOSExtensions / iOSServices / HamsterBridge` Swift 文件逐文件 `swiftc -parse`：**全部通过**。
- XcodeIntegration plist / entitlements：`plutil -lint` 通过。
- `Tools/verify_v6_integration.py`：通过。

## 仍需 Mac/iPhone 才能完成的真实性边界

1. Xcode / iOS SDK 第一编、签名、App Group、Extension memory/runtime。
2. Hamster 具体 revision 的 session 类型名与 API 名最后 7 个映射表达式。
3. iPhone 逐屏截图和高速录屏测量：baseline、safe area、圆角、阴影、popup、转场曲线/时长。
4. 腾讯私有云候选、AI、翻译、语音、GIF/表情内容不能从 IPA 恢复成腾讯后端；只能接自己的等效 provider。
5. clean-room 图标仍要逐个按几何/视觉重新绘制并真机比对，不能直接把腾讯专有图标打进发行包。
