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
        let measured = WTMeasuredKeyboard353.self
        for (index, id) in measured.t26BottomRowIDs.enumerated() {
            let frame = try XCTUnwrap(frames[id], "missing bottom-row key \(id)")
            XCTAssertEqual(frame.x, measured.t26BottomRowOrigins[index], accuracy: 0.5)
            XCTAssertEqual(frame.width, measured.t26BottomRowWidths[index], accuracy: 0.5)
            XCTAssertEqual(frame.y, 173, accuracy: 0.5)
            XCTAssertEqual(frame.height, measured.rowHeight, accuracy: 0.5)
        }
    }

    func testT26LetterRowsUseMeasuredPitchAndCentredSecondRow() throws {
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: WTLayouts353.t26Pinyin, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        let measured = WTMeasuredKeyboard353.self

        for (index, id) in ["KEY_Q", "KEY_W", "KEY_E", "KEY_R", "KEY_T",
                            "KEY_Y", "KEY_U", "KEY_I", "KEY_O", "KEY_P"].enumerated() {
            let frame = try XCTUnwrap(frames[id])
            XCTAssertEqual(frame.x, measured.keyInset + Double(index) * measured.letterKeyPitch,
                           accuracy: 0.1)
            XCTAssertEqual(frame.width, measured.letterKeyWidth, accuracy: 0.1)
        }

        // Measured reference origin: the extracted resource rectangle sits 5.9 pt too far left.
        let firstSecondRowKey = try XCTUnwrap(frames["KEY_A"]).x
        XCTAssertEqual(firstSecondRowKey, 26.33, accuracy: 0.3)
        let lastSecondRowKey = try XCTUnwrap(frames["KEY_L"])
        XCTAssertEqual(lastSecondRowKey.x + lastSecondRowKey.width, 403.67, accuracy: 0.3)

        let shift = try XCTUnwrap(frames["KEY_SHIFT"])
        XCTAssertEqual(shift.x, 5, accuracy: 0.1)
        XCTAssertEqual(shift.width, measured.functionKeyWidth, accuracy: 0.1)
        let delete = try XCTUnwrap(frames["KEY_DEL"])
        XCTAssertEqual(delete.x, 377, accuracy: 0.1)
        XCTAssertEqual(delete.width, measured.functionKeyWidth, accuracy: 0.1)
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
        XCTAssertEqual(key2.frame.width, 83.67, accuracy: 0.3)
        XCTAssertEqual(key2.frame.x, 173.33, accuracy: 0.3)
        XCTAssertEqual(key2.frame.height, 49.3, accuracy: 1.5)

        let gutter = try XCTUnwrap(result.first { $0.id == "VIEW_LIST" || $0.id == "KEY_SYMB" })
        XCTAssertEqual(gutter.frame.width, 72, accuracy: 0.3)
    }

    func testT9BottomRowMatchesMeasuredContract() throws {
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: WTLayouts353.t9Pinyin, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        let measured = WTMeasuredKeyboard353.self
        for (index, id) in measured.t9BottomRowIDs.enumerated() {
            let frame = try XCTUnwrap(frames[id], "missing nine-key bottom key \(id)")
            XCTAssertEqual(frame.x, measured.t9BottomRowOrigins[index], accuracy: 0.5)
            XCTAssertEqual(frame.width, measured.t9BottomRowWidths[index], accuracy: 0.5)
        }
    }

    func testMeasuredKeyboardPanelMatchesReferenceHeight() {
        XCTAssertEqual(WTMeasuredKeyboard353.panelTop + WTMeasuredKeyboard353.panelHeight, 932)
        XCTAssertEqual(WTMeasuredKeyboard353.headerHeight + WTMeasuredKeyboard353.canvasHeight,
                       WTMeasuredKeyboard353.panelHeight, accuracy: 0.01)
        XCTAssertEqual(WTMeasuredKeyboard353.keyAreaHeight, 224)
    }
}
}
