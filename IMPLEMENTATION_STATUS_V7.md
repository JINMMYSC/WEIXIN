# WeType 3.5.3 全功能复刻实施状态 V7

V7 把 V6 剩余的几条“硬线”继续并行推进，重点不是再加空面板，而是让云候选、AI/翻译、语音、App Group 共享和 Mac 构建验证开始形成真正可接通的实现。

## V7 实际完成

### 1. 云候选进入真实输入链

- 新增 `WTCloudCandidateService` / `WTCloudCandidate` / `WTCloudCandidateMerger`。
- `WTCloudCandidateBinding` 在本地 Rime composition 不为空时异步请求云候选。
- 显示时保留第一本地候选，去重后插入云候选，再补回剩余本地候选。
- 云候选使用负 source index 标识，点击时不误调用 Rime candidate index，而是清除本地 composition 后直接上屏。
- 网络失败不会影响本地 Rime 打字。

### 2. Provider 从接口升级到可运行 HTTP 实现

新增 `WTHTTPProviderServices.swift`：

- `WTHTTPAIService`
- `WTHTTPTranslationService`
- `WTHTTPCloudCandidateService`
- `WTHTTPHotWordService`
- `WTHTTPMediaService`

并新增 `WTProviderConfiguration` / `WTProviderEndpoint` 和 App Group 配置读取。腾讯私有服务仍不复制；现在只需接自己的 JSON 服务端即可让对应 UI 真正工作。

### 3. 语音链路从“UI 状态机”推进到 Host App 实现

- 新增 `WTHostSpeechRecognitionService`，使用 `Speech + AVFoundation` 在主 App 中录音与识别。
- 新增 `WTJSONServiceMailbox`，通过 App Group 在 Keyboard Extension 与 Host App 之间交换 request/response。
- 键盘侧 `startVoice` 会创建 voice request 并尝试打开 `wtreplica://voice?request=...`。
- 主 App 新增 URL route + `WTHostVoiceCaptureView`，识别完成后把结果写回 mailbox。
- 键盘重新出现时消费响应并上屏。
- Widget 的无 request 语音入口现在也会由主 App 自动创建 request。

### 4. App Group 本地能力真正接到 runtime

新增 `WTKeyboardServiceBinder`：

- 剪贴板 JSON store
- Emoji 最近记录 store
- 常用语 store
- Vision 手写 fallback
- UITextChecker 纠错 fallback
- HTTP AI / 翻译 / 热词 / 媒体 provider
- Bonjour 设备发现/传输
- voice mailbox bridge

`WTKeyboardInputViewController` 已直接创建并持有 binder，不再需要每个面板手工接 closure。

### 5. UI 图标几何继续对齐

从 WeType 3.5.3 keyboard extension 的 PNG 资源测量了 **190 个逻辑 icon family**：

- point canvas size
- alpha glyph bounds
- glyph offset
- @2x/@3x source scale

原 bitmap 不打进 replica；只保留几何测量。生成 `WTIconGeometry353` 后，工具栏/控制中心的 clean-room placeholder 已开始按原 glyph 尺寸布局，而不再统一写死 18/21 pt。

### 6. Mac/Xcode 第一编准备升级为可自动执行

- 新增 `.github/workflows/ios-build.yml`，在 `macos-15` 上跑 `swift test + xcodegen + xcodebuild`。
- 新增 `XcodeIntegration/validate_on_mac.sh`，本地 Mac 一条命令构建 App / Keyboard / Share / Widget 四个 target。
- Keyboard target 排除 host-only Speech implementation，避免 extension-safe API 边界混入。

## 验证

- Core test 从 V6 的 30 个提升到 **36 / 36 passed**。
- 新增 cloud merge、provider config、App Group mailbox、icon geometry tests。
- 全部 Swift 文件 `swiftc -parse` 通过。
- 所有 plist / entitlements `plutil -lint` 通过。
- V7 icon geometry extraction 成功：190 个 logical icon families。

## 真实性边界

V7 仍没有在 Linux 上冒充 Xcode/UIKit 真编译完成。真正的下一关仍是 macOS workflow/Xcode 结果、Hamster 精确 revision 接线、iPhone 同机像素与交互校准，以及生产 provider/传输安全加固。
