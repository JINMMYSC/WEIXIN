import SwiftUI

public struct WTPhrasesPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "常用语", onBack: { runtime.state.back() })
            if runtime.phrases.isEmpty {
                WTPhase4PanelStateView(
                    state: runtime.panelLoadState(.phrases),
                    emptyTitle: "暂无常用语",
                    emptySubtitle: "可在主 App 的常用语设置中添加，点击后直接上屏。"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(runtime.phrases) { item in
                            Button { runtime.insertPhrase(item) } label: {
                                HStack(spacing: 10) {
                                    Text(item.text)
                                        .font(.system(size: 14))
                                        .foregroundStyle(WTChrome353.primaryText)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    WTSemanticGlyph(name: "arrow.up.left")
                                        .font(.system(size: 11))
                                        .foregroundStyle(WTChrome353.secondary)
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                .background(WTChrome353.surface)
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .background(WTChrome353.surface)
    }
}
