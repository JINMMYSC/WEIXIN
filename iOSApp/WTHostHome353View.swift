import SwiftUI

public struct WTHostHome353View: View {
    public init() {}

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    productHeader
                        .padding(.top, 22)
                        .padding(.bottom, 26)
                    featureCard
                        .padding(.bottom, 36)
                    sectionTitle("设置")
                    cardGrid(WTHostHomeCatalog353.cards)
                    sectionTitle("更多")
                        .padding(.top, 24)
                    cardGrid(WTHostHomeCatalog353.moreCards)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(wtHex: WTHostHomeCatalog353.backgroundHex).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(Color(wtHex: "#23C891"))
    }

    private var productHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color(wtHex: "#2FCB91"))
                Text("P")
                    .font(.system(size: 18, weight: .heavy, design: .rounded).italic())
                    .foregroundStyle(.white)
                    .offset(x: -1, y: -1)
            }
            .frame(width: 29, height: 29)
            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 2))

            VStack(alignment: .leading, spacing: 1) {
                Text("微信输入法")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(wtHex: "#191919"))
                Text("简洁、好用、打字快")
                    .font(.system(size: 13.5, weight: .regular))
                    .foregroundStyle(Color(wtHex: "#8D8D8D"))
            }
            Spacer()
        }
        .frame(height: 30)
    }

    private var featureCard: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(wtHex: "#F4F4F4")
                WTHostKeyboardPreview353()
                    .padding(.horizontal, 72)
                    .padding(.vertical, 22)
            }
            .frame(height: 224)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("灵动表达")
                        .font(.system(size: 16.5, weight: .semibold))
                    Text("一键润色或扩写内容，表达更高效")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color(wtHex: "#8A8A8A"))
                }
                Spacer()
                Text("✓ 已开启")
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(Color(wtHex: "#989898"))
                    .padding(.horizontal, 13)
                    .frame(height: 36)
                    .background(Color(wtHex: "#F1F1F1"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 16)
            .frame(height: 46)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 25, weight: .semibold))
            .foregroundStyle(Color(wtHex: "#191919"))
            .padding(.leading, 8)
            .padding(.bottom, 13)
    }

    private func cardGrid(_ cards: [WTHostHomeCard353]) -> some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                NavigationLink(destination: destinationView(card.destination)) {
                    cardView(card)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("host.home.card.\(card.assetFamily)")
            }
        }
    }

    private func cardView(_ card: WTHostHomeCard353) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            WTSemanticGlyph(name: glyphName(for: card.assetFamily))
                .font(.system(size: 25, weight: .regular))
                .foregroundStyle(Color(wtHex: "#4B4B4B"))
                .frame(width: 30, height: 30, alignment: .leading)
                .padding(.bottom, 14)

            HStack(spacing: 5) {
                Text(card.title)
                    .font(.system(size: 16.5, weight: .semibold))
                    .foregroundStyle(Color(wtHex: "#222222"))
                    .lineLimit(1)
                WTSemanticGlyph(name: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(wtHex: "#7A7A7A"))
                Spacer(minLength: 0)
            }
            Text(card.subtitle)
                .font(.system(size: 12.5, weight: .regular))
                .foregroundStyle(Color(wtHex: "#8A8A8A"))
                .lineSpacing(2)
                .lineLimit(2)
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 17)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, minHeight: 134, maxHeight: 134, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func destinationView(_ raw: String) -> some View {
        if raw == WTSettingsDestination.displaySetting.rawValue {
            WTDisplaySettings353View()
                .navigationBarHidden(false)
        } else if let destination = WTSettingsDestination(rawValue: raw) {
            WTSettingsDetailView(destination: destination)
                .navigationBarHidden(false)
        } else {
            Text(raw)
                .navigationBarHidden(false)
        }
    }

    private func glyphName(for family: String) -> String {
        switch family {
        case "icon_layout": return "keyboard"
        case "icon_app_setup_vibration": return "iphone.radiowaves.left.and.right"
        case "icon_app_setup_customize_toolbar": return "wand.and.stars"
        case "icon_app_setup_multiple_devices": return "desktopcomputer"
        case "icon_clipboard": return "list.clipboard"
        case "icon_app_setup_voice": return "mic.badge.plus"
        case "icon_app_setup_pluslogo": return "plus.circle"
        case "icon_app_setup_air": return "airplane"
        case "icon_app_setup_computer": return "desktopcomputer"
        case "icon_app_setup_privacy": return "lock.shield"
        case "icon_app_setup_help": return "questionmark.circle"
        case "icon_app_setup_about": return "info.circle"
        default: return "keyboard.badge.ellipsis"
        }
    }
}

private struct WTHostKeyboardPreview353: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { _ in key(width: 16, height: 20) }
            }
            HStack(spacing: 4) {
                ForEach(0..<9, id: \.self) { _ in key(width: 17, height: 20) }
            }
            HStack(spacing: 4) {
                key(width: 24, height: 20, gray: true)
                ForEach(0..<7, id: \.self) { _ in key(width: 18, height: 20) }
                key(width: 24, height: 20, gray: true)
            }
            HStack(spacing: 4) {
                key(width: 33, height: 20, gray: true)
                key(width: 20, height: 20)
                key(width: 82, height: 20)
                key(width: 24, height: 20)
                key(width: 42, height: 20, gray: true)
            }
        }
        .padding(9)
        .background(Color(wtHex: "#CDD0D8"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func key(width: CGFloat, height: CGFloat, gray: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(gray ? Color(wtHex: "#AFB4BD") : Color.white)
            .frame(width: width, height: height)
    }
}
