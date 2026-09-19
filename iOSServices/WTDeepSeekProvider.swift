#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Transport seam: production uses `URLSession`, tests inject a fixture so the whole chain can
/// be verified without network access or a key.
public protocol WTDeepSeekTransport: Sendable {
    func send(_ request: URLRequest) async throws -> (data: Data, statusCode: Int)
}

public struct WTURLSessionDeepSeekTransport: WTDeepSeekTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (data: Data, statusCode: Int) {
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        return (data, status)
    }
}

/// OpenAI-compatible chat provider. Every keyboard surface that needs generated text goes
/// through here so the request shape and the failure states stay identical.
public struct WTDeepSeekProvider: Sendable {
    public let configuration: WTDeepSeekConfiguration
    private let transport: WTDeepSeekTransport

    public init(configuration: WTDeepSeekConfiguration,
                transport: WTDeepSeekTransport = WTURLSessionDeepSeekTransport()) {
        self.configuration = configuration
        self.transport = transport
    }

    public func askAI(tool: WTAITool, text: String) async throws -> String {
        try await complete(WTDeepSeekPrompt.askAI(tool: tool, text: text))
    }

    public func translate(text: String, from source: String, to target: String) async throws -> String {
        try await complete(WTDeepSeekPrompt.translate(text: text, from: source, to: target))
    }

    public func correct(text: String) async throws -> String {
        try await complete(WTDeepSeekPrompt.correction(text: text))
    }

    public func polish(text: String, style: String) async throws -> String {
        try await complete(WTDeepSeekPrompt.polish(text: text, style: style))
    }

    public func splitWords(text: String) async throws -> [String] {
        let raw = try await complete(WTDeepSeekPrompt.splitWords(text: text))
        return WTDeepSeekPrompt.parseWordList(raw)
    }

    public func complete(_ messages: [WTDeepSeekMessage]) async throws -> String {
        let request = try makeRequest(messages: messages)
        let (data, status) = try await transport.send(request)
        return try Self.decode(data: data, statusCode: status)
    }

    /// Exposed for tests: builds the exact URLRequest the chain sends.
    public func makeRequest(messages: [WTDeepSeekMessage],
                            temperature: Double = 0.3) throws -> URLRequest {
        guard configuration.isConfigured else { throw WTDeepSeekError.notConfigured }
        guard let url = configuration.chatCompletionsURL else { throw WTDeepSeekError.invalidEndpoint }
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let authorization = configuration.authorizationHeader {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        let body = WTDeepSeekChatRequest(
            model: configuration.model,
            messages: messages,
            temperature: temperature,
            stream: false
        )
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    /// Maps the provider payload onto the text every surface expects, and turns API error
    /// payloads into a message the panels can show.
    public static func decode(data: Data, statusCode: Int) throws -> String {
        try WTDeepSeekResponseDecoder.text(from: data, statusCode: statusCode)
    }
}
#endif
