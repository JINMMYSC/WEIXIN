import SwiftUI

public struct WTWordSplittingView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var text = ""
    @State private var loading = false

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "拆词", onBack: { runtime.state.back() })
            HStack(spacing: 8) {
                TextField("输入要拆分的词", text: $text).font(.system(size: 13)).textFieldStyle(.plain)
                Button("拆分") { Task { await split() } }.buttonStyle(WTGreenPillButtonStyle()).disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding(10).background(WTChrome353.surface)

            if loading { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity) }
            else if runtime.wordSplitOptions.isEmpty {
                WTEmptyPanelState(systemName: "rectangle.split.3x1", title: "拆词", subtitle: "输入词语后显示可选拆分结果，点击任意片段即可上屏。")
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(runtime.wordSplitOptions) { option in
                            HStack(spacing: 6) {
                                ForEach(option.parts, id: \.self) { part in
                                    Button { runtime.commitDirectText(part) } label: {
                                        Text(part).font(.system(size: 14, weight: .medium)).padding(.horizontal, 12).frame(height: 34)
                                            .background(WTChrome353.panelBackground).clipShape(RoundedRectangle(cornerRadius: 8))
                                    }.buttonStyle(.plain)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(10).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.padding(8)
                }
            }
        }.background(WTChrome353.panelBackground)
    }

    @MainActor private func split() async {
        loading = true
        runtime.wordSplitOptions = await runtime.splitWords(text)
        loading = false
    }
}
