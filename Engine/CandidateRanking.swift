import Foundation

struct ScoredCandidate: Equatable {
    let candidate: InputCandidate
    let score: Double
}

/// Deterministic ranking seam for recovered language-model scores.
/// Ties retain source order and duplicate text is emitted only once.
struct CandidateRanker {
    func rank(_ candidates: [ScoredCandidate]) -> [InputCandidate] {
        var seen = Set<String>()
        return candidates.enumerated()
            .sorted { left, right in
                if left.element.score != right.element.score {
                    return left.element.score > right.element.score
                }
                return left.offset < right.offset
            }
            .compactMap { item in
                seen.insert(item.element.candidate.text).inserted ? item.element.candidate : nil
            }
    }
}
