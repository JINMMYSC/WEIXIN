import Foundation

public struct WTProviderEndpoint: Codable, Equatable, Sendable {
    public var url: URL
    public var headers: [String: String]
    public var timeoutSeconds: Double

    public init(url: URL, headers: [String: String] = [:], timeoutSeconds: Double = 15) {
        self.url = url
        self.headers = headers
        self.timeoutSeconds = timeoutSeconds
    }
}

public struct WTProviderConfiguration: Codable, Equatable, Sendable {
    public var ai: WTProviderEndpoint?
    public var translation: WTProviderEndpoint?
    public var cloudCandidate: WTProviderEndpoint?
    public var hotWords: WTProviderEndpoint?
    public var media: WTProviderEndpoint?
    public var bookVideo: WTProviderEndpoint?

    public init(
        ai: WTProviderEndpoint? = nil,
        translation: WTProviderEndpoint? = nil,
        cloudCandidate: WTProviderEndpoint? = nil,
        hotWords: WTProviderEndpoint? = nil,
        media: WTProviderEndpoint? = nil,
        bookVideo: WTProviderEndpoint? = nil
    ) {
        self.ai = ai
        self.translation = translation
        self.cloudCandidate = cloudCandidate
        self.hotWords = hotWords
        self.media = media
        self.bookVideo = bookVideo
    }
}

public struct WTCloudCandidate: Codable, Hashable, Sendable {
    public var text: String
    public var comment: String?
    public var score: Double

    public init(text: String, comment: String? = nil, score: Double = 0) {
        self.text = text
        self.comment = comment
        self.score = score
    }
}

public protocol WTCloudCandidateService: AnyObject {
    func candidates(for composition: String, limit: Int) async throws -> [WTCloudCandidate]
}

public enum WTCloudCandidateMerger {
    /// Merge remote suggestions behind the first local candidate while preserving
    /// deterministic local ordering. Remote duplicates are removed by text.
    public static func merge(local: [WTCandidate], cloud: [WTCloudCandidate], limit: Int = 20) -> [WTCandidate] {
        guard limit > 0 else { return [] }
        if local.isEmpty {
            return cloud.sorted { lhs, rhs in
                if lhs.score == rhs.score { return lhs.text < rhs.text }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map { WTCandidate(text: $0.text, comment: $0.comment) }
        }

        var output: [WTCandidate] = []
        var seen = Set<String>()
        let localTexts = Set(local.map(\.text))
        let first = local[0]
        output.append(first)
        seen.insert(first.text)

        let orderedCloud = cloud.sorted { lhs, rhs in
            if lhs.score == rhs.score { return lhs.text < rhs.text }
            return lhs.score > rhs.score
        }
        for item in orderedCloud where !seen.contains(item.text) && !localTexts.contains(item.text) {
            output.append(WTCandidate(text: item.text, comment: item.comment))
            seen.insert(item.text)
            if output.count >= limit { return output }
        }

        for item in local.dropFirst() where !seen.contains(item.text) {
            output.append(item)
            seen.insert(item.text)
            if output.count >= limit { break }
        }
        return output
    }
}

public enum WTServiceRequestKind: String, Codable, Sendable {
    case voice
    case ai
    case translation
}

public struct WTServiceRequest: Codable, Hashable, Sendable {
    public var id: UUID
    public var kind: WTServiceRequestKind
    public var createdAt: Date
    public var payload: [String: String]

    public init(id: UUID = UUID(), kind: WTServiceRequestKind, createdAt: Date = Date(), payload: [String: String] = [:]) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.payload = payload
    }
}

public struct WTServiceResponse: Codable, Hashable, Sendable {
    public var requestID: UUID
    public var completedAt: Date
    public var value: String?
    public var error: String?

    public init(requestID: UUID, completedAt: Date = Date(), value: String? = nil, error: String? = nil) {
        self.requestID = requestID
        self.completedAt = completedAt
        self.value = value
        self.error = error
    }
}

public protocol WTServiceMailbox: AnyObject {
    func submit(_ request: WTServiceRequest) throws
    func pending() throws -> [WTServiceRequest]
    func complete(_ response: WTServiceResponse) throws
    func response(for requestID: UUID) throws -> WTServiceResponse?
    func remove(requestID: UUID) throws
}
