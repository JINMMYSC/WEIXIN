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
            let state = runtime.panelLoadState(.textPolish)
            switch state {
            case .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(state: state, emptyTitle: "文字润色", emptySubtitle: "输入内容后进行润色。", retry: input.isEmpty ? nil : { run() })
            default:
                workingSurface
            }
        }
        .background(WTChrome353.surface)
    }

    private var workingSurface: some View {
        VStack(spacing: 0) {
            TextEditor(text: $input)
                .font(.system(size: 14))
                .padding(8)
                .background(WTChrome353.panelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(8)
            if runtime.panelLoadState(.textPolish) == .loading {
                ProgressView().tint(WTChrome353.accent).frame(maxWidth: .infinity, minHeight: 64)
            } else if !result.isEmpty {
                ScrollView {
                    Text(result).font(.system(size: 14)).frame(maxWidth: .infinity, alignment: .leading).padding(10)
                }
                .background(WTChrome353.accent.opacity(0.06))
            }
            HStack {
                Button(running ? "润色中…" : "润色") { run() }.disabled(running || input.isEmpty)
                Spacer()
                Button("上屏") { runtime.insertText(result) }.disabled(result.isEmpty)
            }
            .font(.system(size: 13, weight: .medium)).padding(.horizontal, 12).frame(height: 40)
        }
    }

    private func run() {
        guard !input.isEmpty else { return }
        running = true
        Task {
            let value = await runtime.runAI(.polish, input)
            await MainActor.run { result = value; running = false }
        }
    }
}
