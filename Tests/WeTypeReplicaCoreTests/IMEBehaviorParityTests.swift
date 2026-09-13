import XCTest
@testable import WeTypeReplicaCore

final class IMEBehaviorParityTests: XCTestCase {
    func testExactCaptureProducesPerfectReport() {
        let capture = WTIMEBehaviorCapture(implementation: "a", snapshots: [
            .init(probeID: "p1", composition: "nihao", candidates: ["你好", "你号"], committedText: nil, isComposing: true)
        ])
        let report = WTIMEBehaviorComparator.compare(reference: capture, replica: capture)
        XCTAssertEqual(report.comparedProbeCount, 1)
        XCTAssertEqual(report.exactProbeCount, 1)
        XCTAssertEqual(report.exactProbeFraction, 1)
        XCTAssertEqual(report.averageCandidatePrefixScore, 1)
    }

    func testCandidateOrderMismatchIsReportedAtFirstDifference() {
        let reference = WTIMEBehaviorCapture(implementation: "wetype", snapshots: [
            .init(probeID: "p1", composition: "nihao", candidates: ["你好", "你号", "拟好"], isComposing: true)
        ])
        let replica = WTIMEBehaviorCapture(implementation: "rime", snapshots: [
            .init(probeID: "p1", composition: "nihao", candidates: ["你好", "拟好", "你号"], isComposing: true)
        ])
        let report = WTIMEBehaviorComparator.compare(reference: reference, replica: replica)
        XCTAssertEqual(report.diffs[0].candidatePrefixMatches, 1)
        XCTAssertEqual(report.diffs[0].comparedCandidateCount, 3)
        XCTAssertFalse(report.diffs[0].exact)
    }

    func testMissingProbeIDsAreSeparatedBySide() {
        let reference = WTIMEBehaviorCapture(implementation: "wetype", snapshots: [
            .init(probeID: "reference-only", composition: "", candidates: [], isComposing: false)
        ])
        let replica = WTIMEBehaviorCapture(implementation: "rime", snapshots: [
            .init(probeID: "replica-only", composition: "", candidates: [], isComposing: false)
        ])
        let report = WTIMEBehaviorComparator.compare(reference: reference, replica: replica)
        XCTAssertEqual(report.missingReplicaProbeIDs, ["reference-only"])
        XCTAssertEqual(report.missingReferenceProbeIDs, ["replica-only"])
    }

    func testStarterCorpusHasBroadCoverage() {
        let categories = Set(WTIMEBehaviorStarterCorpus.probes.map(\.category))
        XCTAssertGreaterThanOrEqual(WTIMEBehaviorStarterCorpus.probes.count, 100)
        XCTAssertTrue(categories.isSuperset(of: ["pinyin", "segmentation", "ranking", "fuzzy", "longPhrase", "mixed", "t9", "shuangpin", "wubi", "stroke", "learning", "correction"]))
    }

    func testAdvancedCorpusCarriesModeAndLearningMetadata() {
        XCTAssertTrue(WTIMEBehaviorStarterCorpus.probes.contains { $0.inputMode == "pinyin9" })
        XCTAssertTrue(WTIMEBehaviorStarterCorpus.probes.contains { $0.inputMode == "shuangpin" })
        XCTAssertTrue(WTIMEBehaviorStarterCorpus.probes.contains { $0.inputMode == "wubi86" })
        XCTAssertTrue(WTIMEBehaviorStarterCorpus.probes.contains { $0.inputMode == "stroke" })
        XCTAssertTrue(WTIMEBehaviorStarterCorpus.probes.contains { ($0.repeatCount ?? 1) > 1 && $0.selectCandidateIndex != nil })
    }
}
