#if canImport(SwiftUI)
import SwiftUI

private struct WTVoiceRoute: Identifiable {
    let id: UUID
}

@main
struct WTReplicaApp: App {
    @State private var voiceRoute: WTVoiceRoute?

    private var appGroupIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier") as? String
            ?? "group.dev.wetype.replica.shared"
    }

    var body: some Scene {
        WindowGroup {
            WTSettingsAppView()
                .onOpenURL(perform: handleURL)
                .sheet(item: $voiceRoute) { route in
                    WTHostVoiceCaptureView(
                        requestID: route.id,
                        mailbox: WTSharedStoreFactory.serviceMailbox(appGroupIdentifier: appGroupIdentifier)
                    )
                }
        }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "wtreplica", url.host == "voice" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let raw = components?.queryItems?.first(where: { $0.name == "request" })?.value,
           let id = UUID(uuidString: raw) {
            voiceRoute = WTVoiceRoute(id: id)
            return
        }
        let request = WTServiceRequest(kind: .voice, payload: ["source": "host-or-widget"])
        try? WTSharedStoreFactory.serviceMailbox(appGroupIdentifier: appGroupIdentifier)?.submit(request)
        voiceRoute = WTVoiceRoute(id: request.id)
    }
}
#endif
