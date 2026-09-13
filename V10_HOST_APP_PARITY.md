# V10 Host App parity evidence

## 3.5.3 shipped Setup modules

从 IPA `Payload/wxkb.app/RNBundles/assets/src/Setup/` 发现并覆盖：

`SetupMain`, `SetupKeyboardSelect`, `SetupSp`, `SetupWb`, `SetupFuzzyPinyin`, `SetupAuxiliaryInput`, `SetupDisplaySetting`, `SetupKeystrokeEffect`, `SetupClipboard`, `SetupDesktop`, `SetupMigrationAssistant`, `SetupPlus`。

V10 的 `ReverseEngineering/V10/host_setup_geometry_353.json` 记录 310 个图片变体、114 个 family 的 canvas/alpha bounds，仅保存测量元数据，不包含原始腾讯图片像素。

## SetupMain feature families accounted for

- `icon_app_setup_keyboard` → 键盘管理
- `icon_layout` → 显示设置
- `icon_app_setup_customize_toolbar` → 工具栏设置
- `icon_app_setup_vibration` → 按键效果
- `icon_clipboard` → 剪贴板
- `icon_app_setup_voice` → 语音输入
- `icon_app_setup_pluslogo` → 微信输入法+
- `icon_app_setup_air` → 隔空传送
- `icon_app_setup_multiple_devices` → 多设备
- `icon_app_setup_computer` → 电脑端
- `icon_setup_migration` → 迁移助手
- `icon_app_setup_privacy` → 隐私
- `icon_app_setup_help` → 帮助与反馈
- `icon_app_setup_about` → 关于

## RN build metadata observed in 3.5.3

`rnbundleInfo.json` 显示：setup/general/feedback 为 `1.3.5 build 944`，platform 为 `1.2.0 build 342`。这些值只用于确定复刻参考版本范围。
