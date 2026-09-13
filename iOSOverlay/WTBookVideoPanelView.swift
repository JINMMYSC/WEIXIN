import SwiftUI

/// Clean-room reconstruction of the rich-content panel family exposed by WeType 3.5.3
/// (Finder/video account, official account, mini program, music, movie, book, etc.).
/// Content comes from an app-owned provider; no Tencent service or proprietary asset is embedded.
public struct WTBookVideoPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var query = ""
    @State private var selectedKinds: Set<WTBookVideoKind> = [.finder]
    @State private var isLoading = false
    @State private var message: String?

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            header
            categoryStrip
            Divider()
            content
        }
        .background(WTChrome353.surface)
        .task { await reload() }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: { runtime.state.back() }) {
                WTBasicGlyphView(.chevronLeft, size: 17, lineWidth: 1.9)
            }
            HStack(spacing: 6) {
                WTBasicGlyphView(.search, tint: WTChrome353.secondary, size: 15)
                TextField("搜索微信内容", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await reload() } }
                if !query.isEmpty {
                    Button(action: { query = "" }) {
                        WTBasicGlyphView(.close, tint: WTChrome353.secondary.opacity(0.72), size: 14)
                    }
                }
            }
            .padding(.horizontal, 10).frame(height: 36)
            .background(WTChrome353.panelBackground, in: RoundedRectangle(cornerRadius: 9))
            Button("搜索") { Task { await reload() } }
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
    }

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WTBookVideoKind.allCases, id: \.self) { kind in
                    let active = selectedKinds.contains(kind)
                    Button(kind.title) {
                        selectedKinds = [kind]
                        Task { await reload() }
                    }
                    .font(.system(size: 13, weight: active ? .semibold : .regular))
                    .foregroundStyle(active ? Color.primary : Color.secondary)
                    .padding(.horizontal, 12).frame(height: 30)
                    .background(active ? Color(uiColor: .tertiarySystemFill) : Color.clear,
                                in: Capsule())
                }
            }.padding(.horizontal, 12).padding(.vertical, 6)
        }
    }

    @ViewBuilder private var content: some View {
        if isLoading {
            VStack(spacing: 10) { ProgressView(); Text("正在搜索").font(.caption).foregroundStyle(.secondary) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message, runtime.bookVideoCards.isEmpty {
            VStack(spacing: 8) {
                WTSemanticGlyph(name: "rectangle.stack.badge.magnifyingglass").font(.system(size: 28)).foregroundStyle(.secondary)
                Text(message).font(.system(size: 13)).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(runtime.bookVideoCards) { card in cardView(card) }
                }.padding(10)
            }
        }
    }

    private func cardView(_ card: WTBookVideoCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9).fill(WTChrome353.panelBackground)
                    WTSemanticGlyph(name: icon(for: card.kind)).font(.system(size: 21))
                }.frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 3) {
                    HStack { Text(card.title).font(.system(size: 15, weight: .semibold)); if let badge = card.badge { Text(badge).font(.caption2).foregroundStyle(.secondary) } }
                    if let subtitle = card.subtitle { Text(subtitle).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1) }
                }
                Spacer()
                Button("发送") { Task { await runtime.performBookVideo(.send, card: card) } }
                    .buttonStyle(.borderedProminent).controlSize(.small)
            }
            if let detail = card.detail { Text(detail).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2) }
            if let rating = card.rating {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { i in WTSemanticGlyph(name: Double(i) + 0.5 < rating ? "star.fill" : "star").font(.caption2) }
                    Text(String(format: "%.1f", rating)).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(WTChrome353.panelBackground, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture { Task { await runtime.performBookVideo(.open, card: card) } }
    }

    private func icon(for kind: WTBookVideoKind) -> String {
        switch kind {
        case .finder: return "play.rectangle"
        case .publicAccount: return "person.crop.square"
        case .miniProgram: return "shippingbox"
        case .music: return "music.note"
        case .movie: return "film"
        case .book: return "book.closed"
        case .baike: return "text.book.closed"
        case .stock: return "chart.line.uptrend.xyaxis"
        case .hotWord: return "flame"
        case .location: return "location"
        case .greeting: return "hand.wave"
        case .wordTranslation: return "character.book.closed"
        }
    }

    private func reload() async {
        isLoading = true; message = nil
        runtime.bookVideoCards = await runtime.searchBookVideo(query, selectedKinds)
        if runtime.bookVideoCards.isEmpty { message = query.isEmpty ? "暂无推荐内容" : "没有找到相关内容" }
        isLoading = false
    }
}
