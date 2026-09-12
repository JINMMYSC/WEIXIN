import XCTest
@testable import WeixinRebuild

final class PinyinEngineTests: XCTestCase {
    func testTableEngineNormalizesLookupKeyAndAssignsStableIDs() {
        let engine = TablePinyinEngine(table: ["ni": ["你", "尼"]])
        XCTAssertEqual(engine.candidates(for: "NI "), [
            InputCandidate(id: 0, text: "你"),
            InputCandidate(id: 1, text: "尼")
        ])
    }

    func testUnknownInputHasNoCandidates() {
        XCTAssertTrue(TablePinyinEngine(table: ["ni": ["你"]]).candidates(for: "hao").isEmpty)
    }
}
