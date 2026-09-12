import XCTest
@testable import WeixinRebuild

final class InputSessionTests: XCTestCase {
    func testInsertAndDeleteOnlyChangeComposingText() {
        let session = InputSession()
        XCTAssertEqual(session.process(.insert("ni")).composingText, "ni")
        XCTAssertEqual(session.process(.deleteBackward), InputSnapshot(committedText: "", composingText: "n", candidates: []))
    }

    func testCommitPendingMovesCompositionToCommittedText() {
        let session = InputSession()
        _ = session.process(.insert("nihao"))
        XCTAssertEqual(session.process(.commitPending), InputSnapshot(committedText: "nihao", composingText: "", candidates: []))
    }

    func testDeleteOnEmptyCompositionDoesNotDeleteCommittedText() {
        let session = InputSession()
        _ = session.process(.insert("a"))
        _ = session.process(.commitPending)
        XCTAssertEqual(session.process(.deleteBackward).committedText, "a")
    }

    func testSelectingCandidateCommitsCandidateAndClearsComposition() {
        let session = InputSession()
        _ = session.process(.insert("ni"))
        let snapshot = session.commitCandidate("你")
        XCTAssertEqual(snapshot, InputSnapshot(committedText: "你", composingText: "", candidates: []))
    }

    func testSnapshotCanBeSerializedAndRestored() throws {
        let source = InputSession()
        _ = source.process(.insert("ni"))
        let data = try source.serializedSnapshot()
        let restored = InputSession()
        try restored.restore(serialized: data)
        XCTAssertEqual(restored.snapshot, source.snapshot)
    }

    func testFreshSessionIsValid() {
        XCTAssertTrue(InputSession().validate())
    }
}
