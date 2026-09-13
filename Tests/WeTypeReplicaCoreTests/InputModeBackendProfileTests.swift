import XCTest
@testable import WeTypeReplicaCore

final class InputModeBackendProfileTests: XCTestCase {
    func testSafeProfileOnlyForcesAsciiSemantic() {
        XCTAssertEqual(WTRimeBackendProfile.safeDefault[.english26]?.options["ascii_mode"], true)
        XCTAssertEqual(WTRimeBackendProfile.safeDefault[.chinesePinyin26]?.options["ascii_mode"], false)
        XCTAssertNil(WTRimeBackendProfile.safeDefault[.wubi]?.schemaID)
    }

    func testOverrideCanBindConcreteSchemaWithoutChangingOtherModes() {
        let override = WTRimeBackendProfile(modes: [
            .wubi: .init(schemaID: "wubi86", options: ["ascii_mode": false])
        ])
        let merged = WTRimeBackendProfile.safeDefault.merging(override)
        XCTAssertEqual(merged[.wubi]?.schemaID, "wubi86")
        XCTAssertEqual(merged[.english26]?.options["ascii_mode"], true)
    }

    func testProfileRoundTripsJSON() throws {
        let profile = WTRimeBackendProfile(modes: [
            .doublePinyin: .init(schemaID: "double_pinyin", properties: ["variant": "abc"])
        ])
        let data = try JSONEncoder().encode(profile)
        XCTAssertEqual(try JSONDecoder().decode(WTRimeBackendProfile.self, from: data), profile)
    }
}
