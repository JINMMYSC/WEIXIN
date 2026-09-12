import Foundation

struct CandidateUpdate: Equatable {
    let version: Int
    let requestID: Int
    let candidates: [InputCandidate]
}

final class CandidateStore {
    private(set) var current: CandidateUpdate?

    @discardableResult
    func apply(_ update: CandidateUpdate) -> Bool {
        guard let current else {
            self.current = update
            return true
        }
        guard update.version > current.version ||
            (update.version == current.version && update.requestID >= current.requestID) else {
            return false
        }
        self.current = update
        return true
    }

    func candidate(withID id: Int) -> InputCandidate? {
        current?.candidates.first { $0.id == id }
    }
}
