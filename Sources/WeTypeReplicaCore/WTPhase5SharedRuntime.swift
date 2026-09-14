import Foundation

/// Phase 5 shared lifecycle contract for the Host app and keyboard extension.
/// The shared App Group is the single source of truth for cross-process state.
public enum WTPhase5SharedRuntime {
    public static let appGroupIdentifier = "group.7518554"
    public static let rootDirectoryName = "WeTypeReplica"

    public enum ProcessRole: String, Codable, Sendable {
        case host
        case keyboard
    }

    private enum Key {
        static let hostHeartbeat = "wt.phase5.heartbeat.host"
        static let keyboardHeartbeat = "wt.phase5.heartbeat.keyboard"
        static let hostBackground = "wt.phase5.background.host"
        static let keyboardBackground = "wt.phase5.background.keyboard"
        static let memoryWarningCount = "wt.phase5.memory-warning.count"
        static let lastMemoryWarning = "wt.phase5.memory-warning.last"
        static let lastPrune = "wt.phase5.transient-prune.last"
    }

    public static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    public static func containerURL() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    public static func rootURL() -> URL? {
        containerURL()?.appendingPathComponent(rootDirectoryName, isDirectory: true)
    }

    public static func markActive(_ role: ProcessRole, at date: Date = Date()) {
        guard let defaults = sharedDefaults() else { return }
        defaults.set(date.timeIntervalSince1970, forKey: heartbeatKey(for: role))
        defaults.removeObject(forKey: backgroundKey(for: role))
    }

    public static func markBackground(_ role: ProcessRole, at date: Date = Date()) {
        guard let defaults = sharedDefaults() else { return }
        defaults.set(date.timeIntervalSince1970, forKey: backgroundKey(for: role))
    }

    public static func noteMemoryWarning(at date: Date = Date()) {
        guard let defaults = sharedDefaults() else { return }
        defaults.set(defaults.integer(forKey: Key.memoryWarningCount) + 1, forKey: Key.memoryWarningCount)
        defaults.set(date.timeIntervalSince1970, forKey: Key.lastMemoryWarning)
    }

    /// Deletes only stale transient handoff files. Persistent clipboard, phrases, emoji history,
    /// Rime user data and provider configuration are intentionally untouched.
    @discardableResult
    public static func pruneTransientFiles(
        olderThan age: TimeInterval = 24 * 60 * 60,
        now: Date = Date(),
        maxFilesPerDirectory: Int = 32
    ) -> Int {
        guard let root = rootURL() else { return 0 }
        let fileManager = FileManager.default
        let directories = [
            root.appendingPathComponent("Phase4Handoff", isDirectory: true),
            root.appendingPathComponent("tmp", isDirectory: true)
        ]
        var removed = 0

        for directory in directories {
            guard let urls = try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            let files = urls.compactMap { url -> (URL, Date)? in
                guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey]),
                      values.isRegularFile == true else { return nil }
                return (url, values.contentModificationDate ?? .distantPast)
            }.sorted { $0.1 > $1.1 }

            for (index, item) in files.enumerated() {
                let stale = now.timeIntervalSince(item.1) > age
                let overBudget = index >= max(0, maxFilesPerDirectory)
                if stale || overBudget {
                    if (try? fileManager.removeItem(at: item.0)) != nil { removed += 1 }
                }
            }
        }

        sharedDefaults()?.set(now.timeIntervalSince1970, forKey: Key.lastPrune)
        return removed
    }

    private static func heartbeatKey(for role: ProcessRole) -> String {
        role == .host ? Key.hostHeartbeat : Key.keyboardHeartbeat
    }

    private static func backgroundKey(for role: ProcessRole) -> String {
        role == .host ? Key.hostBackground : Key.keyboardBackground
    }
}
