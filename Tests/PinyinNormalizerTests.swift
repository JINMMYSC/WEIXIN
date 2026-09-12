import XCTest
@testable import WeixinRebuild

final class PinyinNormalizerTests: XCTestCase {
    func testNormalizesCaseAndDropsUnsupportedCharacters() {
        XCTAssertEqual(PinyinNormalizer().normalize(" Nǐ-Hǎo!123 "), "niho")
    }

    func testKeepsInternalApostropheAndRemovesRepeatedOrTrailingSeparators() {
        XCTAssertEqual(PinyinNormalizer().normalize("xi''an'"), "xi'an")
    }

    func testEmptyOrSeparatorOnlyInputProducesEmptyString() {
        XCTAssertEqual(PinyinNormalizer().normalize("'''"), "")
    }
}
