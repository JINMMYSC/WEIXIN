import XCTest
@testable import WeTypeReplicaCore

final class TransferTrustedDevicesTests: XCTestCase {
    func testRecordSuccessfulTransferCreatesAndUpdatesDevice() throws {
        let t0 = Date(timeIntervalSince1970: 100)
        let t1 = Date(timeIntervalSince1970: 200)
        var registry = WTTrustedTransferRegistry()
        registry.recordSuccessfulTransfer(to: .init(id: "peer-1", name: "iPhone"), at: t0)
        registry.recordSuccessfulTransfer(to: .init(id: "peer-1", name: "New iPhone"), at: t1)
        XCTAssertEqual(registry.activeDevices.count, 1)
        XCTAssertEqual(registry.activeDevices[0].name, "New iPhone")
        XCTAssertEqual(registry.activeDevices[0].successfulTransfers, 2)
        XCTAssertEqual(registry.activeDevices[0].firstTrustedAt, t0)
        XCTAssertEqual(registry.activeDevices[0].lastSeenAt, t1)

        let data = try registry.encoded()
        XCTAssertEqual(try WTTrustedTransferRegistry.decode(data), registry)
    }

    func testRevokeRestoreAndForget() {
        let peer = WTPeerDevice(id: "peer-2", name: "Mac")
        var registry = WTTrustedTransferRegistry()
        registry.recordSuccessfulTransfer(to: peer, at: Date(timeIntervalSince1970: 10))
        registry.revoke(id: peer.id, at: Date(timeIntervalSince1970: 20))
        XCTAssertTrue(registry.activeDevices.isEmpty)
        XCTAssertEqual(registry.revokedDevices.map(\.id), [peer.id])

        registry.restore(id: peer.id, at: Date(timeIntervalSince1970: 30))
        XCTAssertEqual(registry.activeDevices.map(\.id), [peer.id])
        registry.forget(id: peer.id)
        XCTAssertNil(registry.device(id: peer.id))
    }

    func testPruneOnlyOldRevokedEntries() {
        var registry = WTTrustedTransferRegistry(devices: [
            .init(id: "old", name: "Old", revokedAt: Date(timeIntervalSince1970: 10)),
            .init(id: "new", name: "New", revokedAt: Date(timeIntervalSince1970: 30)),
            .init(id: "active", name: "Active", revokedAt: nil)
        ])
        registry.pruneRevoked(olderThan: Date(timeIntervalSince1970: 20))
        XCTAssertNil(registry.device(id: "old"))
        XCTAssertNotNil(registry.device(id: "new"))
        XCTAssertNotNil(registry.device(id: "active"))
    }
}
