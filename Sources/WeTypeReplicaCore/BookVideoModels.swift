import Foundation

/// Clean-room model for the rich WeChat content surfaces discovered in WeType 3.5.3.
/// The original binary calls this feature family "BookVideo" and contains models for
/// video accounts (Finder), official accounts, mini programs, music, movies, books,
/// Baike, stock, hot words, locations and greetings.
public enum WTBookVideoKind: String, Codable, Sendable, CaseIterable {
    case finder
    case publicAccount
    case miniProgram
    case music
    case movie
    case book
    case baike
    case stock
    case hotWord
    case location
    case greeting
    case wordTranslation

    public var title: String {
        switch self {
        case .finder: return "视频号"
        case .publicAccount: return "公众号"
        case .miniProgram: return "小程序"
        case .music: return "音乐"
        case .movie: return "电影"
        case .book: return "图书"
        case .baike: return "百科"
        case .stock: return "股票"
        case .hotWord: return "热词"
        case .location: return "位置"
        case .greeting: return "问候"
        case .wordTranslation: return "翻译"
        }
    }
}

public struct WTBookVideoCard: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var kind: WTBookVideoKind
    public var title: String
    public var subtitle: String?
    public var detail: String?
    public var badge: String?
    public var rating: Double?
    public var deepLink: URL?
    public var payload: [String: String]

    public init(
        id: String,
        kind: WTBookVideoKind,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        badge: String? = nil,
        rating: Double? = nil,
        deepLink: URL? = nil,
        payload: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.badge = badge
        self.rating = rating
        self.deepLink = deepLink
        self.payload = payload
    }
}

public enum WTBookVideoAction: String, Codable, Sendable {
    case open
    case send
    case quickSend
    case dismiss
}

public protocol WTBookVideoService: AnyObject {
    func search(query: String, kinds: Set<WTBookVideoKind>) async throws -> [WTBookVideoCard]
    func perform(_ action: WTBookVideoAction, card: WTBookVideoCard) async throws
}
