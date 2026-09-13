import XCTest
@testable import WeTypeReplicaCore

final class MemoryPressureBudgetTests: XCTestCase {
    func testClipboardTrimKeepsPinnedFirstThenRecentUnpinned() {
        let pinned = WTClipboardItem(text: "pinned", pinned: true)
        let one = WTClipboardItem(text: "one")
        let two = WTClipboardItem(text: "two")
        let budget = WTKeyboardMemoryPressureBudget(maxClipboardItems: 2)
        let result = budget.trimmedClipboard([one, pinned, two])
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.text, "pinned")
        XCTAssertEqual(result.last?.text, "one")
    }

    func testZeroBudgetDropsPresentationClipboard() {
        let budget = WTKeyboardMemoryPressureBudget(maxClipboardItems: 0)
        XCTAssertTrue(budget.trimmedClipboard([WTClipboardItem(text: "x")]).isEmpty)
    }
}
