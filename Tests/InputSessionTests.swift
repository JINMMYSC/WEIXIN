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

    func testInvalidCandidateStateIsRejectedByValidation() {
        let session = InputSession()
        _ = session.replaceCandidates([
            InputCandidate(id: -1, text: "坏")
        ])
        XCTAssertFalse(session.validate())
        XCTAssertFalse(InputSnapshot(
            committedText: "",
            composingText: "",
            candidates: [InputCandidate(id: 1, text: "")]
        ).isValid)
    }

    func testSerializedInvalidSnapshotCannotBeRestored() throws {
        let invalid = InputSnapshot(
            committedText: "",
            composingText: "",
            candidates: [InputCandidate(id: -1, text: "坏")]
        )
        let data = try JSONEncoder().encode(invalid)
        XCTAssertThrowsError(try InputSession().restore(serialized: data)) { error in
            XCTAssertEqual(error as? InputSession.RestoreError, .invalidSnapshot)
        }
    }

    func testReplayProducesDeterministicSnapshots() {
        let replay = InputReplay([
            .insert("ni"), .insert("hao"), .deleteBackward, .commitPending, .reset
        ])
        let first = replay.run()
        let second = replay.run()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.last, InputSnapshot(committedText: "", composingText: "", candidates: []))
        XCTAssertEqual(first[2].composingText, "niha")
        XCTAssertEqual(first[3].committedText, "niha")
    }

    func testInputReplayEventsRoundTripAsJSON() throws {
        let events: [InputEvent] = [.insert("ni"), .deleteBackward, .commitPending, .reset]
        let data = try JSONEncoder().encode(events)
        XCTAssertEqual(try JSONDecoder().decode([InputEvent].self, from: data), events)

        let replay = InputReplay(events)
        XCTAssertEqual(try InputReplay(data: replay.encoded()), replay)
    }
}
