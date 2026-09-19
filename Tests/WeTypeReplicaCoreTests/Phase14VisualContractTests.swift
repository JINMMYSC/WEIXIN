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

    func testT26CapsUseTheMeasuredRowHeight() throws {
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: WTLayouts353.t26Pinyin, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        for id in ["KEY_Q", "KEY_A", "KEY_Z", "KEY_123", "KEY_SPACE"] {
            let frame = try XCTUnwrap(frames[id])
            XCTAssertEqual(frame.height, WTMeasuredKeyboard353.t26RowHeight, accuracy: 0.01)
        }
    }

    func testT9RowsUseTheMeasuredRowTopsAndHeight() throws {
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: WTLayouts353.t9Pinyin, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        let expected = ["KEY_1": 3.0, "KEY_4": 59.0, "KEY_7": 115.0, "KEY_SPACE": 171.0]
        for (id, top) in expected {
            let frame = try XCTUnwrap(frames[id], "missing \(id)")
            XCTAssertEqual(frame.y, top, accuracy: 0.01)
            XCTAssertEqual(frame.height, WTMeasuredKeyboard353.t9RowHeight, accuracy: 0.01)
        }
    }

    func testT9PunctuationColumnSharesTheMeasuredRowPitch() throws {
        let resolved = WT353RuntimeLayoutGeometry.resolvedT9(WTLayouts353.t9Pinyin)
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: resolved, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        for index in 0..<4 {
            let frame = try XCTUnwrap(frames["WT353_T9_PUNCT_\(index)"])
            XCTAssertEqual(frame.y, WTMeasuredKeyboard353.t9RowTops[index], accuracy: 0.01)
            XCTAssertEqual(frame.width, WTMeasuredKeyboard353.t9GutterWidth, accuracy: 0.01)
            XCTAssertEqual(frame.height, WTMeasuredKeyboard353.t9RowHeight, accuracy: 0.01)
        }
    }

    func testHeaderRowMatchesTheMeasuredToolbarGrid() {
        let measured = WTMeasuredKeyboard353.self
        XCTAssertEqual(measured.headerRowTop, 31, accuracy: 0.01)
        XCTAssertEqual(measured.headerRowHeight, 32, accuracy: 0.01)
        XCTAssertEqual(measured.headerRowTop + measured.headerRowHeight, 63, accuracy: 0.01)
        XCTAssertEqual(measured.toolSlotPitch - measured.toolButtonSize, 14, accuracy: 0.01)
        XCTAssertEqual(measured.viewportWidth - measured.toolRowTrailingX, 13, accuracy: 0.01)
    }

    func testMeasuredPanelGeometryMatchesTheReferenceFrames() {
        let panels = WTMeasuredPanels353.self

        // Emoji: nine columns of 46.2 pt pitch inside the 430 pt keyboard width.
        XCTAssertEqual(panels.emojiColumns, 9)
        XCTAssertEqual(panels.emojiColumnPitch, 46.2, accuracy: 0.1)
        XCTAssertEqual(Double(panels.emojiColumns) * panels.emojiColumnPitch, 415.8, accuracy: 1.0)
        XCTAssertEqual(panels.emojiRowPitch, 40, accuracy: 0.1)

        // Plus: four 81.67 pt cards on a 102.67 pt pitch.
        XCTAssertEqual(panels.plusCardSize, 81.67, accuracy: 0.01)
        XCTAssertEqual(panels.plusCardSize + panels.plusCardSpacing, 102.67, accuracy: 0.05)
        XCTAssertEqual(panels.plusLeadingInset + 4 * panels.plusCardSize
                       + 3 * panels.plusCardSpacing, 413.35, accuracy: 0.1)
        // The measured grid leaves 16.65 pt on the trailing edge.
        XCTAssertEqual(430.0 - (panels.plusLeadingInset + 4 * panels.plusCardSize
                                + 3 * panels.plusCardSpacing), 16.65, accuracy: 0.1)
        XCTAssertEqual(panels.plusCardBackground, "#F7F6F8")

        // Clipboard: 47.5 pt rows, 8 pt apart.
        XCTAssertEqual(panels.clipboardRowHeight, 47.5, accuracy: 0.01)
        XCTAssertEqual(panels.clipboardRowSpacing, 8, accuracy: 0.01)
        XCTAssertEqual(panels.clipboardRowHeight + panels.clipboardRowSpacing, 55.5, accuracy: 0.01)
    }

    func testSymbolPanelUsesTheMeasuredLetterGridAndFiveKeyRow() throws {
        let frames = Dictionary(uniqueKeysWithValues: WTKeyboardGeometryResolver353
            .resolve(layout: WTLayouts353Resolved.t26CnSymbol, viewportWidth: 430)
            .map { ($0.id, $0.frame) })
        let measured = WTMeasuredKeyboard353.self

        // Rows 1 and 2 repeat the letter-key grid.
        for (index, id) in ["KEY_11", "KEY_12", "KEY_13", "KEY_14", "KEY_15"].enumerated() {
            let key = try XCTUnwrap(frames[id])
            XCTAssertEqual(key.x, measured.keyInset + Double(index) * measured.letterKeyPitch,
                           accuracy: 0.01)
            XCTAssertEqual(key.width, measured.letterKeyWidth, accuracy: 0.01)
            XCTAssertEqual(key.height, measured.t26RowHeight, accuracy: 0.01)
        }

        // Row 3: switch, six 43.33 pt punctuation keys, delete — measured on the six-key page
        // the extracted resource describes.
        let symbolSwitch = try XCTUnwrap(frames["KEY_SYMB"])
        XCTAssertEqual(symbolSwitch.x, 5, accuracy: 0.01)
        XCTAssertEqual(symbolSwitch.width, 48.33, accuracy: 0.01)

        var previousEnd = symbolSwitch.x + symbolSwitch.width
        for id in ["KEY_33", "KEY_34", "KEY_35", "KEY_36", "KEY_37", "KEY_38"] {
            let key = try XCTUnwrap(frames[id], "missing \(id)")
            XCTAssertEqual(key.width, 43.33, accuracy: 0.01)
            XCTAssertGreaterThanOrEqual(key.x, previousEnd, "\(id) overlaps the previous key")
            previousEnd = key.x + key.width
        }
        XCTAssertEqual(try XCTUnwrap(frames["KEY_33"]).x, 69.33, accuracy: 0.01)
        let delete = try XCTUnwrap(frames["KEY_DEL"])
        XCTAssertEqual(delete.x, 377, accuracy: 0.01)
        XCTAssertLessThanOrEqual(previousEnd, delete.x)

        // The bottom row keeps its resource geometry scaled once into the 430 pt viewport.
        let space = try XCTUnwrap(frames["KEY_SPACE"])
        XCTAssertEqual(space.width, 46.0 * 430.0 / 414.0, accuracy: 0.1)
        XCTAssertEqual(space.y, 173, accuracy: 0.01)
    }
}
