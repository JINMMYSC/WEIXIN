import XCTest
@testable import WeTypeReplicaCore

final class PersistentStoreTests: XCTestCase {
    private func tempURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString)-\(name)")
    }

    func testClipboardDeduplicatesAndPins() {
        let url = tempURL("clipboard.json")
        let store = WTJSONClipboardStore(url: url)
        store.add("hello")
        store.add("hello")
        XCTAssertEqual(store.items.count, 1)
        let id = store.items[0].id
        store.setPinned(true, id: id)
        XCTAssertTrue(store.items[0].pinned)
        let reloaded = WTJSONClipboardStore(url: url)
        XCTAssertEqual(reloaded.items.first?.text, "hello")
        XCTAssertEqual(reloaded.items.first?.pinned, true)
    }

    func testEmojiUsagePersistsAndRanks() {
        let url = tempURL("emoji.json")
        let store = WTJSONEmojiStore(url: url)
        store.record("😀")
        store.record("😂")
        store.record("😀")
        XCTAssertEqual(store.recent.first?.symbol, "😀")
        XCTAssertEqual(store.recent.first?.count, 2)
        XCTAssertEqual(WTJSONEmojiStore(url: url).recent.first?.symbol, "😀")
    }

    func testPhraseStoreMaintainsOrder() {
        let url = tempURL("phrases.json")
        let store = WTJSONPhraseStore(url: url)
        store.add("A")
        store.add("B")
        store.move(from: 1, to: 0)
        XCTAssertEqual(store.items.map(\.text), ["B", "A"])
        XCTAssertEqual(WTJSONPhraseStore(url: url).items.map(\.text), ["B", "A"])
    }
}
