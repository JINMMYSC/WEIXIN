# WEIXIN

微信输入法 3.5.3 离线行为对照重建实验。独立研究工程，不是腾讯原始源码。

## 当前范围

主 App、键盘扩展和 GitHub Actions 已建立。键盘扩展具备输入会话、拼音规范化、候选栏、候选选择、分页、删除、提交、切换键盘、异步结果门控和可恢复学习记录闭环；候选引擎目前通过可注入表适配器接入，便于测试和替换为逆向后的真实资源。它仍不是腾讯原版算法的复刻。

## 构建

使用 XcodeGen 2.46.0 根据 `project.yml` 生成工程。CI 使用 macos-15、Xcode 16.4，运行主 App 测试并检查扩展是否正确嵌入，随后构建未签名真机 App。

```sh
xcodegen generate
xcodebuild -list -project WeixinRebuild.xcodeproj
```

在 Actions 中查看实际运行结果；提交工作流不代表构建通过。成功产物中的 `WeixinRebuild-unsigned.ipa` 是未签名包，可以下载后交给手机签名软件处理；它不能直接安装到 iPhone。实机 IPA 仍需主 App 和扩展对应的证书、描述文件及安装方式。签名材料不得提交到仓库。

## 研究与验收

见 `docs/plan.md`、`docs/sampling.md` 和 `docs/trace-format.md`。候选与界面按固定环境逐例对照，`ReplayTrace` 可保存事件与基准快照，`ReplayComparator` 可逐步报告差异；未完成的模块不使用占位候选伪装成原版结果。

仓库不包含原始 IPA、解包二进制、腾讯词库或模型。资源格式证据和限制见 `docs/resource-reverse.md`；下一阶段将依据已确认的装载线索接入等效资源，并用原版回放逐例校验。
