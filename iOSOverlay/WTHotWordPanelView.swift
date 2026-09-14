import SwiftUI

public struct WTHotWordPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var filter = ""
    @State private var showAdd = false
    @State private var draftWord = ""

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private var visible: [WTHotWordItem] {
        let source = runtime.hotWords.sorted { $0.rank < $1.rank }
        guard !filter.isEmpty else { return source }
        return source.filter { $0.word.localizedCaseInsensitiveContains(filter) || ($0.tag?.localizedCaseInsensitiveContains(filter) ?? false) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "热词", onBack: { runtime.state.back() }, trailingSystemName: "plus") { showAdd = true }
            HStack(spacing: 8) {
                WTBasicGlyphView(.search, tint: WTChrome353.secondary, size: 15)
                TextField("搜索热词", text: $filter).font(.system(size: 13))
                Button { Task { await reload() } } label: { WTSemanticGlyph(name: "arrow.clockwise") }.buttonStyle(.plain).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 11)
            .frame(height: 34)
            .background(WTChrome353.surface)

            content
        }
        .background(WTChrome353.surface)
        .task { if runtime.hotWords.isEmpty { await reload() } }
        .alert("添加热词", isPresented: $showAdd) {
            TextField("词语", text: $draftWord)
            Button("取消", role: .cancel) { draftWord = "" }
            Button("添加") { addDraft() }
        } message: { Text("添加后可在热词面板直接上屏。") }
    }

    @ViewBuilder private var content: some View {
        if !visible.isEmpty {
            list
        } else {
            let state = runtime.panelLoadState(.hotWords)
            switch state {
            case .loading, .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(
                    state: state,
                    emptyTitle: "暂无热词",
                    emptySubtitle: "可以手动添加本地热词。",
                    retry: { Task { await reload() } }
                )
            case .idle, .ready, .empty:
                WTPhase4PanelStateView(state: .empty, emptyTitle: filter.isEmpty ? "暂无热词" : "没有匹配的热词", emptySubtitle: "点击右上角 + 可添加本地热词。")
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(visible.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 0) {
                        Button { runtime.commitDirectText(item.word) } label: {
                            HStack(spacing: 10) {
                                Text("\(index + 1)").font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary).frame(width: 22)
                                Text(item.word).font(.system(size: 14)).foregroundStyle(.primary)
                                if let tag = item.tag, !tag.isEmpty {
                                    Text(tag).font(.system(size: 9, weight: .medium)).foregroundStyle(WTChrome353.accent)
                                        .padding(.horizontal, 5).padding(.vertical, 2)
                                        .background(WTChrome353.accent.opacity(0.10)).clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(.leading, 10).frame(height: 38)
                        }.buttonStyle(.plain)
                        Menu {
                            Button("删除", role: .destructive) {
                                runtime.deleteHotWord(item.word)
                                runtime.hotWords.removeAll { $0.word == item.word }
                                runtime.setPanelLoadState(runtime.hotWords.isEmpty ? .empty : .ready, for: .hotWords)
                            }
                        } label: { WTSemanticGlyph(name: "ellipsis").frame(width: 36, height: 38) }.buttonStyle(.plain)
                    }
                    if index != visible.count - 1 { Divider().padding(.leading, 42) }
                }
            }
        }
    }

    private func addDraft() {
        let word = draftWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }
        runtime.addHotWord(word)
        if !runtime.hotWords.contains(where: { $0.word == word }) {
            runtime.hotWords.insert(.init(word: word, rank: 0, tag: "自定义"), at: 0)
        }
        runtime.setPanelLoadState(.ready, for: .hotWords)
        draftWord = ""
    }

    @MainActor private func reload() async {
        runtime.hotWords = await runtime.loadHotWords()
    }
}
