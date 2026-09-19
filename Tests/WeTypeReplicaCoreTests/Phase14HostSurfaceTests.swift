import XCTest
@testable import WeTypeReplicaCore

final class Phase14HostSurfaceTests: XCTestCase {
    func testHomeCardOrderMatchesReference() {
        XCTAssertEqual(WTHostHomeCatalog353.cards.map(\.title), [
            "布局和显示", "按键效果", "定制工具栏", "辅助输入",
            "跨设备粘贴传送", "剪贴板", "键盘管理", "语音转文字",
            "拼写 Plus", "单机模式"
        ])
    }

    func testHomeGridContract() {
        XCTAssertEqual(WTHostHomeCatalog353.outerMargin, 20)
        XCTAssertEqual(WTHostHomeCatalog353.columnSpacing, 14)
        XCTAssertEqual(WTHostHomeCatalog353.cardCornerRadius, 16)
        XCTAssertEqual(WTHostHomeCatalog353.backgroundHex, "#E2F1F0")
    }

    func testDisplaySettingsUsesObservedRowOrder() {
        XCTAssertEqual(
            WTDisplaySettingsCatalog353.sections.flatMap(\.rows).map(\.title),
            ["表情键", "数字键盘", "候选字", "键盘高度", "拼音显示位置"]
        )
    }

    func testDisplaySettingsRowsHaveStableIdentifiers() {
        let ids = WTDisplaySettingsCatalog353.sections.flatMap(\.rows).map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testHostSettingsChromeMatchesTheMeasuredPages() {
        let chrome = WTHostSettingsChrome353.self
        XCTAssertEqual(chrome.pageBackground, "#F0F0F0")
        XCTAssertEqual(chrome.cardBackground, "#FFFFFF")
        XCTAssertEqual(chrome.cardCornerRadius, 14, accuracy: 0.01)
        XCTAssertEqual(chrome.sideMargin, 20, accuracy: 0.01)
        XCTAssertEqual(chrome.groupSpacing, 16, accuracy: 0.01)
        XCTAssertEqual(chrome.rowHeight, 44, accuracy: 0.01)
        XCTAssertEqual(chrome.tallRowHeight, 64, accuracy: 0.01)
    }
}
