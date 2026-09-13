import XCTest
@testable import WeTypeReplicaCore

final class IMECompatibilityProfileTests: XCTestCase {
    func testRuleReordersWithoutLosingSourceIndexes() {
        let profile = WTIMECompatibilityProfile(rules: [
            .init(id: "x", inputMode: "pinyin26", composition: "ni", preferredCandidateOrder: ["呢", "你"])
        ])
        let result = profile.apply(
            to: [.init(text: "你"), .init(text: "尼"), .init(text: "呢")],
            inputMode: "pinyin26",
            composition: "ni"
        )
        XCTAssertEqual(result.map { $0.candidate.text }, ["呢", "你", "尼"])
        XCTAssertEqual(result.map(\.sourceIndex), [2, 0, 1])
    }

    func testRuleNeverInventsReferenceOnlyCandidate() {
        let profile = WTIMECompatibilityProfile(rules: [
            .init(id: "x", inputMode: "pinyin26", composition: "ni", preferredCandidateOrder: ["不存在", "你"])
        ])
        let result = profile.apply(to: [.init(text: "你"), .init(text: "尼")], inputMode: "pinyin26", composition: "ni")
        XCTAssertEqual(result.map { $0.candidate.text }, ["你", "尼"])
    }

    func testBuilderCreatesRuleOnlyFromSharedVisibleCandidates() {
        let corpus = WTIMEBehaviorCorpus(source: "test", probes: [
            .init(id: "p", category: "ranking", keys: ["n", "i"], inputMode: "pinyin26")
        ])
        let reference = WTIMEBehaviorCapture(implementation: "WeType", snapshots: [
            .init(probeID: "p", composition: "ni", candidates: ["呢", "你", "妮"], isComposing: true)
        ])
        let replica = WTIMEBehaviorCapture(implementation: "Rime", snapshots: [
            .init(probeID: "p", composition: "ni", candidates: ["你", "尼", "呢"], isComposing: true)
        ])
        let profile = WTIMECompatibilityProfileBuilder.build(corpus: corpus, reference: reference, replica: replica)
        XCTAssertEqual(profile.rules.count, 1)
        XCTAssertEqual(profile.rules[0].preferredCandidateOrder, ["呢", "你"])
    }
}
