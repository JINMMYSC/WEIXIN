import Foundation

struct KeyboardOutput: Equatable {
    let snapshot: InputSnapshot
    let committedText: String?
}

final class KeyboardSessionBridge {
    private let session: InputSession

    init(session: InputSession = InputSession()) {
        self.session = session
    }

    @discardableResult
    func handle(_ event: InputEvent) -> KeyboardOutput {
        let pending = event == .commitPending ? session.snapshot.composingText : nil
        let snapshot = session.process(event)
        return KeyboardOutput(snapshot: snapshot, committedText: pending?.isEmpty == false ? pending : nil)
    }
}
