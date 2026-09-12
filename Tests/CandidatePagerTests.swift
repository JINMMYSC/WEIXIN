import XCTest
@testable import WeixinRebuild

final class CandidatePagerTests: XCTestCase {
    func testPagesCandidatesInStableGroups() {
        var pager = CandidatePager(pageSize: 2)
        pager.replace(with: (0..<5).map { InputCandidate(id: $0, text: "候选\($0)") })
        XCTAssertEqual(pager.visibleCandidates.map(\.id), [0, 1])
        pager.nextPage()
        XCTAssertEqual(pager.visibleCandidates.map(\.id), [2, 3])
        pager.nextPage()
        XCTAssertEqual(pager.visibleCandidates.map(\.id), [4])
        XCTAssertFalse(pager.hasNextPage)
    }
}
