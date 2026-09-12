import XCTest
@testable import WeixinRebuild

final class ReplayComparisonTests: XCTestCase {
    func testReportsOnlyMismatchingSteps() {
        let same = InputSnapshot(committedText: "", composingText: "n", candidates: [])
        let changed = InputSnapshot(committedText: "", composingText: "ni", candidates: [])
        let differences = ReplayComparator().differences(
            expected: [same, changed], actual: [same, same]
        )
        XCTAssertEqual(differences, [ReplayDifference(step: 1, expected: changed, actual: same)])
    }

    func testMatchingReplayHasNoDifferences() {
        let snapshot = InputSnapshot(committedText: "好", composingText: "", candidates: [])
        XCTAssertTrue(ReplayComparator().differences(expected: [snapshot], actual: [snapshot]).isEmpty)
    }

    func testReportsMissingSteps() {
        let snapshot = InputSnapshot(committedText: "", composingText: "", candidates: [])
        XCTAssertEqual(
            ReplayComparator().differences(expected: [snapshot], actual: []),
            [ReplayDifference(step: 0, expected: snapshot, actual: nil)]
        )
    }
}
