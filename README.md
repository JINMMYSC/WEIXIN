# WeTypeReplicaOverlay

微信输入法 / WeType 3.5.3 的兼容复刻实验工程。目标是把 **Hamster/librime 当输入引擎底座**，而键盘几何、候选、手势与各功能面板由自己的 Overlay 按 3.5.3 的行为重新实现。

> 这不是腾讯源码，也不包含原 App 的专有服务端实现。工程使用从 IPA 中测量/分析出来的布局参数和行为接口进行独立重写。

## 当前能验证的内容

- IPA 基准 SHA-256 见 `ReverseEngineering/IPA_SHA256.txt`。
- 15 个键盘 INI 已解析；带 `INHERIT` 的布局会展开为最终有效布局。
- `style.ini` 的 style 继承已解析。
- Core Swift Package 可在当前环境编译，`swift test` 当前 24/24 通过。
- iOS Overlay 文件通过 Swift parser 语法检查；真正 iOS SDK 编译与真机测试仍需 macOS/Xcode。

## 目录

- `Sources/WeTypeReplicaCore/`：跨平台可测试的数据模型、布局、输入引擎协议、状态机、手势解析。
- `iOSOverlay/`：SwiftUI 键盘、候选、工具栏、控制中心、Emoji、剪贴板、手写、语音、翻译、AI、纠错等键盘界面。
- `iOSApp/`：主 App 设置首页与输入/AI/语音/剪贴板/外观/传送等详情页。
- `iOSExtensions/`：Share Extension、语音 Widget、Control Center 的共享 visual surfaces。
- `ReverseEngineering/V2/`：最终有效布局、style、行为证据。
- `ReverseEngineering/BinaryMap/`：主 App/Extension 的依赖、类名与功能字符串地图。
- `Tools/`：从 WeType 3.5.3 IPA 重新生成分析产物与 Swift 布局的脚本。
- `INTEGRATION_HAMSTER.md`：接 Hamster/librime 的边界设计。
- `IMPLEMENTATION_STATUS.md`：全功能当前状态与下一步。

## 快速验证

```bash
swift test
swiftc -frontend -parse iOSOverlay/*.swift
```

在 macOS 上进入 Hamster 工程后，把 `WeTypeReplicaCore` 与 `iOSOverlay` 接入 Keyboard Extension target，再实现 `WTIMEEngine` adapter，把 Rime 的 composition/candidates/commit/reset/delete 映射过来。

## V3 新增（2026-09-13）

- `GeneratedLayoutsV3.swift`: 15 个 inheritance-resolved 真实布局。
- `GeneratedStylesV3.swift`: 修正带行尾注释 section 后的 26 个真实 style。
- `KeyInteraction.swift`: tap / 上滑 / 下滑 / 长按 / FLOATLIST / 中英动态值。
- `PersistentStores.swift` + `CandidatePreferences.swift`: 剪贴板、Emoji、常用语、候选固定/屏蔽持久化。
- `HamsterBridge/`: Rime closure adapter 与 UIInputViewController overlay installer。
- `iOSServices/WTBonjourTransferService.swift`: Bonjour + Network.framework 传送首版。
- `ReverseEngineering/V3/BINARY_BEHAVIOR_MAP.md`: 二进制行为分类报告。
- 当前 Core 单测：21/21 通过；iOS Swift 语法解析通过。


## V4 新增（2026-09-13）

- 全量键盘 chrome：控制中心、快捷设置、输入方案切换、全符号。
- 候选栏/Emoji/剪贴板/语音/翻译/AI/纠错 UI 第二轮对齐。
- 文字润色、设备同步、隔空传送、图片 panel。
- 主 App 设置页面骨架（20+ 详情 destination）。
- Share/Widget/Control Center visual surfaces。
- Core 测试 24/24；所有新增 iOS Swift 文件 parser 通过。
- 详细界面覆盖见 `ReverseEngineering/V4_UI_SURFACE_MAP.md`。

## V5 新增（2026-09-13）

- 实际可变的单手键盘 shell，不再只是状态开关。
- 键盘宽高/位置调节已经进入 renderer，并有保存/取消/恢复默认。
- 工具栏自定义排序并直接驱动 compact toolbar。
- 热词搜索/新增/删除、表情包/自定义表情/GIF 浏览与预览、拆词、笔画筛选。
- 剪贴板图片详情/授权、Plus 能力配置、顶部提示/网络提示/服务说明组件。
- 主 App 新增上述设置入口。
- 新增 `SurfaceCatalog.swift`：93 个 WeType 3.5.3 UI class/surface 覆盖账本。
- Core tests：28/28 通过；全部 iOS Swift 文件 parser 通过。
