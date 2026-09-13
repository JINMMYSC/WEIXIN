import XCTest
@testable import WeTypeReplicaCore

final class IconGeometryTests: XCTestCase {
    func testMeasuredToolbarGeometryExists() {
        let emoji = WTIconGeometry353.geometry("icon_bar_emoji_24")
        XCTAssertEqual(emoji?.canvas.width, 24)
        XCTAssertEqual(emoji?.canvas.height, 24)
        XCTAssertNotNil(emoji)
        XCTAssertEqual(emoji!.glyph.width, 17.333, accuracy: 0.001)
    }

    func testControlCenterUses44PointCanvas() {
        let voice = WTIconGeometry353.geometry("control_center_voice")
        XCTAssertEqual(voice?.canvas.width, 44)
        XCTAssertEqual(voice?.canvas.height, 44)
    }
}
