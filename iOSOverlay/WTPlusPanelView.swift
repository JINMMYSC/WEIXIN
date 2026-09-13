import SwiftUI

public struct WTPlusPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var enabled = true
    @State private var section = 0
    @State private var showStatement = false
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private let cards: [(String,String,WTKeyboardTool,Int)] = [
        ("智能纠错","checkmark.seal",.correction,1), ("Emoji 增强","face.smiling",.emoji,1),
        ("隔空传送","paperplane",.quickSend,2), ("文字润色","wand.and.stars",.textPolish,1),
        ("热词","flame",.hotWords,2), ("表情包","face.smiling.inverse",.stickers,2)
    ]

    private var visibleCards: [(String,String,WTKeyboardTool,Int)] { section == 0 ? cards : cards.filter { $0.3 == section } }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WTPanelHeader(title: "微信输入法+", onBack: { runtime.state.back() }, trailingSystemName: "info.circle") { showStatement = true }
                ScrollView {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            ZStack { RoundedRectangle(cornerRadius: 12).fill(WTChrome353.accent); Text("+").font(.system(size: 22, weight: .bold)).foregroundStyle(.white) }.frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 3) { Text("微信输入法+").font(.system(size: 16, weight: .semibold)); Text("扩展输入能力").font(.system(size: 11)).foregroundStyle(.secondary) }
                            Spacer(); Toggle("", isOn: $enabled).labelsHidden().tint(WTChrome353.accent)
                        }.padding(12).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 12))

                        Picker("", selection: $section) { Text("全部").tag(0); Text("智能").tag(1); Text("效率").tag(2) }
                            .pickerStyle(.segmented)

                        ForEach(visibleCards, id: \.0) { card in
                            Button { if enabled { runtime.presentTool(card.2) } } label: {
                                HStack(spacing: 10) {
                                    WTSemanticGlyph(name: card.1).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) { Text(card.0).font(.system(size: 14)); Text(enabled ? "已开启" : "总开关已关闭").font(.system(size: 10)).foregroundStyle(.secondary) }
                                    Spacer(); WTSemanticGlyph(name: "chevron.right").font(.system(size: 10)).foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 12).frame(height: 48).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                            }.buttonStyle(.plain).disabled(!enabled)
                        }
                    }.padding(10)
                }
            }.background(WTChrome353.panelBackground)

            if showStatement {
                Color.black.opacity(0.2).ignoresSafeArea().onTapGesture { showStatement = false }
                VStack(alignment: .leading, spacing: 10) {
                    Text("微信输入法+说明").font(.system(size: 15, weight: .semibold))
                    Text("这里对应原版 Plus 功能选择、能力项和说明界面。清洁室版本不会连接腾讯私有服务，网络能力由你自己的 provider 提供。")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                    Button("知道了") { showStatement = false }.buttonStyle(WTGreenPillButtonStyle()).frame(maxWidth: .infinity, alignment: .trailing)
                }.padding(16).frame(maxWidth: 300).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(radius: 16)
            }
        }
    }
}
