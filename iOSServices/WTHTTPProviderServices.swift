#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum WTHTTPProviderError: LocalizedError {
    case invalidStatus(Int)
    case malformedResponse
    case providerNotConfigured

    public var errorDescription: String? {
        switch self {
        case .invalidStatus(let code): return "Provider HTTP status \(code)"
        case .malformedResponse: return "Provider response format is invalid"
        case .providerNotConfigured: return "Provider is not configured"
        }
    }
}

private struct WTTextResponse: Codable { var text: String }
private struct WTCloudResponse: Codable { var candidates: [WTCloudCandidate] }
private struct WTHotWordResponse: Codable { var items: [WTHotWordItem] }
private struct WTMediaResponse: Codable { var items: [WTMediaCard] }
private struct WTBookVideoResponse: Codable {
    var items: [WTBookVideoCard]?
    var ok: Bool?
}

public final class WTHTTPProviderClient: @unchecked Sendable {
    private let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }

    public func post<Request: Encodable, Response: Decodable>(
        _ endpoint: WTProviderEndpoint,
        body: Request,
        response: Response.Type
    ) async throws -> Response {
        var request = URLRequest(url: endpoint.url, timeoutInterval: endpoint.timeoutSeconds)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (key, value) in endpoint.headers { request.setValue(value, forHTTPHeaderField: key) }
        request.httpBody = try JSONEncoder().encode(body)
        let (data, rawResponse) = try await session.data(for: request)
        guard let http = rawResponse as? HTTPURLResponse else { throw WTHTTPProviderError.malformedResponse }
        guard (200..<300).contains(http.statusCode) else { throw WTHTTPProviderError.invalidStatus(http.statusCode) }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

public final class WTHTTPAIService: WTAIService {
    private struct Body: Codable { var tool: String; var text: String; var instruction: String? }
    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient
    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) { self.endpoint = endpoint; self.client = client }

    public func run(_ request: WTAIRequest) async throws -> String {
        let result: WTTextResponse = try await client.post(endpoint, body: Body(tool: request.tool.rawValue, text: request.text, instruction: request.instruction), response: WTTextResponse.self)
        return result.text
    }
}

public final class WTHTTPTranslationService: WTTranslationService {
    private struct Body: Codable { var text: String; var source: String; var target: String }
    private struct Response: Codable {
        var source: String?
        var target: String
        var sourceLanguage: String?
        var targetLanguage: String?
    }
    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient
    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) { self.endpoint = endpoint; self.client = client }

    public func translate(_ text: String, from source: String, to target: String) async throws -> WTTranslationResult {
        let result: Response = try await client.post(endpoint, body: Body(text: text, source: source, target: target), response: Response.self)
        return .init(source: result.source ?? text, target: result.target, sourceLanguage: result.sourceLanguage ?? source, targetLanguage: result.targetLanguage ?? target)
    }
}

public final class WTHTTPCloudCandidateService: WTCloudCandidateService {
    private struct Body: Codable { var composition: String; var limit: Int }
    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient
    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) { self.endpoint = endpoint; self.client = client }

    public func candidates(for composition: String, limit: Int) async throws -> [WTCloudCandidate] {
        let result: WTCloudResponse = try await client.post(endpoint, body: Body(composition: composition, limit: limit), response: WTCloudResponse.self)
        return Array(result.candidates.prefix(max(0, limit)))
    }
}

public final class WTHTTPHotWordService {
    private struct Body: Codable { var locale: String }
    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient
    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) { self.endpoint = endpoint; self.client = client }
    public func load(locale: String = "zh-Hans") async throws -> [WTHotWordItem] {
        let result: WTHotWordResponse = try await client.post(endpoint, body: Body(locale: locale), response: WTHotWordResponse.self)
        return result.items.sorted { $0.rank < $1.rank }
    }
}

public final class WTHTTPMediaService {
    private struct Body: Codable { var kind: String; var query: String }
    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient
    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) { self.endpoint = endpoint; self.client = client }
    public func search(kind: WTMediaContentKind, query: String) async throws -> [WTMediaCard] {
        let result: WTMediaResponse = try await client.post(endpoint, body: Body(kind: kind.rawValue, query: query), response: WTMediaResponse.self)
        return result.items
    }
}

/// Clean-room provider boundary for the rich-content surface family called BookVideo in 3.5.3.
/// The endpoint receives only user-visible query/action data and returns replica-owned cards.
public final class WTHTTPBookVideoService: WTBookVideoService {
    private struct Body: Codable {
        var operation: String
        var query: String?
        var kinds: [String]?
        var action: String?
        var card: WTBookVideoCard?
    }

    private let endpoint: WTProviderEndpoint
    private let client: WTHTTPProviderClient

    public init(endpoint: WTProviderEndpoint, client: WTHTTPProviderClient = .init()) {
        self.endpoint = endpoint
        self.client = client
    }

    public func search(query: String, kinds: Set<WTBookVideoKind>) async throws -> [WTBookVideoCard] {
        let body = Body(
            operation: "search",
            query: query,
            kinds: kinds.map(\.rawValue).sorted(),
            action: nil,
            card: nil
        )
        let result: WTBookVideoResponse = try await client.post(endpoint, body: body, response: WTBookVideoResponse.self)
        return result.items ?? []
    }

    public func perform(_ action: WTBookVideoAction, card: WTBookVideoCard) async throws {
        let body = Body(operation: "action", query: nil, kinds: nil, action: action.rawValue, card: card)
        let result: WTBookVideoResponse = try await client.post(endpoint, body: body, response: WTBookVideoResponse.self)
        if result.ok == false { throw WTHTTPProviderError.malformedResponse }
    }
}
#endif
