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
}
#endif
