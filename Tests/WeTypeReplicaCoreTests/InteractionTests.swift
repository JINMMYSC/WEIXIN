import XCTest
@testable import WeTypeReplicaCore

final class InteractionTests: XCTestCase {
    func testChineseQuoteKeyUsesChineseVariant() {
        let state = WTKeyboardState(inputMode: .chinesePinyin26)
        let key = WTLayouts353Resolved.t26Pinyin.item(id: "KEY_,")!
        XCTAssertEqual(WTKeyActionResolver.action(for: key, gesture: .tap, state: state), .directText("，"))
    }

    func testEnglishQuoteKeyUsesEnglishVariant() {
        let state = WTKeyboardState(inputMode: .english26)
        let key = WTLayouts353Resolved.t26Pinyin.item(id: "KEY_,")!
        XCTAssertEqual(WTKeyActionResolver.action(for: key, gesture: .tap, state: state), .directText("."))
    }

    func testSwipeUpReadsExact26KeyNumber() {
        let state = WTKeyboardState(inputMode: .chinesePinyin26)
        let q = WTLayouts353Resolved.t26Pinyin.item(id: "KEY_Q")!
        XCTAssertEqual(WTKeyActionResolver.action(for: q, gesture: .swipeUp, state: state), .directText("1"))
    }

    func testLongPressFloatListParsesAccentedV() {
        let state = WTKeyboardState(inputMode: .chinesePinyin26)
        let v = WTLayouts353Resolved.t26Pinyin.item(id: "KEY_V")!
        let action = WTKeyActionResolver.action(for: v, gesture: .longPress, state: state)
        guard case .longPressOptions(let values, _) = action else { return XCTFail("missing long press") }
        XCTAssertEqual(values, ["V","v","ü","ǖ","ǘ","ǚ","ǜ"])
    }

    func testLanguageToggleReturnsToNineKey() {
        var state = WTKeyboardState(inputMode: .chinesePinyin9)
        state.toggleLanguage()
        XCTAssertEqual(state.inputMode, .english26)
        state.toggleLanguage()
        XCTAssertEqual(state.inputMode, .chinesePinyin9)
    }

    func testOneShotShiftConsumesAfterCharacter() {
        var state = WTKeyboardState(inputMode: .english26)
        state.cycleShift()
        XCTAssertEqual(state.shiftState, .once)
        state.consumeOneShotShiftIfNeeded()
        XCTAssertEqual(state.shiftState, .off)
    }

    func testResolvedEnglishLayoutInheritedAllKeys() {
        XCTAssertEqual(WTLayouts353Resolved.t26En.items.count, 36)
        XCTAssertNotNil(WTLayouts353Resolved.t26En.item(id: "KEY_RETURN"))
    }

    func testResolvedStrokeLayoutInheritedNineKeyGeometry() {
        let item = WTLayouts353Resolved.t9Stroke.item(id: "KEY_DEL")
        XCTAssertEqual(item?.rect, WTRect(x: 340, y: 3, width: 69, height: 50))
    }
}
