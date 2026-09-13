import SwiftUI

public struct WTInputModeSwitcherView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private let modes: [(WTInputMode, String, String)] = [
        (.chinesePinyin26, "拼音 26 键", "keyboard"),
        (.chinesePinyin9, "拼音 9 键", "square.grid.3x3"),
        (.doublePinyin, "双拼", "rectangle.split.3x1"),
        (.wubi, "五笔", "square.grid.3x3.topleft.filled"),
        (.stroke, "笔画", "line.diagonal"),
        (.handwriting, "手写", "scribble"),
        (.english26, "英文", "character.cursor.ibeam")
    ]

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "切换键盘", onBack: { runtime.state.back() })
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(modes, id: \.0) { mode, title, icon in
                    Button {
                        runtime.chooseInputMode(mode)
                    } label: {
                        HStack(spacing: 10) {
                            WTSemanticGlyph(name: icon)
                                .font(.system(size: 20))
                                .frame(width: 28)
                            Text(title)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            if runtime.state.inputMode == mode {
                                WTSemanticGlyph(name: "checkmark.circle.fill")
                                    .foregroundStyle(WTChrome353.accent)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 50)
                        .background(WTChrome353.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            Spacer(minLength: 0)
        }
        .background(WTChrome353.panelBackground)
    }
}
