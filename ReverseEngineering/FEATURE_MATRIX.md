# 微信输入法 3.5.3 逆向功能矩阵

基准 IPA SHA-256: `2336aa34f2c64ec7a6e33b5fd2bbb4b3635baaf799ea6706d362a404144f36bf`

键盘扩展: `com.tencent.wetype.keyboard` / Principal Class: `WBInputViewController`  
键盘扩展资源体积: `314M`  
Mach-O `LC_ENCRYPTION_INFO_64.cryptid = 0`: **当前 IPA 二进制已经是可直接静态分析的未加密状态，不需要再砸壳。**

## 已确认模块与证据

| 模块 | IPA 证据 | 逆向到的关键类/结构 | 复刻路线 |
|---|---|---|---|
| 26 键拼音 | `t26_pinyin.ini`, `style.ini` | `KBIMEMgr processInput:...`, `WBRootViewManager` | Hamster/librime 做输入引擎；自定义绝对坐标渲染层复刻 UI |
| 9 键拼音 | `t9_pinyin.ini` | `KBIMEMgr getSyllableOfSession`, `selectSyllable` | Rime 九键方案 + 自定义绝对布局 |
| 笔画 | `t9_stroke.ini` | `KBIMESessionType_HandWrite` 之外另有 stroke dict/version | Rime/自定义 schema |
| 数字符号 | `t9_number.ini`, `t26_cn_symbol.ini`, `t26_en_symbol.ini`, `full_symbol2.ini` | 面板切换由 `WBRootViewManager switchPanelView:` 管理 | 全部按 IPA 坐标与状态机重写 |
| 候选栏 | `candidate_sperator@2x/3x`, 大量 candidate assets | `WBCandidateView`, `WBCandidateExpandView`, `KBIMEMgr selectCandidate:...` | Rime context/candidates + 自定义候选 UI |
| Emoji/表情 | 1100+ PNG 中大量 emoji/sticker 资源 | `WBEmojiMgr`, `WBEmojiPageView`, `WBSticker*` | 自建 Emoji/贴图面板；最近使用独立存储 |
| 剪贴板 | `icon_keybar_clipboard_*` | `WBPasteboardListView`, `WBPasteboardHistorySQL`, `WBPasteboardService` | App Group 数据层 + 卡片 UI |
| 手写 | `handwriting.ini`, `imeData.bundle/hwd_hand_write.bin` | `WBHandwritingPanelView`, `WBHandWritingInkLikeOverlayView`, `KBIMEMgr processHandWriteInput` | 自定义 Canvas + 可替换识别器接口 |
| 语音 | voice assets + Live Activity extension | `WBVoiceInput*` 大量类，离线/在线两套管线 | 主 App/扩展协作；UI 与状态机复刻，识别服务做等效实现 |
| 翻译 | translate assets | `WBTranslateView`, `WBTranslater`, `WBTranslateLanguagePreferences` | 自建翻译 service + 同款面板状态 |
| AI/问 AI | askAI/rewrite/textpolish assets | `WBAskAIWebView`, `WBRewrite*`, `WBTextPolish*` | 自建 AI service，UI/操作逻辑按 3.5.3 对齐 |
| 拼写纠错 | correction assets | `WBCorrectManager`, `WBCorrectionDetailView`, `KBIMEMgr requestCorrection` | 本地/服务端纠错均可挂统一接口 |
| 设备同步/隔空传送 | `WXP2PTransferDyn.framework`, Share Extension | `WBDeviceSyncManager`, `WBFileTransferInviteStayToolBarButton` | 自建 LAN/P2P 传输层 + App Group/Share Extension |
| 词典/热词 | `imeData.bundle` 多词典文件 | `WBDict*`, `WBHotWord*`, `KBIMEMgr addUserDictItem` | Rime userdb + 自建置顶/屏蔽层 |
| 小组件/控制中心 | Widget extensions + control_center assets | `widgetExtension.appex`, `WBVoiceInputWidgetExtension.appex` | 独立 WidgetKit targets |

## 关键结构结论

1. 3.5.3 的键盘几何不是“估出来”的。`t26_pinyin.ini` 与 `t9_pinyin.ini` 直接给出了 414×224 基准坐标、每一个按键的 `RECT`、上滑输入、长按浮窗内容和 style 名称。
2. 26 键第一行单键是 35×46，Q 从 (5,5) 开始；回车键是 (323,173,86,46)。九键中 2/3/4… 主键为 81×50，删除键是 (340,3,69,50)。
3. `style.ini` 明确给出浅色/深色键帽、按下态、文字色、功能键绿色（#23C891）、字号等。
4. Hamster 官方公开仓库适合作为 Rime 引擎和 iOS keyboard extension 底座，但它公开版本的自定义键盘以“整行布局”为主；其 issue #564 也反映非整行布局限制。微信 3.5.3 的九键含左侧跨三行符号区、右侧功能列，因此**要做到像素级一致不能只写 YAML，必须加自己的绝对坐标渲染层**。
5. 因此当前代码结构已改为：Hamster/librime 只负责 engine/service；`WTKeyboardCanvasView` 负责按 IPA 的绝对坐标渲染，面板状态由 `WTKeyboardState` 统一管理。
