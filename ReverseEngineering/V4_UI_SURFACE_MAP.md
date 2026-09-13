# WeType 3.5.3 UI Surface Map — V4

基准：`微信输入法 3.5.3` IPA，键盘扩展 `com.tencent.wetype.keyboard`。

这份表只记录从二进制类名、selector、INI 和资源文件名能够确认的界面/交互面。V4 的复刻代码只使用独立重写的 SwiftUI/SF Symbols，不把腾讯原 PNG/GIF/字体打包进输出工程。

| 原版证据 | 原版 surface | V4 对应 | 状态 |
|---|---|---|---|
| `WBRootInputView`, `WBMainInputView`, `WBT26Panel` | 26 键主键盘 | `WTKeyboardCanvasView` | 已按 414×224 INI 绝对几何实现 |
| `WBT9Panel` | 9 键主键盘 | `WTKeyboardCanvasView` | 已按不规则 INI 几何实现 |
| `WBKeyPopupView`, long-press selectors | 长按/上滑/下滑 | `WTLongPressPopupView`, `KeyInteraction.swift` | 已实现 |
| `WBCandidateView` | 横向候选 | `WTCandidateBar` | 已实现第二版样式 |
| `WBCandidateExpandView` | 展开候选 | `WTCandidateBar.expandedGrid` | 已实现 |
| candidate long-press selectors | 候选置顶/删除 | `candidateActionMenu` | 已实现兼容层 |
| `WBCustomToolBarView` | 键盘工具栏 | `WTFunctionToolbarView` | V4 重做 |
| `WBControlCenterView`, `WBCCMainView` | 更多功能/控制中心 | `WTControlCenterView` | V4 新增 |
| `WBQuickSettingView` | 快捷设置 | `WTQuickSettingsView` | V4 新增 |
| `WBLanguageSwitchView`, `icon_popup_*` | 输入方案切换 | `WTInputModeSwitcherView` | V4 新增 |
| `WBSymbolListView`, `WBSymbolExpand*`, `WBFullSymbolPanel2` | 全符号分类 | `WTFullSymbolPanelView` | V4 新增 |
| `WBEmojiPageView`, `WBEmojiPageContainerView` | Emoji | `WTEmojiPanelView` | V4 扩展分类/最近 |
| `WBSticker*`, `icon_keybar_option_sticker` | 表情包 | `WTEmojiPanelView` 导航壳 | 在线内容 provider 未接 |
| `icon_keybar_option_gif` | GIF | `WTEmojiPanelView` 导航壳 | 在线内容 provider 未接 |
| `WBPasteboardListView`, `WBPasteboardHistorySQL` | 剪贴板 | `WTClipboardPanelView` + JSON store | 已实现文字历史/固定/删除 |
| `WBTPListView` / 常用语资源 | 常用语 | `WTPhrasesPanelView` + JSON store | 已实现基础逻辑 |
| `WBHandwritingPanelView`, `WBHandWritingInkLikeOverlayView` | 手写 | `WTHandwritingCanvasView` | Canvas/候选回灌已实现，识别 provider 待接 |
| `WBVoiceInputInteractionView`, `WBVoiceInputControlBar`, `WBVoiceInputWaveView` | 语音 | `WTVoicePanelView` | V4 重做状态 UI；真实录音/IPC 待 macOS/iOS 联调 |
| `WBTranslateView`, `WBTranslateViewToolBar` | 翻译 | `WTTranslatePanelView` | V4 重做 UI；provider 待接 |
| `WBAIAssistantView`, `WBAIAssistantToolSelectionView`, `WBAskAIWebView` | AI | `WTAIPanelView` | V4 重做工具选择 UI；provider 待接 |
| `WBCorrectionDetailView`, `WBCorrectionNoticeView` | 纠错 | `WTCorrectionPanelView` | V4 重做；provider 待接 |
| `WBRewriteDetailView`, `WBTextPolishCandidateModel` | 文字润色/改写 | `WTTextPolishPanelView` | V4 新增 |
| `WBDeviceSyncManager` | 设备同步 | `WTDeviceSyncPanelView` | V4 新增 UI，Bonjour service 已有 |
| file-transfer toolbar/resources | 隔空传送 | `WTQuickSendPanelView`, `WTQuickSendShareView` | V4 新增键盘/Share UI |
| picture toolbar/resources | 图片 | `WTPicturePanelView` | V4 新增入口/host handoff |
| control-center assets | 系统控制中心入口 | `WTControlCenterButtons` | V4 新增共享 visual surface |
| `WBVoiceInputWidgetExtension` | 语音 Widget | `WTVoiceWidgetView` | V4 新增共享 visual surface |
| app `setup.hbc`, setup icon resources | 主 App 设置 | `WTSettingsAppView` | V4 新增完整导航骨架与可交互设置项 |
| `icon_setup_keyboard_management*` | 键盘管理 | `WTSettingsDetailView.keyboardManagement` | V4 新增 |
| pinyin/shuangpin/wubi/stroke/hand icons | 输入法设置 | 详情页面 | V4 新增 |
| AI/translate/voice/correction icons | 智能设置 | 详情页面 | V4 新增 |
| clipboard/commonwords/emoji/hotword icons | 工具设置 | 详情页面 | V4 新增 |
| appearance/font/vibration/handed icons | 外观体验 | 详情页面 | V4 新增 |
| experiment/guide icons | 实验室/帮助 | 详情页面 | V4 新增 |

## 仍不能在当前 Linux 环境确认的“像素级一致”项

1. UIKit/SwiftUI 在真实 iPhone 逻辑分辨率下的字体基线、safe-area、动态高度。
2. 原版专有图标、Lottie/GIF 的逐帧动画；V4 只保留布局和动作位，不打包原版权资产。
3. 语音、AI、翻译、云候选、GIF/表情包等腾讯服务端行为；需要等效 provider。
4. Widget/Control Center/Share Extension 的 entitlement、签名、跳转，需要 Xcode target 真机联调。
5. Settings 主 App 的 RN/Hermes 页面目前按可确认的资源/功能结构独立重写，仍需真机逐屏对照原版截图继续细调。
