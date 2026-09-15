import XCTest
@testable import WeTypeReplicaCore

final class Phase14VisualContractTests: XCTestCase {
    func testMeasuredLightPalette() {
        XCTAssertEqual(WTPhase14Palette353.keyboardBackground, "#DDDEE2")
        XCTAssertEqual(WTPhase14Palette353.normalKey, "#FFFFFF")
        XCTAssertEqual(WTPhase14Palette353.grayKey, "#AFB4BD")
        XCTAssertEqual(WTPhase14Palette353.accent, "#23C891")
        XCTAssertEqual(WTPhase14Palette353.voiceActiveAccent, "#1FC085")
        XCTAssertEqual(WTPhase14Palette353.hostBackground, "#E2F1F0")
    }

    func testT26BottomRowMatchesMeasured430PointContract() throws {
        let result = WTKeyboardGeometryResolver353.resolve(
            layout: WTLayouts353.t26Pinyin,
            viewportWidth: 430
        )
        let frames = Dictionary(uniqueKeysWithValues: result.map { ($0.id, $0.frame) })
        XCTAssertEqual(try XCTUnwrap(frames["KEY_123"]).width, 74.7, accuracy: 1.5)
        XCTAssertEqual(try XCTUnwrap(frames["KEY_,"]).width, 31.3, accuracy: 1.5)
        XCTAssertEqual(try XCTUnwrap(frames["KEY_SPACE"]).width, 149.0, accuracy: 1.5)
        XCTAssertEqual(try XCTUnwrap(frames["KEY_CHANGE"]).width, 34.3, accuracy: 1.5)
        XCTAssertEqual(try XCTUnwrap(frames["KEY_RETURN"]).width, 80.0, accuracy: 1.5)
    }

    func testResolvedT26BottomRowIsOrderedAndNonOverlapping() {
        let frames = WTKeyboardGeometryResolver353.resolve(layout: WTLayouts353.t26Pinyin, viewportWidth: 430)
            .filter { ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"].contains($0.id) }
            .sorted { $0.frame.x < $1.frame.x }
        XCTAssertEqual(frames.map(\.id), ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"])
        for pair in zip(frames, frames.dropFirst()) {
            XCTAssertLessThanOrEqual(pair.0.frame.x + pair.0.frame.width, pair.1.frame.x)
        }
    }

    func testT9MeasuredGeometryDoesNotRegress() throws {
        let result = WTKeyboardGeometryResolver353.resolve(layout: WTLayouts353.t9Pinyin, viewportWidth: 430)
        let key2 = try XCTUnwrap(result.first { $0.id == "KEY_2" })
        XCTAssertEqual(key2.frame.width, 83.7, accuracy: 1.5)
        XCTAssertEqual(key2.frame.height, 49.3, accuracy: 1.5)
    }
}
