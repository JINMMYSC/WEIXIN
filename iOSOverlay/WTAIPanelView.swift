import SwiftUI

public struct WTAIPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var selected: WTAITool = .askAI
    @State private var input = ""
    @State private var result = ""
    @State private var running = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "AI", onBack: { runtime.state.back() }, trailingSystemName: "square.and.arrow.up") {}
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    toolButton(.askAI, "问 AI", "sparkles")
                    toolButton(.rewrite, "改写", "arrow.triangle.2.circlepath")
                    toolButton(.polish, "润色", "wand.and.stars")
                    toolButton(.copywriting, "写作", "square.and.pencil")
                    toolButton(.translate, "翻译", "character.book.closed")
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 42)

            TextEditor(text: $input)
                .font(.system(size: 14))
                .padding(6)
                .background(WTChrome353.panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .padding(.horizontal, 8)

            if !result.isEmpty {
                ScrollView {
                    Text(result).font(.system(size: 14)).frame(maxWidth: .infinity, alignment: .leading).padding(9)
                }
                .frame(maxHeight: 72)
                .background(WTChrome353.accent.opacity(0.06))
            }

            HStack {
                Button(running ? "处理中…" : "发送") { run() }.disabled(running || input.isEmpty)
                Spacer()
                Button("上屏") { runtime.insertText(result) }.disabled(result.isEmpty)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .frame(height: 40)
        }
    }

    private func toolButton(_ tool: WTAITool, _ title: String, _ symbol: String) -> some View {
        Button { selected = tool } label: {
            HStack(spacing: 4) { WTSemanticGlyph(name: symbol); Text(title) }
                .font(.system(size: 12, weight: selected == tool ? .semibold : .regular))
                .foregroundStyle(selected == tool ? WTChrome353.accent : Color.primary)
                .padding(.horizontal, 10).frame(height: 30)
                .background(selected == tool ? WTChrome353.accent.opacity(0.10) : WTChrome353.panelBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func run() {
        running = true
        Task { let value = await runtime.runAI(selected, input); await MainActor.run { result = value; running = false } }
    }
}
