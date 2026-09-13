import XCTest
@testable import WeTypeReplicaCore

final class KeyboardSessionPersistenceTests: XCTestCase {
    func testSessionSnapshotRestoresInputModeButNotTransientPanelOrShift() throws {
        var state = WTKeyboardState(inputMode: .chinesePinyin9)
        state.present(.emoji)
        let snapshot = WTKeyboardSessionSnapshot(state: state)
        let data = try WTKeyboardSessionPersistence.encode(snapshot)
        let restored = try WTKeyboardSessionPersistence.decode(data).restoredState()
        XCTAssertEqual(restored.inputMode, .chinesePinyin9)
        XCTAssertEqual(restored.lastChineseMode, .chinesePinyin9)
        XCTAssertEqual(restored.panel, .keyboard)
        XCTAssertEqual(restored.shiftState, .off)
    }

    func testEnglishSessionRemembersLastChineseMode() {
        var state = WTKeyboardState(inputMode: .chinesePinyin9)
        state.toggleLanguage()
        let snapshot = WTKeyboardSessionSnapshot(state: state)
        let restored = snapshot.restoredState()
        XCTAssertEqual(restored.inputMode, .english26)
        XCTAssertEqual(restored.lastChineseMode, .chinesePinyin9)
        var mutable = restored
        mutable.toggleLanguage()
        XCTAssertEqual(mutable.inputMode, .chinesePinyin9)
    }
}
