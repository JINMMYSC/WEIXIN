# V10 IME compatibility layer

WeType 3.5.3 使用腾讯私有 `wxime`，replica 使用 Hamster/librime，因此“算法源码相同”不是目标。V10 的目标是通过同机黑盒 capture，把**用户可见行为**逐项匹配。

新增的 `WTIMECompatibilityProfile` 只执行安全的可观察行为修正：

- 规则按 input mode + composition 匹配；
- 参考候选必须同时存在于当前 Rime candidate menu 才允许提升顺序；
- 不生成 Rime 中不存在的腾讯候选；
- 每项保留原始 Rime `sourceIndex`；
- 后续用户固定/删除、云候选仍可叠加。

流程：

1. 同一台 iPhone 跑 `ReverseEngineering/V9/IME_BEHAVIOR_CORPUS.json`；
2. 导出 WeType reference capture 与 replica capture；
3. 用 `Tools/build_ime_compatibility_profile.py` 生成 profile；
4. Overlay 加载 profile 后重跑；
5. 只针对实际测到的不一致迭代规则。
