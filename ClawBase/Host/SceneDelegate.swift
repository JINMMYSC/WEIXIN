import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let host = UIHostingController(rootView: WTSettingsAppView())
        host.view.backgroundColor = .systemBackground

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = host
        self.window = window
        window.makeKeyAndVisible()
    }
}
