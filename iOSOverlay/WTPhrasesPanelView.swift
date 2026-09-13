import SwiftUI

public struct WTPhrasesPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("返回") { runtime.state.back() }
                Spacer()
                Text("常用语").font(.headline)
                Spacer()
                Color.clear.frame(width: 36)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)

            if runtime.phrases.isEmpty {
                Spacer()
                Text("暂无常用语")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(runtime.phrases) { item in
                            Button {
                                runtime.insertPhrase(item)
                            } label: {
                                HStack {
                                    Text(item.text)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    WTSemanticGlyph(name: "arrow.up.left")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                .background(WTChrome353.surface)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
