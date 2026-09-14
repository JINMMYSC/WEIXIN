#if canImport(UIKit)
import Foundation

@MainActor
public enum WTAdvancedProviderBinder {
    private static var bookVideoServices: [ObjectIdentifier: WTHTTPBookVideoService] = [:]

    /// Idempotently binds independently owned rich-content services that are not part of the
    /// local IME engine. This keeps provider lifetime tied to the runtime without Tencent APIs.
    public static func install(runtime: WTKeyboardRuntime, appGroupIdentifier: String) {
        let key = ObjectIdentifier(runtime)
        guard bookVideoServices[key] == nil else { return }

        let configURL = WTSharedStoreFactory.providerConfigurationURL(appGroupIdentifier: appGroupIdentifier)
        let config = WTProviderConfigurationStore.load(from: configURL)
        guard let endpoint = config.bookVideo else {
            runtime.setPanelLoadState(.fallback("未配置富内容服务；视频号、公众号、小程序等入口保留但不会调用腾讯私有接口"), for: .bookVideo)
            return
        }

        let service = WTHTTPBookVideoService(endpoint: endpoint)
        bookVideoServices[key] = service
        runtime.setPanelLoadState(.idle, for: .bookVideo)

        runtime.searchBookVideoProvider = { [weak runtime, weak service] query, kinds in
            guard let runtime, let service else { return [] }
            runtime.setPanelLoadState(.loading, for: .bookVideo)
            do {
                let cards = try await service.search(query: query, kinds: kinds)
                runtime.setPanelLoadState(cards.isEmpty ? .empty : .ready, for: .bookVideo)
                return cards
            } catch {
                runtime.setPanelLoadState(.failed(error.localizedDescription), for: .bookVideo)
                return []
            }
        }

        runtime.performBookVideoProvider = { [weak runtime, weak service] action, card in
            guard let runtime, let service else { return }
            do {
                try await service.perform(action, card: card)
                runtime.setPanelLoadState(.ready, for: .bookVideo)
            } catch {
                runtime.setPanelLoadState(.failed(error.localizedDescription), for: .bookVideo)
            }
        }
    }
}
#endif
