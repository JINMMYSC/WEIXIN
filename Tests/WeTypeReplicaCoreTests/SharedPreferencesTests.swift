import XCTest
@testable import WeTypeReplicaCore

final class SharedPreferencesTests: XCTestCase {
    func testSnapshotReadsSharedKeyboardSettings() {
        let suite = "WTSharedPreferencesTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else { return XCTFail("no defaults") }
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(false, forKey: WTSharedPreferenceKey.keySound)
        defaults.set(true, forKey: WTSharedPreferenceKey.haptic)
        defaults.set(0.7, forKey: WTSharedPreferenceKey.hapticLevel)
        defaults.set("左手", forKey: WTSharedPreferenceKey.oneHandedMode)
        defaults.set(0.79, forKey: WTSharedPreferenceKey.oneHandedWidth)
        defaults.set(1.12, forKey: WTSharedPreferenceKey.fontScale)
        defaults.set(0.83, forKey: WTSharedPreferenceKey.keyboardWidth)
        defaults.set(1.10, forKey: WTSharedPreferenceKey.keyboardHeight)
        defaults.set(-0.12, forKey: WTSharedPreferenceKey.keyboardX)
        defaults.set(0.08, forKey: WTSharedPreferenceKey.keyboardY)

        let snapshot = WTKeyboardPreferenceSnapshot(defaults: defaults)
        XCTAssertFalse(snapshot.keySoundEnabled)
        XCTAssertTrue(snapshot.hapticEnabled)
        XCTAssertEqual(snapshot.hapticLevel, 0.7, accuracy: 0.0001)
        XCTAssertEqual(snapshot.oneHandedMode, .left)
        XCTAssertEqual(snapshot.oneHandedWidth, 0.79, accuracy: 0.0001)
        XCTAssertEqual(snapshot.fontScale, 1.12, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.widthScale, 0.83, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.heightScale, 1.10, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.horizontalOffset, -0.12, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.verticalOffset, 0.08, accuracy: 0.0001)
    }

    func testSnapshotClampsUnsafeValues() {
        let suite = "WTSharedPreferencesClamp.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else { return XCTFail("no defaults") }
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(4.0, forKey: WTSharedPreferenceKey.fontScale)
        defaults.set(0.2, forKey: WTSharedPreferenceKey.keyboardWidth)
        defaults.set(4.0, forKey: WTSharedPreferenceKey.keyboardHeight)
        defaults.set(99.0, forKey: WTSharedPreferenceKey.hapticLevel)

        let snapshot = WTKeyboardPreferenceSnapshot(defaults: defaults)
        XCTAssertEqual(snapshot.fontScale, 1.20, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.widthScale, 0.72, accuracy: 0.0001)
        XCTAssertEqual(snapshot.keyboardAdjustment.heightScale, 1.18, accuracy: 0.0001)
        XCTAssertEqual(snapshot.hapticLevel, 1.0, accuracy: 0.0001)
    }
}
