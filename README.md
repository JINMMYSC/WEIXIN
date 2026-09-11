# WEIXIN

微信输入法 3.5.3 离线行为对照重建实验。独立研究工程，不是腾讯原始源码。

## 当前范围

首批搭建主 App、键盘扩展和 GitHub Actions。主 App 提供原版/重建版采样用输入框；键盘扩展暂时明确显示引擎未接入，只提供切换系统键盘入口。尚未实现拼音、词库、候选排序或原版界面复现。

## 构建

使用 XcodeGen 2.46.0 根据 `project.yml` 生成工程。CI 使用 macos-15、Xcode 16.4，运行主 App 测试并检查扩展是否正确嵌入，随后构建未签名真机 App。

```sh
xcodegen generate
xcodebuild -list -project WeixinRebuild.xcodeproj
```

在 Actions 中查看实际运行结果；提交工作流不代表构建通过。成功产物中的 `unsigned-device-app.zip` 不能直接安装到 iPhone。实机 IPA 需另接入主 App 和扩展对应的证书、描述文件及安装方式。签名材料不得提交到仓库。

## 研究与验收

见 `docs/plan.md` 和 `docs/sampling.md`。候选与界面按固定环境逐例对照，未完成的模块不使用占位候选伪装成原版结果。

仓库不包含原始 IPA、解包二进制、腾讯词库或模型。下一阶段依据静态分析证据，定位初始化、输入、候选和上屏链路，确认规格后实现。
