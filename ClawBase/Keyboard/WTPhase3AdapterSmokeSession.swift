import Foundation

/// Phase 3 compile/runtime smoke session.
///
/// This deliberately exercises `WTHamsterRimeSessionAdapter` without claiming that the
/// production librime binary is linked yet. The public Hamster/RimeKit integration will
/// replace this session behind the same protocol, so the keyboard UI and controller do not
/// need to change again when the real engine arrives.
final class WTPhase3AdapterSmokeSession: WTHamsterRimeSessionProtocol {
    private var logicalMode: WTInputMode = .chinesePinyin9
    private var compositionStorage = ""
    private var candidateStorage: [WTCandidate] = []

    var wtComposition: String { compositionStorage }
    var wtCandidates: [WTCandidate] { candidateStorage }
    var wtIsComposing: Bool { !compositionStorage.isEmpty }
    var wtCandidatePageState: WTCandidatePageState { .singlePage }

    @discardableResult
    func wtProcess(_ input: String) -> Bool {
        guard !input.isEmpty else { return false }

        // English mode intentionally falls through to the document proxy. The production
        // Rime bridge will use ascii_mode instead.
        if logicalMode == .english26 { return false }

        let token: String
        if logicalMode == .chinesePinyin9 {
            guard let digit = Self.t9GroupToDigit[input.uppercased()] else { return false }
            token = digit
        } else {
            guard input.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "'" }) else { return false }
            token = input.lowercased()
        }

        compositionStorage.append(contentsOf: token)
        rebuildCandidates()
        return true
    }

    func wtDrainCommit() -> String? { nil }

    func wtSetInputMode(_ mode: WTInputMode) {
        logicalMode = mode
        wtReset()
    }

    func wtApplyModeDescriptor(_ descriptor: WTRimeModeDescriptor, logicalMode mode: WTInputMode) {
        // The smoke session validates the adapter contract only. Schema IDs/options are applied
        // by the concrete RimeKit session in the production Phase 3 integration.
        wtSetInputMode(mode)
    }

    @discardableResult
    func wtMoveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool { false }

    func wtSelectCandidate(at index: Int) -> String? {
        guard candidateStorage.indices.contains(index) else { return nil }
        let text = candidateStorage[index].text
        wtReset()
        return text
    }

    func wtDeleteBackward() {
        guard !compositionStorage.isEmpty else { return }
        compositionStorage.removeLast()
        rebuildCandidates()
    }

    func wtReset() {
        compositionStorage = ""
        candidateStorage = []
    }

    private func rebuildCandidates() {
        guard !compositionStorage.isEmpty else {
            candidateStorage = []
            return
        }

        var values = Self.smokeLexicon[compositionStorage] ?? []
        values.append(compositionStorage)
        var seen = Set<String>()
        candidateStorage = values.compactMap { value in
            guard seen.insert(value).inserted else { return nil }
            return WTCandidate(text: value, comment: "phase3-smoke")
        }
    }

    static func selfTest() -> Bool {
        let session = WTPhase3AdapterSmokeSession()
        let engine = WTHamsterRimeSessionAdapter(session: session)

        engine.setInputMode(.chinesePinyin9)
        for token in ["MNO", "GHI", "GHI", "ABC", "MNO"] {
            guard engine.process(token) else { return false }
        }
        guard engine.context.composition == "64426",
              engine.context.candidates.first?.text == "你好",
              engine.selectCandidate(at: 0) == "你好",
              !engine.context.isComposing else { return false }

        engine.setInputMode(.chinesePinyin26)
        for token in ["n", "i", "h", "a", "o"] {
            guard engine.process(token) else { return false }
        }
        return engine.context.composition == "nihao" && engine.context.candidates.first?.text == "你好"
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

    private static let smokeLexicon: [String: [String]] = [
        "ni": ["你", "呢"],
        "hao": ["好", "号"],
        "nihao": ["你好"],
        "wo": ["我"],
        "shi": ["是", "时"],
        "weixin": ["微信"],
        "64": ["你", "呢"],
        "426": ["好", "号"],
        "64426": ["你好"],
        "96": ["我"],
        "744": ["是", "时"],
        "934946": ["微信"]
    ]
}
