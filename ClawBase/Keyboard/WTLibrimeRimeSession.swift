import Foundation

/// Real Phase 3 librime session used by Release builds.
///
/// The C/Objective-C bridge is deliberately tiny and pinned to the public LibrimeKit/librime
/// binary revision prepared by `ci_prepare_librimekit.sh`. The keyboard UI only sees the
/// WTHamsterRimeSessionProtocol boundary.
final class WTLibrimeRimeSession: WTHamsterRimeSessionProtocol {
    private static let appGroupID = "group.7518554"

    /// Rime only deploys schemas listed by `default.yaml` plus the user's `default.custom.yaml`.
    /// The public rime-prelude default does not list CLAW's custom T9/full-pinyin schemas, so the
    /// Release keyboard must stage this deterministic overlay before librime initializes.
    private static let phase3DefaultCustomYAML = """
    patch:
      schema_list:
        - schema: claw_pinyin26
        - schema: claw_pinyin9
        - schema: double_pinyin
        - schema: wubi86
        - schema: stroke
        - schema: pinyin_simp
    """

    private let bridge: WTLibrimeBridge
    private var logicalMode: WTInputMode = .chinesePinyin9
    private var snapshotStorage: WTLibrimeContextSnapshot

    init() {
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
        let normalized = normalizedInput(input)
        let consumed = bridge.processText(normalized)
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

        if let schemaID = descriptor.schemaID, !schemaID.isEmpty {
            let selected = bridge.selectSchema(schemaID)
            if !selected {
                // Keep 26-key/English usable even if a custom schema deployment is damaged.
                // T9 intentionally has no Latin fallback because silently accepting digits would
                // hide a broken Phase 3 deployment instead of producing Chinese candidates.
                for fallback in Self.fallbackSchemaIDs(for: mode) {
                    if bridge.selectSchema(fallback) { break }
                }
            }
        }
        for (option, value) in descriptor.options {
            bridge.setOption(option, value: value)
        }
        for (property, value) in descriptor.properties {
            bridge.setProperty(property, value: value)
        }
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
