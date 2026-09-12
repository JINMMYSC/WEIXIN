import Foundation
import XCTest
@testable import WeixinRebuild

final class IndexedResourceTests: XCTestCase {
    func testRejectsTruncatedHeader() {
        XCTAssertThrowsError(try IndexedResource(data: Data([1, 2, 3]))) { error in
            XCTAssertEqual(error as? IndexedResource.ParseError, .tooSmall)
        }
    }

    func testParsesIndexedContainerAndExposesRecordBoundaries() throws {
        var data = Data()
        data.append(contentsOf: [0x01, 0x00, 0x00, 0x80])
        data.append(contentsOf: [0x02, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x18, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x1b, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0])
        data.append(contentsOf: [0x41, 0x42, 0x43, 0x44, 0x45])

        let resource = try IndexedResource(data: data)
        XCTAssertEqual(resource.records, [Data([0x41, 0x42, 0x43]), Data([0x44, 0x45])])
    }

    func testRejectsNonIndexedContainer() {
        XCTAssertThrowsError(try IndexedResource(data: Data(repeating: 0, count: 32))) { error in
            XCTAssertEqual(error as? IndexedResource.ParseError, .invalidMagic)
        }
    }

    func testRejectsDescendingOffsets() {
        var data = Data([0x01, 0, 0, 0x80, 0x02, 0, 0, 0])
        data.append(contentsOf: [0x10, 0, 0, 0, 0x0f, 0, 0, 0])
        data.append(Data(repeating: 0, count: 16))
        XCTAssertThrowsError(try IndexedResource(data: data))
    }

    func testRejectsOffsetPastEndOfPayload() {
        var data = Data([0x01, 0, 0, 0x80, 0x01, 0, 0, 0])
        data.append(contentsOf: [0x20, 0, 0, 0])
        data.append(Data(repeating: 0, count: 8))
        XCTAssertThrowsError(try IndexedResource(data: data)) { error in
            XCTAssertEqual(error as? IndexedResource.ParseError, .invalidOffset)
        }
    }
}
