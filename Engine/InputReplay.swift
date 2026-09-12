import Foundation

/// Deterministic event replay used by host tests and future device trace imports.
/// A replay never mutates the event list, so the same trace can be compared with
/// multiple engine implementations.
struct InputReplay {
    let events: [InputEvent]

    init(_ events: [InputEvent]) {
        self.events = events
    }

    func run(on session: InputSession = InputSession()) -> [InputSnapshot] {
        events.map { session.process($0) }
    }
}
