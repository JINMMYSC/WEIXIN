# WeType 3.5.3 全功能复刻实施状态 V8

V8 的目标不是继续“加页面数量”，而是把已经覆盖的 93 个 surface 往真实行为与视觉细节收敛，并把仍然不一样的部分明确量化。

## 本轮实际完成

### 1. Return 键从固定“换行”升级成原版的上下文状态

二进制存在 `WBReturnKeyView / WBNewlineKeyView`、`returnKeyTypeDidChange`、`returnKeyTypeForSession:` 等证据；`STYLE_RETURN RULE=1` 也有 neutral/brand 两个分支。V8 新增 `WTReturnKeyPresentation`，Keyboard Extension 直接读取当前 host 的 `UITextDocumentProxy.returnKeyType`，切换“换行 / 发送 / 搜索 / 完成 / 前往 / 继续…”等标签，并在语义动作态使用 `#23C891`。

### 2. 隔空传送从原型升级成可恢复的协议

新增 `TransferProtocol.swift` 和 pairing/invite model。`WTBonjourTransferService` 现在：流式传输、`.part` 断点续传、SHA-256 校验、配对码 HMAC、最终 ACK、进度状态。键盘设备页和主 App 设置页也显示共享配对码并支持更换。

静态逆向同时确认原版存在 P2P transfer code、bound-device/dispatch、invite、auth、MD5/checksum、resume 等体系；V8 已补齐用户可见状态和一部分底层语义，但仍不冒充腾讯私有控制面。

### 3. 视觉 token 继续从真实 3.5.3 资源收敛

- Host App palette 使用 IPA 中 `WBColor.json` 的 light/dark 值；
- keyboard key style 使用 `style.ini` 的 normal/gray/pressed/border/shadow/brand 值；
- calibration 默认值统一由 `WTTheme353` 驱动。

### 4. 图标 clean-room pass 继续推进

- 22 个主工具入口全部用独立 Canvas vector；
- toolbar arrange 同样改用这些 vector；
- back/chevron/search/close/plus 等高频 chrome 新增 `WTBasicGlyphView` 自绘；
- `iOSOverlay` 中剩余 SF Symbol 使用从 V7 的约 50+ 降到 **36**，剩余主要是二级面板语义图标/空状态占位。

### 5. 像素差异工具已经可用

`Tools/measure_visual_diff.py` 会输出 MAE、RMSE、exact pixel fraction、阈值差异占比、差异 bbox 与差异图。V8 用 26 键 preview 自比做 self-test：MAE/RMSE 为 0，exact fraction 为 1.0。

### 6. `wxime` vs librime 的行为差不再只写成“待验证”

V8 新增 `WTIMEBehaviorProbe / WTIMEBehaviorSnapshot / WTIMEBehaviorComparator` 与 30 条 starter corpus。以后在同一台 iPhone 上分别跑 WeType 3.5.3 与 replica，就能把 composition、候选排序前缀、commit、composing state 量化成 JSON report，而不是凭手感说“差不多”。这一层不会复制腾讯 `wxime` 内部代码，只比较用户可观察行为。

## 验证

- Core Swift Package：**48 / 48 tests passed**。
- `Sources / iOSOverlay / iOSApp / iOSExtensions / iOSServices / HamsterBridge`：所有 Swift 文件 `swiftc -parse` 通过。
- XcodeIntegration 的 plist / entitlements：`plutil -lint` 全通过。
- visual diff self-test：通过。

## 现在不能假装已经完成的边界

完整差异见 `ReverseEngineering/V8/UI_PARITY_DELTA.md`。最关键仍是：Mac/Xcode 第一编与签名、指定 Hamster revision 的 concrete Rime API 映射、真实 iPhone 同机逐屏/逐动画校准、腾讯私有 `wxime`/云服务与我们的等效实现之间的行为差。
