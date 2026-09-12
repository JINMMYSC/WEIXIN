import Foundation

enum InputEvent: Equatable {
    case insert(String)
    case deleteBackward
    case commitPending
    case reset
}

struct InputCandidate: Equatable {
    let id: Int
    let text: String
}

struct InputSnapshot: Equatable {
    let committedText: String
    let composingText: String
    let candidates: [InputCandidate]
}

final class InputSession {
    private(set) var snapshot = InputSnapshot(committedText: "", composingText: "", candidates: [])

    @discardableResult
    func process(_ event: InputEvent) -> InputSnapshot {
        switch event {
        case let .insert(text):
            snapshot = InputSnapshot(
                committedText: snapshot.committedText,
                composingText: snapshot.composingText + text,
                candidates: []
            )
        case .deleteBackward:
            guard !snapshot.composingText.isEmpty else { return snapshot }
            snapshot = InputSnapshot(
                committedText: snapshot.committedText,
                composingText: String(snapshot.composingText.dropLast()),
                candidates: []
            )
        case .commitPending:
            snapshot = InputSnapshot(
                committedText: snapshot.committedText + snapshot.composingText,
                composingText: "",
                candidates: []
            )
        case .reset:
            snapshot = InputSnapshot(committedText: "", composingText: "", candidates: [])
        }
        return snapshot
    }
}
