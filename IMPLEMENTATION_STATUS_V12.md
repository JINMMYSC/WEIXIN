# WeType 3.5.3 全功能复刻实施状态 V12

V12 继续遵守用户要求：**CI 留到最后**。本轮同时推进输入引擎行为、隔空传送安全、Share Extension、Live Activity、跨 target 共享状态五条线。

## 1. 输入链路修掉了几个会直接影响“像不像”的行为问题

- `WTIMEEngine` 新增 `drainCommit()`：适配 librime 的 `get_commit` 独立提交语义。之前某些由 `process_key` 直接产生的 commit 有可能只改变引擎状态却没有送进宿主输入框。
- 新增 `setInputMode(_:)`：26 键 / 九键 / 双拼 / 五笔 / 笔画 / 英文切换现在会传播到真实后端，不再只是换 UI。
- 空格键改为“有 composition 时先交给输入引擎处理并 drain commit；空闲时才插入字面空格”。
- 直接标点/符号在存在 composition 时先接受首候选，再插入符号，不再把正在输入的拼音静默丢掉。
- host text context 切换时新增 residual-composition 清理，候选展开/长按 popup 也同步清空。
- Hamster production adapter contract 因此从原来的简单五个 closure 升级为可覆盖真实 librime 生命周期的 typed contract。

## 2. 隔空传送升级到协议 V3：配对后文件内容真正加密

原 V8/V11 已有：流式传输、断点续传、SHA-256、HMAC 配对认证、最终 ACK。

V12 新增：
- `WTTransferEnvelope.currentVersion = 3`
- 配对码存在时使用 ChaCha20-Poly1305 逐 chunk AEAD 加密
- 传输 key 使用 HKDF-SHA256 + 每次随机 salt 派生
- 每个 encrypted record 独立 framing，并限制最大密文帧大小
- resume 在加密模式下自动回退到完整 plaintext chunk 边界，截断未完成尾块后继续
- deterministic chunk nonce + per-transfer derived key，避免同 key 下 nonce 重用
- 接收端验证 record nonce、AEAD tag、最终 SHA-256、最终 ACK

未设置配对码时仍允许本地明文兼容模式；正式发行建议默认要求配对。

## 3. Share Extension 从“点发送就结束”修成真实传输生命周期

V11 的 Share Extension 有一个实际风险：启动 async send 后立即 `completeRequest`，系统可能在文件真正发完前结束扩展。

V12 已改为：
- 分享内容先复制到 extension 自己的临时目录，避免 `NSItemProvider` callback 结束后源 URL 失效
- 优先 file representation，失败时回退 data representation / URL / text
- 支持 file / image / movie / audio / data / URL / plain text
- 多文件顺序发送
- 只有全部 `await transfer.send` 成功以后才调用 `completeRequest`
- UI 显示读取、发现设备、连接、发送进度、错误和完成状态
- Share target 读取和 Host/Keyboard 相同的 App Group 配对码，因此 V3 加密链可直接生效
- Share activation rule 补上 movie 与 web URL

## 4. Voice Live Activity 生命周期继续收敛

- attributes 新增 `startedAt`
- ContentState 新增 `updatedAt / isFinal`
- Dynamic Island / Live Activity 显示计时、preparing / recording / recognizing / result / failed / ended 状态
- result / failed 使用 final state，并抑制完全相同的 partial update，减少 ActivityKit 更新浪费
- activity 支持 `wtreplica://voice?request=...` deep link，回到正确语音请求
- 结束状态保留约 2 秒再 dismiss，避免完成结果瞬间消失

## 5. 共享 key 去硬编码

`wt.transfer.pairingCode` 收敛到 `WTSharedPreferenceKey.transferPairingCode`，Host App / Keyboard service / Share Extension 使用同一 key，减少 target 间漂移。

## 验证

- Core tests：**72 / 72 passed**
- 全部 shipping / bridge / core Swift：逐文件 `swiftc -parse` 通过
- plist / entitlements：`plutil -lint` 通过
- `verify_v12_pre_ci.py`：通过，并继承 V11 的 deployment / XcodeGen / App Group / Debug-vs-Release gate
- shipping SF Symbol placeholder 仍保持 0（沿用 V9/V10 gate）

## 当前严格完成度

在仍未运行 macOS/Xcode 真编译、未进行同 iPhone 100-probe 与 79-case 视觉采集的前提下，本轮把静态/离线可完成部分继续推进，严格口径估计约 **86%**。
