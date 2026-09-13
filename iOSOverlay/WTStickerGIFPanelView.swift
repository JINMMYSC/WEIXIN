import SwiftUI

public struct WTStickerGIFPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var kind: WTMediaContentKind = .sticker
    @State private var query = ""
    @State private var loading = false
    @State private var preview: WTMediaCard?

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WTPanelHeader(title: panelTitle, onBack: { runtime.state.back() }, trailingSystemName: "magnifyingglass") {
                    Task { await reload() }
                }
                HStack(spacing: 0) {
                    segment(.sticker, title: "表情包")
                    segment(.customSticker, title: "自定义")
                    segment(.gif, title: "GIF")
                }
                .frame(height: 34).background(WTChrome353.surface)

                HStack(spacing: 8) {
                    WTBasicGlyphView(.search, tint: WTChrome353.secondary, size: 15)
                    TextField(searchPlaceholder, text: $query)
                        .font(.system(size: 13)).onSubmit { Task { await reload() } }
                    if !query.isEmpty { Button { query = "" } label: { WTBasicGlyphView(.close, tint: WTChrome353.secondary, size: 14) }.buttonStyle(.plain) }
                }
                .padding(.horizontal, 10).frame(height: 34)
                .background(WTChrome353.panelBackground)

                if loading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if runtime.mediaCards.isEmpty {
                    WTEmptyPanelState(systemName: kind == .gif ? "photo.stack" : "face.smiling.inverse", title: kind == .gif ? "暂无 GIF" : "暂无表情包", subtitle: "界面和交互位已经补齐；在线内容由独立 provider 提供。")
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: kind == .gif ? 3 : 4), spacing: 8) {
                            ForEach(runtime.mediaCards) { card in
                                Button { preview = card } label: {
                                    VStack(spacing: 5) {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color(uiColor: .tertiarySystemFill))
                                            .aspectRatio(kind == .gif ? 1.3 : 1, contentMode: .fit)
                                            .overlay { WTSemanticGlyph(name: mediaSymbol).font(.system(size: 22)).foregroundStyle(.secondary) }
                                        Text(card.title).font(.system(size: 10)).lineLimit(1).foregroundStyle(.primary)
                                    }
                                }.buttonStyle(.plain)
                            }
                        }.padding(8)
                    }
                }
            }
            .background(WTChrome353.surface)

            if let preview {
                Color.black.opacity(0.22).ignoresSafeArea().onTapGesture { self.preview = nil }
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 16).fill(WTChrome353.panelBackground)
                        .frame(width: 150, height: 130)
                        .overlay { WTSemanticGlyph(name: preview.kind == .gif ? "photo.stack" : "face.smiling").font(.system(size: 42)).foregroundStyle(.secondary) }
                    Text(preview.title).font(.system(size: 14, weight: .semibold))
                    HStack(spacing: 8) {
                        Button("取消") { self.preview = nil }.buttonStyle(.bordered)
                        Button("发送") { runtime.sendMedia(preview); self.preview = nil }.buttonStyle(WTGreenPillButtonStyle())
                    }
                }
                .padding(16).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)).shadow(radius: 16)
            }
        }
        .task { await reload() }
    }

    private var panelTitle: String {
        switch kind { case .sticker: return "表情包"; case .customSticker: return "自定义表情"; case .gif: return "GIF" }
    }
    private var searchPlaceholder: String {
        switch kind { case .sticker: return "搜索表情包"; case .customSticker: return "搜索自定义表情"; case .gif: return "搜索 GIF" }
    }
    private var mediaSymbol: String { kind == .gif ? "photo.on.rectangle.angled" : (kind == .customSticker ? "plus.square.dashed" : "face.smiling") }

    private func segment(_ value: WTMediaContentKind, title: String) -> some View {
        Button { kind = value; Task { await reload() } } label: {
            Text(title).font(.system(size: 13, weight: kind == value ? .semibold : .regular))
                .foregroundStyle(kind == value ? WTChrome353.accent : Color.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) { if kind == value { Capsule().fill(WTChrome353.accent).frame(width: 28, height: 2) } }
        }.buttonStyle(.plain)
    }

    @MainActor private func reload() async {
        loading = true
        runtime.mediaCards = await runtime.loadMedia(kind, query)
        loading = false
    }
}
