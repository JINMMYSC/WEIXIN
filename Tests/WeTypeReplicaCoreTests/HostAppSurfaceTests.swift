import XCTest
@testable import WeTypeReplicaCore

final class HostAppSurfaceTests: XCTestCase {
    func testAllDiscoveredSetupAssetFoldersAreCatalogued() {
        let expected: Set<String> = [
            "SetupAuxiliaryInput", "SetupClipboard", "SetupDesktop", "SetupDisplaySetting",
            "SetupFuzzyPinyin", "SetupKeyboardSelect", "SetupKeystrokeEffect", "SetupMain",
            "SetupMigrationAssistant", "SetupPlus", "SetupSp", "SetupWb"
        ]
        XCTAssertEqual(WTHostSetupSurfaceCatalog353.ids, expected)
        XCTAssertEqual(Set(WTHostSetupGeometry353.screens), expected)
    }

    func testSetupDisplaySettingHasMeasuredFamilies() {
        XCTAssertNotNil(WTHostSetupGeometry353.geometry(screen: "SetupDisplaySetting", family: "img_keyboard_height"))
        XCTAssertNotNil(WTHostSetupGeometry353.geometry(screen: "SetupDisplaySetting", family: "img_number_26"))
        XCTAssertNotNil(WTHostSetupGeometry353.geometry(screen: "SetupDisplaySetting", family: "img_number_9"))
    }

    func testSetupMainEvidenceLinksToExpectedDestinations() {
        XCTAssertEqual(WTHostSetupSurfaceCatalog353.surface("SetupMain")?.preferredDestination, "settingsHome")
        XCTAssertEqual(WTHostSetupSurfaceCatalog353.surface("SetupMigrationAssistant")?.preferredDestination, "migrationAssistant")
        XCTAssertEqual(WTHostSetupSurfaceCatalog353.surface("SetupDesktop")?.preferredDestination, "desktop")
    }

    func testRNBundleVersionsMatchShippedMetadata() {
        XCTAssertEqual(WTRNBundleBuildCatalog353.setup.version, "1.3.5")
        XCTAssertEqual(WTRNBundleBuildCatalog353.setup.build, 944)
        XCTAssertEqual(WTRNBundleBuildCatalog353.platform.version, "1.2.0")
    }
    func testAllSetupMainFeatureIconFamiliesHaveDestinations() {
        let expected: Set<String> = [
            "icon_app_setup_keyboard", "icon_layout", "icon_app_setup_customize_toolbar",
            "icon_app_setup_vibration", "icon_clipboard", "icon_app_setup_voice",
            "icon_app_setup_pluslogo", "icon_app_setup_air", "icon_app_setup_multiple_devices",
            "icon_app_setup_computer", "icon_setup_migration", "icon_app_setup_privacy",
            "icon_app_setup_help", "icon_app_setup_about"
        ]
        XCTAssertEqual(WTHostMainEntryCatalog353.families, expected)
        for family in expected {
            XCTAssertNotNil(WTHostSetupGeometry353.geometry(screen: "SetupMain", family: family), family)
        }
    }

}
