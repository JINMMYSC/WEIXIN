import XCTest
@testable import WeTypeReplicaCore

final class TransferBatchTests: XCTestCase {
    func testBatchProgressAndRetryOnlyFailedItems() {
        var batch = WTTransferBatch(names: ["a", "b"])
        XCTAssertEqual(batch.beginNext(), 0)
        batch.updateProgress(0.5, at: 0)
        XCTAssertEqual(batch.overallProgress, 0.25, accuracy: 0.0001)
        batch.markFailed(0, message: "network")
        XCTAssertEqual(batch.beginNext(), 1)
        batch.markCompleted(1)
        XCTAssertTrue(batch.isFinished)
        batch.retryFailed()
        XCTAssertEqual(batch.nextPendingIndex, 0)
        XCTAssertFalse(batch.isFinished)
        XCTAssertEqual(batch.items[0].attempts, 1)
    }

    func testCancelMarksPendingAndActiveButPreservesCompleted() {
        var batch = WTTransferBatch(names: ["a", "b", "c"])
        _ = batch.beginNext()
        batch.markCompleted(0)
        _ = batch.beginNext()
        batch.cancel()
        XCTAssertTrue(batch.cancelled)
        XCTAssertEqual(batch.items[0].status, .completed)
        XCTAssertEqual(batch.items[1].status, .cancelled)
        XCTAssertEqual(batch.items[2].status, .cancelled)
        XCTAssertNil(batch.beginNext())
    }
    func testRetryCapPreventsInfiniteShareExtensionLoop() {
        var batch = WTTransferBatch(names: ["a"])
        for _ in 0..<3 {
            XCTAssertEqual(batch.beginNext(), 0)
            batch.markFailed(0, message: "network")
            batch.retryFailed(maxAttempts: 3)
        }
        XCTAssertFalse(batch.hasRetryableFailure(maxAttempts: 3))
        XCTAssertNil(batch.nextPendingIndex)
        XCTAssertEqual(batch.items[0].attempts, 3)
    }

}
