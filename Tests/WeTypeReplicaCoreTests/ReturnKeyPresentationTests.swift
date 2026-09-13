import XCTest
@testable import WeTypeReplicaCore

final class ReturnKeyPresentationTests: XCTestCase {
    func testDefaultReturnIsNeutralNewline() {
        let p = WTReturnKeyPresentation(kind: .default)
        XCTAssertEqual(p.title, "换行")
        XCTAssertFalse(p.usesAccent)
    }

    func testSemanticReturnKeysUseBrandState() {
        let expectations: [(WTReturnKeyKind, String)] = [
            (.send, "发送"), (.search, "搜索"), (.done, "完成"), (.go, "前往"), (.continue, "继续")
        ]
        for (kind, title) in expectations {
            let p = WTReturnKeyPresentation(kind: kind)
            XCTAssertEqual(p.title, title)
            XCTAssertTrue(p.usesAccent)
        }
    }
}
