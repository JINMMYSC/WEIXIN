# WeType 3.5.3 全功能复刻实施状态 V9

V9 的目标是继续收敛“看得见的不一样”和“输入行为无法量化”的部分，而不是继续增加空页面。

## 本轮实际完成

### 1. shipping UI 的 SF Symbol 占位清零

- 新增 `iOSShared/WTSemanticGlyph.swift`，使用 clean-room SwiftUI 几何路径绘制二级语义图标。
- App / Keyboard / Share / Widget 四个 Xcode target 都加入 `iOSShared`。
- `Image(systemName:)` 与 `systemImage:` 在 shipping UI source 中现为 **0**。
- 新增 `Tools/verify_no_system_symbols.py`，以后重新引入 SF Symbol 占位会直接被验证脚本抓出。

说明：这代表“占位图标”这一差异被关闭，但最终几何仍要用同机截图对照继续校准，并不把 clean-room 绘制冒充腾讯原始资产。

### 2. wxime ↔ librime 黑盒语料从 30 扩展到 100

新增范围：

- 26 键拼音 / 候选排序 / 分词 / 模糊音 / 长句 / 中英混输
- 九宫格 T9：15 组
- 双拼：10 组（device runner 需按同一双拼方案映射规范音节）
- 五笔 86：10 组
- 笔画：10 组；键位输入 b/c/d/e/f 来自 WeType 3.5.3 自带 `t9_stroke` 映射
- 个性化学习：8 组，支持 repeat + candidate selection 元数据
- 纠错：7 组

`WTIMEBehaviorProbe` 新增 `inputMode / repeatCount / selectCandidateIndex`，能够描述真实学习与多输入方案测试，而不只是一串字母。

### 3. 真机逐屏对齐不再没有清单

新增 `WTVisualParityManifest` 和 `ReverseEngineering/V9/VISUAL_CAPTURE_MANIFEST.json`：

- **57 个 capture case**
- **26 个 surface family**
- light / dark
- 26 键 / 九键 / 符号
- candidate expand / candidate menu
- key popup / long press
- Emoji / 剪贴板 / 手写 / 语音 / 翻译 / AI / 纠错
- 单手左右、控制中心、快捷设置、设备传送、贴纸/GIF、BookVideo
- send/search Return key
- secure field / Spotlight / landscape
- Share Extension / Voice Widget

真机阶段可以直接按 manifest 逐条拍 reference/replica，不再靠人工记忆“还有哪一屏没比”。

## 验证

- Core Swift Package：**51 / 51 tests passed**。
- shipping UI：**0 SF Symbol placeholder API usages**。
- `Sources / iOSShared / iOSOverlay / iOSApp / iOSExtensions / iOSServices / HamsterBridge` 全部 Swift 文件 `swiftc -parse` 通过。
- plist / entitlements lint 通过。
- V8 integration verifier 继续通过，并检测到 iOSOverlay SF Symbol usage = 0。
- `project.yml` 已确认四个 target 都包含 `iOSShared`。

## 真实性边界

当前环境仍不是 macOS，因此没有把 Xcode/iOS SDK 编译、签名、真机安装冒充为完成。现在最重要的下一步已经收敛成：**真实 Mac 第一编 + 公共 Hamster revision 接线 + 同一 iPhone 的 100 组输入行为捕获 + 57 组视觉/动画捕获。**
