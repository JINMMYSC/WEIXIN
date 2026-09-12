import XCTest
@testable import WeixinRebuild

final class KeyboardSessionBridgeTests: XCTestCase {
    func testCommitProducesOneHostCommitAction() {
        let bridge = KeyboardSessionBridge()
        _ = bridge.handle(.insert("nihao"))
        let output = bridge.handle(.commitPending)
        XCTAssertEqual(output.committedText, "nihao")
        XCTAssertEqual(output.snapshot.composingText, "")
    }

    func testEmptyCommitDoesNotSendTextToHost() {
        XCTAssertNil(KeyboardSessionBridge().handle(.commitPending).committedText)
    }
}
