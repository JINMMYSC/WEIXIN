import XCTest
@testable import WeTypeReplicaCore

private final class MockEngine: WTIMEEngine {
    var buffer = ""
    var context: WTIMEContext {
        WTIMEContext(
            composition: buffer,
            candidates: buffer.isEmpty ? [] : [WTCandidate(text: "你"), WTCandidate(text: "呢")],
            isComposing: !buffer.isEmpty
        )
    }
    func process(_ input: String) -> Bool {
        guard input.count == 1, input.first?.isLetter == true else { return false }
        buffer += input
        return true
    }
    func selectCandidate(at index: Int) -> String? {
        guard !buffer.isEmpty, index < context.candidates.count else { return nil }
        defer { buffer = "" }
        return context.candidates[index].text
    }
    func deleteBackward() { if !buffer.isEmpty { buffer.removeLast() } }
    func reset() { buffer = "" }
}

private final class CommitOnProcessEngine: WTIMEEngine {
    var pending: String?
    var context = WTIMEContext()
    func process(_ input: String) -> Bool {
        guard input == "!" else { return false }
        pending = "！"
        return true
    }
    func drainCommit() -> String? { defer { pending = nil }; return pending }
    func selectCandidate(at index: Int) -> String? { nil }
    func deleteBackward() {}
    func reset() { pending = nil }
}

private final class SpaceCommitEngine: WTIMEEngine {
    var composing = true
    var pending: String?
    var context: WTIMEContext { .init(composition: composing ? "ni" : "", candidates: composing ? [.init(text: "你")] : [], isComposing: composing) }
    func process(_ input: String) -> Bool {
        guard input == " ", composing else { return false }
        composing = false; pending = "你"; return true
    }
    func drainCommit() -> String? { defer { pending = nil }; return pending }
    func selectCandidate(at index: Int) -> String? { nil }
    func deleteBackward() {}
    func reset() { composing = false; pending = nil }
}

private final class ModeRecordingEngine: WTIMEEngine {
    var selectedMode: WTInputMode?
    var context = WTIMEContext()
    func process(_ input: String) -> Bool { false }
    func setInputMode(_ mode: WTInputMode) { selectedMode = mode }
    func selectCandidate(at index: Int) -> String? { nil }
    func deleteBackward() {}
    func reset() {}
}

private final class MockDocument: WTDocumentSink {
    var text = ""
    func insertText(_ text: String) { self.text += text }
    func deleteBackward() { if !text.isEmpty { text.removeLast() } }
    func insertReturn() { text += "\n" }
}

final class CoordinatorTests: XCTestCase {
    func testCompositionGoesToEngineAndCandidateCommitsToDocument() {
        let engine = MockEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.processCharacter("n"); sut.processCharacter("i")
        XCTAssertEqual(engine.context.composition, "ni")
        XCTAssertEqual(doc.text, "")
        sut.chooseCandidate(0)
        XCTAssertEqual(doc.text, "你")
        XCTAssertFalse(engine.context.isComposing)
    }

    func testProcessDrainsEngineCommitIntoDocument() {
        let engine = CommitOnProcessEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.processCharacter("!")
        XCTAssertEqual(doc.text, "！")
        XCTAssertNil(engine.pending)
    }

    func testSpaceAcceptsFirstCandidateWithoutAddingLiteralSpace() {
        let engine = MockEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.processCharacter("n")
        sut.spaceKey()
        XCTAssertEqual(doc.text, "你")
        XCTAssertFalse(engine.context.isComposing)
    }

    func testSpaceDrainsBackendCommitWhenRimeConsumesSpace() {
        let engine = SpaceCommitEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.spaceKey()
        XCTAssertEqual(doc.text, "你")
        XCTAssertNil(engine.pending)
    }

    func testDirectSymbolCommitsCompositionBeforeSymbol() {
        let engine = MockEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.processCharacter("n")
        sut.commitDirectText("。")
        XCTAssertEqual(doc.text, "你。")
        XCTAssertFalse(engine.context.isComposing)
    }

    func testSwitchModePropagatesToBackend() {
        let engine = ModeRecordingEngine(); let doc = MockDocument()
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.switchMode(.chinesePinyin9)
        XCTAssertEqual(engine.selectedMode, .chinesePinyin9)
    }

    func testDeletePrefersCompositionBeforeHostDocument() {
        let engine = MockEngine(); let doc = MockDocument(); doc.text = "A"
        let sut = WTKeyboardCoordinator(engine: engine, document: doc)
        sut.processCharacter("n")
        sut.deleteBackward()
        XCTAssertEqual(doc.text, "A")
        sut.deleteBackward()
        XCTAssertEqual(doc.text, "")
    }
}

private final class PagedMockEngine: WTIMEEngine {
    var page = 0
    var context: WTIMEContext {
        .init(
            composition: "ni",
            candidates: page == 0 ? [.init(text: "你"), .init(text: "呢")] : [.init(text: "泥"), .init(text: "拟")],
            isComposing: true,
            candidatePage: .init(currentPage: page, pageSize: 2, hasPrevious: page > 0, hasNext: page == 0)
        )
    }
    func process(_ input: String) -> Bool { true }
    func moveCandidatePage(_ direction: WTCandidatePageDirection) -> Bool {
        switch direction {
        case .next where page == 0: page = 1; return true
        case .previous where page == 1: page = 0; return true
        default: return false
        }
    }
    func selectCandidate(at index: Int) -> String? { context.candidates.indices.contains(index) ? context.candidates[index].text : nil }
    func deleteBackward() {}
    func reset() {}
}

extension CoordinatorTests {
    func testCandidatePagingMovesBackendWithoutDestroyingComposition() {
        let engine = PagedMockEngine()
        let sut = WTKeyboardCoordinator(engine: engine)
        XCTAssertTrue(sut.moveCandidatePage(.next))
        XCTAssertEqual(engine.context.candidatePage.currentPage, 1)
        XCTAssertEqual(engine.context.composition, "ni")
        XCTAssertEqual(engine.context.candidates.first?.text, "泥")
        XCTAssertTrue(sut.moveCandidatePage(.previous))
        XCTAssertEqual(engine.context.candidatePage.currentPage, 0)
    }

    func testCandidatePagingRejectsUnavailableDirection() {
        let engine = PagedMockEngine()
        let sut = WTKeyboardCoordinator(engine: engine)
        XCTAssertFalse(sut.moveCandidatePage(.previous))
        XCTAssertEqual(engine.context.candidatePage.currentPage, 0)
    }
}
