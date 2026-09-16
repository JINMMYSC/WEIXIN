import SwiftUI

public struct WTHostHome353View: View {
    public init() {}

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(WTHostHomeCatalog353.cards.enumerated()), id: \.offset) { _, card in
                        NavigationLink(destination: destinationView(card.destination)) {
                            cardView(card)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("host.home.card.\(card.assetFamily)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(wtHex: WTHostHomeCatalog353.backgroundHex).ignoresSafeArea())
            .navigationTitle("微信输入法")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color(wtHex: "#23C891"))
    }

    private func cardView(_ card: WTHostHomeCard353) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            WTSemanticGlyph(name: glyphName(for: card.assetFamily))
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Color(wtHex: "#23C891"))
            Text(card.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Text(card.subtitle)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(WTHostHomeCatalog353.cardCornerRadius), style: .continuous))
    }

    @ViewBuilder
    private func destinationView(_ raw: String) -> some View {
        if raw == WTSettingsDestination.displaySetting.rawValue {
            WTDisplaySettings353View()
        } else if let destination = WTSettingsDestination(rawValue: raw) {
            WTSettingsDetailView(destination: destination)
        } else {
            Text(raw)
        }
    }

    private func glyphName(for family: String) -> String {
        switch family {
        case "icon_layout": return "rectangle.grid.2x2"
        case "icon_app_setup_vibration": return "waveform"
        case "icon_app_setup_customize_toolbar": return "slider.horizontal.3"
        case "icon_app_setup_multiple_devices": return "laptopcomputer.and.iphone"
        case "icon_clipboard": return "doc.on.clipboard"
        case "icon_app_setup_voice": return "mic"
        case "icon_app_setup_pluslogo": return "plus.circle"
        case "icon_app_setup_air": return "airplane"
        default: return "keyboard"
        }
    }
}
