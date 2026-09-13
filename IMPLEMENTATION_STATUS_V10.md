# WeType 3.5.3 全功能复刻实施状态 V10

V10 继续按“用户可见 UI / 内容结构 / 操作逻辑尽量对齐 3.5.3，闭源代码和腾讯私有资产不直接复制”的 clean-room 路线推进。本轮不是继续增加泛化页面，而是把 **Host App 设置模块证据、候选排序兼容层、候选 source-index 正确性和真机视觉验收矩阵**一起往前压。

## 本轮实际完成

### 1. Host App 的原版 Setup 模块不再凭猜测

直接从用户提供的 WeType 3.5.3 IPA 的 `RNBundles/assets/src/Setup/` 做只读测量，确认 12 个 Setup 模块：

- `SetupMain`
- `SetupKeyboardSelect`
- `SetupSp`
- `SetupWb`
- `SetupFuzzyPinyin`
- `SetupAuxiliaryInput`
- `SetupDisplaySetting`
- `SetupKeystrokeEffect`
- `SetupClipboard`
- `SetupDesktop`
- `SetupMigrationAssistant`
- `SetupPlus`

新增 `WTHostSetupSurfaceCatalog353`，并把这些模块全部映射到 replica 的 Host App 页面。V10 还从安装包只提取**几何测量数据**：310 个图片变体 / 114 个图片 family / 12 个 screen；生成 `GeneratedHostSetupGeometry353.swift`，不把腾讯原始图片像素打进工程。

### 2. SetupMain 入口全部有对应 destination

3.5.3 `SetupMain/images/setup/` 中发现的 14 个 32pt 功能图标 family 已全部有 clean-room destination：键盘管理、显示/布局、工具栏自定义、按键反馈、剪贴板、语音、微信输入法+、隔空传送、多设备、电脑端、迁移助手、隐私、帮助、关于。

Host App 新增/细化：

- 模糊拼音
- 辅助输入
- 显示设置
- 按键效果
- 工具栏设置
- 多设备
- 电脑端
- 迁移助手
- 隐私
- 首页功能 banner strip

设置首页的原版 32pt icon 槽位开始使用 `WTHostSetupGeometry353` 的 canvas / alpha-bounds 测量来放置 clean-room 矢量，不再全部统一尺寸居中。

### 3. wxime ↔ librime 差异开始能“修”，不只是“测”

V8/V9 已有 100 组黑盒 corpus。V10 新增 `WTIMECompatibilityProfile` / `WTIMECompatibilityRule`：

- 从 WeType reference capture 与 librime replica capture 自动生成安全候选重排提示；
- 只移动本地 Rime 中**已经存在**的候选，不凭空创造腾讯候选；
- 每个展示候选保留真实 `sourceIndex`，所以 UI 排序变化后点击仍选中正确的 Rime candidate；
- profile 可按 input mode + composition 精确匹配。

新增 `Tools/build_ime_compatibility_profile.py`，以后同机跑完 corpus 后可直接生成候选排序 shim JSON。

### 4. 候选链路修正：兼容排序 / 用户固定 / 云候选可组合

`WTCandidatePreferenceStore` 现在可以接收已经重排过的 `WTDisplayedCandidate`，保留 source index；`WTKeyboardOverlayBinding` 支持：

1. 本地 Rime 候选
2. WeType 行为 compatibility reorder
3. 用户“固定至首位 / 删除”偏好
4. 云候选插入
5. 点击后映射回正确 Rime index

`WTCloudCandidateBinding` 也升级为接受 `displayedLocal`，不会把 compatibility/pin 后的本地顺序悄悄恢复成原始 Rime 顺序。

### 5. 真机逐屏对照范围扩大

V9 为 57 个 capture case；V10 把 Host App 12 个 Setup 模块中的主要页面纳入浅色/深色验收，当前 manifest 为：

- **79 个视觉 capture case**
- **37 个 surface**

新增重点：键盘选择、模糊拼音、辅助输入、显示设置、按键效果、剪贴板设置、电脑端、迁移、Plus、双拼、五笔等 Host App 页面。

## 验证

- Core Swift Package：**60 / 60 tests passed**。
- `Sources / iOSShared / iOSApp / iOSOverlay / iOSExtensions / iOSServices / HamsterBridge`：**88 个 Swift 文件 `swiftc -parse` 全通过**。
- XcodeIntegration plist / entitlements：`plutil -lint` 全通过。
- shipping UI：`Image(systemName:)` / `systemImage:` 检查仍为 **0**。
- `Tools/verify_v10_integration.py`：通过。

## 当前真实性边界

V10 仍然没有在本环境冒充完成以下事项：

1. macOS/Xcode/iOS SDK 真编译、签名、安装、Extension 内存与生命周期验证；
2. 公开 Hamster 指定 revision 的 concrete librime API 最终类型映射；
3. 同一台 iPhone 对 WeType 3.5.3 / replica 跑 100 组 IME reference capture；
4. 同一台 iPhone 跑 79 组截图/高速录屏并回填 baseline、shadow、popup、动画 timing；
5. 腾讯私有云候选 / AI / 翻译 / 语音 / GIF / 富内容服务只能由自己的等效 provider 替代；
6. Vision 手写与 Apple Speech fallback 不会天然输出与腾讯模型完全相同的结果。
