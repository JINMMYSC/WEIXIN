import XCTest
@testable import WeixinRebuild

final class EditPinyinIndexTests: XCTestCase {
    func testRecordRejectsTrailingBytesEvenIfTheyLookLikeEmptyRecord() {
        XCTAssertThrowsError(try EditPinyinIndex(recordData: Data(repeating: 0, count: 8))) { error in
            XCTAssertEqual(error as? EditPinyinIndex.ParseError, .invalidRecordLength)
        }
    }

    func testFileContainerPreservesLastRecordTrailer() throws {
        let file = Data([1, 0, 0, 128, 1, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 43])
        let index = try EditPinyinIndex(data: file)
        XCTAssertEqual(index.trailingData, Data([43]))
    }

    func testFileContainerKeepsZeroEntryRecord() throws {
        let file = Data([1, 0, 0, 128, 1, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0])
        let index = try EditPinyinIndex(data: file)
        XCTAssertEqual(index.records.count, 1)
        XCTAssertTrue(index.records[0].keys.isEmpty)
    }

    func testEmptyIndexedRecordIsNotSilentlyDropped() {
        let file = Data([1, 0, 0, 128, 1, 0, 0, 0, 12, 0, 0, 0])
        XCTAssertThrowsError(try EditPinyinIndex(data: file))
    }
    func testParsesRecordEnvelopeAndPayload() throws {
        var data = Data()
        data.append(contentsOf: [2, 0, 0, 0])
        data.append(contentsOf: [1, 0, 0, 0, 2, 0, 0, 0])
        data.append(contentsOf: [2, 0, 5, 0])
        data.append(contentsOf: Array("ABCDE".utf8))
        let index = try EditPinyinIndex(recordData: data)
        XCTAssertEqual(index.records.count, 1)
        XCTAssertEqual(index.records[0].keys, [1, 2])
        XCTAssertEqual(index.records[0].endOffsets, [2, 5])
        XCTAssertEqual(String(data: index.records[0].payload, encoding: .utf8), "ABCDE")
        XCTAssertEqual(String(data: index.records[0].payload(for: 0)!, encoding: .utf8), "AB")
        XCTAssertEqual(String(data: index.records[0].payload(for: 1)!, encoding: .utf8), "CDE")
        XCTAssertNil(index.records[0].payload(for: 2))
    }

    func testRejectsNonMonotonicOffsets() {
        var data = Data([2, 0, 0, 0])
        data.append(contentsOf: Array(repeating: 0, count: 8))
        data.append(contentsOf: [3, 0, 2, 0])
        XCTAssertThrowsError(try EditPinyinIndex(recordData: data)) { error in
            XCTAssertEqual(error as? EditPinyinIndex.ParseError, .nonMonotonicOffsets(offset: 0))
        }
    }

    func testRejectsTruncatedPayload() {
        var data = Data([1, 0, 0, 0, 1, 0, 0, 0, 4, 0])
        data.append(contentsOf: [1, 2])
        XCTAssertThrowsError(try EditPinyinIndex(recordData: data)) { error in
            XCTAssertEqual(error as? EditPinyinIndex.ParseError, .payloadOutOfBounds(offset: 0))
        }
    }
}
