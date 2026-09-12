import XCTest
@testable import WeixinRebuild

final class EditPinyinIndexTests: XCTestCase {
    func testParsesRecordEnvelopeAndPayload() throws {
        var data = Data()
        data.append(contentsOf: [2, 0, 0, 0])
        data.append(contentsOf: [1, 0, 0, 0, 2, 0, 0, 0])
        data.append(contentsOf: [2, 0, 5, 0])
        data.append(contentsOf: Array("你好abc".utf8))
        let index = try EditPinyinIndex(data: data)
        XCTAssertEqual(index.records.count, 1)
        XCTAssertEqual(index.records[0].keys, [1, 2])
        XCTAssertEqual(index.records[0].endOffsets, [2, 5])
        XCTAssertEqual(String(data: index.records[0].payload, encoding: .utf8), "你好abc")
    }

    func testRejectsNonMonotonicOffsets() {
        var data = Data([2, 0, 0, 0])
        data.append(contentsOf: Array(repeating: 0, count: 8))
        data.append(contentsOf: [3, 0, 2, 0])
        XCTAssertThrowsError(try EditPinyinIndex(data: data)) { error in
            XCTAssertEqual(error as? EditPinyinIndex.ParseError, .nonMonotonicOffsets(offset: 0))
        }
    }

    func testRejectsTruncatedPayload() {
        var data = Data([1, 0, 0, 0, 1, 0, 0, 0, 4, 0])
        data.append(contentsOf: [1, 2])
        XCTAssertThrowsError(try EditPinyinIndex(data: data)) { error in
            XCTAssertEqual(error as? EditPinyinIndex.ParseError, .payloadOutOfBounds(offset: 0))
        }
    }
}
