import SwiftUI
import UIKit

/// Host home rebuilt from same-device WeType 3.5.3 reference captures.
/// The geometry below is intentionally expressed in points rather than generic Form/List metrics:
/// 20pt page inset, 14pt inter-card gap, 134pt setup cards, 94pt "More" cards.
public struct WTHostHomeParityView: View {
    @State private var scrollOffset: CGFloat = 0

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                WTHost353Palette.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: WTHostScrollOffsetKey.self,
                                value: proxy.frame(in: .named("WT353HostScroll")).minY
                            )
                        }
                        .frame(height: 0)

                        largeHeader
                            .padding(.top, 24)
                            .padding(.horizontal, 20)

                        heroCard
                            .padding(.top, 26)
                            .padding(.horizontal, 20)

                        sectionTitle("设置")
                            .padding(.top, 36)

                        settingsGrid
                            .padding(.top, 14)

                        sectionTitle("更多")
                            .padding(.top, 42)

                        moreGrid
                            .padding(.top, 14)
                            .padding(.bottom, 34)
                    }
                }
                .coordinateSpace(name: "WT353HostScroll")
                .onPreferenceChange(WTHostScrollOffsetKey.self) { scrollOffset = $0 }

                if scrollOffset < -104 {
                    compactHeader
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(WTHost353Palette.accent)
    }

    private var largeHeader: some View {
        HStack(spacing: 14) {
            WTWeType353Logo(size: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text("微信输入法")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(WTHost353Palette.primary)
                Text("简洁、好用、打字快")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WTHost353Palette.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(height: 70)
    }

    private var compactHeader: some View {
        HStack(spacing: 9) {
            WTWeType353Logo(size: 32)
            Text("微信输入法")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(WTHost353Palette.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 54)
        .background(WTHost353Palette.background)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
        }
    }

    private var heroCard: some View {
        VStack(spacing: 0) {
            WTHost353KeyboardHero()
                .frame(height: 274)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("多语言自由说大模型")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WTHost353Palette.primary)
                    Text("中文、英文、各个方言都可以混说")
                        .font(.system(size: 12.5))
                        .foregroundStyle(WTHost353Palette.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                HStack(spacing: 6) {
                    WTSemanticGlyph(name: "checkmark")
                        .scaleEffect(0.8)
                    Text("已开启")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(Color(white: 0.48))
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(Color(white: 0.16))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 16)
            .frame(height: 88)
            .background(Color(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0))
        }
        .frame(maxWidth: .infinity)
        .background(WTHost353Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 21, weight: .semibold))
            .foregroundStyle(WTHost353Palette.primary)
            .padding(.horizontal, 28)
    }

    private var settingsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            WTHost353SettingsCard(
                title: "布局和显示",
                subtitle: "表情键、数字键盘、候选字、高度调节等",
                glyph: "keyboard",
                destination: AnyView(WTSettingsDetailView(destination: .displaySetting))
            )
            WTHost353SettingsCard(
                title: "按键效果",
                subtitle: "声音、触感、按键气泡",
                glyph: "waveform",
                destination: AnyView(WTSettingsDetailView(destination: .keystrokeEffect))
            )
            WTHost353SettingsCard(
                title: "定制工具栏",
                subtitle: "收起键盘等常用功能固定在工具栏",
                glyph: "sparkles",
                destination: AnyView(WTSettingsDetailView(destination: .toolbarCustomization))
            )
            WTHost353SettingsCard(
                title: "辅助输入",
                subtitle: "智能加空格、模糊拼音、英文首字母大写等",
                glyph: "keyboard.fill",
                destination: AnyView(WTSettingsDetailView(destination: .auxiliaryInput))
            )
            WTHost353SettingsCard(
                title: "跨设备粘贴传送",
                subtitle: "隔空传文件、文字、图片跨设备粘贴，词库同步",
                glyph: "laptopcomputer.and.iphone",
                destination: AnyView(WTTransfer353View())
            )
            WTHost353SettingsCard(
                title: "剪贴板",
                subtitle: "快速使用复制内容",
                glyph: "doc.on.clipboard",
                destination: AnyView(WTSettingsDetailView(destination: .clipboard))
            )
            WTHost353SettingsCard(
                title: "键盘管理",
                subtitle: "全键盘、九宫格、手写五笔、双拼、笔画输入",
                glyph: "keyboard",
                destination: AnyView(WTSettingsDetailView(destination: .keyboardManagement))
            )
            WTHost353SettingsCard(
                title: "语音转文字",
                subtitle: "设置语音免跳转方式",
                glyph: "waveform",
                destination: AnyView(WTSettingsDetailView(destination: .voice))
            )
            WTHost353SettingsCard(
                title: "拼写 Plus",
                subtitle: "智能拼写、表情、颜文字等智能推荐",
                glyph: "plus.circle",
                destination: AnyView(WTSettingsDetailView(destination: .plus))
            )
            WTHost353SettingsCard(
                title: "单机模式",
                subtitle: "无需联网，纯本地使用",
                glyph: "paperplane",
                destination: AnyView(WTOffline353View())
            )
            WTHost353SettingsCard(
                title: "换机助手",
                subtitle: "同步个人词库、设置项、常用语等到新设备",
                glyph: "iphone",
                destination: AnyView(WTSettingsDetailView(destination: .migrationAssistant))
            )
        }
        .padding(.horizontal, 20)
    }

    private var moreGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            WTHost353SettingsCard(
                title: "隐私与权限", subtitle: nil, glyph: "lock.shield", compact: true,
                destination: AnyView(WTSettingsDetailView(destination: .privacy))
            )
            WTHost353SettingsCard(
                title: "电脑版", subtitle: nil, glyph: "desktopcomputer", compact: true,
                destination: AnyView(WTSettingsDetailView(destination: .desktop))
            )
            WTHost353SettingsCard(
                title: "关于", subtitle: nil, glyph: "info.circle", compact: true,
                destination: AnyView(WTSettingsDetailView(destination: .about))
            )
            WTHost353SettingsCard(
                title: "帮助与反馈", subtitle: nil, glyph: "questionmark.circle", compact: true,
                destination: AnyView(WTSettingsDetailView(destination: .help))
            )
        }
        .padding(.horizontal, 20)
    }
}

private enum WTHost353Palette {
    static let background = Color(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0)
    static let card = Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)
    static let primary = Color(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0)
    static let secondary = Color(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0)
    static let icon = Color(red: 188.0/255.0, green: 188.0/255.0, blue: 188.0/255.0)
    static let accent = Color(red: 35.0/255.0, green: 200.0/255.0, blue: 145.0/255.0)
}

private struct WTHostScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct WTWeType353Logo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            Circle()
                .fill(WTHost353Palette.accent)
                .padding(size * 0.09)
            Path { path in
                let w = size
                path.move(to: CGPoint(x: w * 0.27, y: w * 0.53))
                path.addLine(to: CGPoint(x: w * 0.67, y: w * 0.53))
                path.move(to: CGPoint(x: w * 0.47, y: w * 0.36))
                path.addLine(to: CGPoint(x: w * 0.38, y: w * 0.70))
                path.move(to: CGPoint(x: w * 0.57, y: w * 0.30))
                path.addLine(to: CGPoint(x: w * 0.50, y: w * 0.57))
                path.addQuadCurve(to: CGPoint(x: w * 0.73, y: w * 0.35), control: CGPoint(x: w * 0.74, y: w * 0.56))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: max(3, size * 0.09), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

private struct WTHost353SettingsCard: View {
    let title: String
    let subtitle: String?
    let glyph: String
    var compact: Bool = false
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 0) {
                WTSemanticGlyph(name: glyph)
                    .foregroundStyle(WTHost353Palette.icon)
                    .scaleEffect(1.65, anchor: .topLeading)
                    .frame(width: 32, height: 32, alignment: .topLeading)

                Spacer(minLength: compact ? 12 : 16)

                HStack(spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(WTHost353Palette.primary)
                        .lineLimit(1)
                    WTSemanticGlyph(name: "chevron.right")
                        .foregroundStyle(Color(white: 0.53))
                        .scaleEffect(0.72)
                        .frame(width: 9, height: 16)
                    Spacer(minLength: 0)
                }

                if let subtitle, !compact {
                    Text(subtitle)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundStyle(WTHost353Palette.secondary)
                        .lineSpacing(3)
                        .lineLimit(2)
                        .padding(.top, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, compact ? 15 : 17)
            .frame(height: compact ? 94 : 134, alignment: .topLeading)
            .frame(maxWidth: .infinity)
            .background(WTHost353Palette.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct WTHost353KeyboardHero: View {
    private let keyRows = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["⇧","Z","X","C","V","B","N","M","⌫"]
    ]

    var body: some View {
        ZStack {
            WTHost353Palette.card
            VStack(spacing: 0) {
                Spacer(minLength: 12)
                VStack(spacing: 5) {
                    HStack(spacing: 5) {
                        Text("◉")
                        Text("Morning，你食咗饭未?")
                            .font(.system(size: 8))
                            .lineLimit(1)
                        Spacer()
                        Text("☺")
                        Text("+")
                    }
                    .foregroundStyle(Color(white: 0.80))
                    .padding(.horizontal, 7)
                    .frame(height: 23)
                    .background(Color(white: 0.12))

                    HStack {
                        Spacer()
                        Text("语音转文字中 …")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(white: 0.48))
                        Spacer()
                        ZStack {
                            Capsule().fill(WTHost353Palette.accent.opacity(0.30))
                            Circle().fill(WTHost353Palette.accent).frame(width: 25, height: 25)
                            Text("●").font(.system(size: 9)).foregroundStyle(.white)
                        }
                        .frame(width: 64, height: 31)
                    }

                    ForEach(Array(keyRows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 4) {
                            ForEach(Array(row.enumerated()), id: \.offset) { _, key in
                                Text(key)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(Color(white: 0.90))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 24)
                                    .background(Color(white: key == "⇧" || key == "⌫" ? 0.29 : 0.42))
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                    }

                    HStack(spacing: 5) {
                        heroBottomKey("123", width: 45)
                        heroBottomKey("，", width: 24)
                        heroBottomKey("", width: 102)
                        heroBottomKey("中\n英", width: 31)
                        heroBottomKey("确定", width: 52)
                    }
                }
                .padding(7)
                .frame(width: 194)
                .background(Color(white: 0.19))
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                HStack(spacing: 6) {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color(white: index == 0 ? 0.72 : 0.28))
                            .frame(width: index == 0 ? 3.5 : 3, height: index == 0 ? 3.5 : 3)
                    }
                }
                .padding(.top, 14)
                Spacer(minLength: 10)
            }
        }
    }

    private func heroBottomKey(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .medium))
            .foregroundStyle(Color(white: 0.90))
            .multilineTextAlignment(.center)
            .frame(width: width, height: 25)
            .background(Color(white: 0.35))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

public struct WTTransfer353View: View {
    @Environment(\.presentationMode) private var presentationMode

    public init() {}

    public var body: some View {
        ZStack {
            WTHost353Palette.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    Text("隔空传送")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(WTHost353Palette.primary)
                    HStack {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            WTSemanticGlyph(name: "chevron.left")
                                .foregroundStyle(WTHost353Palette.primary)
                                .scaleEffect(1.15)
                                .frame(width: 28, height: 36)
                        }
                        Spacer()
                    }
                }
                .frame(height: 58)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    NavigationLink(destination: WTSettingsDetailView(destination: .multiDevice)) {
                        transferCard(
                            glyph: "laptopcomputer.and.iphone",
                            title: "关联其他设备",
                            subtitle: "关联后即可互传文件",
                            trailing: .greenButton("去关联")
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: WTHostPhase4RouteView(route: .quickSend, appGroupIdentifier: "group.7518554")) {
                        transferCard(
                            glyph: "iphone",
                            title: "传给其他人",
                            subtitle: "无需流量，快速收发照片、视频和文件",
                            trailing: .chevron
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 11)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func transferCard(glyph: String, title: String, subtitle: String, trailing: WTTransferTrailing) -> some View {
        HStack(spacing: 14) {
            WTSemanticGlyph(name: glyph)
                .foregroundStyle(WTHost353Palette.icon)
                .scaleEffect(2.0)
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WTHost353Palette.primary)
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundStyle(WTHost353Palette.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)

            switch trailing {
            case .greenButton(let text):
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background(WTHost353Palette.accent)
                    .clipShape(Capsule())
            case .chevron:
                WTSemanticGlyph(name: "chevron.right")
                    .foregroundStyle(Color(white: 0.38))
                    .scaleEffect(1.05)
                    .frame(width: 18, height: 28)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(WTHost353Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private enum WTTransferTrailing {
    case greenButton(String)
    case chevron
}

private struct WTOffline353View: View {
    @AppStorage("wt.offline.enabled", store: UserDefaults(suiteName: "group.7518554")) private var enabled = false

    var body: some View {
        Form {
            Section("单机模式") {
                Toggle("启用单机模式", isOn: $enabled)
            }
            Section {
                Text("开启后仅使用本地输入引擎与本地数据，不请求网络服务。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("单机模式")
        .navigationBarTitleDisplayMode(.inline)
    }
}
