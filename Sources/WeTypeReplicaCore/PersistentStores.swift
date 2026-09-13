import Foundation

public struct WTPhraseItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var text: String
    public var createdAt: Date
    public var sortOrder: Int

    public init(id: UUID = UUID(), text: String, createdAt: Date = Date(), sortOrder: Int = 0) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}

public protocol WTPhraseStore: AnyObject {
    var items: [WTPhraseItem] { get }
    func add(_ text: String)
    func delete(id: UUID)
    func move(from source: Int, to destination: Int)
}

private enum WTJSONStoreIO {
    static func load<T: Decodable>(_ type: T.Type, from url: URL, fallback: T) -> T {
        guard let data = try? Data(contentsOf: url), let decoded = try? JSONDecoder().decode(T.self, from: data) else { return fallback }
        return decoded
    }

    static func save<T: Encodable>(_ value: T, to url: URL) {
        let fm = FileManager.default
        try? fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}

public final class WTJSONClipboardStore: WTClipboardStore {
    public private(set) var items: [WTClipboardItem]
    private let url: URL
    private let maxItems: Int

    public init(url: URL, maxItems: Int = 100) {
        self.url = url
        self.maxItems = max(1, maxItems)
        self.items = WTJSONStoreIO.load([WTClipboardItem].self, from: url, fallback: [])
        sort()
    }

    public func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.removeAll { $0.text == trimmed && !$0.pinned }
        items.append(.init(text: trimmed))
        trimAndSave()
    }

    public func setPinned(_ pinned: Bool, id: UUID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].pinned = pinned
        sort(); save()
    }

    public func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    public func clearUnpinned() {
        items.removeAll { !$0.pinned }
        save()
    }

    private func sort() {
        items.sort {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            return $0.createdAt > $1.createdAt
        }
    }

    private func trimAndSave() {
        sort()
        let pinned = items.filter(\.pinned)
        let unpinned = Array(items.filter { !$0.pinned }.prefix(maxItems))
        items = pinned + unpinned
        save()
    }

    private func save() { WTJSONStoreIO.save(items, to: url) }
}

public final class WTJSONEmojiStore: WTEmojiStore {
    public private(set) var recent: [WTEmojiUsage]
    private let url: URL
    private let maxRecent: Int

    public init(url: URL, maxRecent: Int = 48) {
        self.url = url
        self.maxRecent = max(1, maxRecent)
        self.recent = WTJSONStoreIO.load([WTEmojiUsage].self, from: url, fallback: [])
        resort()
    }

    public func record(_ symbol: String) {
        guard !symbol.isEmpty else { return }
        if let i = recent.firstIndex(where: { $0.symbol == symbol }) {
            recent[i].count += 1
            recent[i].lastUsedAt = Date()
        } else {
            recent.append(.init(symbol: symbol))
        }
        resort()
        recent = Array(recent.prefix(maxRecent))
        WTJSONStoreIO.save(recent, to: url)
    }

    private func resort() {
        recent.sort {
            if $0.count != $1.count { return $0.count > $1.count }
            return $0.lastUsedAt > $1.lastUsedAt
        }
    }
}

public final class WTJSONPhraseStore: WTPhraseStore {
    public private(set) var items: [WTPhraseItem]
    private let url: URL

    public init(url: URL) {
        self.url = url
        self.items = WTJSONStoreIO.load([WTPhraseItem].self, from: url, fallback: [])
        normalize()
    }

    public func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !items.contains(where: { $0.text == trimmed }) else { return }
        items.append(.init(text: trimmed, sortOrder: items.count))
        reindexAndSave()
    }

    public func delete(id: UUID) {
        items.removeAll { $0.id == id }
        reindexAndSave()
    }

    public func move(from source: Int, to destination: Int) {
        guard items.indices.contains(source), destination >= 0, destination <= items.count else { return }
        let item = items.remove(at: source)
        let target = min(destination, items.count)
        items.insert(item, at: target)
        reindexAndSave()
    }

    private func normalize() {
        items.sort { $0.sortOrder < $1.sortOrder }
        for i in items.indices { items[i].sortOrder = i }
    }

    private func reindexAndSave() {
        for i in items.indices { items[i].sortOrder = i }
        WTJSONStoreIO.save(items, to: url)
    }
}
