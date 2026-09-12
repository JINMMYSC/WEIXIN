# 第二轮：回调、候选更新与上屏链路

本轮基于 `wxkb_plugin` 的静态反汇编，补齐输入处理、候选转换、选词和文本提交之间的可确认连接。地址均为未加 ASLR slide 的虚拟地址；这些结论描述重建规格，不是腾讯原始 ABI。

## 已确认链路

```text
KBIMEMgr.processInput:... 0x10014dd00
  -> 包装函数 0x10014e7b0
  -> wxime_process_input 0x1008ac5dc
  -> getLocalCandidates... 0x100156e34
  -> 候选转换 0x100135c18
  -> wxime_candidate_next 0x1008abefc
  -> candidateWordWithIMECandidate:...
```

选词路径为 `KBIMEMgr.selectCandidate:...`（0x100152484）→ 0x1008b0008 → `select_candidate_impl`（0x1008b0030）。待输入强制提交路径为 `emitPendingInputToScreen...` → `wxime_force_emit_pending_input`（0x1008ad1c4）。

## 提交到宿主

`processInput` 内存在向 `session:emitInputToScreen:replacedSuffix:flag:source:` 发送消息的直接输出分支（0x10014e154）。另一条路径经 `emitPendingInputToScreen...` 处理 pending input，二者不能合并成一个同步回调。

`WBRootViewManager._insertText:`（0x1002fd5c4）最终向 `textDocumentProxy.insertText:`（0x1002fd618、0x1002fd7f0）写入文本；同一方法还处理 `_markedText`、`markedTextInsertScheme:` 和 `_setMarkedText:selectedRange:`。重建必须区分组合串、最终提交、替换后缀以及光标/选区。

## 回调与异步证据

`initIMEEngine`（0x100141b48）在 0x100141c70 注册 `setDidFinishSetEngineInfoBlock:`。`switchSession:config:` 通过 block 和 `dispatch_async` 创建、预热会话。`KBIMESession` 可见属性包含 `scheduleEventBlocksMap`、`destroyBlocks`、`candidateListUpdatedCount` 与 `associationCandidates`，但静态证据尚不足以恢复事件键、block invoke 地址和完整运行时对象关系。

## 重建接口草案

```text
Session.open(type, configuration) -> SessionID
Session.process(event) -> Result { pendingText, candidates, cursorInfo, actions }
Session.select(candidateID, suffix, source) -> Result { pendingText, committedText, candidates }
Session.forceEmit(suffix, onlySelection) -> EmitResult
HostAdapter.setMarkedText(text, selectedRange)
HostAdapter.insertText(text)
```

这只是从静态证据抽出的最小职责边界。`wxime_process_input` 的返回结构、候选更新事件、旧结果丢弃规则和异步时序仍需设备黑盒采样或更细控制流分析确认；本轮没有运行原版，也没有修改 IPA。
