import Foundation

/// Limits applied only to in-memory presentation caches. Persistent stores remain untouched,
/// so the keyboard can cheaply rebuild the full UI after iOS reclaims extension memory.
public struct WTKeyboardMemoryPressureBudget: Equatable, Sendable {
    public var maxVisibleCandidates: Int
    public var maxClipboardItems: Int
    public var maxPhrases: Int
    public var maxRecentEmoji: Int

    public init(
        maxVisibleCandidates: Int = 12,
        maxClipboardItems: Int = 12,
        maxPhrases: Int = 12,
        maxRecentEmoji: Int = 16
    ) {
        self.maxVisibleCandidates = max(0, maxVisibleCandidates)
        self.maxClipboardItems = max(0, maxClipboardItems)
        self.maxPhrases = max(0, maxPhrases)
        self.maxRecentEmoji = max(0, maxRecentEmoji)
    }

    public static let extensionWarning = WTKeyboardMemoryPressureBudget()

    /// Pinned clipboard items are kept before recent unpinned entries.
    public func trimmedClipboard(_ items: [WTClipboardItem]) -> [WTClipboardItem] {
        guard maxClipboardItems > 0 else { return [] }
        let pinned = items.filter(\.pinned)
        let unpinned = items.filter { !$0.pinned }
        if pinned.count >= maxClipboardItems { return Array(pinned.prefix(maxClipboardItems)) }
        return pinned + unpinned.prefix(maxClipboardItems - pinned.count)
    }
}
