import SwiftUI

public struct WTWordSplittingView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var source = ""
    @State private var loading = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "拆词", onBack: { runtime.state.back() }, trailingSystemName: "magnifyingglass") { Task { await run() } }
            TextEditor(text: $source)
                .font(.system(size: 14))
                .padding(6)
                .frame(height: 64)
                .background(WTChrome353.panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .padding(8)

            content

            HStack {
                Button(loading ? "处理中…" : "拆词") { Task { await run() } }.disabled(loading || source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
                Button("清空") { source = ""; runtime.wordSplitOptions = []; runtime.setPanelLoadState(.idle, for: .wordSplitting) }
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .frame(height: 40)
        }
        .background(WTChrome353.surface)
    }

    @ViewBuilder private var content: some View {
        let state = runtime.panelLoadState(.wordSplitting)
        switch state {
        case .loading:
            ProgressView().tint(WTChrome353.accent).frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed, .offline, .permissionDenied, .fallback:
            WTPhase4PanelStateView(state: state, emptyTitle: "暂无拆词结果", emptySubtitle: "输入内容后开始拆词。", retry: { Task { await run() } })
        default:
            if runtime.wordSplitOptions.isEmpty {
                WTPhase4PanelStateView(state: source.isEmpty ? .idle : .empty, emptyTitle: "暂无拆词结果", emptySubtitle: "支持按标点、空格与 Unicode 字符边界生成本地可用拆分。")
            } else {
                ScrollView {
                    LazyVStack(spacing: 7) {
                        ForEach(runtime.wordSplitOptions) { option in
                            Button {
                                runtime.commitDirectText(option.parts.joined(separator: " "))
                            } label: {
                                HStack(spacing: 6) {
                                    ForEach(Array(option.parts.enumerated()), id: \.offset) { _, part in
                                        Text(part).font(.system(size: 13, weight: .medium)).padding(.horizontal, 7).padding(.vertical, 4)
                                            .background(WTChrome353.accent.opacity(0.08)).clipShape(Capsule())
                                    }
                                    Spacer(minLength: 0)
                                    WTSemanticGlyph(name: "arrow.up.left").font(.system(size: 11)).foregroundStyle(WTChrome353.secondary)
                                }
                                .padding(.horizontal, 10).frame(minHeight: 38).background(WTChrome353.surface)
                            }.buttonStyle(.plain)
                        }
                    }.padding(8)
                }
            }
        }
    }

    @MainActor private func run() async {
        let value = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        loading = true
        runtime.wordSplitOptions = await runtime.splitWords(value)
        loading = false
    }
}
