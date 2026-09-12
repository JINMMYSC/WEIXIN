import XCTest
@testable import WeixinRebuild

final class KeyboardSessionBridgeTests: XCTestCase {
    func testCommitProducesOneHostCommitAction() {
        let bridge = KeyboardSessionBridge()
        _ = bridge.handle(.insert("nihao"))
        let output = bridge.handle(.commitPending)
        XCTAssertEqual(output.committedText, "nihao")
        XCTAssertEqual(output.snapshot.composingText, "")
    }

    func testEmptyCommitDoesNotSendTextToHost() {
        XCTAssertNil(KeyboardSessionBridge().handle(.commitPending).committedText)
    }

    func testCandidateSelectionProducesHostCommitAction() {
        let bridge = KeyboardSessionBridge()
        _ = bridge.handle(.insert("ni"))
        let output = bridge.selectCandidate(InputCandidate(id: 0, text: "你"))
        XCTAssertEqual(output.committedText, "你")
        XCTAssertEqual(output.snapshot.composingText, "")
    }

    func testEngineCandidatesArePublishedAfterInput() {
        let bridge = KeyboardSessionBridge(engine: TablePinyinEngine(table: ["ni": ["你", "尼"]]))
        let output = bridge.handle(.insert("NI"))
        XCTAssertEqual(output.snapshot.candidates.map(\.text), ["你", "尼"])
    }

    func testCandidateSelectionRecordsLearningEvent() {
        let learning = InMemoryCandidateLearningStore()
        let candidate = InputCandidate(id: 0, text: "你")
        let bridge = KeyboardSessionBridge(learning: learning)
        _ = bridge.selectCandidate(candidate)
        XCTAssertEqual(learning.selectionCount(for: "你"), 1)
    }

    func testLateAsyncCandidateUpdateCannotOverwriteNewerInput() {
        let bridge = KeyboardSessionBridge()
        _ = bridge.handle(.insert("n"))
        XCTAssertTrue(bridge.applyCandidateUpdate(CandidateUpdate(
            version: 4, requestID: 10,
            candidates: [InputCandidate(id: 0, text: "你")]
        )))
        XCTAssertFalse(bridge.applyCandidateUpdate(CandidateUpdate(
            version: 3, requestID: 99,
            candidates: [InputCandidate(id: 0, text: "旧")]
        )))
        XCTAssertEqual(bridge.handle(.insert("i")).snapshot.composingText, "ni")
    }

    func testCommitFirstCandidateClearsComposition() {
        let bridge = KeyboardSessionBridge(engine: TablePinyinEngine(table: ["ni": ["你"]]))
        _ = bridge.handle(.insert("ni"))
        let output = bridge.commitFirstCandidate()
        XCTAssertEqual(output?.committedText, "你")
        XCTAssertEqual(output?.snapshot.composingText, "")
        XCTAssertNil(KeyboardSessionBridge().commitFirstCandidate())
    }
}
