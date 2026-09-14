import Foundation

/// Real Phase 3 librime session used by Release builds.
final class WTLibrimeRimeSession: WTHamsterRimeSessionProtocol {
    private static let appGroupID = "group.7518554"
    private static let simplifiedKey = "wt.script.simplified"
    private static let legacySimplifiedKey = "phase3.simplifiedChinese"
    private static let fuzzyMasterKey = "wt.pinyin.blur"
    private static let fuzzyZZhKey = "wt.fuzzy.z_zh"
    private static let fuzzyCChKey = "wt.fuzzy.c_ch"
    private static let fuzzySShKey = "wt.fuzzy.s_sh"
    private static let fuzzyNLKey = "wt.fuzzy.n_l"
    private static let fuzzyFHKey = "wt.fuzzy.f_h"
    private static let fuzzyAnAngKey = "wt.fuzzy.an_ang"
    private static let fuzzyEnEngKey = "wt.fuzzy.en_eng"
    private static let fuzzyInIngKey = "wt.fuzzy.in_ing"
    private static let doubleSchemeKey = "wt.double.scheme"
    private static let wubiMixKey = "wt.wubi.mix"
    private static let legacyFuzzyRetroflexKey = "phase3.fuzzy.retroflexInitials"
    private static let legacyFuzzyNasalLateralKey = "phase3.fuzzy.nasalLateral"

    private static let phase3DefaultCustomYAML = """
    patch:
      schema_list:
        - schema: claw_pinyin26
        - schema: claw_pinyin9
        - schema: double_pinyin
        - schema: double_pinyin_flypy
        - schema: double_pinyin_mspy
        - schema: claw_double_pinyin_sogou
        - schema: wubi86
        - schema: wubi_pinyin
        - schema: wubi_trad
        - schema: stroke
        - schema: pinyin_simp
    """

    private struct FuzzySettings: Equatable {
        var zZh = false
        var cCh = false
        var sSh = false
        var nL = false
        var fH = false
        var anAng = false
        var enEng = false
        var inIng = false

        var algebraRules: [String] {
            var rules: [String] = []
            if zZh { rules += ["derive/^zh/z/", "derive/^z/zh/"] }
            if cCh { rules += ["derive/^ch/c/", "derive/^c/ch/"] }
            if sSh { rules += ["derive/^sh/s/", "derive/^s/sh/"] }
            if nL { rules += ["derive/^n/l/", "derive/^l/n/"] }
            if fH { rules += ["derive/^f/h/", "derive/^h/f/"] }
            if anAng { rules += ["derive/an$/ang/", "derive/ang$/an/"] }
            if enEng { rules += ["derive/en$/eng/", "derive/eng$/en/"] }
            if inIng { rules += ["derive/in$/ing/", "derive/ing$/in/"] }
            return rules
        }
    }

    private let bridge: WTLibrimeBridge
    private let preferences: UserDefaults?
    private let userDataURL: URL
    private let sharedPinyinSchemaPath: String?
    private var logicalMode: WTInputMode = .chinesePinyin9
    private var snapshotStorage: WTLibrimeContextSnapshot
    private var simplifiedChinese: Bool
    private var fuzzySettings: FuzzySettings

    init() {
        let preferences = UserDefaults(suiteName: Self.appGroupID)
        self.preferences = preferences
        self.simplifiedChinese = Self.boolPreference(
            preferences,
            primary: Self.simplifiedKey,
            fallback: Self.legacySimplifiedKey,
            defaultValue: true
        )
        self.fuzzySettings = Self.loadFuzzyPreferences(preferences)

        let fileManager = FileManager.default
        let bundle = Bundle.main
        let sharedURL = bundle.url(forResource: "RimeSharedSupport", withExtension: nil)
        let userRoot = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let userURL = userRoot.appendingPathComponent("RimeUserData", isDirectory: true)
        self.userDataURL = userURL
        self.sharedPinyinSchemaPath = sharedURL?.appendingPathComponent("claw_pinyin26.schema.yaml").path
        try? fileManager.createDirectory(at: userURL, withIntermediateDirectories: true)
        Self.stagePhase3DefaultCustomization(in: userURL)
        Self.stageFuzzyCustomization(self.fuzzySettings, in: userURL)

        let sharedPath = sharedURL?.path ?? bundle.bundlePath
        bridge = WTLibrimeBridge(sharedDataDir: sharedPath, userDataDir: userURL.path)
        snapshotStorage = bridge.snapshot()
    }

    var wtComposition: String { snapshotStorage.composition }
    var wtCompositionState: WTIMECompositionState {
        WTIMECompositionState(
            length: snapshotStorage.compositionLength,
            cursorPosition: snapshotStorage.cursorPosition,
            selectionStart: snapshotStorage.selectionStart,
            selectionEnd: snapshotStorage.selectionEnd
        )
    }
    var wtCandidates: [WTCandidate] {
        snapshotStorage.candidates.map { record in
            WTCandidate(text: record.text, comment: record.comment.isEmpty ? nil : record.comment)
        }
    }
    var wtIsComposing: Bool { snapshotStorage.composing }
    var wtCandidatePageState: WTCandidatePageState {
        WTCandidatePageState(
            currentPage: snapshotStorage.pageNumber,
            pageSize: snapshotStorage.pageSize,
            hasPrevious: snapshotStorage.pageNumber > 0,
            hasNext: !snapshotStorage.lastPage
        )
    }

    @discardableResult
    func wtProcess(_ input: String) -> Bool {
        let consumed = bridge.processText(normalizedInput(input))
        refresh()
        return consumed
    }

    func wtDrainCommit() -> String? {
        let committed = bridge.drainCommit()
        refresh()
        return committed
    }

    func wtSetInputMode(_ mode: WTInputMode) {
        logicalMode = mode
        bridge.reset()
        refresh()
    }

    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode mode: WTInputMode) {
        logicalMode = mode
        reloadSharedPreferences()
        bridge.reset()
        if mode == .chinesePinyin26 { deployCurrentFuzzyCustomization() }

        if let requested = descriptor.schemaID, !requested.isEmpty {
            let schemaID = effectiveSchemaID(baseSchemaID: requested, mode: mode)
            let selected = bridge.selectSchema(schemaID)
            if !selected {
                for fallback in Self.fallbackSchemaIDs(for: mode) {
                    if bridge.selectSchema(fallback) { break }
                }
            }
        }
        for (option, value) in descriptor.options where option != "zh_hans" && option != "simplification" {
            bridge.setOption(option, value: value)
        }
        applyScriptPreference(for: mode)
        for (property, value) in descriptor.properties { bridge.setProperty(property, value: value) }
        refresh()
    }

    func wtSetSimplifiedChinese(_ simplified: Bool) {
        simplifiedChinese = simplified
        preferences?.set(simplified, forKey: Self.simplifiedKey)
        preferences?.set(simplified, forKey: Self.legacySimplifiedKey)
        if logicalMode == .wubi {
            bridge.reset()
            let schemaID = effectiveSchemaID(baseSchemaID: "wubi86", mode: .wubi)
            if !bridge.selectSchema(schemaID) { _ = bridge.selectSchema("wubi86") }
            bridge.setOption("ascii_mode", value: false)
        }
        applyScriptPreference(for: logicalMode)
        refresh()
    }

    func wtSetFuzzyPinyin(_ option: WTFuzzyPinyinOption, enabled: Bool) {
        preferences?.set(true, forKey: Self.fuzzyMasterKey)
        switch option {
        case .zZh:
            preferences?.set(enabled, forKey: Self.fuzzyZZhKey)
        case .cCh:
            preferences?.set(enabled, forKey: Self.fuzzyCChKey)
        case .sSh:
            preferences?.set(enabled, forKey: Self.fuzzySShKey)
        case .nasalLateral:
            preferences?.set(enabled, forKey: Self.fuzzyNLKey)
            preferences?.set(enabled, forKey: Self.legacyFuzzyNasalLateralKey)
        case .fH:
            preferences?.set(enabled, forKey: Self.fuzzyFHKey)
        case .anAng:
            preferences?.set(enabled, forKey: Self.fuzzyAnAngKey)
        case .enEng:
            preferences?.set(enabled, forKey: Self.fuzzyEnEngKey)
        case .inIng:
            preferences?.set(enabled, forKey: Self.fuzzyInIngKey)
        case .retroflexInitials:
            preferences?.set(enabled, forKey: Self.fuzzyZZhKey)
            preferences?.set(enabled, forKey: Self.fuzzyCChKey)
            preferences?.set(enabled, forKey: Self.fuzzySShKey)
            preferences?.set(enabled, forKey: Self.legacyFuzzyRetroflexKey)
        }

        let updated = Self.loadFuzzyPreferences(preferences)
        guard updated != fuzzySettings else { return }
        fuzzySettings = updated
        Self.stageFuzzyCustomization(updated, in: userDataURL)
        guard logicalMode == .chinesePinyin26 else { return }
        bridge.reset()
        deployCurrentFuzzyCustomization()
        if !bridge.selectSchema("claw_pinyin26") { _ = bridge.selectSchema("pinyin_simp") }
        bridge.setOption("ascii_mode", value: false)
        applyScriptPreference(for: .chinesePinyin26)
        refresh()
    }

    func wtReloadPhase3Preferences() {
        reloadSharedPreferences()
        refresh()
    }

    func wtSyncUserData() {
        _ = bridge.syncUserData()
    }

    @discardableResult
    func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        let moved = bridge.movePage(direction == .previous ? -1 : 1)
        refresh()
        return moved
    }

    func wtSelectCandidate(at index: Int) -> String? {
        let committed = bridge.selectCandidate(at: index)
        refresh()
        return committed
    }

    func wtDeleteBackward() {
        bridge.deleteBackward()
        refresh()
    }

    func wtReset() {
        bridge.reset()
        refresh()
    }

    private func refresh() {
        snapshotStorage = bridge.snapshot()
    }

    private func reloadSharedPreferences() {
        simplifiedChinese = Self.boolPreference(
            preferences,
            primary: Self.simplifiedKey,
            fallback: Self.legacySimplifiedKey,
            defaultValue: simplifiedChinese
        )
        let updated = Self.loadFuzzyPreferences(preferences)
        if updated != fuzzySettings {
            fuzzySettings = updated
            Self.stageFuzzyCustomization(updated, in: userDataURL)
        }
    }

    private func deployCurrentFuzzyCustomization() {
        guard let sharedPinyinSchemaPath else { return }
        _ = bridge.deploySchemaFile(sharedPinyinSchemaPath)
    }

    private func normalizedInput(_ input: String) -> String {
        guard logicalMode == .chinesePinyin9 else { return input.lowercased() }
        if let digit = Self.t9GroupToDigit[input.uppercased()] { return digit }
        return input
    }

    private func effectiveSchemaID(baseSchemaID: String, mode: WTInputMode) -> String {
        if mode == .doublePinyin, baseSchemaID == "double_pinyin" {
            return Self.doublePinyinSchemaID(preferences?.string(forKey: Self.doubleSchemeKey))
        }
        if mode == .wubi, baseSchemaID == "wubi86" {
            if !simplifiedChinese { return "wubi_trad" }
            let mixed = (preferences?.object(forKey: Self.wubiMixKey) as? Bool) ?? true
            return mixed ? "wubi_pinyin" : "wubi86"
        }
        return baseSchemaID
    }

    private static func doublePinyinSchemaID(_ configured: String?) -> String {
        switch configured {
        case "小鹤双拼": return "double_pinyin_flypy"
        case "微软双拼": return "double_pinyin_mspy"
        case "搜狗双拼": return "claw_double_pinyin_sogou"
        case "自然码": return "double_pinyin"
        default: return "double_pinyin_flypy"
        }
    }

    private func applyScriptPreference(for mode: WTInputMode) {
        switch mode {
        case .chinesePinyin26, .chinesePinyin9:
            bridge.setOption("zh_hans", value: simplifiedChinese)
        case .doublePinyin:
            bridge.setOption("simplification", value: simplifiedChinese)
        case .wubi:
            bridge.setOption("zh_trad", value: !simplifiedChinese)
        case .english26, .stroke, .handwriting:
            break
        }
    }

    private static func boolPreference(
        _ defaults: UserDefaults?,
        primary: String,
        fallback: String,
        defaultValue: Bool
    ) -> Bool {
        if let value = defaults?.object(forKey: primary) as? Bool { return value }
        if let value = defaults?.object(forKey: fallback) as? Bool { return value }
        return defaultValue
    }

    private static func loadFuzzyPreferences(_ defaults: UserDefaults?) -> FuzzySettings {
        let master = (defaults?.object(forKey: fuzzyMasterKey) as? Bool) ?? true
        guard master else { return FuzzySettings() }
        let legacyRetroflex = defaults?.object(forKey: legacyFuzzyRetroflexKey) as? Bool ?? false
        let legacyNL = defaults?.object(forKey: legacyFuzzyNasalLateralKey) as? Bool ?? false
        return FuzzySettings(
            zZh: (defaults?.object(forKey: fuzzyZZhKey) as? Bool) ?? legacyRetroflex,
            cCh: (defaults?.object(forKey: fuzzyCChKey) as? Bool) ?? legacyRetroflex,
            sSh: (defaults?.object(forKey: fuzzySShKey) as? Bool) ?? legacyRetroflex,
            nL: (defaults?.object(forKey: fuzzyNLKey) as? Bool) ?? legacyNL,
            fH: (defaults?.object(forKey: fuzzyFHKey) as? Bool) ?? false,
            anAng: (defaults?.object(forKey: fuzzyAnAngKey) as? Bool) ?? false,
            enEng: (defaults?.object(forKey: fuzzyEnEngKey) as? Bool) ?? false,
            inIng: (defaults?.object(forKey: fuzzyInIngKey) as? Bool) ?? false
        )
    }

    private static func stageFuzzyCustomization(_ settings: FuzzySettings, in userURL: URL) {
        let target = userURL.appendingPathComponent("claw_pinyin26.custom.yaml", isDirectory: false)
        let rules = settings.algebraRules
        guard !rules.isEmpty else {
            if FileManager.default.fileExists(atPath: target.path) { try? FileManager.default.removeItem(at: target) }
            return
        }
        var lines = ["patch:", "  \"speller/algebra/+\":"]
        lines.append(contentsOf: rules.map { "    - \($0)" })
        lines.append("")
        let expected = Data(lines.joined(separator: "\n").utf8)
        if let existing = try? Data(contentsOf: target), existing == expected { return }
        try? expected.write(to: target, options: .atomic)
    }

    private static func stagePhase3DefaultCustomization(in userURL: URL) {
        let target = userURL.appendingPathComponent("default.custom.yaml", isDirectory: false)
        let expected = Data(phase3DefaultCustomYAML.utf8)
        if let existing = try? Data(contentsOf: target), existing == expected { return }
        try? expected.write(to: target, options: .atomic)
    }

    private static func fallbackSchemaIDs(for mode: WTInputMode) -> [String] {
        switch mode {
        case .chinesePinyin26, .english26:
            return ["pinyin_simp", "luna_pinyin"]
        case .doublePinyin:
            return ["double_pinyin_flypy", "double_pinyin", "pinyin_simp"]
        case .wubi:
            return ["wubi_pinyin", "wubi_trad", "wubi86"]
        case .stroke:
            return ["stroke"]
        case .chinesePinyin9, .handwriting:
            return []
        }
    }

    private static let t9GroupToDigit: [String: String] = [
        "ABC": "2", "DEF": "3", "GHI": "4", "JKL": "5",
        "MNO": "6", "PQRS": "7", "TUV": "8", "WXYZ": "9"
    ]
}
