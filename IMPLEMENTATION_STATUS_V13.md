# WeType 3.5.3 全功能复刻实施状态 V13

V13 继续遵循“CI 最后再跑”的约束，把还可以在 Linux/静态环境里确定的输入行为、Extension 恢复和 Share 传输状态继续向前收敛。

## 本轮实际完成

### 1. 候选分页从 UI 假展开升级成真正 backend contract

新增 `WTCandidatePageDirection / WTCandidatePageState`，并把候选分页贯通到：

- `WTIMEContext`
- `WTIMEEngine.moveCandidatePage`
- `WTHamsterRimeSessionProtocol.wtCandidatePageState / wtMoveCandidatePage`
- `WTHamsterRimeSessionAdapter`
- `WTKeyboardOverlayBinding`
- `WTKeyboardRuntime`
- `WTCandidateBar`

展开候选页现在有上一页/下一页状态，不再把“所有候选一次塞进 SwiftUI Grid”当成最终实现。Hamster 的实际公开 revision 只需要把 Rime candidate-menu 的 page number / `is_last_page` / page-up/page-down 接到该 contract。

### 2. Keyboard Extension 低内存/重启恢复

新增 `WTKeyboardSessionSnapshot`。只持久化安全恢复的输入模式状态：当前输入模式与最后一个中文模式；不会持久化 composition、候选、长按菜单或临时面板。

`WTKeyboardServiceBinder` 现在会从 App Group `UserDefaults` 恢复/保存 session；`WTKeyboardInputViewController.didReceiveMemoryWarning()` 会先保存 session，再释放 Emoji/媒体/BookVideo/手写候选/设备列表等可重建的 transient cache。

这样 Extension 被 iOS 回收后重新拉起，不会无条件跳回 26 键中文，同时不会把上一输入框的未提交拼音带到新 session。

### 3. Share Extension 多文件发送加入真正的取消/失败重试状态机

新增纯 Core `WTTransferBatch`：

- pending / transferring / completed / failed / cancelled
- per-item attempts
- overall progress
- retry failed only
- cancellation preserves completed items

Share Extension 现在保存 send Task；发送中“取消”会取消 Task，失败后出现“重试”，重试只重新排队失败项。`WTBonjourTransferService` 的 send/stream/receive 路径加入 `Task.checkCancellation()` checkpoint，避免 UI 已取消而大文件仍持续读写完整个文件。

### 4. 现有 V12 行为继续保留

- librime commit-drain / mode switch / space-to-first-candidate 语义
- host text-context 切换清除 residual composition
- paired ChaCha20-Poly1305 + HKDF + SHA-256 + resume + ACK
- Share provider 内容 staging 后再发送
- Voice Live Activity / Dynamic Island request deep-link 与 final state
- 5 target Xcode/XcodeGen 结构
- shipping UI 继续保持无 SF Symbol 占位

## 验证

- Core Swift Package：**78 / 78 tests passed**。
- `Sources / Tests / iOSOverlay / iOSApp / iOSExtensions / iOSServices / HamsterBridge / iOSShared`：**115 个 Swift 文件 `swiftc -parse` 全部通过**。
- 5 个 plist + 5 个 entitlements：`plutil -lint` 全部通过。
- shipping UI system-symbol gate：通过。
- `Tools/verify_v13_pre_ci.py`：通过，并继承 V12 所有 gate。

## 当前严格完成度

按“微信输入法 3.5.3 全功能、UI、操作逻辑以及真机行为尽量一致”的严格口径，V13 约 **88%**。

这个百分比没有把“已经有页面”当作“已经完成真机一致性”。剩余工作主要集中在真实 Hamster/librime revision 接线、Xcode/iPhone 真编译、同机输入行为与视觉录制对照，以及腾讯私有云服务的等效 provider。
