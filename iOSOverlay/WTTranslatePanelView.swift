import SwiftUI

public struct WTTranslatePanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var source = "中文"
    @State private var target = "英文"
    @State private var input = ""
    @State private var result = ""
    @State private var running = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "翻译", onBack: { runtime.state.back() })
            let state = runtime.panelLoadState(.translate)
            switch state {
            case .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(
                    state: state,
                    emptyTitle: "暂无翻译结果",
                    emptySubtitle: "输入内容后开始翻译。",
                    retry: input.isEmpty ? nil : { run() }
                )
            default:
                editorSurface
            }
        }
        .background(WTChrome353.surface)
    }

    private var editorSurface: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Menu(source) { languageButtons(binding: $source) }.frame(maxWidth: .infinity)
                Button { swap(&source, &target); swap(&input, &result) } label: {
                    WTSemanticGlyph(name: "arrow.left.arrow.right").font(.system(size: 13)).frame(width: 42, height: 34)
                }
                .buttonStyle(.plain)
                Menu(target) { languageButtons(binding: $target) }.frame(maxWidth: .infinity)
            }
            .font(.system(size: 13, weight: .medium))
            .frame(height: 34)
            .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }

            HStack(spacing: 6) {
                editor($input, placeholder: "输入要翻译的内容")
                if runtime.panelLoadState(.translate) == .loading {
                    ProgressView().tint(WTChrome353.accent).frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(WTChrome353.panelBackground).clipShape(RoundedRectangle(cornerRadius: 9))
                } else {
                    editor($result, placeholder: "翻译结果")
                }
            }
            .padding(7)

            HStack {
                Button(running ? "翻译中…" : "翻译") { run() }.disabled(running || input.isEmpty)
                Spacer()
                Button("上屏") { runtime.insertText(result) }.disabled(result.isEmpty)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .frame(height: 38)
        }
    }

    private func editor(_ binding: Binding<String>, placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            if binding.wrappedValue.isEmpty { Text(placeholder).font(.system(size: 12)).foregroundStyle(.tertiary).padding(10) }
            TextEditor(text: binding).font(.system(size: 14)).padding(5)
        }
        .background(WTChrome353.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    @ViewBuilder private func languageButtons(binding: Binding<String>) -> some View {
        ForEach(["中文","英文","日文","韩文"], id: \.self) { value in Button(value) { binding.wrappedValue = value } }
    }

    private func run() {
        guard !input.isEmpty else { return }
        running = true
        Task {
            let value = await runtime.translate(input, source, target)
            await MainActor.run {
                result = value
                running = false
            }
        }
    }
}
