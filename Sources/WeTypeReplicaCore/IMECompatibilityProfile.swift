import Foundation

public struct WTIMECompatibilityRule: Codable, Hashable, Sendable, Identifiable {
    public var id: String
    public var inputMode: String
    public var composition: String
    /// Reference-visible ordering to prefer when those texts also exist in the local Rime menu.
    public var preferredCandidateOrder: [String]
    /// Candidate texts observed in WeType but intentionally hidden in the replica for this probe/context.
    public var hiddenCandidates: Set<String>

    public init(
        id: String,
        inputMode: String,
        composition: String,
        preferredCandidateOrder: [String] = [],
        hiddenCandidates: Set<String> = []
    ) {
        self.id = id
        self.inputMode = inputMode
        self.composition = composition
        self.preferredCandidateOrder = preferredCandidateOrder
        self.hiddenCandidates = hiddenCandidates
    }
}

public struct WTIMECompatibilityProfile: Codable, Equatable, Sendable {
    public var formatVersion: Int
    public var referenceImplementation: String
    public var rules: [WTIMECompatibilityRule]

    public init(formatVersion: Int = 1, referenceImplementation: String = "WeType 3.5.3", rules: [WTIMECompatibilityRule] = []) {
        self.formatVersion = formatVersion
        self.referenceImplementation = referenceImplementation
        self.rules = rules
    }

    public func rule(inputMode: String, composition: String) -> WTIMECompatibilityRule? {
        rules.first { $0.inputMode == inputMode && $0.composition == composition }
    }

    /// Reorders only candidates that already exist in the local engine menu. Source indices are retained,
    /// so tapping a visually moved candidate still selects the correct underlying Rime item.
    public func apply(
        to candidates: [WTCandidate],
        inputMode: String,
        composition: String
    ) -> [WTDisplayedCandidate] {
        let indexed = candidates.enumerated().map { WTDisplayedCandidate(sourceIndex: $0.offset, candidate: $0.element) }
        guard let rule = rule(inputMode: inputMode, composition: composition) else { return indexed }

        let visible = indexed.filter { !rule.hiddenCandidates.contains($0.candidate.text) }
        guard !rule.preferredCandidateOrder.isEmpty else { return visible }
        let rank = Dictionary(uniqueKeysWithValues: rule.preferredCandidateOrder.enumerated().map { ($0.element, $0.offset) })
        return visible.enumerated().sorted { lhs, rhs in
            let l = rank[lhs.element.candidate.text]
            let r = rank[rhs.element.candidate.text]
            switch (l, r) {
            case let (a?, b?): return a < b
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return lhs.offset < rhs.offset
            }
        }.map(\.element)
    }
}

public enum WTIMECompatibilityProfileBuilder {
    /// Builds safe reorder hints from two black-box captures. It never invents candidates and never
    /// extracts engine internals: only reference-visible texts that also exist in the replica are moved.
    public static func build(
        corpus: WTIMEBehaviorCorpus,
        reference: WTIMEBehaviorCapture,
        replica: WTIMEBehaviorCapture,
        prefixLimit: Int = 10
    ) -> WTIMECompatibilityProfile {
        let probes = Dictionary(uniqueKeysWithValues: corpus.probes.map { ($0.id, $0) })
        let ref = Dictionary(uniqueKeysWithValues: reference.snapshots.map { ($0.probeID, $0) })
        let rep = Dictionary(uniqueKeysWithValues: replica.snapshots.map { ($0.probeID, $0) })
        var rules: [WTIMECompatibilityRule] = []

        for id in Set(ref.keys).intersection(rep.keys).sorted() {
            guard let p = probes[id], let a = ref[id], let b = rep[id] else { continue }
            guard a.candidates != b.candidates else { continue }
            let localSet = Set(b.candidates)
            let desired = Array(a.candidates.prefix(max(1, prefixLimit))).filter { localSet.contains($0) }
            guard !desired.isEmpty else { continue }
            rules.append(.init(
                id: id,
                inputMode: p.inputMode ?? "pinyin26",
                composition: b.composition,
                preferredCandidateOrder: desired
            ))
        }
        return .init(referenceImplementation: reference.implementation, rules: rules)
    }
}
