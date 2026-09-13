import XCTest
@testable import WeTypeReplicaCore

final class TransferProtocolTests: XCTestCase {
    func testEnvelopeSanitizesNameAndChunkSize() {
        let envelope = WTTransferEnvelope(
            fileName: "../bad/name:demo.txt",
            totalSize: 123,
            sha256Hex: "AABB",
            chunkSize: 1
        )
        XCTAssertEqual(envelope.fileName, "name_demo.txt")
        XCTAssertEqual(envelope.sha256Hex, "aabb")
        XCTAssertEqual(envelope.chunkSize, 16 * 1024)
    }

    func testResumeOffsetClampsToFileBounds() {
        XCTAssertEqual(WTTransferProtocol.clampedResumeOffset(-10, totalSize: 100), 0)
        XCTAssertEqual(WTTransferProtocol.clampedResumeOffset(50, totalSize: 100), 50)
        XCTAssertEqual(WTTransferProtocol.clampedResumeOffset(150, totalSize: 100), 100)
    }

    func testControlFrameRoundTripLengthPrefix() throws {
        let payload = Data("hello".utf8)
        let framed = try WTTransferProtocol.frame(payload)
        XCTAssertEqual(try WTTransferProtocol.payloadLength(from: framed.prefix(4)), payload.count)
        XCTAssertEqual(framed.dropFirst(4), payload)
    }

    func testEncryptedEnvelopeRoundTripsMetadata() throws {
        let envelope = WTTransferEnvelope(
            transferID: UUID(),
            fileName: "demo.bin",
            totalSize: 999,
            sha256Hex: "ABCD",
            chunkSize: 64 * 1024,
            authTagHex: "FF00",
            encryption: .chacha20poly1305,
            keySaltHex: "00112233445566778899aabbccddeeff"
        )
        let data = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(WTTransferEnvelope.self, from: data)
        XCTAssertEqual(decoded, envelope)
        XCTAssertEqual(decoded.version, 3)
        XCTAssertEqual(decoded.encryption, .chacha20poly1305)
        XCTAssertEqual(decoded.authTagHex, "ff00")
    }

    func testEncryptedResumeAlignsToPlaintextChunkBoundary() {
        let chunk = 64 * 1024
        XCTAssertEqual(WTTransferProtocol.alignedResumeOffset(0, totalSize: 1_000_000, chunkSize: chunk), 0)
        XCTAssertEqual(WTTransferProtocol.alignedResumeOffset(70_000, totalSize: 1_000_000, chunkSize: chunk), Int64(chunk))
        XCTAssertEqual(WTTransferProtocol.alignedResumeOffset(1_000_000, totalSize: 1_000_000, chunkSize: chunk), 1_000_000)
    }

    func testEncryptedRecordFrameRoundTripLengthPrefix() throws {
        let payload = Data(repeating: 0xA5, count: 1024)
        let framed = try WTTransferProtocol.encryptedRecordFrame(payload)
        XCTAssertEqual(try WTTransferProtocol.encryptedRecordLength(from: framed.prefix(4)), payload.count)
        XCTAssertEqual(framed.dropFirst(4), payload)
    }

    func testAckCodableRoundTrip() throws {
        let id = UUID()
        let ack = WTTransferAck(transferID: id, success: true, receivedSize: 42, sha256Hex: "DEAD")
        let data = try JSONEncoder().encode(ack)
        XCTAssertEqual(try JSONDecoder().decode(WTTransferAck.self, from: data), WTTransferAck(transferID: id, success: true, receivedSize: 42, sha256Hex: "dead"))
    }
}
