# V10 Remaining hard gaps

1. **Mac/Xcode real build + signing**：Host App / Keyboard / Share / Widget 需要真实 iOS SDK 类型检查、编译、签名、安装。
2. **Concrete Hamster public revision adapter**：将选定公开 revision 的真实 Rime session/controller API 映射到 `WTHamsterRimeSessionProtocol`。
3. **100-probe same-device IME captures**：采集 WeType 3.5.3 reference + replica 输出，使用 V10 compatibility builder 生成/迭代候选排序 shim。
4. **79-case same-device UI calibration**：逐屏截图和高速录屏，校准 safe area、baseline、阴影、圆角、popup geometry、手势阈值、动画 timing。
5. **Host App exact copy/order/content capture**：V10 已用 12 个 Setup asset folder 与 14 个 SetupMain family 锁定页面范围，但页面精确文案、行排序、banner 状态仍要真机逐屏采集。
6. **Provider parity**：AI/润色、翻译、语音、云候选、热词、GIF/表情、BookVideo/富内容需要 production provider；不会复现腾讯私有后端。
7. **Recognition parity**：Vision handwriting / Apple Speech 只是 fallback；最终需要更接近目标行为的识别模型或兼容排序层。
8. **Transfer security/control plane**：已有 resume/SHA-256/HMAC/ACK，但 transport 仍需生产级加密，并且不会复现腾讯私有 P2P dispatch backend。
9. **Runtime regression**：Spotlight、安全输入框、低内存 Extension 重启、横屏、深色、English→number→return、预输入残留等必须真机跑完。
10. **Original iOS minimum target**：原版 3.5.3 的 `MinimumOSVersion` 为 15.1；当前 replica Xcode 骨架为了部分 SwiftUI/Widget API 暂以 iOS 17 为基线。如需要发行兼容 iOS 15.1，还需做 availability/backport pass。
