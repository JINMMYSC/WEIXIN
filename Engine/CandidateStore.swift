import Foundation

struct CandidateUpdate: Equatable, Codable {
    let version: Int
    let requestID: Int
    let candidates: [InputCandidate]
}

final class CandidateStore {
    private(set) var current: CandidateUpdate?

    @discardableResult
    func apply(_ update: CandidateUpdate) -> Bool {
        var ids = Set<Int>()
        guard update.version >= 0, update.requestID >= 0,
              update.candidates.allSatisfy({ $0.id >= 0 && !$0.text.isEmpty && !$0.text.contains("\0") && ids.insert($0.id).inserted }) else {
            return false
        }
        guard let current else {
            self.current = update
            return true
        }
        guard update.version > current.version ||
            (update.version == current.version && update.requestID > current.requestID) else {
            return false
        }
        self.current = update
        return true
    }

    func reset() {
        current = nil
    }

    func candidate(withID id: Int) -> InputCandidate? {
        current?.candidates.first { $0.id == id }
    }
}
