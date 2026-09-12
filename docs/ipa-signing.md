# 未签名 IPA 安装说明

CI 生成的 `WeixinRebuild-unsigned.ipa` 是给签名工具使用的包，不是可直接安装的已签名应用。

签名前请确认压缩包根目录包含：

```text
Payload/
  WeixinRebuild.app/
    Info.plist
    PlugIns/
      RebuildKeyboard.appex/
        Info.plist
```

在手机签名软件中导入 IPA，选择你自己的开发证书和设备描述文件后签名安装。安装后依次打开“设置 → 通用 → 键盘 → 键盘 → 添加新键盘”，启用“重建键盘”。首次测试请在主 App 输入框中验证字母键、删除、组合文本、提交和换行。

当前包仍是研究版本：候选词库和原版排序尚未接入，不能作为微信输入法的功能替代品。签名材料、设备 UDID 和个人证书不提交到仓库。
