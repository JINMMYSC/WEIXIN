import XCTest
@testable import WeixinRebuild

final class ReplayTraceTests: XCTestCase {
    func testTraceRunsAndRoundTrips() throws {
        let expected = [
            InputSnapshot(committedText: "", composingText: "n", candidates: []),
            InputSnapshot(committedText: "", composingText: "ni", candidates: [])
        ]
        let trace = ReplayTrace(events: [.insert("n"), .insert("i")], expectedSnapshots: expected)
        XCTAssertTrue(trace.differences().isEmpty)
        XCTAssertEqual(try ReplayTrace(data: trace.encoded()), trace)
    }

    func testTraceSurfacesMismatch() {
        let trace = ReplayTrace(
            events: [.insert("n")],
            expectedSnapshots: [InputSnapshot(committedText: "", composingText: "x", candidates: [])]
        )
        XCTAssertEqual(trace.differences().map(\.step), [0])
    }
}
