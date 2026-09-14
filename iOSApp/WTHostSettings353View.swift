import SwiftUI

/// Clean-room renderer for the user-observable SetupMain structure shipped in WeChat Input 3.5.3.
/// Entry order and icon canvas geometry come from the extracted 3.5.3 bundle metadata.
public struct WTHostSettings353View: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List {
                ForEach(WTHostMainEntry353ViewModel.all) { item in
                    NavigationLink(destination: WTSettingsDetailView(destination: item.destination)) {
                        HStack(spacing: 13) {
                            WTHostSetupEntryGlyph353(assetFamily: item.assetFamily, semanticName: item.semanticName)
                            Text(item.title)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.primary)
                            Spacer(minLength: 8)
                        }
                        .frame(minHeight: 50)
                        .contentShape(Rectangle())
                    }
                    .accessibilityIdentifier("host.setup.\(item.assetFamily)")
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("微信输入法")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text("3.5.3")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("微信输入法")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .tint(WTHost353Palette.accent)
    }
}

private struct WTHostMainEntry353ViewModel: Identifiable {
    let assetFamily: String
    let title: String
    let destination: WTSettingsDestination
    let semanticName: String
    var id: String { assetFamily }

    static let all: [Self] = [
        .init(assetFamily: "icon_app_setup_keyboard", title: "键盘管理", destination: .keyboardManagement, semanticName: "keyboard"),
        .init(assetFamily: "icon_layout", title: "显示设置", destination: .displaySetting, semanticName: "paintbrush"),
        .init(assetFamily: "icon_app_setup_customize_toolbar", title: "工具栏设置", destination: .toolbarCustomization, semanticName: "rectangle.3.group"),
        .init(assetFamily: "icon_app_setup_vibration", title: "按键效果", destination: .keystrokeEffect, semanticName: "speaker.wave.2"),
        .init(assetFamily: "icon_clipboard", title: "剪贴板", destination: .clipboard, semanticName: "doc.on.clipboard"),
        .init(assetFamily: "icon_app_setup_voice", title: "语音输入", destination: .voice, semanticName: "waveform"),
        .init(assetFamily: "icon_app_setup_pluslogo", title: "微信输入法+", destination: .plus, semanticName: "plus.circle"),
        .init(assetFamily: "icon_app_setup_air", title: "隔空传送", destination: .transfer, semanticName: "paperplane"),
        .init(assetFamily: "icon_app_setup_multiple_devices", title: "多设备", destination: .multiDevice, semanticName: "laptopcomputer.and.iphone"),
        .init(assetFamily: "icon_app_setup_computer", title: "电脑端", destination: .desktop, semanticName: "desktopcomputer"),
        .init(assetFamily: "icon_setup_migration", title: "迁移助手", destination: .migrationAssistant, semanticName: "arrow.triangle.2.circlepath"),
        .init(assetFamily: "icon_app_setup_privacy", title: "隐私", destination: .privacy, semanticName: "checkmark.shield"),
        .init(assetFamily: "icon_app_setup_help", title: "帮助与反馈", destination: .help, semanticName: "questionmark.circle"),
        .init(assetFamily: "icon_app_setup_about", title: "关于微信输入法", destination: .about, semanticName: "info.circle")
    ]
}

private struct WTHostSetupEntryGlyph353: View {
    let assetFamily: String
    let semanticName: String

    var body: some View {
        let geometry = WTHostSetupGeometry353.geometry(screen: "SetupMain", family: assetFamily)
        let canvas = geometry?.canvas ?? WTSize(width: 32, height: 32)
        let bounds = geometry?.glyphBounds ?? WTRect(x: 7, y: 7, width: 18, height: 18)
        let scale = max(0.55, min(1.75, min(bounds.width, bounds.height) / 18.0))
        let dx = (bounds.x + bounds.width / 2.0) - canvas.width / 2.0
        let dy = (bounds.y + bounds.height / 2.0) - canvas.height / 2.0

        WTSemanticGlyph(name: semanticName)
            .foregroundStyle(WTHost353Palette.icon)
            .scaleEffect(scale)
            .offset(x: dx, y: dy)
            .frame(width: canvas.width, height: canvas.height)
            .frame(width: 32, height: 32)
    }
}

private enum WTHost353Palette {
    static let accent = Color(red: 35 / 255, green: 200 / 255, blue: 145 / 255)
    static let icon = Color.primary
}
