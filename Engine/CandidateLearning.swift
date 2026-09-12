import Foundation

protocol CandidateLearningStore: AnyObject {
    func recordSelection(_ candidate: InputCandidate)
    func selectionCount(for text: String) -> Int
    func reset()
}

protocol SnapshottingCandidateLearningStore: CandidateLearningStore {
    func snapshot() -> CandidateLearningSnapshot
    @discardableResult func restore(_ snapshot: CandidateLearningSnapshot) -> Bool
}

struct CandidateLearningSnapshot: Codable, Equatable {
    let counts: [String: Int]
}

/// Small deterministic offline store. The weighting is intentionally exposed
/// as a seam; it is not a claim about the original app's learning algorithm.
final class InMemoryCandidateLearningStore: SnapshottingCandidateLearningStore {
    private var counts: [String: Int] = [:]

    func recordSelection(_ candidate: InputCandidate) {
        guard !candidate.text.isEmpty else { return }
        counts[candidate.text, default: 0] += 1
    }

    func selectionCount(for text: String) -> Int { counts[text, default: 0] }

    func reset() { counts.removeAll(keepingCapacity: true) }

    func snapshot() -> CandidateLearningSnapshot {
        CandidateLearningSnapshot(counts: counts)
    }

    @discardableResult
    func restore(_ snapshot: CandidateLearningSnapshot) -> Bool {
        guard snapshot.counts.allSatisfy({ !$0.key.isEmpty && $0.value >= 0 }) else { return false }
        counts = snapshot.counts
        return true
    }

    func serializedSnapshot() throws -> Data {
        try JSONEncoder().encode(snapshot())
    }

    func restore(serialized data: Data) throws {
        let decoded = try JSONDecoder().decode(CandidateLearningSnapshot.self, from: data)
        guard restore(decoded) else { throw RestoreError.invalidSnapshot }
    }

    enum RestoreError: Error, Equatable { case invalidSnapshot }
}

struct LearningAwarePinyinEngine: PinyinEngine {
    private let base: WeightedPinyinEngine
    private let learning: CandidateLearningStore

    init(base: WeightedPinyinEngine, learning: CandidateLearningStore) {
        self.base = base
        self.learning = learning
    }

    func candidates(for composingText: String) -> [InputCandidate] {
        let baseCandidates = base.candidates(for: composingText)
        return baseCandidates.enumerated().sorted { left, right in
            let leftCount = learning.selectionCount(for: left.element.text)
            let rightCount = learning.selectionCount(for: right.element.text)
            if leftCount != rightCount { return leftCount > rightCount }
            return left.offset < right.offset
        }.map(\.element)
    }
}
