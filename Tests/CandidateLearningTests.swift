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

    func testLearningSnapshotRoundTripsAndRejectsInvalidCounts() throws {
        let source = InMemoryCandidateLearningStore()
        source.recordSelection(InputCandidate(id: 0, text: "你"))
        let data = try source.serializedSnapshot()
        let restored = InMemoryCandidateLearningStore()
        try restored.restore(serialized: data)
        XCTAssertEqual(restored.selectionCount(for: "你"), 1)

        let invalid = CandidateLearningSnapshot(counts: ["你": -1])
        XCTAssertFalse(restored.restore(invalid))
    }

    func testEqualLearningCountsKeepBaseOrder() {
        let store = InMemoryCandidateLearningStore()
        let base = WeightedPinyinEngine(table: ["x": [
            ScoredCandidate(candidate: InputCandidate(id: 20, text: "甲"), score: 1),
            ScoredCandidate(candidate: InputCandidate(id: 10, text: "乙"), score: 2)
        ]])
        let engine = LearningAwarePinyinEngine(base: base, learning: store)
        XCTAssertEqual(engine.candidates(for: "x").map(\.text), ["乙", "甲"])
    }
}
