import Foundation


public struct WTDisplayedCandidate: Equatable, Sendable {
    public let sourceIndex: Int
    public let candidate: WTCandidate
    public init(sourceIndex: Int, candidate: WTCandidate) {
        self.sourceIndex = sourceIndex
        self.candidate = candidate
    }
}

public struct WTCandidatePreferencesSnapshot: Codable, Equatable, Sendable {
    public var pinned: [String]
    public var hidden: Set<String>
    public init(pinned: [String] = [], hidden: Set<String> = []) {
        self.pinned = pinned
        self.hidden = hidden
    }
}

/// Local compatibility layer for the 3.5.3 candidate long-press actions.
/// A concrete Rime adapter can additionally update userdb; this store guarantees
/// the UI behavior even when a public Rime API cannot delete/re-rank a word directly.
public final class WTCandidatePreferenceStore {
    public private(set) var snapshot: WTCandidatePreferencesSnapshot
    private let url: URL

    public init(url: URL) {
        self.url = url
        self.snapshot = WTJSONStoreIOForCandidates.load(from: url)
    }

    public func pinToFront(_ word: String) {
        guard !word.isEmpty else { return }
        snapshot.hidden.remove(word)
        snapshot.pinned.removeAll { $0 == word }
        snapshot.pinned.insert(word, at: 0)
        save()
    }

    public func hide(_ word: String) {
        guard !word.isEmpty else { return }
        snapshot.pinned.removeAll { $0 == word }
        snapshot.hidden.insert(word)
        save()
    }

    public func restore(_ word: String) {
        snapshot.hidden.remove(word)
        save()
    }

    public func apply(to candidates: [WTCandidate]) -> [WTCandidate] {
        applyIndexed(to: candidates).map(\.candidate)
    }

    public func applyIndexed(to candidates: [WTCandidate]) -> [WTDisplayedCandidate] {
        let indexed = candidates.enumerated().map { WTDisplayedCandidate(sourceIndex: $0.offset, candidate: $0.element) }
        return applyIndexed(to: indexed)
    }

    /// Applies user pin/delete preferences after any engine-compatibility reorder while retaining the
    /// original source indices required for selection in librime.
    public func applyIndexed(to candidates: [WTDisplayedCandidate]) -> [WTDisplayedCandidate] {
        let visible = candidates.filter { !snapshot.hidden.contains($0.candidate.text) }
        guard !snapshot.pinned.isEmpty else { return visible }
        let rank = Dictionary(uniqueKeysWithValues: snapshot.pinned.enumerated().map { ($0.element, $0.offset) })
        return visible.enumerated().sorted { a, b in
            let ar = rank[a.element.candidate.text]
            let br = rank[b.element.candidate.text]
            switch (ar, br) {
            case let (x?, y?): return x < y
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return a.offset < b.offset
            }
        }.map(\.element)
    }

    private func save() {
        let fm = FileManager.default
        try? fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(snapshot) { try? data.write(to: url, options: .atomic) }
    }
}

private enum WTJSONStoreIOForCandidates {
    static func load(from url: URL) -> WTCandidatePreferencesSnapshot {
        guard let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(WTCandidatePreferencesSnapshot.self, from: data) else {
            return .init()
        }
        return value
    }
}
