import Foundation

public struct WTCandidate: Codable, Hashable, Sendable {
    public let text: String
    public let comment: String?
    public init(text: String, comment: String? = nil) {
        self.text = text
        self.comment = comment
    }
}

public struct WTIMECompositionState: Codable, Equatable, Sendable {
    public var length: Int
    public var cursorPosition: Int
    public var selectionStart: Int
    public var selectionEnd: Int

    public init(length: Int = 0, cursorPosition: Int = 0, selectionStart: Int = 0, selectionEnd: Int = 0) {
        self.length = max(0, length)
        self.cursorPosition = max(0, cursorPosition)
        self.selectionStart = max(0, selectionStart)
        self.selectionEnd = max(0, selectionEnd)
    }

    public var hasSelection: Bool { selectionEnd > selectionStart }
    public static let empty = WTIMECompositionState()
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
    public var compositionState: WTIMECompositionState
    public var candidates: [WTCandidate]
    public var isComposing: Bool
    public var candidatePage: WTCandidatePageState

    public init(
        composition: String = "",
        compositionState: WTIMECompositionState = .empty,
        candidates: [WTCandidate] = [],
        isComposing: Bool = false,
        candidatePage: WTCandidatePageState = .singlePage
    ) {
        self.composition = composition
        self.compositionState = compositionState
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

    public func returnKey() {
        if engine.context.isComposing {
            if let first = engine.selectCandidate(at: 0), !first.isEmpty { document?.insertText(first) }
            else { engine.reset() }
        } else {
            document?.insertReturn()
        }
    }

    public func deleteBackward() {
        if engine.context.isComposing { engine.deleteBackward() }
        else { document?.deleteBackward() }
    }

    public func selectCandidate(at index: Int) {
        if let committed = engine.selectCandidate(at: index), !committed.isEmpty {
            document?.insertText(committed)
        }
    }

    public func reset() { engine.reset() }
}
