# WeType 3.5.3 全功能复刻实施状态 V14

V14 继续遵循“CI 最后再跑”的约束，集中清理还能在 Linux/静态环境里落地的运行时可靠性、设备管理和最终 Rime 接线准备。

## 本轮实际完成

### 1. 已配对/可信设备不再只是临时发现列表

新增 `WTTrustedTransferDevice / WTTrustedTransferRegistry`：

- 成功通过配对并完成传输后记录设备；
- 保存首次配对、最后出现时间、成功传输次数；
- 支持本地移除/撤销记录、恢复与过期清理；
- 通过 App Group `UserDefaults` 持久化；
- 键盘“设备”面板新增“已配对设备”区域和移除操作。

`WTBonjourTransferService` 新增 `onAuthenticatedPeer`，只有发送端收到最终完整性 ACK 后才写入可信设备记录，不把“仅发现到附近设备”误算为已配对。

注意：这仍不是腾讯私有 bound-device 控制面；当前配对密钥为共享 pairing code，因此“移除设备”主要是本地记录管理。生产级逐设备吊销仍需要独立设备密钥/控制面。

### 2. Share Extension 重试不再可能无限循环

`WTTransferBatch` 新增按最大尝试次数筛选失败项：

- `retryableFailedIndexes(maxAttempts:)`
- `hasRetryableFailure(maxAttempts:)`
- `retryFailed(maxAttempts:)`

Share Extension 当前上限为每项 3 次尝试；达到上限后 UI 明确显示“已达重试上限”，不会继续反复排队失败的大文件。

### 3. Keyboard Extension 低内存回收进一步收敛

新增 `WTKeyboardMemoryPressureBudget`。收到 memory warning 时，不只清空媒体/手写/BookVideo 等大缓存，还会限制：

- 当前候选展示数量；
- 剪贴板展示数量（优先保留 pinned）；
- 常用语展示数量；
- 最近 Emoji 数量。

这些操作只裁剪内存中的 presentation cache，不删除 App Group 持久化数据。

同时 `WTKeyboardInputViewController.viewDidDisappear` 也保存逻辑输入模式状态，因为 iOS 有可能在没有先发 memory warning 的情况下回收键盘扩展。

### 4. Hamster/librime 最终模式接线从硬编码升级成配置描述

新增 `WTRimeModeDescriptor / WTRimeBackendProfile`：

- schema ID 可配置；
- Rime options 可配置；
- properties 可配置；
- safe default 只同步通用 `ascii_mode`，不会猜用户具体拼音/双拼/五笔 schema 名。

`WTHamsterRimeSessionAdapter` 和 `WTHamsterAdapterTemplate` 已经支持该 profile。最终选定 Hamster 公开 revision 后，只需把其真实 schema / option API 映射到 `wtApplyModeDescriptor`，不再改 Overlay UI。

公开 Hamster 仓库仍明确以 librime 为底层，并提供 `make framework` / `make schema` 的编译路径；最终具体 wrapper symbol 仍需在 macOS/Xcode 针对选定公开 revision 验证。

## 验证

- Core Swift Package：**87 / 87 tests passed**。
- `Sources / Tests / iOSOverlay / iOSApp / iOSExtensions / iOSServices / HamsterBridge / iOSShared`：**121 个 Swift 文件 `swiftc -parse` 全部通过**。
- XcodeIntegration：5 个 plist + 5 个 entitlements，`plutil -lint` 全通过。
- shipping UI system-symbol gate：**0 个 `Image(systemName:)` / `systemImage:` 占位**。
- `Tools/verify_v14_pre_ci.py`：通过，并继承 V13 全部门禁。

## 当前严格完成度

按“微信输入法 3.5.3 全功能、UI、操作逻辑、输入行为与真机运行尽量一致”的严格口径，V14 约 **89%**。

没有把 Linux 的 parser/test 当成 Xcode 真编译，也没有把 clean-room provider 当成腾讯私有服务结果。剩余主要集中在 Hamster 真实 revision 接线、Xcode/iPhone 真机验证、100 组 IME 黑盒对照、79 组视觉/动画校准，以及生产 provider/识别模型。
