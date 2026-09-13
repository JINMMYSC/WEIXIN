import Foundation

/// File-backed mailbox intended for an App Group container. Keyboard and host app
/// can exchange small service requests without linking either side to the other's UI.
public final class WTJSONServiceMailbox: WTServiceMailbox, @unchecked Sendable {
    private struct State: Codable {
        var requests: [WTServiceRequest] = []
        var responses: [WTServiceResponse] = []
    }

    private let url: URL
    private let lock = NSLock()

    public init(url: URL) {
        self.url = url
    }

    public func submit(_ request: WTServiceRequest) throws {
        try mutate { state in
            state.requests.removeAll { $0.id == request.id }
            state.requests.append(request)
        }
    }

    public func pending() throws -> [WTServiceRequest] {
        try read().requests.sorted { $0.createdAt < $1.createdAt }
    }

    public func complete(_ response: WTServiceResponse) throws {
        try mutate { state in
            state.responses.removeAll { $0.requestID == response.requestID }
            state.responses.append(response)
            state.requests.removeAll { $0.id == response.requestID }
        }
    }

    public func response(for requestID: UUID) throws -> WTServiceResponse? {
        try read().responses.first { $0.requestID == requestID }
    }

    public func remove(requestID: UUID) throws {
        try mutate { state in
            state.requests.removeAll { $0.id == requestID }
            state.responses.removeAll { $0.requestID == requestID }
        }
    }

    private func read() throws -> State {
        lock.lock(); defer { lock.unlock() }
        return try readUnlocked()
    }

    private func mutate(_ body: (inout State) -> Void) throws {
        lock.lock(); defer { lock.unlock() }
        var state = try readUnlocked()
        body(&state)
        try writeUnlocked(state)
    }

    private func readUnlocked() throws -> State {
        guard FileManager.default.fileExists(atPath: url.path) else { return State() }
        let data = try Data(contentsOf: url)
        guard !data.isEmpty else { return State() }
        return try JSONDecoder().decode(State.self, from: data)
    }

    private func writeUnlocked(_ state: State) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(state)
        try data.write(to: url, options: .atomic)
    }
}
