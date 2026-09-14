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
        runtime.setPanelLoadState(.loading, for: .wordSplitting)
        var options = await runtime.splitWords(value)
        if options.isEmpty { options = localFallback(value) }
        runtime.wordSplitOptions = options
        runtime.setPanelLoadState(options.isEmpty ? .empty : .ready, for: .wordSplitting)
        loading = false
    }

    private func localFallback(_ value: String) -> [WTWordSplitOption] {
        var unique: [[String]] = []
        func append(_ parts: [String]) {
            let cleaned = parts.filter { !$0.isEmpty }
            guard cleaned.count > 1, !unique.contains(cleaned) else { return }
            unique.append(cleaned)
        }

        let whitespace = value.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        append(whitespace)

        let punctuation = CharacterSet.punctuationCharacters.union(.symbols)
        var tokens: [String] = []
        var current = ""
        for scalar in value.unicodeScalars {
            if punctuation.contains(scalar) || CharacterSet.whitespacesAndNewlines.contains(scalar) {
                if !current.isEmpty { tokens.append(current); current = "" }
            } else {
                current.unicodeScalars.append(scalar)
            }
        }
        if !current.isEmpty { tokens.append(current) }
        append(tokens)

        let characters = value.map(String.init).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if characters.count > 1 && characters.count <= 16 {
            append(characters)
            if characters.count >= 4 {
                append(stride(from: 0, to: characters.count, by: 2).map { index in
                    characters[index..<min(index + 2, characters.count)].joined()
                })
            }
        }
        return unique.prefix(4).map(WTWordSplitOption.init(parts:))
    }
}
