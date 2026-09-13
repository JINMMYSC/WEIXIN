import Foundation

/// Minimal state that is safe to restore after the keyboard extension is evicted and relaunched.
/// Transient panels, composition text and candidate menus are intentionally excluded.
public struct WTKeyboardSessionSnapshot: Codable, Equatable, Sendable {
    public var version: Int
    public var inputMode: WTInputMode
    public var lastChineseMode: WTInputMode

    public init(version: Int = 1, inputMode: WTInputMode, lastChineseMode: WTInputMode) {
        self.version = version
        self.inputMode = inputMode
        self.lastChineseMode = lastChineseMode.isChineseFamily ? lastChineseMode : .chinesePinyin26
    }

    public init(state: WTKeyboardState) {
        self.init(inputMode: state.inputMode, lastChineseMode: state.lastChineseMode)
    }

    public func restoredState() -> WTKeyboardState {
        WTKeyboardState(inputMode: inputMode, panel: .keyboard, shiftState: .off, lastChineseMode: lastChineseMode)
    }
}

public enum WTKeyboardSessionPersistence {
    public static let defaultsKey = "wt.keyboard.session.v1"

    public static func encode(_ snapshot: WTKeyboardSessionSnapshot) throws -> Data {
        try JSONEncoder().encode(snapshot)
    }

    public static func decode(_ data: Data) throws -> WTKeyboardSessionSnapshot {
        let snapshot = try JSONDecoder().decode(WTKeyboardSessionSnapshot.self, from: data)
        guard snapshot.version == 1 else { throw WTKeyboardSessionPersistenceError.unsupportedVersion(snapshot.version) }
        return snapshot
    }
}

public enum WTKeyboardSessionPersistenceError: Error, Equatable {
    case unsupportedVersion(Int)
}
