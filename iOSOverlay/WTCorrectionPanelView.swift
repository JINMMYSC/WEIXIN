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
            if suggestions.isEmpty {
                Text("输入文字后检查错别字和拼写问题")
                    .font(.system(size: 12)).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(Array(suggestions.enumerated()), id: \.offset) { _, text in
                            Button(text) { runtime.insertText(text) }
                                .font(.system(size: 13)).padding(.horizontal, 12).frame(height: 30)
                                .background(WTChrome353.accent.opacity(0.10)).foregroundStyle(WTChrome353.accent).clipShape(Capsule())
                        }
                    }.padding(.horizontal, 8)
                }
            }
            Spacer(minLength: 0)
            HStack { Button(running ? "检查中…" : "开始检查") { run() }.disabled(running || input.isEmpty); Spacer() }
                .font(.system(size: 13, weight: .medium)).padding(.horizontal, 12).frame(height: 40)
        }
    }

    private func run() {
        running = true
        Task { let values = await runtime.correctionSuggestions(input); await MainActor.run { suggestions = values; running = false } }
    }
}
