import SwiftUI

public struct WTQuickSettingsView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var simplifiedChinese = true
    @State private var fuzzyRetroflex = false
    @State private var fuzzyNL = false

    private static let appGroupID = "group.7518554"
    private static let simplifiedNotification = Notification.Name("WTPhase3SimplifiedChanged")
    private static let fuzzyRetroflexNotification = Notification.Name("WTPhase3FuzzyRetroflexChanged")
    private static let fuzzyNLNotification = Notification.Name("WTPhase3FuzzyNLChanged")

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "快捷设置", onBack: { runtime.state.back() })
            ScrollView {
                VStack(spacing: 8) {
                    toggleRow("简体中文", system: "character.book.closed", isOn: Binding(
                        get: { simplifiedChinese },
                        set: { value in
                            simplifiedChinese = value
                            let defaults = UserDefaults(suiteName: Self.appGroupID)
                            defaults?.set(value, forKey: "wt.script.simplified")
                            NotificationCenter.default.post(name: Self.simplifiedNotification, object: NSNumber(value: value))
                        }
                    ))
                    toggleRow("模糊音 z/zh · c/ch · s/sh", system: "textformat.abc", isOn: Binding(
                        get: { fuzzyRetroflex },
                        set: { value in
                            fuzzyRetroflex = value
                            let defaults = UserDefaults(suiteName: Self.appGroupID)
                            defaults?.set(true, forKey: "wt.pinyin.blur")
                            defaults?.set(value, forKey: "wt.fuzzy.z_zh")
                            defaults?.set(value, forKey: "wt.fuzzy.c_ch")
                            defaults?.set(value, forKey: "wt.fuzzy.s_sh")
                            NotificationCenter.default.post(name: Self.fuzzyRetroflexNotification, object: NSNumber(value: value))
                        }
                    ))
                    toggleRow("模糊音 n/l", system: "textformat.abc", isOn: Binding(
                        get: { fuzzyNL },
                        set: { value in
                            fuzzyNL = value
                            let defaults = UserDefaults(suiteName: Self.appGroupID)
                            defaults?.set(true, forKey: "wt.pinyin.blur")
                            defaults?.set(value, forKey: "wt.fuzzy.n_l")
                            NotificationCenter.default.post(name: Self.fuzzyNLNotification, object: NSNumber(value: value))
                        }
                    ))

                    toggleRow("按键音", system: "speaker.wave.2", isOn: binding(\.keySoundEnabled))
                    toggleRow("按键振动", system: "iphone.radiowaves.left.and.right", isOn: binding(\.hapticEnabled))
                    toggleRow("智能标点", system: "textformat", isOn: binding(\.smartPunctuationEnabled))
                    toggleRow("拼写纠错", system: "checkmark.circle", isOn: binding(\.autoCorrectionEnabled))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("单手键盘")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            oneHandButton(.left, "左")
                            oneHandButton(.off, "关闭")
                            oneHandButton(.right, "右")
                        }
                    }
                    .padding(12)
                    .background(WTChrome353.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    HStack(spacing: 8) {
                        shortcut("字体", system: "textformat.size") { runtime.state.present(.fontPicker) }
                        shortcut("键盘调节", system: "rectangle.arrowtriangle.2.outward") { runtime.state.present(.keyboardAdjust) }
                        shortcut("授权", system: "checkmark.shield") { runtime.state.present(.guide) }
                    }
                }
                .padding(10)
            }
        }
        .background(WTChrome353.panelBackground)
        .onAppear(perform: loadPhase3Preferences)
    }

    private func loadPhase3Preferences() {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        simplifiedChinese = (defaults?.object(forKey: "wt.script.simplified") as? Bool) ?? true
        let master = (defaults?.object(forKey: "wt.pinyin.blur") as? Bool) ?? true
        let retroflex = ["wt.fuzzy.z_zh", "wt.fuzzy.c_ch", "wt.fuzzy.s_sh"].contains {
            defaults?.object(forKey: $0) as? Bool == true
        }
        fuzzyRetroflex = master && retroflex
        fuzzyNL = master && ((defaults?.object(forKey: "wt.fuzzy.n_l") as? Bool) ?? false)
    }

    private func binding(_ keyPath: WritableKeyPath<WTQuickSettingState, Bool>) -> Binding<Bool> {
        Binding(
            get: { runtime.quickSettings[keyPath: keyPath] },
            set: { runtime.quickSettings[keyPath: keyPath] = $0 }
        )
    }

    private func toggleRow(_ title: String, system: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            WTSemanticGlyph(name: system).frame(width: 24)
            Text(title).font(.system(size: 14))
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(WTChrome353.accent)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(WTChrome353.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func shortcut(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                WTSemanticGlyph(name: system).font(.system(size: 17))
                Text(title).font(.system(size: 10))
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(WTChrome353.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }.buttonStyle(.plain)
    }

    private func oneHandButton(_ mode: WTOneHandedMode, _ title: String) -> some View {
        Button {
            runtime.toggleOneHanded(mode)
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(runtime.quickSettings.oneHandedMode == mode ? WTChrome353.accent.opacity(0.15) : WTChrome353.panelBackground)
                .foregroundStyle(runtime.quickSettings.oneHandedMode == mode ? WTChrome353.accent : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
