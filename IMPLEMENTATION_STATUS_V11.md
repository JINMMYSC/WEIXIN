# WeType 3.5.3 全功能复刻实施状态 V11

V11 的原则：**把 CI 留到最后**，优先清掉当前 Linux/静态环境还能继续完成的工程硬任务。

## 本轮实际完成

### 1. iOS 版本兼容从“统一 iOS 17”改成按 3.5.3 原包分层
从原 IPA Info.plist 重新核对：
- Host App：iOS 15.1
- Keyboard Extension：iOS 15.1
- Share Extension：iOS 16.0
- Voice Live Activity Extension：iOS 16.1
- Widget Extension：iOS 17.0

工程现在按这组 target 分层；Core Swift Package 下调到 iOS 15。为了让 Host/Keyboard 真正能在 15.1 编译，已替换：
- NavigationStack / navigationDestination → NavigationView / destination NavigationLink
- LabeledContent → clean-room 兼容行
- symbolEffect → iOS 15 自定义 pulse 动画
- scrollContentBackground → iOS 15 兼容实现

### 2. 主 App 设置不再只写 UserDefaults.standard
V10 的设置页虽然完整，但部分设置只停留在 Host App 自己的 defaults。
V11 改成 App Group 共享设置，并新增 `WTKeyboardPreferenceSnapshot`：
- 按键音
- 震动及强度
- 单手模式
- 单手宽度
- 字体比例
- 键盘宽高/偏移
- 剪贴板开关
- 云候选开关
- 语音开关
- 工具栏开关

Keyboard Extension 每次出现都会重载共享设置，设置 App 的调整现在会真正传到键盘 Runtime。

### 3. 按键反馈真实接入 Runtime
`WTKeyboardFeedbackService` 不再是孤立文件：
- 普通键触发轻反馈/按键音
- 删除键走独立反馈
- 震动强度读取共享设置
- 工具栏显示开关进入真实渲染路径

### 4. 新增 Debug 预览 IME
新增 `WTPreviewIMEEngine`，只用于 Debug/静态开发阶段：
- 可以输入、退格、选候选、提交
- 内置极小 smoke lexicon，只保证 UI/交互链能跑
- Release 明确仍要求 Hamster/librime，不把 preview engine 冒充生产中文输入引擎

这让以后 Mac/CI 第一编即使还没完成具体 Hamster revision 适配，也能先做 UI/Extension smoke test。

### 5. 补上 3.5.3 的 Voice Live Activity target
原 3.5.3 不只有普通 Widget，还存在独立 Voice Input Live Activity Extension。
V11 新增：
- `WTVoiceActivityAttributes`
- `WTVoiceLiveActivityController`
- `WTVoiceLiveActivityWidget`
- Dynamic Island compact / expanded / minimal UI
- Host Speech capture 与 Live Activity start/update/end 接线
- iOS 16.1 独立 target / plist / App Group entitlement

### 6. XcodeGen 工程嵌入结构继续补全
Host App 现在显式 embed：
- Keyboard Extension
- Share Extension
- Widget Extension
- Voice Activity Extension

Widget / Voice Activity 也增加 App Group entitlement。

### 7. Pre-CI 静态门禁
新增 `Tools/verify_v11_pre_ci.py`，在 CI 之前直接阻止：
- deployment target 漂移
- iOS 16/17-only API 再次误入 15.1 shipping surface
- XcodeGen source/plist/entitlement 路径丢失
- App Group 设置契约缺失
- Debug preview engine 与 Release Hamster boundary 混淆

## 当前验证
- Core tests：**64 / 64 passed**
- Swift parse：**92 files passed**
- plist / entitlements：全部 `plutil -lint` 通过
- XcodeGen YAML：5 targets 结构解析通过
- shipping SF Symbol placeholder：**0**
- V11 pre-CI verifier：通过
- legacy V10 integration verifier：仍通过

## 当前严格完成度
按“功能 + UI + 操作逻辑 + 真机行为 + 可安装发布”一起计算：**约 83%**。

这不是按页面数量算；剩下的是最硬的真机/引擎/服务项。
