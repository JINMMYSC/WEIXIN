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
}
