import Foundation

struct CandidatePager {
    private(set) var candidates: [InputCandidate] = []
    private(set) var page = 0
    let pageSize: Int

    init(pageSize: Int = 5) {
        self.pageSize = max(1, pageSize)
    }

    mutating func replace(with candidates: [InputCandidate]) {
        self.candidates = candidates
        page = 0
    }

    mutating func nextPage() {
        guard !candidates.isEmpty else { return }
        page = min(page + 1, maxPage)
    }

    mutating func previousPage() {
        page = max(0, page - 1)
    }

    var visibleCandidates: [InputCandidate] {
        let start = page * pageSize
        return Array(candidates.dropFirst(start).prefix(pageSize))
    }

    var hasNextPage: Bool { page < maxPage }
    var hasPreviousPage: Bool { page > 0 }

    private var maxPage: Int {
        max(0, (candidates.count - 1) / pageSize)
    }
}
