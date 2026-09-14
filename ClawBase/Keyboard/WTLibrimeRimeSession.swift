import Foundation

/// Real Phase 3 librime session used by Release builds.
final class WTLibrimeRimeSession: WTHamsterRimeSessionProtocol {
    private static let appGroupID = "group.7518554"
    private static let simplifiedKey = "phase3.simplifiedChinese"
    private static let fuzzyRetroflexKey = "phase3.fuzzy.retroflexInitials"
    private static let fuzzyNasalLateralKey = "phase3.fuzzy.nasalLateral"

    /// Rime deploys schemas listed by default.yaml plus the user's deterministic overlay.
    /// All entries here are CLAW-owned schema wrappers or exact pinned public Rime schemas.
    private static let phase3DefaultCustomYAML = """
    patch:
      schema_list:
        - schema: claw_pinyin26
        - schema: claw_pinyin26_fuzzy_zhz
        - schema: claw_pinyin26_fuzzy_ln
        - schema: claw_pinyin26_fuzzy_all
        - schema: claw_pinyin9
        - schema: double_pinyin
        - schema: wubi86
        - schema: stroke
        - schema: pinyin_simp
    """

    private let bridge: WTLibrimeBridge
    private let preferences: UserDefaults?
    private var logicalMode: WTInputMode = .chinesePinyin9
    private var snapshotStorage: WTLibrimeContextSnapshot
    private var simplifiedChinese: Bool
    private var fuzzyRetroflexInitials: Bool
    private var fuzzyNasalLateral: Bool

    init() {
        let preferences = UserDefaults(suiteName: Self.appGroupID)
        self.preferences = preferences
        self.simplifiedChinese = (preferences?.object(forKey: Self.simplifiedKey) as? Bool) ?? true
        self.fuzzyRetroflexInitials = preferences?.bool(forKey: Self.fuzzyRetroflexKey) ?? false
        self.fuzzyNasalLateral = preferences?.bool(forKey: Self.fuzzyNasalLateralKey) ?? false

        let fileManager = FileManager.default
        let bundle = Bundle.main
        let sharedURL = bundle.url(forResource: "RimeSharedSupport", withExtension: nil)
        let userRoot = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let userURL = userRoot.appendingPathComponent("RimeUserData", isDirectory: true)
        try? fileManager.createDirectory(at: userURL, withIntermediateDirectories: true)
        Self.stagePhase3DefaultCustomization(in: userURL)

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
        bridge.reset()

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
        for (property, value) in descriptor.properties {
            bridge.setProperty(property, value: value)
        }
        refresh()
    }

    func wtSetSimplifiedChinese(_ simplified: Bool) {
        simplifiedChinese = simplified
        preferences?.set(simplified, forKey: Self.simplifiedKey)
        applyScriptPreference(for: logicalMode)
        refresh()
    }

    func wtSetFuzzyPinyin(_ option: WTFuzzyPinyinOption, enabled: Bool) {
        switch option {
        case .retroflexInitials:
            fuzzyRetroflexInitials = enabled
            preferences?.set(enabled, forKey: Self.fuzzyRetroflexKey)
        case .nasalLateral:
            fuzzyNasalLateral = enabled
            preferences?.set(enabled, forKey: Self.fuzzyNasalLateralKey)
        }
        guard logicalMode == .chinesePinyin26 else { return }
        bridge.reset()
        let schemaID = effectiveSchemaID(baseSchemaID: "claw_pinyin26", mode: .chinesePinyin26)
        if !bridge.selectSchema(schemaID) { _ = bridge.selectSchema("claw_pinyin26") }
        bridge.setOption("ascii_mode", value: false)
        applyScriptPreference(for: .chinesePinyin26)
        refresh()
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

    private func normalizedInput(_ input: String) -> String {
        guard logicalMode == .chinesePinyin9 else { return input.lowercased() }
        if let digit = Self.t9GroupToDigit[input.uppercased()] { return digit }
        return input
    }

    private func effectiveSchemaID(baseSchemaID: String, mode: WTInputMode) -> String {
        guard mode == .chinesePinyin26, baseSchemaID == "claw_pinyin26" else { return baseSchemaID }
        switch (fuzzyRetroflexInitials, fuzzyNasalLateral) {
        case (true, true): return "claw_pinyin26_fuzzy_all"
        case (true, false): return "claw_pinyin26_fuzzy_zhz"
        case (false, true): return "claw_pinyin26_fuzzy_ln"
        case (false, false): return "claw_pinyin26"
        }
    }

    private func applyScriptPreference(for mode: WTInputMode) {
        switch mode {
        case .chinesePinyin26, .chinesePinyin9:
            bridge.setOption("zh_hans", value: simplifiedChinese)
        case .doublePinyin:
            bridge.setOption("simplification", value: simplifiedChinese)
        case .english26, .wubi, .stroke, .handwriting:
            break
        }
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
            return ["double_pinyin", "pinyin_simp"]
        case .wubi:
            return ["wubi86"]
        case .stroke:
            return ["stroke"]
        case .chinesePinyin9, .handwriting:
            return []
        }
    }

    private static let t9GroupToDigit: [String: String] = [
        "ABC": "2",
        "DEF": "3",
        "GHI": "4",
        "JKL": "5",
        "MNO": "6",
        "PQRS": "7",
        "TUV": "8",
        "WXYZ": "9"
    ]
}
