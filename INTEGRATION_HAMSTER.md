# Hamster 集成方案 V3

## 结构

- Hamster/librime：保留 extension 生命周期、Rime session、schema/userdb。
- WeTypeReplicaCore：布局、状态机、手势解析、候选/持久化模型。
- iOSOverlay：按 3.5.3 绝对坐标渲染 UI。
- HamsterBridge：只做 API 粘合，不把 Hamster 私有类型扩散进 UI。

## 最少需要接的 5 个 Rime closure

在 Hamster 当前持有 Rime session 的位置，用 `WTHamsterAdapterTemplate.make(...)` 填：

1. `context`：返回 composition + candidates + composing state。
2. `process`：把按键字符串交给当前 Rime session。
3. `selectCandidate`：按原始候选 index 选择候选，并返回 commit text（如果该 API 有 commit）。
4. `deleteBackward`：删除 Rime preedit 的一个单位。
5. `reset`：清掉当前 composition/session preedit。

然后创建：

```swift
let binding = WTKeyboardOverlayBinding(
    inputController: self,
    engine: engine,
    initialState: WTKeyboardState(inputMode: .chinesePinyin26),
    onInputModeChanged: { mode in
        // 在这里切 Hamster/Rime schema 或 ascii_mode。
    }
)
binding.install()
```

## 必须注意的候选索引

V3 的 UI 支持“固定到首位/屏蔽”兼容层，所以显示候选顺序可能和 Rime 原始候选顺序不同。`WTKeyboardRuntime.candidateSourceIndexes` 专门保存“显示 index -> Rime source index”，选择候选时必须使用 source index。

## 真机联调硬标准

- composition 删除优先于宿主文本删除。
- 候选 commit 后不能残留 preedit 字母。
- 中文 9 键 -> 英文 -> 中文必须回到 9 键，而不是强制 26 键。
- 26 键上滑 Q~P 输出 1~0；A~M 按 IPA 配置输出符号。
- Emoji/剪贴板/手写/数字/符号返回时保持进入前的输入模式。
- Spotlight、Notes、Messages、Safari、微信文本框分别回归。
