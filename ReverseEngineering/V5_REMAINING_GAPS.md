# V5 Remaining Gaps / 下一轮硬任务

1. **Hamster 真 session 接线**：把 `WTIMEEngine` closure 接到 Hamster 当前 librime session 的 composition/candidates/process/select/delete/reset。
2. **macOS/Xcode 第一编**：创建/接入 Keyboard Extension target，修复真实 iOS SDK 类型错误，再做真机安装。
3. **逐屏截图校准**：26 键、9 键、候选栏、控制中心、符号、Emoji、剪贴板、语音、翻译、AI、设置 App 按 iPhone 逻辑像素逐项调整。
4. **原版动效测量**：按键 popup、候选展开、控制中心转场、语音 waveform、表情预览的 duration/curve。
5. **provider 实装**：手写识别、语音、翻译、AI、纠错、文字润色、热词、表情包/GIF。
6. **3 个未判明 surface**：继续分析 `WBFinderView / WBTPListView / WBTPPlayerView` 的调用者和 selector 上下文。
7. **clean-room 图标**：依据原版几何与视觉风格重画，不直接嵌入腾讯原资源。
