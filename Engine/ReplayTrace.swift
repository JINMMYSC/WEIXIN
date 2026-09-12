import Foundation

struct ReplayTrace: Codable, Equatable {
    let replay: InputReplay
    let expectedSnapshots: [InputSnapshot]

    init(events: [InputEvent], expectedSnapshots: [InputSnapshot]) {
        self.replay = InputReplay(events)
        self.expectedSnapshots = expectedSnapshots
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
