import SwiftUI

private struct WTEmojiCategory: Identifiable {
    let id: String
    let icon: String
    let values: [String]
}

public struct WTEmojiPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var selected: String

    private let categories: [WTEmojiCategory] = [
        .init(id: "faces", icon: "face.smiling", values: ["😀","🥹","☺️","😉","😗","😝","🤓","😌","😔","😁","😅","😊","😇","😙","😛","😎","😏","😞","😄","😂","😇","😍","😘","😜","🤪","🥳","😣","😕","😆","🤣","🙂","🥰","😋","🤨","🤩","😢","🙁"]),
        .init(id: "gestures", icon: "hand.raised", values: ["👍","👎","👌","✌️","🤞","🫰","🤟","🤘","🤙","👈","👉","👆","👇","☝️","👏","🙌","🫶","🤲","🤝","🙏","💪","🫵","✍️","💅","🤳"]),
        .init(id: "animals", icon: "pawprint", values: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🐔","🐧","🐦","🐤","🦄","🐝","🦋","🐌","🐞","🐢","🐍","🦎","🦖","🦕"]),
        .init(id: "food", icon: "birthday.cake", values: ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🥑","🍆","🥦","🥬","🥒","🌶️","🌽","🥕","🧄","🧅","🥔","🍠"]),
        .init(id: "travel", icon: "globe", values: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","🛵","🏍️","🚲","🛴","✈️","🚀","🚁","⛵️","🚤","🚢","🚆","🚇","🚉","🏠","🏢","🏬","🏥","🏫"]),
        .init(id: "symbols", icon: "textformat.abc", values: ["❤️","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❣️","💕","💞","💓","💗","💖","💘","💝","✨","⭐️","🌟","💫","🔥","💥","💯","✅","❌","⭕️","❗️","❓","⚠️","♻️"]),
        .init(id: "flags", icon: "flag", values: ["🏁","🚩","🎌","🏴","🏳️","🏳️‍🌈","🇨🇳","🇯🇵","🇺🇸","🇬🇧","🇫🇷","🇩🇪","🇰🇷","🇸🇬","🇦🇺","🇨🇦"]),
    ]

    public init(runtime: WTKeyboardRuntime) {
        self.runtime = runtime
        _selected = State(initialValue: runtime.recentEmoji.isEmpty ? "faces" : "recent")
    }

    private var values: [String] {
        if selected == "recent" { return runtime.recentEmoji }
        return categories.first(where: { $0.id == selected })?.values ?? []
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            emojiGrid
            categoryBar
            footer
        }
        .background(WTChrome353.panelBackground)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("表情符号与人物")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(WTChrome353.secondary)
            Spacer(minLength: 0)
            Button {
                // Keep the Phase 4 media route explicit; the original UI exposes custom stickers here.
                runtime.state.present(.stickers)
            } label: {
                HStack(spacing: 4) {
                    WTSemanticGlyph(name: "wand.and.stars")
                    Text("定制表情")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WTChrome353.secondary)
            }
            .buttonStyle(.plain)
            Rectangle().fill(WTChrome353.separator).frame(width: 0.5, height: 13)
            Button { runtime.state.present(.stickers) } label: {
                WTSemanticGlyph(name: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
    }

    @ViewBuilder private var emojiGrid: some View {
        if values.isEmpty && selected == "recent" {
            WTPhase4PanelStateView(
                state: .empty,
                emptyTitle: "暂无最近使用",
                emptySubtitle: "使用过的 Emoji 会显示在这里。"
            )
            .frame(maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 2) {
                    ForEach(Array(values.enumerated()), id: \.offset) { _, symbol in
                        Button { runtime.chooseEmoji(symbol) } label: {
                            Text(symbol)
                                .font(.system(size: 25))
                                .frame(maxWidth: .infinity, minHeight: 31)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
            }
        }
    }

    private var categoryBar: some View {
        HStack(spacing: 0) {
            Button { runtime.state.back() } label: {
                WTSemanticGlyph(name: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 32)
                    .background(WTChrome353.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 5)

            categoryButton(id: "recent", system: "clock")
            ForEach(categories) { category in categoryButton(id: category.id, system: category.icon) }
            Spacer(minLength: 0)
            Button { runtime.deleteBackward() } label: {
                WTSemanticGlyph(name: "delete.left")
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 40, height: 38)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 40)
        .overlay(alignment: .top) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }

    private var footer: some View {
        HStack {
            Button { runtime.advanceToNextInputMode() } label: {
                WTSemanticGlyph(name: "globe")
                    .font(.system(size: 22))
                    .frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
            Spacer()
            Button { runtime.state.present(.voice) } label: {
                WTSemanticGlyph(name: "mic")
                    .font(.system(size: 22))
                    .frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
    }

    private func categoryButton(id: String, system: String) -> some View {
        Button { selected = id } label: {
            WTSemanticGlyph(name: system)
                .font(.system(size: 14, weight: selected == id ? .semibold : .regular))
                .foregroundStyle(selected == id ? WTChrome353.primaryText : WTChrome353.secondary)
                .frame(width: 33, height: 38)
                .background(selected == id ? WTChrome353.elevatedSurface : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
