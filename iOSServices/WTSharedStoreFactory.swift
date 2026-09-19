#if canImport(UIKit)
import Foundation

public enum WTSharedStoreFactory {
    public static func containerURL(appGroupIdentifier: String) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    public static func clipboard(appGroupIdentifier: String) -> WTJSONClipboardStore? {
        containerURL(appGroupIdentifier: appGroupIdentifier).map {
            WTJSONClipboardStore(url: $0.appendingPathComponent("WeTypeReplica/clipboard.json"))
        }
    }

    public static func emoji(appGroupIdentifier: String) -> WTJSONEmojiStore? {
        containerURL(appGroupIdentifier: appGroupIdentifier).map {
            WTJSONEmojiStore(url: $0.appendingPathComponent("WeTypeReplica/emoji-recent.json"))
        }
    }

    public static func phrases(appGroupIdentifier: String) -> WTJSONPhraseStore? {
        containerURL(appGroupIdentifier: appGroupIdentifier).map {
            WTJSONPhraseStore(url: $0.appendingPathComponent("WeTypeReplica/phrases.json"))
        }
    }

    public static func serviceMailbox(appGroupIdentifier: String) -> WTJSONServiceMailbox? {
        containerURL(appGroupIdentifier: appGroupIdentifier).map {
            WTJSONServiceMailbox(url: $0.appendingPathComponent("WeTypeReplica/service-mailbox.json"))
        }
    }

    public static func providerConfigurationURL(appGroupIdentifier: String) -> URL? {
        containerURL(appGroupIdentifier: appGroupIdentifier)?.appendingPathComponent("WeTypeReplica/provider-config.json")
    }

    public static func deepSeekConfigurationURL(appGroupIdentifier: String) -> URL? {
        containerURL(appGroupIdentifier: appGroupIdentifier)?.appendingPathComponent("WeTypeReplica/deepseek-config.json")
    }
}

/// Persists the user-entered DeepSeek configuration inside the App Group container so the host
/// app and the keyboard extension share one chain. The key is written by the host app only;
/// it never enters the repository, build settings, or CI logs.
public enum WTDeepSeekConfigurationStore {
    public static func load(appGroupIdentifier: String) -> WTDeepSeekConfiguration {
        guard let url = WTSharedStoreFactory.deepSeekConfigurationURL(appGroupIdentifier: appGroupIdentifier),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(WTDeepSeekConfiguration.self, from: data) else {
            return WTDeepSeekConfiguration()
        }
        return value
    }

    @discardableResult
    public static func save(_ configuration: WTDeepSeekConfiguration,
                            appGroupIdentifier: String) -> Bool {
        guard let url = WTSharedStoreFactory.deepSeekConfigurationURL(appGroupIdentifier: appGroupIdentifier) else {
            return false
        }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(configuration)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return true
        } catch {
            return false
        }
    }
}
#endif
