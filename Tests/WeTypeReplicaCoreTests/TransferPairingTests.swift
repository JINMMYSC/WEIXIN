import XCTest
@testable import WeTypeReplicaCore

final class TransferPairingTests: XCTestCase {
    func testPairingCodeNormalization() {
        XCTAssertEqual(WTTransferPairingInfo.normalized(" 12-34 56ab78 "), "12345678")
        XCTAssertEqual(WTTransferPairingInfo.normalized("1234567890"), "12345678")
    }

    func testPairingCodeRequiresSixDigits() {
        XCTAssertFalse(WTTransferPairingInfo(code: "12345", deviceName: "A").isUsable)
        XCTAssertTrue(WTTransferPairingInfo(code: "123456", deviceName: "A").isUsable)
    }
}
