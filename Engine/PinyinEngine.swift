import Foundation

protocol PinyinEngine {
    func candidates(for composingText: String) -> [InputCandidate]
}

struct EmptyPinyinEngine: PinyinEngine {
    func candidates(for composingText: String) -> [InputCandidate] { [] }
}

/// A small, deterministic adapter used until the recovered dictionaries are
/// wired in. Keeping the lookup table injected makes the session testable and
/// avoids pretending that these values reproduce the original engine.
struct TablePinyinEngine: PinyinEngine {
    private let table: [String: [String]]

    init(table: [String: [String]]) {
        self.table = table
    }

    func candidates(for composingText: String) -> [InputCandidate] {
        let key = PinyinNormalizer().normalize(composingText)
        return (table[key] ?? []).enumerated().map {
            InputCandidate(id: $0.offset, text: $0.element)
        }
    }
}

/// Adapter used to validate the full score-to-candidate path before the
/// recovered language model is wired in.
struct WeightedPinyinEngine: PinyinEngine {
    private let table: [String: [ScoredCandidate]]
    private let ranker: CandidateRanker

    init(table: [String: [ScoredCandidate]], ranker: CandidateRanker = CandidateRanker()) {
        self.table = table
        self.ranker = ranker
    }

    func candidates(for composingText: String) -> [InputCandidate] {
        let key = PinyinNormalizer().normalize(composingText)
        return ranker.rank(table[key] ?? [])
    }
}
