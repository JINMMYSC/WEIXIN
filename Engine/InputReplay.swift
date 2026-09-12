import Foundation

/// Deterministic event replay used by host tests and future device trace imports.
/// A replay never mutates the event list, so the same trace can be compared with
/// multiple engine implementations.
struct InputReplay: Codable, Equatable {
    let events: [InputEvent]

    init(_ events: [InputEvent]) {
        self.events = events
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    func run(on session: InputSession = InputSession()) -> [InputSnapshot] {
        events.map { session.process($0) }
    }
}
