import XCTest
@testable import WeTypeReplicaCore

final class ProviderModelTests: XCTestCase {
    func testCloudCandidateMergeKeepsFirstLocalAndDeduplicates() {
        let local = [WTCandidate(text: "你"), WTCandidate(text: "尼"), WTCandidate(text: "拟")]
        let cloud = [
            WTCloudCandidate(text: "你好", comment: "云", score: 9),
            WTCloudCandidate(text: "尼", comment: "duplicate", score: 8),
            WTCloudCandidate(text: "你们", comment: "云", score: 7)
        ]
        let merged = WTCloudCandidateMerger.merge(local: local, cloud: cloud, limit: 5)
        XCTAssertEqual(merged.map(\.text), ["你", "你好", "你们", "尼", "拟"])
    }

    func testCloudOnlySortsByScore() {
        let cloud = [WTCloudCandidate(text: "B", score: 1), WTCloudCandidate(text: "A", score: 3)]
        XCTAssertEqual(WTCloudCandidateMerger.merge(local: [], cloud: cloud).map(\.text), ["A", "B"])
    }

    func testProviderConfigurationRoundTrip() throws {
        let config = WTProviderConfiguration(ai: .init(url: URL(string: "https://example.com/ai")!, headers: ["X-Key": "x"]))
        let data = try JSONEncoder().encode(config)
        XCTAssertEqual(try JSONDecoder().decode(WTProviderConfiguration.self, from: data), config)
    }
}
