import XCTest
@testable import WeixinRebuild

final class CandidateLearningTests: XCTestCase {
    func testSelectionCountMovesLearnedCandidateFirst() {
        let store = InMemoryCandidateLearningStore()
        let you = InputCandidate(id: 0, text: "你")
        let ni = InputCandidate(id: 1, text: "尼")
        let base = WeightedPinyinEngine(table: ["ni": [
            ScoredCandidate(candidate: you, score: 10),
            ScoredCandidate(candidate: ni, score: 20)
        ]])
        store.recordSelection(you)
        store.recordSelection(you)
        let engine = LearningAwarePinyinEngine(base: base, learning: store)
        XCTAssertEqual(engine.candidates(for: "ni").map(\.text), ["你", "尼"])
        store.reset()
        XCTAssertEqual(store.selectionCount(for: "你"), 0)
    }

    func testEmptyCandidateIsNotLearned() {
        let store = InMemoryCandidateLearningStore()
        store.recordSelection(InputCandidate(id: 0, text: ""))
        XCTAssertEqual(store.selectionCount(for: ""), 0)
    }
}
