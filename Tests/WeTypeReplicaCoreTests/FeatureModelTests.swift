import XCTest
@testable import WeTypeReplicaCore

final class FeatureModelTests: XCTestCase {
    func testTransferProgressCarriesPeerAndFraction() {
        let state = WTTransferState.transferring(peer: "iPhone", progress: 0.5)
        XCTAssertEqual(state, .transferring(peer: "iPhone", progress: 0.5))
    }

    func testSurfaceCatalogCoversV5EvidenceClasses() {
        let required = [
            "WBStickerPreviewView", "WBHotWordListView", "WBFontFilterPickerView",
            "WBWordSplittingView", "WBRectSettingView", "WBPasteboardImageDetailView",
            "WBPlusConfigView", "WBAuthGuideView", "WBArrangeView", "WBCustomStickerView"
        ]
        for name in required {
            XCTAssertNotNil(WTUISurfaceCatalog353.mapping(for: name), "missing surface mapping for \(name)")
        }
        XCTAssertGreaterThanOrEqual(WTUISurfaceCatalog353.mappings.count, 50)
    }

    func testBookVideoModelsAndFormerUnknownSurfacesAreClassified() throws {
        let card = WTBookVideoCard(id: "f1", kind: .finder, title: "视频号", subtitle: "demo")
        let data = try JSONEncoder().encode(card)
        XCTAssertEqual(try JSONDecoder().decode(WTBookVideoCard.self, from: data), card)

        XCTAssertEqual(WTUISurfaceCatalog353.mapping(for: "WBFinderView")?.status, .providerRequired)
        XCTAssertEqual(WTUISurfaceCatalog353.mapping(for: "WBTPListView")?.status, .debugOnly)
        XCTAssertEqual(WTUISurfaceCatalog353.mapping(for: "WBTPPlayerView")?.status, .debugOnly)
    }

    func testClipboardItemPinStateRoundTrip() throws {
        let item = WTClipboardItem(text: "hello", pinned: true)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(WTClipboardItem.self, from: data)
        XCTAssertEqual(decoded, item)
    }
}
