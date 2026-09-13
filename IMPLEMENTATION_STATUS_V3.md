# WeType 3.5.3 全功能复刻实施状态 V3

| 线 | 状态 | 当前可交付内容 |
|---|---|---|
| 26 键拼音 | 代码已落地 | 414×224 精确几何、上/下滑、长按、Shift/语言状态 |
| 26 英文 | 代码已落地 | INI 继承展开、英文动态标点、Shift 状态 |
| 9 键拼音 | 代码已落地 | 不规则绝对布局、上滑数字、独立功能列 |
| 五笔/笔画/双拼 | 框架已落地 | 五笔/笔画布局继承已展开；引擎仍由 Rime provider 驱动 |
| 数字/符号 | 代码已落地 | 9/26 来源数字页、中英符号页、Full Symbol |
| 候选 | 第二阶段 | 横向/展开、点击 select、长按固定/删除兼容层 |
| Emoji | 第二阶段 | 分类、最近记录、8 列 UI、上屏 |
| 剪贴板 | 第二阶段 | JSON/App Group store、固定/删除/清空/卡片 UI |
| 常用语 | 第一阶段 | JSON store、排序模型、键盘面板 |
| 手写 | 第一阶段+ | Canvas、撤销/清除、异步识别 callback、候选回灌 |
| 语音 | UI/服务边界 | 完整状态视图；真实录音/IPC 尚未联调 |
| 翻译 | UI/服务边界 | 输入/结果/换语言/上屏；provider 待接 |
| AI | UI/服务边界 | 问AI/改写/润色/写作；provider 待接 |
| 纠错 | UI/服务边界 | 检查/建议/上屏；provider 待接 |
| 设备传送 | 首版实现 | Bonjour discovery + Network.framework send/receive |
| Hamster/Rime | 接线层已落地 | Closure adapter + UIInputViewController overlay binding |
| 主 App | 未建 Xcode target | 设置模型/页面下一批 |
| Share Extension | 未建 Xcode target | 传送 service 已可复用 |
| Widget/控制中心 | 未建 Xcode target | 逆向范围已确认 |
| 真机验收 | 待 Xcode | 当前环境没有 iOS SDK/签名/真机 |
