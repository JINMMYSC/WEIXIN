# WeType 3.5.3 全功能复刻实施状态 V5

V5 继续按“全界面 + 全操作逻辑”推进，不把只存在于逆向证据里的界面当成已完成。`implemented` 在这里表示已经有独立重写的 Swift/SwiftUI surface 和状态入口，**不等于已经在真实 iPhone 上逐像素验收**。

## V5 新增的实际代码

- **工具栏自定义**：新增 `WTToolbarArrangeView`，可以添加/移除/调整快捷工具顺序；`WTFunctionToolbarView` 已改为读取运行时顺序。对应 `WBArrangeView / WBArrangeCell / WBCustomToolBarScrolView`。
- **真实单手键盘壳**：新增 `WTOneHandedShell`，左/右单手模式会实际缩窄主键盘，并提供换边/恢复全尺寸操作，不再只是设置开关。
- **键盘尺寸与位置调节**：`WTKeyboardAdjustView` 增加实时预览、宽高/XY 调整、保存、取消、恢复默认；`WTKeyboardCanvasView` 已真正应用这些参数。对应 `WBRectSettingView / WBRectSettingOperationView` 及 `saveAdjustedRectSettings / cancelAdjustedRectSettings` 证据。
- **字体界面**：新增 `WTFontPickerView`；键帽字号缩放已实际进入 renderer。
- **热词全流程 UI**：新增搜索、刷新、手动添加、删除、点击上屏，以及 provider 接口。对应 `WBHotWordListView / WBHotwordEditView / WBAddHotWordEntranceView`。
- **表情包 / 自定义表情 / GIF**：新增三段内容浏览、搜索、空态、预览、发送 bridge。对应 `WBStickerNativeView / WBStickerCollectionView / WBCustomStickerView / WBStickerPreviewView / WBStickerPageContainerView`。在线资源仍由独立 provider 提供。
- **拆词**：新增 `WTWordSplittingView` + provider 接口，对应 `showWordSplittingViewWithContentText:` / `splitedKeywordsWithText:`。
- **笔画筛选**：新增 `WTStrokeFilterView`，五种笔画筛选状态与 change callback 已接入笔画键盘。
- **剪贴板图片/授权**：新增 `WTPasteboardImageDetailView` 与 `WTGuideAuthView`，剪贴板面板增加图片入口。对应 `WBPasteboardImageDetailView / WBPasteboardAuthHeaderView / WBAuthGuideView`。
- **微信输入法+**：`WTPlusPanelView` 扩展为总开关、功能分段、能力列表、说明层。对应 `WBPlusConfigView / WBPlusSelectionView / WBPlusStatementView / WBPlusConfigAbilityItemView`。
- **瞬态 UI 组件**：新增 `WTTopBarTipsView / WTNetworkAlertView / WTLicenseAlertView`，覆盖顶部提示、网络提示、服务说明类 surface。
- **主 App 设置**：增加表情包/GIF、Plus、字体、键盘调节、授权指南等设置目的地。
- **系统化覆盖账本**：新增 `SurfaceCatalog.swift`，现在记录 **93 个**从 WeType 3.5.3 class/selector 证据确认的 surface/component 映射。

## Surface ledger 当前状态

- `implemented`: **62** — 已有 clean-room UI/source surface；仍需 Xcode/iPhone 像素验收。
- `providerRequired`: **26** — UI/状态机已有，真实内容或服务必须接自己的 provider，例如 AI、翻译、语音、手写识别、表情包、热词。
- `xcodeValidationRequired`: **2** — iOS privacy/Network runtime 才能确认。
- `notYetImplemented`: **3** — `WBFinderView`、`WBTPListView`、`WBTPPlayerView`，已确认 class 身份，但业务语义仍需继续拆二进制/宿主场景。

## 验证

- Core Swift Package：**28/28 tests passed**。
- `iOSOverlay/*.swift`：Swift parser 通过。
- `iOSApp/*.swift`：Swift parser 通过。
- `iOSExtensions/*.swift`：Swift parser 通过。
- `HamsterBridge/*.swift`、`iOSServices/*.swift`：Swift parser 通过。

## 仍然不能在 Linux 里冒充完成的部分

1. Xcode Keyboard Extension 真正编译、签名、entitlement、App Group 与真机安装。
2. iPhone 上的字体 baseline、safe area、键盘动态高度、暗色模式和动画曲线逐像素校准。
3. Hamster 当前源码里的 librime session 5 个 closure 真接线。
4. 腾讯服务端相关能力只能做等效 provider，不能从 IPA 恢复为腾讯私有后端。
5. 原版专有图标/GIF/字体不直接打包；当前使用 clean-room/SF Symbols 占位，最终需要逐个重画并真机对照。
