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

    func testWeightedEngineNormalizesAndRanksCandidates() {
        let engine = WeightedPinyinEngine(table: [
            "ni": [
                ScoredCandidate(candidate: InputCandidate(id: 1, text: "你"), score: 1),
                ScoredCandidate(candidate: InputCandidate(id: 2, text: "尼"), score: 4)
            ]
        ])
        XCTAssertEqual(engine.candidates(for: "N-I").map(\.text), ["尼", "你"])
    }

    func testBootstrapEngineProvidesAuditableOfflineCandidates() {
        let engine = BootstrapPinyinEngine()
        XCTAssertEqual(engine.candidates(for: "NIHAO").map(\.text), ["你好"])
        XCTAssertEqual(engine.candidates(for: "wei-xin").map(\.text), ["微信"])
        XCTAssertTrue(engine.candidates(for: "not-in-bootstrap-table").isEmpty)
    }
}
