# WeType 3.5.3 UI Surface Map — V5 delta

V5 在 V4 基础上继续从 `objc_classname.txt`、`objc_methname.txt` 与 IPA 资源名补齐可见 surface。以下是本轮重点新增证据与实现。

| WeType 3.5.3 证据 | 行为/界面推断 | V5 clean-room 对应 | 当前状态 |
|---|---|---|---|
| `WBArrangeView`, `WBArrangeCell`, `arrangeView:didSelectCell:`, `arrangeView:didUpdateLayout:` | 工具栏/项目排列 | `WTToolbarArrangeView` | 已实现添加/移除/上下移动 |
| `WBRectSettingView`, `WBRectSettingOperationView`, `saveAdjustedRectSettings`, `cancelAdjustedRectSettings` | 键盘尺寸/位置调节 | `WTKeyboardAdjustView` + renderer transform | 已实现实时预览、保存/取消 |
| `WBFontFilterPickerView`, `fontFilterInfos`, `setFontFilters:` | 字体筛选/显示 | `WTFontPickerView` | UI 已实现；字号已进入键帽 renderer |
| `WBHotWordListView`, `WBHotwordEditView`, `WBAddHotWordEntranceView`, `getHotWords`, `deleteHotWordIterator:` | 热词列表/新增/删除 | `WTHotWordPanelView` | UI/操作已实现；词库 provider 待接 |
| `WBStickerNativeView`, `WBStickerCollectionView`, `WBCustomStickerView`, `WBStickerPreviewView`, `searchStickersWithText:` | 表情包、自定义表情、搜索、预览 | `WTStickerGIFPanelView` | UI/预览/发送 bridge 已实现；内容 provider 待接 |
| `sendGif`, `icon_keybar_option_gif*`, GIF assets | GIF 浏览/发送 | `WTStickerGIFPanelView(.gif)` | UI 已实现；内容 provider 待接 |
| `showWordSplittingViewWithContentText:source:`, `splitedKeywordsWithText:`, `splitWordChangeFromSelectedResult:` | 拆词结果与选择 | `WTWordSplittingView` | UI/state 已实现；拆词 provider 待接 |
| `WBStrokeFilterView`, `strokeFilterChangedBlock`, `getCandidatesCount:...filterStroke:` | 笔画候选筛选 | `WTStrokeFilterView` | 已接到笔画模式 + callback |
| `WBPasteboardAuthHeaderView`, `showPasteboardAuthGuidePage...`, `WBPasteboardImageDetailView` | 剪贴板授权/图片详情 | `WTGuideAuthView`, `WTPasteboardImageDetailView` | UI 已实现；真机 privacy 行为待验收 |
| `WBPlusConfigView`, `WBPlusSelectionView`, `WBPlusStatementView`, `plusStatus`, `plusCorrectionStatus`, `plusEmojiStatus` | Plus 总开关/能力选择/说明 | `WTPlusPanelView` | UI/状态已实现；在线能力走独立 provider |
| `WBTopBarTipsView` | 顶部提示条 | `WTTopBarTipsView` | 已实现 |
| `WBNetworkAlertView` | 网络异常提示 | `WTNetworkAlertView` | 已实现 |
| `WBLicenseAlertView`, `licenseAlertAgreed` | 在线功能服务说明 | `WTLicenseAlertView` | 已实现 |
| 单手设置资源 + V4 状态 | 单手布局真实缩窄/换边 | `WTOneHandedShell` | V5 已从“设置状态”升级到实际布局 |

完整 machine-readable/Swift 覆盖账本见 `Sources/WeTypeReplicaCore/SurfaceCatalog.swift`，当前记录 93 个 class/surface 映射。

## V5 明确仍未标记完成的原版 class

- `WBFinderView`：selector 表明与微信宿主的 Finder/内容发送相关，需继续确认宿主场景后才能 clean-room 重写。
- `WBTPListView`
- `WBTPPlayerView`

后两者 class 身份已经确认，但仅凭当前 selector 还不足以安全判断其对用户的业务含义，因此 V5 不猜实现。
