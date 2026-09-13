import XCTest
@testable import WeTypeReplicaCore

final class LayoutTests: XCTestCase {
    func testT26GeometryMatches353() {
        let layout = WTLayouts353.t26Pinyin
        XCTAssertEqual(layout.baseSize, WTSize(width: 414, height: 224))
        XCTAssertEqual(layout.items.filter { $0.id.hasPrefix("KEY_") }.count, 36)
        XCTAssertEqual(layout.items.first(where: { $0.id == "KEY_Q" })?.rect,
                       WTRect(x: 5, y: 5, width: 35, height: 46))
        XCTAssertEqual(layout.items.first(where: { $0.id == "KEY_RETURN" })?.rect,
                       WTRect(x: 323, y: 173, width: 86, height: 46))
        XCTAssertEqual(layout.items.first(where: { $0.id == "KEY_SPACE" })?.function, "space")
    }

    func testT9GeometryMatches353() {
        let layout = WTLayouts353.t9Pinyin
        XCTAssertEqual(layout.baseSize, WTSize(width: 414, height: 224))
        XCTAssertEqual(layout.items.first(where: { $0.id == "KEY_2" })?.input, "ABC")
        XCTAssertEqual(layout.items.first(where: { $0.id == "KEY_DEL" })?.rect,
                       WTRect(x: 340, y: 3, width: 69, height: 50))
    }

    func testPanelReturnPreservesInputMode() {
        var state = WTKeyboardState(inputMode: .english26)
        state.present(.emoji)
        state.back()
        XCTAssertEqual(state.inputMode, .english26)
        XCTAssertEqual(state.panel, .keyboard)
    }

    func testNestedPanelReturn() {
        var state = WTKeyboardState(inputMode: .chinesePinyin9)
        state.present(.symbols)
        state.present(.emoji)
        state.back()
        XCTAssertEqual(state.panel, .symbols)
        state.back()
        XCTAssertEqual(state.panel, .keyboard)
        XCTAssertEqual(state.inputMode, .chinesePinyin9)
    }
}
