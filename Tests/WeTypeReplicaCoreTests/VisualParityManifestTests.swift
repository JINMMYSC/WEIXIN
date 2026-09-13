import XCTest
@testable import WeTypeReplicaCore

final class VisualParityManifestTests: XCTestCase {
    func testStarterManifestCoversCriticalKeyboardSurfaces() {
        let surfaces = Set(WTVisualParityStarterManifest.cases.map(\.surface))
        XCTAssertGreaterThanOrEqual(WTVisualParityStarterManifest.cases.count, 70)
        XCTAssertTrue(surfaces.isSuperset(of: ["keyboard26", "keyboard9", "candidateExpanded", "keyPopup", "longPressPopup", "emoji", "clipboard", "handwriting", "voice", "translate", "askAI", "settingsHome", "settingsDisplay", "settingsFuzzyPinyin", "settingsMigration", "settingsDesktop"]))
    }

    func testStarterManifestIncludesDarkLandscapeAndHostReturnCases() {
        let cases = WTVisualParityStarterManifest.cases
        XCTAssertTrue(cases.contains { $0.appearance == "dark" })
        XCTAssertTrue(cases.contains { $0.orientation == "landscape" })
        XCTAssertTrue(cases.contains { $0.surface == "returnKey" && $0.hostContext == "send" })
        XCTAssertTrue(cases.contains { $0.surface == "returnKey" && $0.hostContext == "search" })
    }
}
