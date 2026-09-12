import Foundation

protocol CandidateLearningStore: AnyObject {
    func recordSelection(_ candidate: InputCandidate)
    func selectionCount(for text: String) -> Int
    func reset()
}

/// Small deterministic offline store. The weighting is intentionally exposed
/// as a seam; it is not a claim about the original app's learning algorithm.
final class InMemoryCandidateLearningStore: CandidateLearningStore {
    private var counts: [String: Int] = [:]

    func recordSelection(_ candidate: InputCandidate) {
        guard !candidate.text.isEmpty else { return }
        counts[candidate.text, default: 0] += 1
    }

    func selectionCount(for text: String) -> Int { counts[text, default: 0] }

    func reset() { counts.removeAll(keepingCapacity: true) }
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
        return baseCandidates.sorted {
            let left = learning.selectionCount(for: $0.text)
            let right = learning.selectionCount(for: $1.text)
            return left == right ? $0.id < $1.id : left > right
        }
    }
}
