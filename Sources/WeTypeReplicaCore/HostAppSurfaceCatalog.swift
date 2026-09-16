import Foundation

public struct WTHostSetupSurface353: Hashable, Sendable, Identifiable {
    public let id: String
    public let purpose: String
    public let evidenceFamilies: [String]
    public let preferredDestination: String

    public init(id: String, purpose: String, evidenceFamilies: [String], preferredDestination: String) {
        self.id = id
        self.purpose = purpose
        self.evidenceFamilies = evidenceFamilies
        self.preferredDestination = preferredDestination
    }
}

/// Host-app setup modules discovered from the shipped 3.5.3 React Native asset tree.
/// This catalog records public/user-observable surface structure only. It does not include original asset pixels.
public enum WTHostSetupSurfaceCatalog353 {
    public static let surfaces: [WTHostSetupSurface353] = [
        .init(id: "SetupMain", purpose: "设置首页、功能入口、首页 banner/footer", evidenceFamilies: ["icon_app_setup_keyboard", "icon_app_setup_voice", "icon_app_setup_multiple_devices", "icon_app_setup_computer", "icon_app_setup_air", "icon_app_setup_customize_toolbar", "icon_setup_migration", "icon_app_setup_pluslogo"], preferredDestination: "settingsHome"),
        .init(id: "SetupKeyboardSelect", purpose: "输入方案添加、删除、排序与进入方案设置", evidenceFamilies: ["icon_add_light", "icon_delete_light", "icon_table_arrow"], preferredDestination: "keyboardManagement"),
        .init(id: "SetupSp", purpose: "双拼方案选择", evidenceFamilies: ["icon_sp_xh_light", "icon_sp_zrm_light", "icon_sp_sg_light", "icon_sp_znabc_light", "icon_sp_wr_light", "icon_sp_pyjj_light", "icon_sp_zg_light"], preferredDestination: "doublePinyin"),
        .init(id: "SetupWb", purpose: "五笔方案选择", evidenceFamilies: ["icon_table_select", "icon_arrow"], preferredDestination: "wubi"),
        .init(id: "SetupFuzzyPinyin", purpose: "模糊拼音规则设置", evidenceFamilies: ["icon_etc_light", "icon_etc_dark"], preferredDestination: "fuzzyPinyin"),
        .init(id: "SetupAuxiliaryInput", purpose: "辅助输入/左右辅助拼音显示", evidenceFamilies: ["blur_pinyin_left_light", "blur_pinyin_right_light", "icon_etc_light"], preferredDestination: "auxiliaryInput"),
        .init(id: "SetupDisplaySetting", purpose: "键盘外观、26/9 键显示、候选/拼音显示、字体和键盘高度", evidenceFamilies: ["img_keyboard_height", "img_number_26", "img_number_9", "img_participle", "img_uppercase", "pinyin_display_upper", "pinyin_display_lower"], preferredDestination: "displaySetting"),
        .init(id: "SetupKeystrokeEffect", purpose: "按键音、振动、语音相关权限/引导", evidenceFamilies: ["icon_voice_big", "icon_voice_small", "fullaccess_guide_light"], preferredDestination: "keystrokeEffect"),
        .init(id: "SetupClipboard", purpose: "剪贴板功能设置与引导", evidenceFamilies: ["img_clipboard_light", "icon_table_arrow"], preferredDestination: "clipboard"),
        .init(id: "SetupDesktop", purpose: "桌面端/多端连接入口", evidenceFamilies: ["icon_computer", "icon_windows", "icon_ios"], preferredDestination: "desktop"),
        .init(id: "SetupMigrationAssistant", purpose: "迁移助手、扫码、更新与完全访问引导", evidenceFamilies: ["icon_scan", "icon_update", "icon_tips_loading", "fullaccess_guide_light"], preferredDestination: "migrationAssistant"),
        .init(id: "SetupPlus", purpose: "微信输入法+ 能力入口", evidenceFamilies: ["icon_setup_ai", "icon_app_pinxieplus_correction", "icon_app_pinxieplus_emoji", "icon_app_pinxieplus_quicksend", "icon_pinxieplus_textpolish", "icon_app_retouching", "icon_app_kaomoji"], preferredDestination: "plus")
    ]

    public static func surface(_ id: String) -> WTHostSetupSurface353? { surfaces.first { $0.id == id } }
    public static var ids: Set<String> { Set(surfaces.map(\.id)) }
}

public struct WTRNBundleBuild353: Hashable, Sendable {
    public let name: String
    public let version: String
    public let build: Int
    public let pipeline: Int
    public init(name: String, version: String, build: Int, pipeline: Int) {
        self.name = name; self.version = version; self.build = build; self.pipeline = pipeline
    }
}

public enum WTRNBundleBuildCatalog353 {
    public static let platform = WTRNBundleBuild353(name: "platform", version: "1.2.0", build: 342, pipeline: 39)
    public static let setup = WTRNBundleBuild353(name: "setup", version: "1.3.5", build: 944, pipeline: 942)
    public static let feedback = WTRNBundleBuild353(name: "feedback", version: "1.3.5", build: 944, pipeline: 942)
    public static let general = WTRNBundleBuild353(name: "general", version: "1.3.5", build: 944, pipeline: 942)
}

public struct WTHostMainEntry353: Hashable, Sendable, Identifiable {
    public var id: String { assetFamily }
    public let assetFamily: String
    public let destination: String
    public let semanticRole: String
    public init(_ assetFamily: String, _ destination: String, _ semanticRole: String) {
        self.assetFamily = assetFamily; self.destination = destination; self.semanticRole = semanticRole
    }
}

/// Every 32pt SetupMain feature icon family found in the shipped host-app bundle is accounted for here.
public enum WTHostMainEntryCatalog353 {
    public static let entries: [WTHostMainEntry353] = [
        .init("icon_app_setup_keyboard", "keyboardManagement", "输入方案/键盘"),
        .init("icon_layout", "displaySetting", "显示与布局"),
        .init("icon_app_setup_customize_toolbar", "toolbarCustomization", "工具栏自定义"),
        .init("icon_app_setup_vibration", "keystrokeEffect", "按键反馈"),
        .init("icon_clipboard", "clipboard", "剪贴板"),
        .init("icon_app_setup_voice", "voice", "语音输入"),
        .init("icon_app_setup_pluslogo", "plus", "微信输入法+"),
        .init("icon_app_setup_air", "transfer", "隔空传送"),
        .init("icon_app_setup_multiple_devices", "multiDevice", "多设备"),
        .init("icon_app_setup_computer", "desktop", "电脑端"),
        .init("icon_setup_migration", "migrationAssistant", "迁移助手"),
        .init("icon_app_setup_privacy", "privacy", "隐私"),
        .init("icon_app_setup_help", "help", "帮助"),
        .init("icon_app_setup_about", "about", "关于")
    ]

    public static var families: Set<String> { Set(entries.map(\.assetFamily)) }
}

public struct WTHostHomeCard353: Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let assetFamily: String
    public let destination: String
    public init(title: String, subtitle: String, assetFamily: String, destination: String) {
        self.title = title
        self.subtitle = subtitle
        self.assetFamily = assetFamily
        self.destination = destination
    }
}

public enum WTHostHomeCatalog353 {
    public static let outerMargin = 20.0
    public static let columnSpacing = 14.0
    public static let cardCornerRadius = 16.0
    public static let backgroundHex = "#E2F1F0"
    public static let cards: [WTHostHomeCard353] = [
        .init(title: "布局和显示", subtitle: "表情键、数字键盘、候选字、高度调节等", assetFamily: "icon_layout", destination: "displaySetting"),
        .init(title: "按键效果", subtitle: "声音、触感、按键气泡", assetFamily: "icon_app_setup_vibration", destination: "keystrokeEffect"),
        .init(title: "定制工具栏", subtitle: "收起键盘等常用功能固定在工具栏", assetFamily: "icon_app_setup_customize_toolbar", destination: "toolbarCustomization"),
        .init(title: "辅助输入", subtitle: "智能加空格、模糊拼音、英文首字母大写等", assetFamily: "icon_app_setup_keyboard", destination: "auxiliaryInput"),
        .init(title: "跨设备粘贴传送", subtitle: "隔空传文件、文字、图片跨设备粘贴、词库同步", assetFamily: "icon_app_setup_multiple_devices", destination: "multiDevice"),
        .init(title: "剪贴板", subtitle: "快速使用复制内容", assetFamily: "icon_clipboard", destination: "clipboard"),
        .init(title: "键盘管理", subtitle: "全键盘、九宫格、手写、五笔、双拼、笔画输入", assetFamily: "icon_app_setup_keyboard", destination: "keyboardManagement"),
        .init(title: "语音转文字", subtitle: "设置语音免跳转方式", assetFamily: "icon_app_setup_voice", destination: "voice"),
        .init(title: "拼写 Plus", subtitle: "智能拼写、表情、颜文字等智能推荐", assetFamily: "icon_app_setup_pluslogo", destination: "plus"),
        .init(title: "单机模式", subtitle: "无需联网，纯本地使用", assetFamily: "icon_app_setup_air", destination: "experiments")
    ]
    public static let moreCards: [WTHostHomeCard353] = [
        .init(title: "隐私与权限", subtitle: "权限、个人词库、隐私设置", assetFamily: "icon_app_setup_privacy", destination: "privacy"),
        .init(title: "电脑版", subtitle: "使用电脑端微信输入法", assetFamily: "icon_app_setup_computer", destination: "desktop"),
        .init(title: "关于", subtitle: "版本与产品信息", assetFamily: "icon_app_setup_about", destination: "about"),
        .init(title: "帮助与反馈", subtitle: "帮助说明与问题反馈", assetFamily: "icon_app_setup_help", destination: "help")
    ]
}

public struct WTDisplaySettingsRow353: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let preferenceKey: String
    public init(id: String, title: String, preferenceKey: String) {
        self.id = id; self.title = title; self.preferenceKey = preferenceKey
    }
}

public struct WTDisplaySettingsSection353: Equatable, Sendable, Identifiable {
    public let id: String
    public let rows: [WTDisplaySettingsRow353]
    public init(id: String, rows: [WTDisplaySettingsRow353]) { self.id = id; self.rows = rows }
}
public enum WTDisplaySettingsCatalog353 {
    public static let sections: [WTDisplaySettingsSection353] = [
        .init(id: "keyboard", rows: [
            .init(id: "emojiKey", title: "表情键", preferenceKey: "wt.display.emoji"),
            .init(id: "numberKeyboard", title: "数字键盘", preferenceKey: "wt.display.number9"),
            .init(id: "candidate", title: "候选字", preferenceKey: "wt.display.candidate")
        ]),
        .init(id: "layout", rows: [
            .init(id: "height", title: "键盘高度", preferenceKey: "wt.display.keyboardHeight"),
            .init(id: "pinyinPosition", title: "拼音显示位置", preferenceKey: "wt.display.pinyinPosition")
        ])
    ]
}
