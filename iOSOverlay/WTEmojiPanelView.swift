import SwiftUI

private struct WTEmojiCategory: Identifiable {
    let id: String
    let icon: String
    let values: [String]
}

private enum WTEmojiContentMode: String, CaseIterable {
    case emoji = "表情"
    case sticker = "表情包"
    case gif = "GIF"
}

public struct WTEmojiPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var selected: String
    @State private var contentMode: WTEmojiContentMode = .emoji

    private let categories: [WTEmojiCategory] = [
        .init(id: "faces", icon: "face.smiling", values: ["😀","😃","😄","😁","😆","🥹","😅","😂","🤣","🥲","😊","😇","🙂","🙃","😉","😌","😍","🥰","😘","😗","😙","😚","😋","😛","😝","😜","🤪","🤨","🧐","🤓","😎","🥸","🤩","🥳","😏","😒","😞","😔","😟","😕","🙁","☹️","😣","😖","😫","😩","🥺","😢","😭","😤","😠","😡","🤬"]),
        .init(id: "gestures", icon: "hand.raised", values: ["👍","👎","👌","✌️","🤞","🫰","🤟","🤘","🤙","👈","👉","👆","👇","☝️","👏","🙌","🫶","🤲","🤝","🙏","💪","🫵","✍️","💅","🤳"]),
        .init(id: "animals", icon: "pawprint", values: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🐔","🐧","🐦","🐤","🦄","🐝","🦋","🐌","🐞","🐢","🐍","🦎","🦖","🦕"]),
        .init(id: "food", icon: "fork.knife", values: ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🥑","🍆","🥦","🥬","🥒","🌶️","🌽","🥕","🧄","🧅","🥔","🍠"]),
        .init(id: "travel", icon: "car", values: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","🛵","🏍️","🚲","🛴","✈️","🚀","🚁","⛵️","🚤","🚢","🚆","🚇","🚉","🏠","🏢","🏬","🏥","🏫"]),
        .init(id: "objects", icon: "lightbulb", values: ["⌚️","📱","💻","⌨️","🖥️","🖨️","🖱️","📷","📹","🎥","📺","📻","⏰","💡","🔦","🕯️","💎","🔧","🔨","🛠️","🧰","🔑","🎁","🎈","🎉","🎊","📌","📎","✏️","📝","📚"]),
        .init(id: "symbols", icon: "heart", values: ["❤️","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❣️","💕","💞","💓","💗","💖","💘","💝","💟","✨","⭐️","🌟","💫","🔥","💥","💯","✅","❌","⭕️","❗️","❓","⚠️","♻️"])
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
            HStack(spacing: 0) {
                ForEach(WTEmojiContentMode.allCases, id: \.self) { mode in
                    Button {
                        contentMode = mode
                        if mode != .emoji { runtime.state.present(.stickers) }
                    } label: {
                        Text(mode.rawValue)
                            .font(.system(size: 13, weight: contentMode == mode ? .semibold : .regular))
                            .foregroundStyle(contentMode == mode ? WTChrome353.accent : Color.primary)
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .overlay(alignment: .bottom) {
                                if contentMode == mode { Capsule().fill(WTChrome353.accent).frame(width: 24, height: 2) }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(WTChrome353.surface)
            .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }

            emojiGrid

            Divider()
            HStack(spacing: 0) {
                categoryButton(id: "recent", system: "clock")
                ForEach(categories) { category in categoryButton(id: category.id, system: category.icon) }
                Spacer(minLength: 0)
                Button("ABC") { runtime.state.back() }
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 44, height: 40)
                Button { runtime.deleteBackward() } label: {
                    WTSemanticGlyph(name: "delete.left").frame(width: 44, height: 40)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 2)
            .frame(height: 42)
        }
        .background(WTChrome353.surface)
    }

    @ViewBuilder private var emojiGrid: some View {
        if values.isEmpty && selected == "recent" {
            WTPhase4PanelStateView(state: .empty, emptyTitle: "暂无最近使用", emptySubtitle: "使用过的 Emoji 会显示在这里。")
        } else {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 5) {
                    ForEach(Array(values.enumerated()), id: \.offset) { _, symbol in
                        Button { runtime.chooseEmoji(symbol) } label: {
                            Text(symbol).font(.system(size: 29)).frame(maxWidth: .infinity, minHeight: 39)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
        }
    }

    private func categoryButton(id: String, system: String) -> some View {
        Button { selected = id; contentMode = .emoji } label: {
            WTSemanticGlyph(name: system)
                .font(.system(size: 14, weight: selected == id ? .semibold : .regular))
                .foregroundStyle(selected == id ? WTChrome353.accent : Color.primary.opacity(0.72))
                .frame(width: 34, height: 38)
        }
    }
}
