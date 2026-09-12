import XCTest
@testable import WeixinRebuild

final class CandidateRankingTests: XCTestCase {
    func testRanksByScoreWithStableTiesAndDeduplicatesText() {
        let ranker = CandidateRanker()
        let result = ranker.rank([
            ScoredCandidate(candidate: InputCandidate(id: 1, text: "甲"), score: 1),
            ScoredCandidate(candidate: InputCandidate(id: 2, text: "乙"), score: 3),
            ScoredCandidate(candidate: InputCandidate(id: 3, text: "甲"), score: 2),
            ScoredCandidate(candidate: InputCandidate(id: 4, text: "丙"), score: 3)
        ])
        XCTAssertEqual(result.map(\.text), ["乙", "丙", "甲"])
        XCTAssertEqual(result.map(\.id), [2, 4, 3])
    }

    func testEmptyInputProducesEmptyResult() {
        XCTAssertTrue(CandidateRanker().rank([]).isEmpty)
    }
}
