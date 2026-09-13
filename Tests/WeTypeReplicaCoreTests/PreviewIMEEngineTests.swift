import XCTest
@testable import WeTypeReplicaCore

final class PreviewIMEEngineTests: XCTestCase {
    func testPreviewEngineSupportsCompositionCandidateDeleteAndCommit() {
        let engine = WTPreviewIMEEngine()
        XCTAssertTrue(engine.process("ni"))
        XCTAssertEqual(engine.context.composition, "ni")
        XCTAssertTrue(engine.context.isComposing)
        XCTAssertEqual(engine.context.candidates.first?.text, "你")
        engine.deleteBackward()
        XCTAssertEqual(engine.context.composition, "n")
        _ = engine.process("i")
        XCTAssertEqual(engine.selectCandidate(at: 0), "你")
        XCTAssertFalse(engine.context.isComposing)
    }

    func testPreviewEngineRejectsFunctionSymbols() {
        let engine = WTPreviewIMEEngine()
        XCTAssertFalse(engine.process("。"))
        XCTAssertTrue(engine.context.candidates.isEmpty)
    }
}
