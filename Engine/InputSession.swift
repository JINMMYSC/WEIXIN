import Foundation

enum InputEvent: Equatable {
    case insert(String)
    case deleteBackward
    case commitPending
    case reset
}

struct InputCandidate: Equatable, Codable {
    let id: Int
    let text: String
}

struct InputSnapshot: Equatable, Codable {
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

    @discardableResult
    func commitCandidate(_ text: String) -> InputSnapshot {
        snapshot = InputSnapshot(
            committedText: snapshot.committedText + text,
            composingText: "",
            candidates: []
        )
        return snapshot
    }

    @discardableResult
    func replaceCandidates(_ candidates: [InputCandidate]) -> InputSnapshot {
        snapshot = InputSnapshot(
            committedText: snapshot.committedText,
            composingText: snapshot.composingText,
            candidates: candidates
        )
        return snapshot
    }

    func restore(_ snapshot: InputSnapshot) {
        self.snapshot = snapshot
    }

    func serializedSnapshot() throws -> Data {
        try JSONEncoder().encode(snapshot)
    }

    func restore(serialized data: Data) throws {
        restore(try JSONDecoder().decode(InputSnapshot.self, from: data))
    }

    func validate() -> Bool {
        !snapshot.committedText.contains("\0") && !snapshot.composingText.contains("\0")
    }
}
