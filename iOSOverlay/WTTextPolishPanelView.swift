import SwiftUI

public struct WTTextPolishPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var input = ""
    @State private var result = ""
    @State private var running = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "文字润色", onBack: { runtime.state.back() })
            TextEditor(text: $input)
                .font(.system(size: 14))
                .padding(8)
                .background(WTChrome353.panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(8)
            if !result.isEmpty {
                ScrollView {
                    Text(result)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
                .background(WTChrome353.accent.opacity(0.06))
            }
            HStack {
                Button(running ? "润色中…" : "润色") { run() }.disabled(running || input.isEmpty)
                Spacer()
                Button("上屏") { runtime.insertText(result) }.disabled(result.isEmpty)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .frame(height: 40)
        }
    }

    private func run() {
        running = true
        Task {
            let value = await runtime.runAI(.polish, input)
            await MainActor.run { result = value; running = false }
        }
    }
}
