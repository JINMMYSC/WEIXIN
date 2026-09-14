import XCTest
@testable import WeTypeReplicaCore

final class GestureParity353Tests: XCTestCase {
    func testDirectionalThresholds() {
        XCTAssertEqual(WT353GestureModel.directionalGesture(dx: 3, dy: -19), .swipeUp)
        XCTAssertEqual(WT353GestureModel.directionalGesture(dx: 3, dy: 19), .swipeDown)
        XCTAssertEqual(WT353GestureModel.directionalGesture(dx: 20, dy: -19), .tap)
        XCTAssertEqual(WT353GestureModel.directionalGesture(dx: 0, dy: -18), .tap)
    }

    func testLongPressGlideClampsToPopupRange() {
        XCTAssertEqual(WT353GestureModel.longPressIndex(origin: 2, translationX: 34, itemCount: 6), 3)
        XCTAssertEqual(WT353GestureModel.longPressIndex(origin: 2, translationX: -1000, itemCount: 6), 0)
        XCTAssertEqual(WT353GestureModel.longPressIndex(origin: 2, translationX: 1000, itemCount: 6), 5)
    }

    func testDeleteClearUsesVerticalDominance() {
        XCTAssertTrue(WT353GestureModel.deleteClearIsArmed(dx: 10, dy: -30))
        XCTAssertFalse(WT353GestureModel.deleteClearIsArmed(dx: 50, dy: -30))
        XCTAssertFalse(WT353GestureModel.deleteClearIsArmed(dx: 0, dy: -28))
    }

    func testDeleteHorizontalStepsAndRollbackTarget() {
        XCTAssertEqual(WT353GestureModel.deleteTargetSteps(dx: -11, dy: 0, currentSteps: 0), 1)
        XCTAssertEqual(WT353GestureModel.deleteTargetSteps(dx: -33, dy: 0, currentSteps: 0), 2)
        XCTAssertEqual(WT353GestureModel.deleteTargetSteps(dx: 0, dy: 0, currentSteps: 4), 0)
        XCTAssertEqual(WT353GestureModel.deleteTargetSteps(dx: 0, dy: -40, currentSteps: 4), 4)
    }

    func testDeleteTapClassification() {
        XCTAssertTrue(WT353GestureModel.isTapDelete(dx: 2, dy: 1, mutated: false, deletedSteps: 0))
        XCTAssertFalse(WT353GestureModel.isTapDelete(dx: 2, dy: 1, mutated: true, deletedSteps: 0))
        XCTAssertFalse(WT353GestureModel.isTapDelete(dx: 11, dy: 0, mutated: false, deletedSteps: 0))
    }
}
