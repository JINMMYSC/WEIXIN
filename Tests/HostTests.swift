import XCTest
@testable import WeixinRebuild

final class HostTests: XCTestCase {
    @MainActor
    func testHostProvidesEditableInputForKeyboardSampling() {
        let controller = HostViewController()
        controller.loadViewIfNeeded()
        let input = controller.view.subviews.compactMap { $0 as? UIStackView }
            .flatMap { $0.arrangedSubviews }.compactMap { $0 as? UITextView }.first
        XCTAssertNotNil(input, "The host must provide a real text input for keyboard testing")
        XCTAssertTrue(input?.isEditable == true)
        XCTAssertTrue(input?.isSelectable == true)
        XCTAssertEqual(input?.accessibilityIdentifier, "sampling-input")
    }

    func testBuiltAppContainsKeyboardExtensionWithCorrectEntryPoint() throws {
        let plugins = try XCTUnwrap(Bundle.main.builtInPlugInsURL)
        let bundle = try XCTUnwrap(Bundle(url: plugins.appendingPathComponent("RebuildKeyboard.appex")))
        XCTAssertEqual(bundle.bundleIdentifier, "com.jinmmysc.weixinrebuild.keyboard")
        let info = try XCTUnwrap(bundle.infoDictionary?["NSExtension"] as? [String: Any])
        XCTAssertEqual(info["NSExtensionPointIdentifier"] as? String, "com.apple.keyboard-service")
        XCTAssertEqual(info["NSExtensionPrincipalClass"] as? String, "RebuildKeyboard.KeyboardViewController")
        let attributes = try XCTUnwrap(info["NSExtensionAttributes"] as? [String: Any])
        XCTAssertEqual(attributes["RequestsOpenAccess"] as? Bool, false)
    }
}

