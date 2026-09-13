import Foundation

public struct WTCandidate: Codable, Hashable, Sendable {
    public let text: String
    public let comment: String?
    public init(text: String, comment: String? = nil) {
        self.text = text
        self.comment = comment
    }
}


public enum WTCandidatePageDirection: String, Codable, Sendable {
    case previous
    case next
}

public struct WTCandidatePageState: Codable, Equatable, Sendable {
    public var currentPage: Int
    public var pageSize: Int
    public var hasPrevious: Bool
    public var hasNext: Bool

    public init(currentPage: Int = 0, pageSize: Int = 0, hasPrevious: Bool = false, hasNext: Bool = false) {
        self.currentPage = max(0, currentPage)
        self.pageSize = max(0, pageSize)
        self.hasPrevious = hasPrevious
        self.hasNext = hasNext
    }

    public static let singlePage = WTCandidatePageState()
}

public struct WTIMEContext: Codable, Equatable, Sendable {
    public var composition: String
    public var candidates: [WTCandidate]
    public var isComposing: Bool
    public var candidatePage: WTCandidatePageState

    public init(
        composition: String = "",
        candidates: [WTCandidate] = [],
        isComposing: Bool = false,
        candidatePage: WTCandidatePageState = .singlePage
    ) {
        self.composition = composition
        self.candidates = candidates
        self.isComposing = isComposing
        self.candidatePage = candidatePage
    }
}

/// Adapter boundary between the replica UI and the actual input engine.
/// Hamster/librime should implement this protocol without changing the UI layer.
public protocol WTIMEEngine: AnyObject {
    var context: WTIMEContext { get }
    @discardableResult func process(_ input: String) -> Bool
    /// Drain text committed asynchronously/by the engine as a consequence of processing a key.
    /// librime exposes this separately through get_commit(), so frontends must consume it after
    /// process/delete/mode actions or committed text can silently disappear.
    func drainCommit() -> String?
    /// Synchronize the logical keyboard mode/schema with the backend.
    func setInputMode(_ mode: WTInputMode)
    /// Move the backend candidate menu without changing composition.
    @discardableResult func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool
    func selectCandidate(at index: Int) -> String?
    func deleteBackward()
    func reset()
}

public extension WTIMEEngine {
    func drainCommit() -> String? { nil }
    func setInputMode(_ mode: WTInputMode) { reset() }
    @discardableResult func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool { false }
}

/// Closure adapter so the overlay can be wired to Hamster without hard-coding
/// a particular Hamster/librime API version into this package.
public final class WTClosureIMEEngine: WTIMEEngine {
    private let contextProvider: () -> WTIMEContext
    private let processHandler: (String) -> Bool
    private let commitHandler: () -> String?
    private let modeHandler: (WTInputMode) -> Void
    private let pageHandler: (WTCandidatePageDirection) -> Bool
    private let selectHandler: (Int) -> String?
    private let deleteHandler: () -> Void
    private let resetHandler: () -> Void

    public init(
        context: @escaping () -> WTIMEContext,
        process: @escaping (String) -> Bool,
        drainCommit: @escaping () -> String? = { nil },
        setInputMode: @escaping (WTInputMode) -> Void = { _ in },
        moveCandidatePage: @escaping (WTCandidatePageDirection) -> Bool = { _ in false },
        selectCandidate: @escaping (Int) -> String?,
        deleteBackward: @escaping () -> Void,
        reset: @escaping () -> Void
    ) {
        self.contextProvider = context
        self.processHandler = process
        self.commitHandler = drainCommit
        self.modeHandler = setInputMode
        self.pageHandler = moveCandidatePage
        self.selectHandler = selectCandidate
        self.deleteHandler = deleteBackward
        self.resetHandler = reset
    }

    public var context: WTIMEContext { contextProvider() }
    @discardableResult public func process(_ input: String) -> Bool { processHandler(input) }
    public func drainCommit() -> String? { commitHandler() }
    public func setInputMode(_ mode: WTInputMode) { modeHandler(mode) }
    @discardableResult public func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool { pageHandler(direction) }
    public func selectCandidate(at index: Int) -> String? { selectHandler(index) }
    public func deleteBackward() { deleteHandler() }
    public func reset() { resetHandler() }
}

public protocol WTDocumentSink: AnyObject {
    func insertText(_ text: String)
    func deleteBackward()
    func insertReturn()
}

public final class WTClosureDocumentSink: WTDocumentSink {
    private let insertHandler: (String) -> Void
    private let deleteHandler: () -> Void
    private let returnHandler: () -> Void

    public init(insertText: @escaping (String) -> Void, deleteBackward: @escaping () -> Void, insertReturn: @escaping () -> Void) {
        self.insertHandler = insertText
        self.deleteHandler = deleteBackward
        self.returnHandler = insertReturn
    }

    public func insertText(_ text: String) { insertHandler(text) }
    public func deleteBackward() { deleteHandler() }
    public func insertReturn() { returnHandler() }
}

public final class WTKeyboardCoordinator {
    public private(set) var state: WTKeyboardState
    public let engine: WTIMEEngine
    public weak var document: WTDocumentSink?

    public init(state: WTKeyboardState = .init(), engine: WTIMEEngine, document: WTDocumentSink? = nil) {
        self.state = state
        self.engine = engine
        self.document = document
    }

    public func processCharacter(_ value: String) {
        if !engine.process(value) {
            document?.insertText(value)
        } else if let committed = engine.drainCommit(), !committed.isEmpty {
            document?.insertText(committed)
        }
        state.consumeOneShotShiftIfNeeded()
    }

    /// Direct symbol/gesture text first resolves active composition instead of silently dropping it.
    public func commitDirectText(_ value: String) {
        if engine.context.isComposing {
            if let first = engine.selectCandidate(at: 0), !first.isEmpty { document?.insertText(first) }
            else { engine.reset() }
        }
        document?.insertText(value)
        state.consumeOneShotShiftIfNeeded()
    }

    /// Mobile Chinese IMEs use space to accept the first candidate while composing; only an idle
    /// space key inserts a literal space.
    public func spaceKey() {
        guard engine.context.isComposing else { document?.insertText(" "); return }
        if engine.process(" ") {
            if let committed = engine.drainCommit(), !committed.isEmpty { document?.insertText(committed) }
            return
        }
        if let first = engine.selectCandidate(at: 0) { document?.insertText(first) }
    }

    @discardableResult
    public func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        engine.moveCandidatePage(direction)
    }

    public func chooseCandidate(_ index: Int) {
        if let committed = engine.selectCandidate(at: index) {
            document?.insertText(committed)
        }
    }

    public func deleteBackward() {
        if engine.context.isComposing {
            engine.deleteBackward()
            if let committed = engine.drainCommit(), !committed.isEmpty { document?.insertText(committed) }
        } else {
            document?.deleteBackward()
        }
    }

    public func returnKey() {
        if engine.context.isComposing, let first = engine.selectCandidate(at: 0) {
            document?.insertText(first)
        } else {
            document?.insertReturn()
        }
    }

    public func present(_ panel: WTPanel) { state.present(panel) }
    public func back() { state.back() }
    public func switchMode(_ mode: WTInputMode) {
        state.switchInputMode(to: mode)
        engine.setInputMode(mode)
    }
    public func toggleLanguage() {
        state.toggleLanguage()
        engine.setInputMode(state.inputMode)
    }
    public func cycleShift() { state.cycleShift() }
}

/// A deterministic, tiny engine used only for local/CI visual and interaction smoke tests.
/// It is not a production Chinese IME and is never intended to replace Hamster/librime.
public final class WTPreviewIMEEngine: WTIMEEngine {
    private var compositionStorage = ""
    private var candidatesStorage: [WTCandidate] = []

    public init() {}

    public var context: WTIMEContext {
        .init(
            composition: compositionStorage,
            candidates: candidatesStorage,
            isComposing: !compositionStorage.isEmpty
        )
    }

    @discardableResult public func process(_ input: String) -> Bool {
        guard !input.isEmpty else { return false }
        let accepted = input.allSatisfy { $0.isLetter || $0.isNumber || $0 == "'" }
        guard accepted else { return false }
        compositionStorage.append(contentsOf: input.lowercased())
        rebuildCandidates()
        return true
    }

    public func selectCandidate(at index: Int) -> String? {
        guard candidatesStorage.indices.contains(index) else { return nil }
        let value = candidatesStorage[index].text
        reset()
        return value
    }

    public func deleteBackward() {
        guard !compositionStorage.isEmpty else { return }
        compositionStorage.removeLast()
        rebuildCandidates()
    }

    public func reset() {
        compositionStorage = ""
        candidatesStorage = []
    }

    private func rebuildCandidates() {
        guard !compositionStorage.isEmpty else { candidatesStorage = []; return }
        let raw = compositionStorage
        var values: [String] = [raw, raw.capitalized, raw.uppercased()]
        if let mapped = Self.smokeLexicon[raw] { values.insert(contentsOf: mapped, at: 0) }
        var seen = Set<String>()
        candidatesStorage = values.compactMap { value in
            guard seen.insert(value).inserted else { return nil }
            return WTCandidate(text: value, comment: "preview")
        }
    }

    private static let smokeLexicon: [String: [String]] = [
        "ni": ["你", "呢"],
        "hao": ["好", "号"],
        "nihao": ["你好"],
        "wo": ["我"],
        "shi": ["是", "时"],
        "weixin": ["微信"]
    ]
}
