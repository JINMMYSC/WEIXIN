import XCTest
@testable import WeTypeReplicaCore

final class CandidatePreferenceTests: XCTestCase {
    private func store() -> WTCandidatePreferenceStore {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "-candidates.json")
        return WTCandidatePreferenceStore(url: url)
    }

    func testPinnedCandidateMovesToFront() {
        let store = store()
        store.pinToFront("三")
        let result = store.apply(to: [.init(text: "一"), .init(text: "二"), .init(text: "三")])
        XCTAssertEqual(result.map(\.text), ["三", "一", "二"])
    }

    func testHiddenCandidateIsFiltered() {
        let store = store()
        store.hide("二")
        let result = store.apply(to: [.init(text: "一"), .init(text: "二"), .init(text: "三")])
        XCTAssertEqual(result.map(\.text), ["一", "三"])
    }
    func testPreferencesPreserveCompatibilitySourceIndexes() {
        let store = store()
        store.pinToFront("你")
        let preordered = [
            WTDisplayedCandidate(sourceIndex: 2, candidate: .init(text: "呢")),
            WTDisplayedCandidate(sourceIndex: 0, candidate: .init(text: "你")),
            WTDisplayedCandidate(sourceIndex: 1, candidate: .init(text: "尼"))
        ]
        let result = store.applyIndexed(to: preordered)
        XCTAssertEqual(result.map { $0.candidate.text }, ["你", "呢", "尼"])
        XCTAssertEqual(result.map(\.sourceIndex), [0, 2, 1])
    }

}
