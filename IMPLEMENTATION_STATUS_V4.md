# WeType 3.5.3 全功能复刻实施状态 V4

V4 的重点不是继续扩“概念范围”，而是把此前缺失的界面层一次性铺开：控制中心、快捷设置、输入方案切换、全符号、设备、快传、图片、文字润色、主 App 设置、Share/Widget/Control Center visual surfaces。

| 模块 | V4 状态 |
|---|---|
| 26/9 键/英文/五笔/笔画/数字符号 | INI 绝对布局层继续保留 |
| 键盘工具栏 | 已重做 compact toolbar |
| 更多功能控制中心 | 已新增 4 列工具页 |
| 快捷设置 | 已新增声音/振动/标点/纠错/单手状态 |
| 输入方案切换 | 已新增 26/9/双拼/五笔/笔画/手写/英文 |
| 全符号 | 已新增 8 分类面板 |
| 候选栏 | V4 重做 compact/expand/action chrome |
| Emoji | V4 扩展为 Emoji/表情包/GIF 三段导航 + 7 分类 |
| 剪贴板 | V4 重做卡片样式/固定状态/读取入口 |
| 语音 | V4 重做 waveform/status/control UI |
| 翻译 | V4 重做语言切换/双编辑区 |
| AI | V4 重做工具 chip/输入/结果/上屏 |
| 纠错 | V4 重做建议 chip/检查操作 |
| 文字润色 | V4 新增独立 panel |
| 设备同步 | V4 新增 panel，service 仍复用 Bonjour/Network.framework |
| 隔空传送 | V4 新增键盘 panel + Share Extension visual surface |
| 图片 | V4 新增 host-app handoff panel |
| 主 App | V4 新增设置首页与 20+ detail destination |
| Widget/控制中心 | V4 新增共享 visual surfaces，Xcode targets 未创建 |
| Hamster/Rime | adapter 边界不变；仍需在真实 Hamster 源码中接 5 个 session closure |
| Xcode/iPhone 验收 | 当前环境不可执行，仍是最大硬阻塞 |

## 当前验证

- `swift test`: **24/24 通过**。
- `iOSOverlay/*.swift`: `swiftc -parse` 全部通过。
- `iOSApp/*.swift`: `swiftc -parse` 通过。
- `iOSExtensions/*.swift`: `swiftc -parse` 通过。
- `HamsterBridge/*.swift`, `iOSServices/*.swift`: parser 通过。
