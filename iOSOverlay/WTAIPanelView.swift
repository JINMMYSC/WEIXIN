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
            let state = runtime.panelLoadState(selectedPanel)
            switch state {
            case .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(
                    state: state,
                    emptyTitle: "开始使用 AI",
                    emptySubtitle: "选择工具并输入内容。",
                    retry: input.isEmpty ? nil : { run() }
                )
            default:
                workingSurface
            }
        }
        .background(WTChrome353.surface)
    }

    private var selectedPanel: WTPanel {
        switch selected {
        case .rewrite, .polish: return .textPolish
        default: return .askAI
        }
    }

    private var workingSurface: some View {
        VStack(spacing: 0) {
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
            .frame(height: 48)

            ZStack {
                TextEditor(text: $input)
                    .font(.system(size: 14))
                    .padding(6)
                    .background(WTChrome353.panelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                if input.isEmpty {
                    Text("输入你想处理的内容")
                        .font(.system(size: 12)).foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(14).allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 8)

            if runtime.panelLoadState(selectedPanel) == .loading {
                ProgressView().tint(WTChrome353.accent).frame(height: 72)
            } else if !result.isEmpty {
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
        Button {
            selected = tool
            result = ""
        } label: {
            VStack(spacing: 3) {
                WTSemanticGlyph(name: symbol).font(.system(size: 19))
                Text(title).font(.system(size: 10, weight: selected == tool ? .semibold : .regular))
            }
            .foregroundStyle(selected == tool ? WTChrome353.accent : Color.primary)
            .frame(width: 54, height: 42)
        }
        .buttonStyle(.plain)
    }

    private func run() {
        guard !input.isEmpty else { return }
        running = true
        Task {
            let value = await runtime.runAI(selected, input)
            await MainActor.run {
                result = value
                running = false
            }
        }
    }
}
