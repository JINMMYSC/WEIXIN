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

/// Small independently authored vocabulary that keeps the keyboard's complete
/// candidate path testable on a device. It is deliberately separate from the
/// recovered resources and does not claim to reproduce their contents.
struct BootstrapPinyinEngine: PinyinEngine {
    let weighted: WeightedPinyinEngine

    init() {
        weighted = WeightedPinyinEngine(table: Self.table)
    }

    func candidates(for composingText: String) -> [InputCandidate] {
        weighted.candidates(for: composingText)
    }

    private static let table: [String: [ScoredCandidate]] = [
        "ni": scored(["你", "呢", "泥", "拟", "尼"]),
        "hao": scored(["好", "号", "浩", "豪", "毫"]),
        "nihao": scored(["你好"]),
        "wo": scored(["我", "握", "窝", "卧"]),
        "women": scored(["我们"]),
        "shi": scored(["是", "时", "事", "十", "市", "使"]),
        "de": scored(["的", "得", "地"]),
        "zhongguo": scored(["中国"]),
        "weixin": scored(["微信"]),
        "zaijian": scored(["再见"]),
        "xiexie": scored(["谢谢"]),
        "jintian": scored(["今天"]),
        "keyi": scored(["可以"])
    ]

    private static func scored(_ texts: [String]) -> [ScoredCandidate] {
        texts.enumerated().map { index, text in
            ScoredCandidate(
                candidate: InputCandidate(id: index, text: text),
                score: Double(texts.count - index)
            )
        }
    }
}
