import XCTest
@testable import WeixinRebuild

final class ResourceLoaderTests: XCTestCase {
    func testMissingResourceIsReportedByName() {
        let testBundle = Bundle(for: ResourceLoaderTests.self)
        XCTAssertThrowsError(try ResourceLoader(bundle: testBundle).loadIndexedResource(named: "not-present")) { error in
            XCTAssertEqual(error as? ResourceLoader.LoadError, .missingResource("not-present"))
        }
    }
}
