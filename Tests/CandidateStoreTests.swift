import XCTest
@testable import WeixinRebuild

final class CandidateStoreTests: XCTestCase {
    func testNewerVersionReplacesOlderCandidates() {
        let store = CandidateStore()
        XCTAssertTrue(store.apply(CandidateUpdate(version: 1, requestID: 4, candidates: [InputCandidate(id: 0, text: "你")])))
        XCTAssertTrue(store.apply(CandidateUpdate(version: 2, requestID: 1, candidates: [InputCandidate(id: 0, text: "好")])))
        XCTAssertEqual(store.candidate(withID: 0)?.text, "好")
    }

    func testLateOlderUpdateIsRejected() {
        let store = CandidateStore()
        _ = store.apply(CandidateUpdate(version: 3, requestID: 9, candidates: []))
        XCTAssertFalse(store.apply(CandidateUpdate(version: 2, requestID: 99, candidates: [InputCandidate(id: 0, text: "旧")])))
        XCTAssertEqual(store.current?.version, 3)
    }

    func testSameVersionAcceptsNonDecreasingRequestID() {
        let store = CandidateStore()
        _ = store.apply(CandidateUpdate(version: 4, requestID: 2, candidates: []))
        XCTAssertFalse(store.apply(CandidateUpdate(version: 4, requestID: 1, candidates: [])))
        XCTAssertTrue(store.apply(CandidateUpdate(version: 4, requestID: 3, candidates: [])))
    }

    func testDuplicateRequestIDIsRejected() {
        let store = CandidateStore()
        _ = store.apply(CandidateUpdate(version: 1, requestID: 1, candidates: [InputCandidate(id: 0, text: "新")]))
        XCTAssertFalse(store.apply(CandidateUpdate(version: 1, requestID: 1, candidates: [InputCandidate(id: 0, text: "重复")])))
        XCTAssertEqual(store.candidate(withID: 0)?.text, "新")
    }

    func testResetDropsAllCandidateState() {
        let store = CandidateStore()
        _ = store.apply(CandidateUpdate(version: 1, requestID: 1, candidates: [InputCandidate(id: 1, text: "你")]))
        store.reset()
        XCTAssertNil(store.current)
    }
}
