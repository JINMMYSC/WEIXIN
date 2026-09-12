import Foundation

enum InputEvent: Equatable, Codable {
    case insert(String)
    case deleteBackward
    case commitPending
    case reset
}

private enum InputEventCodingKey: String, CodingKey { case type, text }
private enum InputEventType: String, Codable { case insert, deleteBackward, commitPending, reset }

extension InputEvent {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InputEventCodingKey.self)
        let type = try container.decode(InputEventType.self, forKey: .type)
        switch type {
        case .insert: self = .insert(try container.decode(String.self, forKey: .text))
        case .deleteBackward: self = .deleteBackward
        case .commitPending: self = .commitPending
        case .reset: self = .reset
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InputEventCodingKey.self)
        switch self {
        case let .insert(text):
            try container.encode(InputEventType.insert, forKey: .type)
            try container.encode(text, forKey: .text)
        case .deleteBackward: try container.encode(InputEventType.deleteBackward, forKey: .type)
        case .commitPending: try container.encode(InputEventType.commitPending, forKey: .type)
        case .reset: try container.encode(InputEventType.reset, forKey: .type)
        }
    }
}

struct InputCandidate: Equatable, Codable {
    let id: Int
    let text: String
}

struct InputSnapshot: Equatable, Codable {
    let committedText: String
    let composingText: String
    let candidates: [InputCandidate]

    var isValid: Bool {
        guard !committedText.contains("\0"), !composingText.contains("\0") else { return false }
        return candidates.allSatisfy { $0.id >= 0 && !$0.text.isEmpty && !$0.text.contains("\0") }
    }
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
        _ = restoreIfValid(snapshot)
    }

    @discardableResult
    func restoreIfValid(_ snapshot: InputSnapshot) -> Bool {
        guard snapshot.isValid else { return false }
        self.snapshot = snapshot
        return true
    }

    func serializedSnapshot() throws -> Data {
        try JSONEncoder().encode(snapshot)
    }

    func restore(serialized data: Data) throws {
        let decoded = try JSONDecoder().decode(InputSnapshot.self, from: data)
        guard restoreIfValid(decoded) else { throw RestoreError.invalidSnapshot }
    }

    enum RestoreError: Error, Equatable {
        case invalidSnapshot
    }

    func validate() -> Bool {
        snapshot.isValid
    }
}
