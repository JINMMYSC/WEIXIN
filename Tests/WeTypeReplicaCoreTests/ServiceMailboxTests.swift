import XCTest
@testable import WeTypeReplicaCore

final class ServiceMailboxTests: XCTestCase {
    func testRequestResponseRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let mailbox = WTJSONServiceMailbox(url: dir.appendingPathComponent("mailbox.json"))
        let request = WTServiceRequest(kind: .translation, payload: ["text": "你好"])
        try mailbox.submit(request)
        XCTAssertEqual(try mailbox.pending().map(\.id), [request.id])

        try mailbox.complete(.init(requestID: request.id, value: "hello"))
        XCTAssertTrue(try mailbox.pending().isEmpty)
        XCTAssertEqual(try mailbox.response(for: request.id)?.value, "hello")

        try mailbox.remove(requestID: request.id)
        XCTAssertNil(try mailbox.response(for: request.id))
        try? FileManager.default.removeItem(at: dir)
    }
}
