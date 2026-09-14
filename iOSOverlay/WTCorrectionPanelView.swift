import SwiftUI

public struct WTCorrectionPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var input = ""
    @State private var suggestions: [String] = []
    @State private var running = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "拼写纠错", onBack: { runtime.state.back() })
            TextEditor(text: $input)
                .font(.system(size: 14)).padding(6).frame(height: 72)
                .background(WTChrome353.panelBackground).clipShape(RoundedRectangle(cornerRadius: 9)).padding(8)

            suggestionSurface

            Spacer(minLength: 0)
            HStack {
                Button(running ? "检查中…" : "开始检查") { run() }.disabled(running || input.isEmpty)
                Spacer()
            }
            .font(.system(size: 13, weight: .medium)).padding(.horizontal, 12).frame(height: 40)
        }
        .background(WTChrome353.surface)
    }

    @ViewBuilder private var suggestionSurface: some View {
        let state = runtime.panelLoadState(.correction)
        switch state {
        case .loading:
            ProgressView().tint(WTChrome353.accent).frame(maxWidth: .infinity, minHeight: 70)
        case .permissionDenied, .offline, .failed, .fallback:
            WTPhase4PanelStateView(state: state, emptyTitle: "暂无纠错建议", emptySubtitle: "输入文字后开始检查。", retry: input.isEmpty ? nil : { run() })
                .frame(minHeight: 86)
        case .ready where !suggestions.isEmpty:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(Array(suggestions.enumerated()), id: \.offset) { _, text in
                        Button(text) { runtime.insertText(text) }
                            .font(.system(size: 13)).padding(.horizontal, 12).frame(height: 30)
                            .background(WTChrome353.accent.opacity(0.10)).foregroundStyle(WTChrome353.accent).clipShape(Capsule())
                    }
                }.padding(.horizontal, 8)
            }
        default:
            Text(input.isEmpty ? "输入文字后检查错别字和拼写问题" : "没有发现需要修改的内容")
                .font(.system(size: 12)).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10)
        }
    }

    private func run() {
        guard !input.isEmpty else { return }
        running = true
        Task {
            let values = await runtime.correctionSuggestions(input)
            await MainActor.run {
                suggestions = values
                running = false
            }
        }
    }
}
