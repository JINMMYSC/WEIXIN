import Foundation

/// A black-box probe used to compare the replica's librime-backed behavior against a captured
/// WeType 3.5.3 run. It intentionally records observable behavior only; it does not depend on
/// Tencent's private implementation details.
public struct WTIMEBehaviorProbe: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var category: String
    public var keys: [String]
    public var candidateLimit: Int
    /// Explicit keyboard/schema mode used by the device runner. Nil means the default 26-key pinyin mode.
    public var inputMode: String?
    /// Repeat the same sequence to observe learning/personalization.
    public var repeatCount: Int?
    /// Optional candidate index to commit after each replay.
    public var selectCandidateIndex: Int?
    public var notes: String?

    public init(
        id: String,
        category: String,
        keys: [String],
        candidateLimit: Int = 10,
        inputMode: String? = nil,
        repeatCount: Int? = nil,
        selectCandidateIndex: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.category = category
        self.keys = keys
        self.candidateLimit = max(1, min(candidateLimit, 50))
        self.inputMode = inputMode
        self.repeatCount = repeatCount.map { max(1, min($0, 20)) }
        self.selectCandidateIndex = selectCandidateIndex.map { max(0, $0) }
        self.notes = notes
    }
}

/// Observable result after replaying one probe on an IME implementation.
public struct WTIMEBehaviorSnapshot: Codable, Equatable, Sendable, Identifiable {
    public var id: String { probeID }
    public var probeID: String
    public var composition: String
    public var candidates: [String]
    public var selectedCandidateIndex: Int?
    public var committedText: String?
    public var isComposing: Bool

    public init(
        probeID: String,
        composition: String,
        candidates: [String],
        selectedCandidateIndex: Int? = nil,
        committedText: String? = nil,
        isComposing: Bool
    ) {
        self.probeID = probeID
        self.composition = composition
        self.candidates = candidates
        self.selectedCandidateIndex = selectedCandidateIndex
        self.committedText = committedText
        self.isComposing = isComposing
    }
}

public struct WTIMEBehaviorCorpus: Codable, Equatable, Sendable {
    public var formatVersion: Int
    public var source: String
    public var probes: [WTIMEBehaviorProbe]

    public init(formatVersion: Int = 1, source: String, probes: [WTIMEBehaviorProbe]) {
        self.formatVersion = formatVersion
        self.source = source
        self.probes = probes
    }
}

public struct WTIMEBehaviorCapture: Codable, Equatable, Sendable {
    public var formatVersion: Int
    public var implementation: String
    public var snapshots: [WTIMEBehaviorSnapshot]

    public init(formatVersion: Int = 1, implementation: String, snapshots: [WTIMEBehaviorSnapshot]) {
        self.formatVersion = formatVersion
        self.implementation = implementation
        self.snapshots = snapshots
    }
}

public struct WTIMEBehaviorProbeDiff: Codable, Equatable, Sendable, Identifiable {
    public var id: String { probeID }
    public var probeID: String
    public var compositionMatches: Bool
    public var candidatePrefixMatches: Int
    public var comparedCandidateCount: Int
    public var committedTextMatches: Bool
    public var composingStateMatches: Bool

    public var exact: Bool {
        compositionMatches && candidatePrefixMatches == comparedCandidateCount && committedTextMatches && composingStateMatches
    }

    public var candidatePrefixScore: Double {
        guard comparedCandidateCount > 0 else { return 1 }
        return Double(candidatePrefixMatches) / Double(comparedCandidateCount)
    }
}

public struct WTIMEBehaviorParityReport: Codable, Equatable, Sendable {
    public var comparedProbeCount: Int
    public var exactProbeCount: Int
    public var averageCandidatePrefixScore: Double
    public var missingReferenceProbeIDs: [String]
    public var missingReplicaProbeIDs: [String]
    public var diffs: [WTIMEBehaviorProbeDiff]

    public var exactProbeFraction: Double {
        guard comparedProbeCount > 0 else { return 0 }
        return Double(exactProbeCount) / Double(comparedProbeCount)
    }
}

public enum WTIMEBehaviorComparator {
    /// Compare observable snapshots without assuming internal engine equivalence.
    /// Candidate order is scored as an exact prefix because the first few suggestions are the
    /// user-visible part that most strongly affects perceived parity.
    public static func compare(reference: WTIMEBehaviorCapture, replica: WTIMEBehaviorCapture) -> WTIMEBehaviorParityReport {
        let referenceByID = Dictionary(uniqueKeysWithValues: reference.snapshots.map { ($0.probeID, $0) })
        let replicaByID = Dictionary(uniqueKeysWithValues: replica.snapshots.map { ($0.probeID, $0) })
        let common = Set(referenceByID.keys).intersection(replicaByID.keys).sorted()
        var diffs: [WTIMEBehaviorProbeDiff] = []
        diffs.reserveCapacity(common.count)

        for id in common {
            guard let lhs = referenceByID[id], let rhs = replicaByID[id] else { continue }
            let comparedCount = min(lhs.candidates.count, rhs.candidates.count)
            var prefixMatches = 0
            for index in 0..<comparedCount {
                if lhs.candidates[index] == rhs.candidates[index] { prefixMatches += 1 }
                else { break }
            }
            diffs.append(.init(
                probeID: id,
                compositionMatches: lhs.composition == rhs.composition,
                candidatePrefixMatches: prefixMatches,
                comparedCandidateCount: comparedCount,
                committedTextMatches: lhs.committedText == rhs.committedText,
                composingStateMatches: lhs.isComposing == rhs.isComposing
            ))
        }

        let exact = diffs.filter(\.exact).count
        let average = diffs.isEmpty ? 0 : diffs.map(\.candidatePrefixScore).reduce(0, +) / Double(diffs.count)
        return .init(
            comparedProbeCount: diffs.count,
            exactProbeCount: exact,
            averageCandidatePrefixScore: average,
            missingReferenceProbeIDs: Set(replicaByID.keys).subtracting(referenceByID.keys).sorted(),
            missingReplicaProbeIDs: Set(referenceByID.keys).subtracting(replicaByID.keys).sorted(),
            diffs: diffs
        )
    }
}

public enum WTIMEBehaviorStarterCorpus {
    private static func chars(_ value: String) -> [String] { value.map(String.init) }

    public static let probes: [WTIMEBehaviorProbe] = {
        var items: [WTIMEBehaviorProbe] = [
            .init(id: "pinyin-nihao", category: "pinyin", keys: chars("nihao")),
            .init(id: "pinyin-zhongguo", category: "pinyin", keys: chars("zhongguo")),
            .init(id: "pinyin-shijie", category: "pinyin", keys: chars("shijie")),
            .init(id: "pinyin-weixin", category: "pinyin", keys: chars("weixin")),
            .init(id: "pinyin-shurufa", category: "pinyin", keys: chars("shurufa")),
            .init(id: "pinyin-changan", category: "segmentation", keys: chars("changan"), notes: "Ambiguous Chang'an/长安 segmentation."),
            .init(id: "pinyin-xian", category: "segmentation", keys: chars("xian"), notes: "Ambiguous xi'an/xian segmentation."),
            .init(id: "pinyin-fangan", category: "segmentation", keys: chars("fangan")),
            .init(id: "pinyin-renmin", category: "ranking", keys: chars("renmin")),
            .init(id: "pinyin-jintian", category: "ranking", keys: chars("jintian")),
            .init(id: "pinyin-mingtian", category: "ranking", keys: chars("mingtian")),
            .init(id: "pinyin-gongzuo", category: "ranking", keys: chars("gongzuo")),
            .init(id: "pinyin-pengyou", category: "ranking", keys: chars("pengyou")),
            .init(id: "pinyin-xihuan", category: "ranking", keys: chars("xihuan")),
            .init(id: "pinyin-xiexie", category: "ranking", keys: chars("xiexie")),
            .init(id: "pinyin-keyi", category: "ranking", keys: chars("keyi")),
            .init(id: "pinyin-shenme", category: "ranking", keys: chars("shenme")),
            .init(id: "pinyin-zenme", category: "ranking", keys: chars("zenme")),
            .init(id: "pinyin-yinggai", category: "ranking", keys: chars("yinggai")),
            .init(id: "pinyin-yijing", category: "ranking", keys: chars("yijing")),
            .init(id: "fuzzy-z-c", category: "fuzzy", keys: chars("zici"), notes: "Capture with the same fuzzy-pinyin switch state on both sides."),
            .init(id: "fuzzy-zh-z", category: "fuzzy", keys: chars("zisi")),
            .init(id: "fuzzy-n-l", category: "fuzzy", keys: chars("nali")),
            .init(id: "fuzzy-en-eng", category: "fuzzy", keys: chars("shengren")),
            .init(id: "longphrase-1", category: "longPhrase", keys: chars("jintiantianqihenhao")),
            .init(id: "longphrase-2", category: "longPhrase", keys: chars("womenyiqiquchifan")),
            .init(id: "longphrase-3", category: "longPhrase", keys: chars("woxiangzhidaoweishenme")),
            .init(id: "english-mixed-1", category: "mixed", keys: chars("iphone")),
            .init(id: "english-mixed-2", category: "mixed", keys: chars("wechat")),
            .init(id: "english-mixed-3", category: "mixed", keys: chars("openai"))
        ]

        let extraPinyin = [
            ("seg-beijing", "beijing"), ("seg-xiangan", "xiangan"), ("seg-fangan2", "fangan"),
            ("seg-shangan", "shangan"), ("rank-shanghai", "shanghai"), ("rank-guangzhou", "guangzhou"),
            ("rank-shenzhen", "shenzhen"), ("rank-gongsi", "gongsi"), ("rank-shijian", "shijian"),
            ("rank-wenti", "wenti")
        ]
        items += extraPinyin.map { .init(id: $0.0, category: "segmentation", keys: chars($0.1)) }

        let t9Words = ["nihao", "zhongguo", "weixin", "shurufa", "jintian", "mingtian", "gongzuo", "pengyou", "xiexie", "shenme", "yinggai", "beijing", "shanghai", "guangzhou", "shenzhen"]
        let t9Map: [Character: Character] = [
            "a":"2","b":"2","c":"2","d":"3","e":"3","f":"3","g":"4","h":"4","i":"4",
            "j":"5","k":"5","l":"5","m":"6","n":"6","o":"6","p":"7","q":"7","r":"7","s":"7",
            "t":"8","u":"8","v":"8","w":"9","x":"9","y":"9","z":"9"
        ]
        for word in t9Words {
            let digits = word.compactMap { t9Map[$0] }.map(String.init)
            items.append(.init(id: "t9-\(word)", category: "t9", keys: digits, inputMode: "pinyin9", notes: "Replay as taps on the actual WeType 3.5.3 T9 ABC/DEF… keys."))
        }

        let shuangpinCanonical = ["ni hao", "zhong guo", "wei xin", "shu ru fa", "jin tian", "ming tian", "gong zuo", "peng you", "xie xie", "shen me"]
        for (index, canonical) in shuangpinCanonical.enumerated() {
            items.append(.init(id: "shuangpin-\(index + 1)", category: "shuangpin", keys: canonical.split(separator: " ").map(String.init), inputMode: "shuangpin", notes: "Keys are canonical syllable tokens; the device runner must map them through the same selected shuangpin schema on both sides."))
        }

        let wubi86: [(String, String)] = [
            ("wubi-ni", "wq"), ("wubi-hao", "vb"), ("wubi-zhong", "k"), ("wubi-guo", "lgyi"),
            ("wubi-ren", "w"), ("wubi-min", "nav"), ("wubi-da", "dd"), ("wubi-xiao", "ihty"),
            ("wubi-shang", "hhgg"), ("wubi-xia", "ghi")
        ]
        items += wubi86.map { .init(id: $0.0, category: "wubi", keys: chars($0.1), inputMode: "wubi86", notes: "Representative Wubi86 code; capture candidate ordering as displayed, not internal table weights.") }

        // WeType 3.5.3 t9_stroke.ini maps five stroke keys to internal inputs b/c/d/e/f.
        let strokeSequences = ["b", "c", "d", "e", "f", "bd", "be", "bcdf", "bbde", "defb"]
        for (index, code) in strokeSequences.enumerated() {
            items.append(.init(id: "stroke-\(index + 1)", category: "stroke", keys: chars(code), inputMode: "stroke", notes: "Internal stroke-key sequence derived from the shipped 3.5.3 t9_stroke layout (一/丨/丿/丶/ㄥ -> b/c/d/e/f)."))
        }

        let learningWords = ["jianyu", "gongzuo", "pengyou", "shurufa", "weixin", "jintian", "shanghai", "beijing"]
        for (index, word) in learningWords.enumerated() {
            items.append(.init(id: "learning-\(index + 1)-\(word)", category: "learning", keys: chars(word), inputMode: "pinyin26", repeatCount: 5, selectCandidateIndex: index == 0 ? 5 : 2, notes: "Record candidate list before each repeat and after the final commit to measure personalization persistence."))
        }

        let correctionTypos = ["nihqo", "zhonggou", "weixni", "shurufa", "jintina", "pengyo", "shenem"]
        for typo in correctionTypos {
            items.append(.init(id: "correction-\(typo)", category: "correction", keys: chars(typo), inputMode: "pinyin26", notes: "Capture correction candidates, auto-fix state and committed output."))
        }
        return items
    }()
}
