import SwiftUI
import Foundation

public struct WTDisplaySettings353View: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(WTDisplaySettingsCatalog353.sections) { section in
                    VStack(spacing: 0) {
                        ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                            rowView(row)
                            if index != section.rows.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(16)
        }
        .background(Color(wtHex: "#F0F0F0").ignoresSafeArea())
        .navigationTitle("布局和显示")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rowView(_ row: WTDisplaySettingsRow353) -> some View {
        HStack {
            Text(row.title).font(.system(size: 16))
            Spacer()
            trailingControl(row)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .accessibilityIdentifier("host.display.\(row.id)")
    }

    @ViewBuilder
    private func trailingControl(_ row: WTDisplaySettingsRow353) -> some View {
        if row.id == "height" {
            Text(heightLabel(row.preferenceKey)).foregroundStyle(.secondary)
        } else if row.id == "pinyinPosition" {
            Text(defaults.string(forKey: row.preferenceKey) ?? "上方").foregroundStyle(.secondary)
        } else {
            Toggle("", isOn: boolBinding(row.preferenceKey, defaultValue: true))
                .labelsHidden()
                .tint(Color(wtHex: "#23C891"))
        }
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

    private func heightLabel(_ key: String) -> String {
        let stored = defaults.double(forKey: key)
        let value = stored == 0 ? 1.0 : stored
        return String(format: "%.0f%%", value * 100)
    }
}
