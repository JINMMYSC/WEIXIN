import SwiftUI
import Foundation

public struct WTSettingsAppView: View {
    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    statusCard
                    featureBannerStrip
                    section("输入设置", rows: [
                        .init("键盘管理", "keyboard", .keyboardManagement, "icon_app_setup_keyboard"),
                        .init("拼音输入", "textformat.abc", .pinyin),
                        .init("模糊拼音", "textformat.abc", .fuzzyPinyin),
                        .init("辅助输入", "textformat.abc", .auxiliaryInput),
                        .init("双拼", "rectangle.split.3x1", .doublePinyin),
                        .init("五笔", "square.grid.3x3", .wubi),
                        .init("笔画", "line.diagonal", .stroke),
                        .init("手写输入", "scribble", .handwriting)
                    ])
                    section("智能输入", rows: [
                        .init("云候选", "icloud", .cloudCandidate),
                        .init("拼写纠错", "checkmark.circle", .correction),
                        .init("AI 功能", "sparkles", .ai),
                        .init("翻译", "character.book.closed", .translation),
                        .init("语音输入", "waveform", .voice, "icon_app_setup_voice")
                    ])
                    section("键盘工具", rows: [
                        .init("工具栏设置", "rectangle.3.group", .toolbarCustomization, "icon_app_setup_customize_toolbar"),
                        .init("剪贴板", "doc.on.clipboard", .clipboard, "icon_clipboard"),
                        .init("常用语", "text.quote", .phrases),
                        .init("Emoji 与表情", "face.smiling", .emoji),
                        .init("表情包与 GIF", "photo.stack", .stickers),
                        .init("热词与用户词", "flame", .hotWords),
                        .init("微信输入法+", "plus.circle", .plus, "icon_app_setup_pluslogo"),
                        .init("隔空传送", "paperplane", .transfer, "icon_app_setup_air")
                    ])
                    section("外观与体验", rows: [
                        .init("显示设置", "paintbrush", .displaySetting, "icon_layout"),
                        .init("键盘外观", "paintbrush", .appearance),
                        .init("键盘字体", "textformat.size", .font),
                        .init("键盘调节", "rectangle.arrowtriangle.2.outward", .keyboardAdjust),
                        .init("按键效果", "speaker.wave.2", .keystrokeEffect, "icon_app_setup_vibration"),
                        .init("声音与振动", "speaker.wave.2", .feedback),
                        .init("单手键盘", "hand.raised", .oneHanded),
                        .init("实验功能", "testtube.2", .experiments)
                    ])
                    section("设备与迁移", rows: [
                        .init("多设备", "laptopcomputer.and.iphone", .multiDevice, "icon_app_setup_multiple_devices"),
                        .init("电脑端", "desktopcomputer", .desktop, "icon_app_setup_computer"),
                        .init("迁移助手", "arrow.triangle.2.circlepath", .migrationAssistant, "icon_setup_migration")
                    ])
                    section("其他", rows: [
                        .init("键盘授权指南", "checkmark.shield", .authorizationGuide),
                        .init("隐私", "checkmark.shield", .privacy, "icon_app_setup_privacy"),
                        .init("帮助与反馈", "questionmark.circle", .help, "icon_app_setup_help"),
                        .init("关于微信输入法", "info.circle", .about, "icon_app_setup_about")
                    ])
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 28)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("微信输入法")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color(red: 35/255, green: 200/255, blue: 145/255))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 35/255, green: 200/255, blue: 145/255))
                    WTSemanticGlyph(name: "keyboard.fill").foregroundStyle(.white).font(.system(size: 22))
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text("微信输入法").font(.system(size: 17, weight: .semibold))
                    Text("键盘已启用后，可在任意输入框使用")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            Button("键盘启用指南") {}
                .font(.system(size: 13, weight: .medium))
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var featureBannerStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                WTHomeFeatureBanner(title: "问 AI", subtitle: "在输入场景中直接提问", glyph: "sparkles")
                WTHomeFeatureBanner(title: "设备同步", subtitle: "手机与电脑协同输入", glyph: "arrow.triangle.2.circlepath")
                WTHomeFeatureBanner(title: "快捷发送", subtitle: "快速发送图片与文件", glyph: "paperplane.fill")
                WTHomeFeatureBanner(title: "文字润色", subtitle: "优化表达与语气", glyph: "wand.and.stars")
                WTHomeFeatureBanner(title: "表情推荐", subtitle: "输入时推荐 Emoji 与表情", glyph: "face.smiling")
            }
            .padding(.vertical, 2)
        }
    }

    private func section(_ title: String, rows: [WTSettingsRowModel]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    NavigationLink(destination: WTSettingsDetailView(destination: row.destination)) {
                        HStack(spacing: 12) {
                            if let family = row.hostSetupFamily {
                                WTHostMeasuredSetupGlyph(family: family, semanticName: row.systemName)
                                    .foregroundStyle(.primary)
                            } else {
                                WTSemanticGlyph(name: row.systemName).frame(width: 32).foregroundStyle(.primary)
                            }
                            Text(row.title).font(.system(size: 15)).foregroundStyle(.primary)
                            Spacer()
                            WTSemanticGlyph(name: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                    if index != rows.count - 1 {
                        Divider().padding(.leading, 58)
                    }
                }
            }
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

public enum WTSettingsDestination: String, Hashable, CaseIterable {
    case keyboardManagement, pinyin, fuzzyPinyin, auxiliaryInput, doublePinyin, wubi, stroke, handwriting
    case cloudCandidate, correction, ai, translation, voice
    case toolbarCustomization, clipboard, phrases, emoji, stickers, hotWords, plus, transfer
    case displaySetting, appearance, font, keyboardAdjust, keystrokeEffect, feedback, oneHanded, experiments
    case multiDevice, desktop, migrationAssistant, authorizationGuide, privacy, help, about

    var title: String {
        switch self {
        case .keyboardManagement: return "键盘管理"
        case .pinyin: return "拼音输入"
        case .fuzzyPinyin: return "模糊拼音"
        case .auxiliaryInput: return "辅助输入"
        case .doublePinyin: return "双拼"
        case .wubi: return "五笔"
        case .stroke: return "笔画"
        case .handwriting: return "手写输入"
        case .cloudCandidate: return "云候选"
        case .correction: return "拼写纠错"
        case .ai: return "AI 功能"
        case .translation: return "翻译"
        case .voice: return "语音输入"
        case .toolbarCustomization: return "工具栏设置"
        case .clipboard: return "剪贴板"
        case .phrases: return "常用语"
        case .emoji: return "Emoji 与表情"
        case .stickers: return "表情包与 GIF"
        case .hotWords: return "热词与用户词"
        case .plus: return "微信输入法+"
        case .transfer: return "隔空传送"
        case .displaySetting: return "显示设置"
        case .appearance: return "键盘外观"
        case .font: return "键盘字体"
        case .keyboardAdjust: return "键盘调节"
        case .keystrokeEffect: return "按键效果"
        case .feedback: return "声音与振动"
        case .oneHanded: return "单手键盘"
        case .experiments: return "实验功能"
        case .multiDevice: return "多设备"
        case .desktop: return "电脑端"
        case .migrationAssistant: return "迁移助手"
        case .authorizationGuide: return "键盘授权指南"
        case .privacy: return "隐私"
        case .help: return "帮助与反馈"
        case .about: return "关于微信输入法"
        }
    }
}

private struct WTSettingsRowModel {
    let title: String
    let systemName: String
    let destination: WTSettingsDestination
    let hostSetupFamily: String?
    init(_ title: String, _ systemName: String, _ destination: WTSettingsDestination, _ hostSetupFamily: String? = nil) {
        self.title = title; self.systemName = systemName; self.destination = destination; self.hostSetupFamily = hostSetupFamily
    }
}

public struct WTSettingsDetailView: View {
    let destination: WTSettingsDestination
    @State private var transferCode = ""
    public init(destination: WTSettingsDestination) { self.destination = destination }

    public var body: some View {
        Form {
            content
        }
        .listStyle(.insetGrouped)
        .pageBackground()
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if destination == .transfer { transferCode = loadOrCreateTransferCode() }
        }
    }

    /// Applies the measured 3.5.3 page background. `scrollContentBackground` needs iOS 16,
    /// so the deployment-floor path configures the UIKit backing view instead.
    @ViewBuilder private func pageBackground() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
                .background(Color(wtHex: WTHostSettingsChrome353.pageBackground).ignoresSafeArea())
        } else {
            background(Color(wtHex: WTHostSettingsChrome353.pageBackground).ignoresSafeArea())
                .onAppear {
                    UITableView.appearance().backgroundColor =
                        UIColor(wtHex: WTHostSettingsChrome353.pageBackground)
                }
        }
    }

    @ViewBuilder private var content: some View {
        switch destination {
        case .keyboardManagement:
            Section("已启用输入方案") {
                Toggle("拼音 26 键", isOn: appStorage("wt.mode.t26", defaultValue: true))
                Toggle("拼音 9 键", isOn: appStorage("wt.mode.t9", defaultValue: true))
                Toggle("双拼", isOn: appStorage("wt.mode.double", defaultValue: false))
                Toggle("五笔", isOn: appStorage("wt.mode.wubi", defaultValue: false))
                Toggle("笔画", isOn: appStorage("wt.mode.stroke", defaultValue: false))
                Toggle("手写", isOn: appStorage("wt.mode.hw", defaultValue: true))
            }
            Section { Text("键盘内的“键盘”面板会按这里的顺序展示输入方案。").font(.footnote).foregroundStyle(.secondary) }
        case .pinyin:
            Section("拼音设置") {
                Toggle("模糊拼音", isOn: appStorage("wt.pinyin.blur", defaultValue: false))
                Toggle("智能纠错", isOn: appStorage("wt.pinyin.correct", defaultValue: true))
                Toggle("首字母简拼", isOn: appStorage("wt.pinyin.simple", defaultValue: true))
                Toggle("动态词频", isOn: appStorage("wt.pinyin.frequency", defaultValue: true))
            }
        case .fuzzyPinyin:
            Section("声母") {
                Toggle("z / zh", isOn: appStorage("wt.fuzzy.z_zh", defaultValue: false))
                Toggle("c / ch", isOn: appStorage("wt.fuzzy.c_ch", defaultValue: false))
                Toggle("s / sh", isOn: appStorage("wt.fuzzy.s_sh", defaultValue: false))
                Toggle("n / l", isOn: appStorage("wt.fuzzy.n_l", defaultValue: false))
                Toggle("f / h", isOn: appStorage("wt.fuzzy.f_h", defaultValue: false))
            }
            Section("韵母") {
                Toggle("an / ang", isOn: appStorage("wt.fuzzy.an_ang", defaultValue: false))
                Toggle("en / eng", isOn: appStorage("wt.fuzzy.en_eng", defaultValue: false))
                Toggle("in / ing", isOn: appStorage("wt.fuzzy.in_ing", defaultValue: false))
            }
        case .auxiliaryInput:
            Section("辅助输入") {
                Picker("拼音提示位置", selection: stringStorage("wt.auxiliary.position", "关闭")) {
                    Text("关闭").tag("关闭"); Text("左侧").tag("左侧"); Text("右侧").tag("右侧")
                }
                Toggle("候选区显示辅助信息", isOn: appStorage("wt.auxiliary.candidate", defaultValue: true))
            }
            Section { Text("3.5.3 安装包包含左右两套辅助拼音展示资源；这里按相同入口结构实现，具体像素在真机校准阶段继续收敛。") }
        case .doublePinyin:
            Section("双拼方案") {
                Picker("方案", selection: stringStorage("wt.double.scheme", "小鹤双拼")) {
                    Text("小鹤双拼").tag("小鹤双拼")
                    Text("自然码").tag("自然码")
                    Text("微软双拼").tag("微软双拼")
                    Text("搜狗双拼").tag("搜狗双拼")
                }
            }
        case .wubi:
            Section("五笔设置") {
                Picker("版本", selection: stringStorage("wt.wubi.scheme", "86 版")) {
                    Text("86 版").tag("86 版")
                    Text("98 版").tag("98 版")
                }
                Toggle("五笔拼音混输", isOn: appStorage("wt.wubi.mix", defaultValue: true))
            }
        case .stroke:
            Section("笔画输入") {
                Toggle("显示笔画提示", isOn: appStorage("wt.stroke.tips", defaultValue: true))
                Toggle("允许通配笔画", isOn: appStorage("wt.stroke.wildcard", defaultValue: true))
            }
        case .handwriting:
            Section("手写设置") {
                Toggle("连续手写", isOn: appStorage("wt.hw.continuous", defaultValue: true))
                Toggle("叠写", isOn: appStorage("wt.hw.overlay", defaultValue: true))
                Picker("笔迹粗细", selection: intStorage("wt.hw.width", 2)) {
                    Text("细").tag(1); Text("标准").tag(2); Text("粗").tag(3)
                }
            }
        case .cloudCandidate:
            Section {
                Toggle("云候选", isOn: appStorage("wt.cloud.enabled", defaultValue: true))
                Toggle("弱网时自动关闭", isOn: appStorage("wt.cloud.weaknetwork", defaultValue: true))
            }
            Section { Text("云候选涉及网络服务，清洁室实现只保留接口和 UI；需要使用你自己的服务端。") }
        case .correction:
            Section {
                Toggle("拼写纠错", isOn: appStorage("wt.correction.enabled", defaultValue: true))
                Toggle("候选栏显示纠错提示", isOn: appStorage("wt.correction.candidate", defaultValue: true))
            }
        case .ai:
            Section("AI 工具") {
                Toggle("问 AI", isOn: appStorage("wt.ai.ask", defaultValue: true))
                Toggle("文字润色", isOn: appStorage("wt.ai.polish", defaultValue: true))
                Toggle("写作", isOn: appStorage("wt.ai.write", defaultValue: true))
                Toggle("翻译", isOn: appStorage("wt.ai.translate", defaultValue: true))
            }
            Section("隐私") { Toggle("发送选中文本前提示", isOn: appStorage("wt.ai.confirm", defaultValue: true)) }
        case .translation:
            Section {
                Picker("默认目标语言", selection: stringStorage("wt.translate.target", "英文")) {
                    Text("英文").tag("英文"); Text("中文").tag("中文"); Text("日文").tag("日文"); Text("韩文").tag("韩文")
                }
                Toggle("自动检测源语言", isOn: appStorage("wt.translate.auto", defaultValue: true))
            }
        case .voice:
            Section("语音输入") {
                Toggle("语音输入", isOn: appStorage("wt.voice.enabled", defaultValue: true))
                Toggle("自动添加标点", isOn: appStorage("wt.voice.punctuation", defaultValue: true))
                Toggle("离线优先", isOn: appStorage("wt.voice.offline", defaultValue: false))
            }
        case .toolbarCustomization:
            Section("键盘工具栏") {
                Toggle("显示工具栏", isOn: appStorage("wt.toolbar.enabled", defaultValue: true))
                Toggle("自动推荐工具", isOn: appStorage("wt.toolbar.smart", defaultValue: true))
                Button("调整工具顺序") {}
            }
            Section { Text("键盘内同样提供拖动排序入口；主 App 与键盘通过 App Group 共用顺序。") }
        case .clipboard:
            Section {
                Toggle("剪贴板历史", isOn: appStorage("wt.clipboard.enabled", defaultValue: true))
                Toggle("自动保存复制内容", isOn: appStorage("wt.clipboard.auto", defaultValue: true))
            }
            Section("历史数量") { Stepper("最多 100 条", value: intStorage("wt.clipboard.max", 100), in: 20...300, step: 20) }
            Section { Button("清空未固定记录", role: .destructive) {} }
        case .phrases:
            Section { Text("常用语列表由主 App 与键盘通过 App Group 共享。") }
            Section { Button("新增常用语") {} }
        case .emoji:
            Section {
                Toggle("显示最近使用", isOn: appStorage("wt.emoji.recent", defaultValue: true))
                Toggle("联想 Emoji", isOn: appStorage("wt.emoji.recommend", defaultValue: true))
                Toggle("表情包入口", isOn: appStorage("wt.emoji.sticker", defaultValue: true))
            }
        case .stickers:
            Section("表情包") {
                Toggle("显示表情包入口", isOn: appStorage("wt.sticker.enabled", defaultValue: true))
                Toggle("显示 GIF 入口", isOn: appStorage("wt.gif.enabled", defaultValue: true))
                Toggle("允许搜索在线内容", isOn: appStorage("wt.media.search", defaultValue: true))
            }
            Section { Text("在线表情包和 GIF 需要由独立内容 provider 提供。") }
        case .hotWords:
            Section {
                Toggle("热词更新", isOn: appStorage("wt.hotword.enabled", defaultValue: true))
                Toggle("用户词自动学习", isOn: appStorage("wt.userdict.learn", defaultValue: true))
            }
            Section { Button("管理用户词") {}; Button("导入词库") {} }
        case .plus:
            Section("微信输入法+") {
                Toggle("智能纠错", isOn: appStorage("wt.plus.correction", defaultValue: true))
                Toggle("Emoji 增强", isOn: appStorage("wt.plus.emoji", defaultValue: true))
                Toggle("隔空传送", isOn: appStorage("wt.plus.transfer", defaultValue: true))
                Toggle("文字润色", isOn: appStorage("wt.plus.polish", defaultValue: true))
            }
        case .transfer:
            Section("设备配对") {
                HStack {
                    Text("配对码")
                    Spacer()
                    Text(transferCode.isEmpty ? "------" : transferCode)
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold, design: .monospaced))
                }
                Button("更换配对码") { transferCode = regenerateTransferCode() }
            }
            Section {
                Toggle("允许发现附近设备", isOn: appStorage("wt.transfer.discoverable", defaultValue: true))
                Toggle("仅同一局域网", isOn: appStorage("wt.transfer.lanonly", defaultValue: true))
            }
            Section("传输") {
                Button("开始查找设备") {}
                WTLabeledValueRow("断点续传", value: "已启用")
                WTLabeledValueRow("完整性校验", value: "SHA-256")
            }
        case .displaySetting:
            Section("键盘样式") {
                Picker("外观", selection: stringStorage("wt.display.theme", "跟随系统")) {
                    Text("跟随系统").tag("跟随系统"); Text("浅色").tag("浅色"); Text("深色").tag("深色")
                }
                Toggle("26 键显示数字", isOn: appStorage("wt.display.number26", defaultValue: false))
                Toggle("9 键显示数字", isOn: appStorage("wt.display.number9", defaultValue: true))
                Toggle("显示大写字母", isOn: appStorage("wt.display.uppercase", defaultValue: false))
                Toggle("显示分词", isOn: appStorage("wt.display.participle", defaultValue: true))
            }
            Section("拼音显示") {
                Picker("位置", selection: stringStorage("wt.display.pinyinPosition", "上方")) {
                    Text("上方").tag("上方"); Text("下方").tag("下方")
                }
            }
            Section("尺寸") {
                Slider(value: doubleStorage("wt.display.keyboardHeight", 1.0), in: 0.85...1.20, step: 0.01) { Text("键盘高度") }
                Slider(value: doubleStorage("wt.display.fontScale", 1.0), in: 0.85...1.20, step: 0.01) { Text("字体大小") }
            }
        case .appearance:
            Section("键盘") {
                Picker("外观", selection: stringStorage("wt.appearance.mode", "跟随系统")) {
                    Text("跟随系统").tag("跟随系统"); Text("浅色").tag("浅色"); Text("深色").tag("深色")
                }
                Slider(value: doubleStorage("wt.appearance.height", 1.0), in: 0.9...1.15, step: 0.01) { Text("键盘高度") }
                Slider(value: doubleStorage("wt.appearance.font", 1.0), in: 0.85...1.2, step: 0.05) { Text("字体大小") }
            }
        case .font:
            Section("字体") {
                Picker("键帽字体大小", selection: stringStorage("wt.font.size", "标准")) {
                    Text("小").tag("小"); Text("标准").tag("标准"); Text("大").tag("大"); Text("特大").tag("特大")
                }
                Toggle("候选词跟随字体大小", isOn: appStorage("wt.font.candidate", defaultValue: true))
            }
        case .keyboardAdjust:
            Section("键盘尺寸") {
                Slider(value: doubleStorage("wt.rect.width", 1.0), in: 0.72...1.0, step: 0.01) { Text("宽度") }
                Slider(value: doubleStorage("wt.rect.height", 1.0), in: 0.80...1.18, step: 0.01) { Text("高度") }
            }
            Section("位置") {
                Slider(value: doubleStorage("wt.rect.x", 0.0), in: -0.20...0.20, step: 0.01) { Text("左右") }
                Slider(value: doubleStorage("wt.rect.y", 0.0), in: -0.15...0.15, step: 0.01) { Text("上下") }
            }
            Section { Button("恢复默认") {} }
        case .keystrokeEffect:
            Section("按键反馈") {
                Toggle("按键音", isOn: appStorage("wt.keystroke.sound", defaultValue: true))
                Toggle("按键振动", isOn: appStorage("wt.keystroke.haptic", defaultValue: true))
                Toggle("按键气泡", isOn: appStorage("wt.keystroke.popup", defaultValue: true))
            }
            Section("语音键") {
                Toggle("显示语音输入入口", isOn: appStorage("wt.keystroke.voice", defaultValue: true))
            }
        case .feedback:
            Section {
                Toggle("按键音", isOn: appStorage("wt.feedback.sound", defaultValue: true))
                Toggle("按键振动", isOn: appStorage("wt.feedback.haptic", defaultValue: true))
                Slider(value: doubleStorage("wt.feedback.haptic.level", 0.5), in: 0...1) { Text("振动强度") }
            }
        case .oneHanded:
            Section {
                Picker("默认单手模式", selection: stringStorage("wt.onehand.mode", "关闭")) {
                    Text("关闭").tag("关闭"); Text("左手").tag("左手"); Text("右手").tag("右手")
                }
                Slider(value: doubleStorage("wt.onehand.width", 0.82), in: 0.68...0.95, step: 0.01) { Text("键盘宽度") }
            }
        case .experiments:
            Section("实验功能") {
                Toggle("候选 AI 建议", isOn: appStorage("wt.exp.candidateai", defaultValue: false))
                Toggle("智能工具栏推荐", isOn: appStorage("wt.exp.toolbar", defaultValue: true))
                Toggle("新符号面板", isOn: appStorage("wt.exp.symbol", defaultValue: true))
            }
        case .multiDevice:
            Section("多设备") {
                Toggle("设备同步", isOn: appStorage("wt.multidevice.sync", defaultValue: true))
                Button("管理已配对设备") {}
                Button("添加新设备") {}
            }
            Section { Text("当前 clean-room 实现会保留与原版相同的用户可见入口和状态，但不会复制腾讯私有设备控制面。") }
        case .desktop:
            Section("电脑端") {
                WTLabeledValueRow("Windows", value: "支持")
                WTLabeledValueRow("iPhone / iPad", value: "本机")
                Button("查找附近设备") {}
            }
            Section { Text("设备发现、配对和文件/文本传送使用独立 clean-room 协议实现，不调用腾讯私有控制面。") }
        case .migrationAssistant:
            Section("迁移助手") {
                Button("扫码迁移") {}
                Button("检查迁移数据更新") {}
                WTLabeledValueRow("完全访问", value: "迁移部分数据时需要")
            }
            Section { Text("安装包中存在扫码、更新、加载和完全访问引导资源；当前已建立对应页面与状态入口。") }
        case .authorizationGuide:
            Section("键盘权限") {
                HStack { WTSemanticGlyph(name: "keyboard").frame(width: 20); Text("键盘启用"); Spacer(); Text("设置中开启").foregroundStyle(.secondary) }
                HStack { WTSemanticGlyph(name: "checkmark.shield").frame(width: 20); Text("允许完全访问"); Spacer(); Text("高级功能需要").foregroundStyle(.secondary) }
                HStack { WTSemanticGlyph(name: "mic").frame(width: 20); Text("麦克风与语音识别"); Spacer(); Text("语音输入需要").foregroundStyle(.secondary) }
                HStack { WTSemanticGlyph(name: "network").frame(width: 20); Text("本地网络"); Spacer(); Text("隔空传送需要").foregroundStyle(.secondary) }
            }
            Section { Button("打开系统设置") {} }
        case .privacy:
            Section("隐私设置") {
                Toggle("网络功能使用前提示", isOn: appStorage("wt.privacy.networkPrompt", defaultValue: true))
                Toggle("剪贴板访问提示", isOn: appStorage("wt.privacy.clipboardPrompt", defaultValue: true))
                Toggle("仅在需要时请求完全访问", isOn: appStorage("wt.privacy.fullAccessPrompt", defaultValue: true))
            }
            Section { Button("查看隐私说明") {} }
        case .help:
            Section { Button("键盘启用指南") {}; Button("常见问题") {}; Button("意见反馈") {} }
        case .about:
            Section {
                HStack { Text("版本"); Spacer(); Text("3.5.3 replica").foregroundStyle(.secondary) }
                Button("隐私说明") {}
                Button("许可与开源组件") {}
            }
        }
    }

    private var sharedTransferDefaults: UserDefaults {
        let group = Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String
        if let group, let defaults = UserDefaults(suiteName: group) { return defaults }
        return .standard
    }

    private func loadOrCreateTransferCode() -> String {
        let key = WTSharedPreferenceKey.transferPairingCode
        if let current = sharedTransferDefaults.string(forKey: key) {
            let normalized = WTTransferPairingInfo.normalized(current)
            if normalized.count >= 6 { return normalized }
        }
        return regenerateTransferCode()
    }

    private func regenerateTransferCode() -> String {
        let value = String(format: "%06d", Int.random(in: 0...999_999))
        sharedTransferDefaults.set(value, forKey: WTSharedPreferenceKey.transferPairingCode)
        return value
    }

    private var sharedSettingsDefaults: UserDefaults { sharedTransferDefaults }

    private func appStorage(_ key: String, defaultValue: Bool) -> Binding<Bool> {
        let defaults = sharedSettingsDefaults
        return Binding(get: { defaults.object(forKey: key) as? Bool ?? defaultValue }, set: { defaults.set($0, forKey: key) })
    }
    private func stringStorage(_ key: String, _ defaultValue: String) -> Binding<String> {
        let defaults = sharedSettingsDefaults
        return Binding(get: { defaults.string(forKey: key) ?? defaultValue }, set: { defaults.set($0, forKey: key) })
    }
    private func intStorage(_ key: String, _ defaultValue: Int) -> Binding<Int> {
        let defaults = sharedSettingsDefaults
        return Binding(get: { defaults.object(forKey: key) as? Int ?? defaultValue }, set: { defaults.set($0, forKey: key) })
    }
    private func doubleStorage(_ key: String, _ defaultValue: Double) -> Binding<Double> {
        let defaults = sharedSettingsDefaults
        return Binding(get: { defaults.object(forKey: key) as? Double ?? defaultValue }, set: { defaults.set($0, forKey: key) })
    }
}

private struct WTLabeledValueRow: View {
    let title: String
    let value: String
    init(_ title: String, value: String) { self.title = title; self.value = value }
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

private struct WTHomeFeatureBanner: View {
    let title: String
    let subtitle: String
    let glyph: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.92, green: 0.99, blue: 0.97), Color(red: 0.84, green: 0.96, blue: 0.93)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 7) {
                WTSemanticGlyph(name: glyph)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(red: 35/255, green: 200/255, blue: 145/255))
                Spacer(minLength: 12)
                Text(title).font(.system(size: 16, weight: .semibold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(2)
            }
            .padding(14)
        }
        .frame(width: 150, height: 150)
        .accessibilityElement(children: .combine)
    }
}

private struct WTHostMeasuredSetupGlyph: View {
    let family: String
    let semanticName: String

    var body: some View {
        let geometry = WTHostSetupGeometry353.geometry(screen: "SetupMain", family: family)
        let canvas = geometry?.canvas ?? WTSize(width: 32, height: 32)
        let bounds = geometry?.glyphBounds ?? WTRect(x: 7, y: 7, width: 18, height: 18)
        let scale = max(0.55, min(1.75, min(bounds.width, bounds.height) / 18.0))
        let dx = (bounds.x + bounds.width / 2.0) - canvas.width / 2.0
        let dy = (bounds.y + bounds.height / 2.0) - canvas.height / 2.0
        WTSemanticGlyph(name: semanticName)
            .scaleEffect(scale)
            .offset(x: dx, y: dy)
            .frame(width: canvas.width, height: canvas.height)
            .frame(width: 32, height: 32)
    }
}
