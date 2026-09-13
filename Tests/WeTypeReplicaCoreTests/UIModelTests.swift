import XCTest
@testable import WeTypeReplicaCore

final class UIModelTests: XCTestCase {
    func testToolbarCatalogHasExpectedCoverage() {
        XCTAssertEqual(WTToolbarCatalog353.expanded.count, 22)
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.emoji))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.deviceSync))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.quickSettings))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.hotWords))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.stickers))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.wordSplitting))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.fontPicker))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.keyboardAdjust))
        XCTAssertTrue(WTToolbarCatalog353.expanded.contains(.plus))
    }

    func testSymbolCatalogIsPopulated() {
        for category in WTSymbolCategory.allCases {
            XCTAssertFalse(WTSymbolCatalog353.values(for: category).isEmpty, "missing symbols for \(category)")
        }
    }

    func testPanelStateCanRoundTripFromNestedTools() {
        var state = WTKeyboardState(inputMode: .chinesePinyin9)
        state.present(.controlCenter)
        state.present(.quickSettings)
        XCTAssertEqual(state.panel, .quickSettings)
        state.back()
        XCTAssertEqual(state.panel, .controlCenter)
        state.back()
        XCTAssertEqual(state.panel, .keyboard)
        XCTAssertEqual(state.inputMode, .chinesePinyin9)
    }

    func testNewV5PanelsPreserveReturnStack() {
        var state = WTKeyboardState(inputMode: .english26)
        state.present(.controlCenter)
        state.present(.hotWords)
        state.present(.wordSplitting)
        state.back()
        XCTAssertEqual(state.panel, .hotWords)
        state.back()
        XCTAssertEqual(state.panel, .controlCenter)
        state.back()
        XCTAssertEqual(state.panel, .keyboard)
        XCTAssertEqual(state.inputMode, .english26)
    }

    func testKeyboardAdjustmentClampsToSafeRange() {
        var value = WTKeyboardAdjustment(widthScale: 0.2, heightScale: 9, horizontalOffset: -8, verticalOffset: 5)
        XCTAssertEqual(value.widthScale, 0.72)
        XCTAssertEqual(value.heightScale, 1.18)
        XCTAssertEqual(value.horizontalOffset, -0.20)
        XCTAssertEqual(value.verticalOffset, 0.15)
        value.widthScale = 2
        value.clamp()
        XCTAssertEqual(value.widthScale, 1.0)
    }

    func testMediaAndHotWordModelsAreStable() throws {
        let hot = WTHotWordItem(word: "微信输入法", rank: 1, tag: "热")
        XCTAssertEqual(hot.id, "微信输入法")
        let card = WTMediaCard(id: "s1", title: "表情", kind: .sticker)
        let data = try JSONEncoder().encode(card)
        XCTAssertEqual(try JSONDecoder().decode(WTMediaCard.self, from: data), card)
    }

    func testVisualCalibrationProfileRoundTrips() throws {
        var profile = WTVisualCalibrationProfile()
        profile.keyCornerRadius = 6.25
        let data = try JSONEncoder().encode(profile)
        XCTAssertEqual(try JSONDecoder().decode(WTVisualCalibrationProfile.self, from: data), profile)
    }
}
