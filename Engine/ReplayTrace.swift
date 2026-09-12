import Foundation

struct ReplayMetadata: Codable, Equatable {
    let appVersion: String?
    let deviceModel: String?
    let osVersion: String?
    let settingsFingerprint: String?
    let learningState: String?
}

struct ReplayTrace: Codable, Equatable {
    let replay: InputReplay
    let expectedSnapshots: [InputSnapshot]
    let metadata: ReplayMetadata?

    var isWellFormed: Bool {
        metadata != nil && replay.events.count == expectedSnapshots.count && expectedSnapshots.allSatisfy(\.isValid)
    }

    init(
        events: [InputEvent],
        expectedSnapshots: [InputSnapshot],
        metadata: ReplayMetadata? = nil
    ) {
        self.replay = InputReplay(events)
        self.expectedSnapshots = expectedSnapshots
        self.metadata = metadata
    }

    func run() -> [InputSnapshot] { replay.run() }

    func differences() -> [ReplayDifference] {
        ReplayComparator().differences(expected: expectedSnapshots, actual: run())
    }

    func encoded() throws -> Data { try JSONEncoder().encode(self) }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
