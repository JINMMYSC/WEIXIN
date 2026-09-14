import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private static let appGroupID = WTPhase5SharedRuntime.appGroupIdentifier
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let host = UIHostingController(rootView: WTHostHomeParityView())
        host.view.backgroundColor = UIColor(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0, alpha: 1)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = host
        self.window = window
        window.makeKeyAndVisible()

        WTPhase5SharedRuntime.markActive(.host)
        _ = WTPhase5SharedRuntime.pruneTransientFiles()

        if let url = connectionOptions.urlContexts.first?.url {
            DispatchQueue.main.async { [weak self] in self?.openPhase4Route(url) }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        WTPhase5SharedRuntime.markActive(.host)
        _ = WTPhase5SharedRuntime.pruneTransientFiles()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        WTPhase5SharedRuntime.markBackground(.host)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        WTPhase5SharedRuntime.markBackground(.host)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        openPhase4Route(url)
    }

    private func openPhase4Route(_ url: URL) {
        guard url.scheme?.lowercased() == "wtreplica" else { return }
        switch url.host?.lowercased() {
        case "voice":
            openVoice(url)
        case "quick-send":
            presentRoute(.quickSend)
        case "picture":
            presentRoute(.picture)
        default:
            break
        }
    }

    private func openVoice(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let raw = components.queryItems?.first(where: { $0.name == "request" })?.value,
              let requestID = UUID(uuidString: raw),
              let groupURL = WTPhase5SharedRuntime.containerURL() else {
            presentRoute(.voiceUnavailable)
            return
        }
        let mailbox = WTJSONServiceMailbox(url: groupURL.appendingPathComponent("WeTypeReplica/service-mailbox.json"))
        let view = WTHostVoiceCaptureView(requestID: requestID, mailbox: mailbox)
        present(UIHostingController(rootView: view))
    }

    private func presentRoute(_ route: WTHostPhase4Route) {
        let view = WTHostPhase4RouteView(route: route, appGroupIdentifier: Self.appGroupID)
        present(UIHostingController(rootView: view))
    }

    private func present(_ controller: UIViewController) {
        controller.modalPresentationStyle = .pageSheet
        guard let root = window?.rootViewController else { return }
        var presenter = root
        while let next = presenter.presentedViewController { presenter = next }
        presenter.present(controller, animated: true)
    }
}
