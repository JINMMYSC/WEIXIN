import SwiftUI
import Foundation

public struct WTDisplaySettings353View: View {
    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CGFloat(WTHostSettingsChrome353.groupSpacing)) {
                numberLayoutCard
                togglePreviewCard(
                    title: "键盘上显示表情键",
                    key: "wt.display.emoji",
                    preview: .emoji
                )
                togglePreviewCard(
                    title: "九宫格 - 上滑输入数字",
                    key: "wt.display.numberSwipe",
                    preview: .numberSwipe
                )
                keyboardHeightCard
                sidebarCard
                pinyinPositionCard
            }
            .padding(.horizontal, CGFloat(WTHostSettingsChrome353.sideMargin))
            .padding(.vertical, CGFloat(WTHostSettingsChrome353.groupSpacing))
        }
        .background(Color(wtHex: WTHostSettingsChrome353.pageBackground).ignoresSafeArea())
        .navigationTitle("布局和显示")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var numberLayoutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                WTSettingsKeyboardPreview353(kind: .fullNumber)
                WTSettingsKeyboardPreview353(kind: .nineNumber)
            }
            HStack {
                selectionLabel("全键盘数字", selected: true)
                Spacer()
                selectionLabel("九宫格数字", selected: false)
            }
        }
        .padding(18)
        .background(Color(wtHex: WTHostSettingsChrome353.cardBackground))
        .clipShape(RoundedRectangle(
            cornerRadius: CGFloat(WTHostSettingsChrome353.cardCornerRadius),
            style: .continuous
        ))
    }

    private func selectionLabel(_ title: String, selected: Bool) -> some View {
        HStack(spacing: 7) {
            ZStack {
                Circle()
                    .stroke(selected ? Color.clear : Color(wtHex: "#D9D9D9"), lineWidth: 1.5)
                    .background(Circle().fill(selected ? Color(wtHex: "#23C891") : Color.clear))
                if selected {
                    Text("✓").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                }
            }
            .frame(width: 20, height: 20)
            Text(title)
                .font(.system(size: 14.5, weight: .medium))
                .foregroundStyle(selected ? Color(wtHex: "#23C891") : Color(wtHex: "#666666"))
        }
    }

    private func togglePreviewCard(title: String, key: String, preview: WTSettingsKeyboardPreview353.Kind) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(wtHex: "#202020"))
                Spacer()
                Toggle("", isOn: boolBinding(key, defaultValue: false))
                    .labelsHidden()
                    .tint(Color(wtHex: "#23C891"))
            }
            WTSettingsKeyboardPreview353(kind: preview)
                .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(Color(wtHex: WTHostSettingsChrome353.cardBackground))
        .clipShape(RoundedRectangle(
            cornerRadius: CGFloat(WTHostSettingsChrome353.cardCornerRadius),
            style: .continuous
        ))
    }

    private var keyboardHeightCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("键盘高度调节")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button("设置") {}
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(Color(wtHex: "#23C891"))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            WTSettingsKeyboardPreview353(kind: .height)
        }
        .padding(18)
        .background(Color(wtHex: WTHostSettingsChrome353.cardBackground))
        .clipShape(RoundedRectangle(
            cornerRadius: CGFloat(WTHostSettingsChrome353.cardCornerRadius),
            style: .continuous
        ))
    }

    private var sidebarCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("九宫格键盘 - 侧边栏")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                WTSemanticGlyph(name: "chevron.right")
                    .foregroundStyle(Color(wtHex: "#777777"))
            }
            HStack(spacing: 12) {
                WTSettingsKeyboardPreview353(kind: .sidebarPinyin)
                WTSettingsKeyboardPreview353(kind: .sidebarNumber)
            }
        }
        .padding(18)
        .background(Color(wtHex: WTHostSettingsChrome353.cardBackground))
        .clipShape(RoundedRectangle(
            cornerRadius: CGFloat(WTHostSettingsChrome353.cardCornerRadius),
            style: .continuous
        ))
    }

    private var pinyinPositionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("拼音显示")
                .font(.system(size: 17, weight: .semibold))
            HStack(spacing: 12) {
                choicePreview("显示在输入框", selected: true)
                choicePreview("显示在候选栏", selected: false)
            }
        }
        .padding(18)
        .background(Color(wtHex: WTHostSettingsChrome353.cardBackground))
        .clipShape(RoundedRectangle(
            cornerRadius: CGFloat(WTHostSettingsChrome353.cardCornerRadius),
            style: .continuous
        ))
    }

    private func choicePreview(_ title: String, selected: Bool) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(wtHex: "#F2F2F2"))
                .frame(height: 58)
                .overlay(Text("wei'xin'shu'ru'fa").font(.system(size: 9)).foregroundStyle(.secondary))
            HStack(spacing: 5) {
                Circle().fill(selected ? Color(wtHex: "#23C891") : Color(wtHex: "#D9D9D9")).frame(width: 14, height: 14)
                Text(title).font(.system(size: 11)).foregroundStyle(Color(wtHex: "#666666"))
            }
        }
        .padding(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? Color(wtHex: "#23C891") : Color(wtHex: "#E3E3E3"), lineWidth: 1))
    }

    private var defaults: UserDefaults {
        if let group = Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String,
           let value = UserDefaults(suiteName: group) {
            return value
        }
        return .standard
    }

    private func boolBinding(_ key: String, defaultValue: Bool) -> Binding<Bool> {
        let store = defaults
        return Binding(
            get: { store.object(forKey: key) as? Bool ?? defaultValue },
            set: { store.set($0, forKey: key) }
        )
    }
}

private struct WTSettingsKeyboardPreview353: View {
    enum Kind { case fullNumber, nineNumber, emoji, numberSwipe, height, sidebarPinyin, sidebarNumber }
    let kind: Kind

    var body: some View {
        ZStack {
            Color(wtHex: "#F4F4F4")
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { col in
                            key(row: row, col: col)
                        }
                    }
                }
                HStack(spacing: 4) {
                    key(width: 46, gray: true)
                    key(width: 34)
                    key(width: 112)
                    key(width: 34)
                    key(width: 46, gray: true)
                }
            }
            .padding(10)
        }
        .frame(height: 126)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private func key(row: Int, col: Int) -> some View {
        let highlighted = kind == .emoji && row == 2 && col == 4
        let numbered = kind == .numberSwipe && row < 3 && col > 0 && col < 4
        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(highlighted ? Color(wtHex: "#AFB4BD") : Color.white)
            .frame(maxWidth: .infinity, minHeight: 25, maxHeight: 25)
            .overlay {
                if highlighted {
                    Text("☺").font(.system(size: 14)).foregroundStyle(Color(wtHex: "#222222"))
                } else if numbered {
                    Text("\(row * 3 + col)")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(wtHex: "#9A9A9A"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(3)
                }
            }
    }

    private func key(width: CGFloat, gray: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(gray ? Color(wtHex: "#E2E3E6") : Color.white)
            .frame(width: width, height: 25)
    }
}
