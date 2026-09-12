# 回放轨迹格式

`ReplayTrace` 是一个 Codable 对象，包含两部分：

- `replay.events`：按顺序执行的 `InputEvent`。插入事件使用 `{ "type": "insert", "text": "ni" }`；退格、提交和重置分别使用 `deleteBackward`、`commitPending`、`reset`。
- `expectedSnapshots`：每一步执行后的基准快照，包含 `committedText`、`composingText` 和候选数组。候选包含稳定的 `id` 与 `text`。
- `metadata`：可选的原版版本、设备型号、系统版本、设置指纹和学习状态。缺少这些元数据的轨迹只能作为非冻结样本。

示例：

```json
{
  "replay": {
    "events": [
      { "type": "insert", "text": "ni" },
      { "type": "commitPending" }
    ]
  },
  "expectedSnapshots": [
    { "committedText": "", "composingText": "ni", "candidates": [] },
    { "committedText": "ni", "composingText": "", "candidates": [] }
  ]
}
```

轨迹执行后由 `ReplayComparator` 逐步比较；候选顺序属于比较内容。采样文件应注明原版版本、设备、输入设置、资源状态和学习状态，不能把不同状态的结果合并为同一基准。

冻结前应满足 `isWellFormed`：事件数必须与基准快照数相同，且每个快照通过状态校验。
