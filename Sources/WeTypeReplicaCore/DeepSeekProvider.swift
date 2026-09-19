import Foundation

/// DeepSeek (OpenAI-compatible) chat provider contract.
///
/// The API key is entered by the user on the host device and stored in the shared App Group
/// container so both the host app and the keyboard extension can read it. It is never part of
/// the repository, the build settings, or CI logs.
public struct WTDeepSeekConfiguration: Codable, Equatable, Sendable {
    public var apiKey: String
    public var baseURL: String
    public var model: String
    public var isEnabled: Bool

    public static let defaultBaseURL = "https://api.deepseek.com"
    public static let defaultModel = "deepseek-chat"

    public init(
        apiKey: String = "",
        baseURL: String = WTDeepSeekConfiguration.defaultBaseURL,
        model: String = WTDeepSeekConfiguration.defaultModel,
        isEnabled: Bool = true
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.isEnabled = isEnabled
    }

    /// The chain is usable only when the user enabled it and supplied a key.
    public var isConfigured: Bool {
        isEnabled && !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// `POST {base}/chat/completions`, tolerating a trailing slash on the configured base URL.
    public var chatCompletionsURL: URL? {
        var base = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !base.isEmpty else { return nil }
        while base.hasSuffix("/") { base.removeLast() }
        return URL(string: base + "/chat/completions")
    }

    public var authorizationHeader: String? {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return key.isEmpty ? nil : "Bearer " + key
    }
}

public struct WTDeepSeekMessage: Codable, Equatable, Sendable {
    public var role: String
    public var content: String
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }

    public static func system(_ content: String) -> WTDeepSeekMessage {
        WTDeepSeekMessage(role: "system", content: content)
    }

    public static func user(_ content: String) -> WTDeepSeekMessage {
        WTDeepSeekMessage(role: "user", content: content)
    }
}

public struct WTDeepSeekChatRequest: Codable, Equatable, Sendable {
    public var model: String
    public var messages: [WTDeepSeekMessage]
    public var temperature: Double
    public var stream: Bool

    public init(
        model: String,
        messages: [WTDeepSeekMessage],
        temperature: Double = 0.3,
        stream: Bool = false
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.stream = stream
    }
}

public struct WTDeepSeekChatResponse: Decodable, Equatable, Sendable {
    public struct Choice: Decodable, Equatable, Sendable {
        public struct Message: Decodable, Equatable, Sendable {
            public var role: String?
            public var content: String?
        }
        public var message: Message?
        public var finishReason: String?

        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }

    public struct APIError: Decodable, Equatable, Sendable {
        public var message: String?
        public var type: String?
        public var code: String?
    }

    public var choices: [Choice]?
    public var error: APIError?

    /// Trimmed assistant text, or `nil` when the provider returned no usable content.
    public var text: String? {
        guard let content = choices?.first?.message?.content else { return nil }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    public var errorMessage: String? {
        guard let error else { return nil }
        return error.message ?? error.code ?? error.type ?? "DeepSeek request failed"
    }
}

/// Prompt builders used by the keyboard surfaces. Keeping them in Core makes the wording and
/// the parsing rules testable without any network access.
/// Failure states shared by the provider and the panels that show its result.
public enum WTDeepSeekError: LocalizedError, Equatable {
    case notConfigured
    case invalidEndpoint
    case emptyResponse
    case invalidStatus(Int, String?)

    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "尚未填写 DeepSeek API Key"
        case .invalidEndpoint: return "DeepSeek 服务地址无效"
        case .emptyResponse: return "DeepSeek 返回了空结果"
        case .invalidStatus(let code, let message):
            if let message, !message.isEmpty { return "DeepSeek 请求失败（\(code)）：\(message)" }
            return "DeepSeek 请求失败（\(code)）"
        }
    }
}

/// Turns an OpenAI-compatible payload into the text every panel expects, and surfaces API error
/// payloads instead of silently returning empty content.
public enum WTDeepSeekResponseDecoder {
    public static func text(from data: Data, statusCode: Int) throws -> String {
        let decoded = try? JSONDecoder().decode(WTDeepSeekChatResponse.self, from: data)
        if statusCode < 200 || statusCode >= 300 {
            throw WTDeepSeekError.invalidStatus(statusCode, decoded?.errorMessage)
        }
        guard let decoded else { throw WTDeepSeekError.emptyResponse }
        if let message = decoded.errorMessage {
            throw WTDeepSeekError.invalidStatus(statusCode, message)
        }
        guard let text = decoded.text else { throw WTDeepSeekError.emptyResponse }
        return text
    }
}

public enum WTDeepSeekPrompt {
    public static let baseSystem = "你是微信输入法的写作助手，只输出结果本身，不要解释、不要加引号、不要使用 Markdown。"

    public static func askAI(tool: WTAITool, text: String) -> [WTDeepSeekMessage] {
        let instruction: String
        switch tool {
        case .askAI: instruction = "回答用户的问题，保持简洁。"
        case .rewrite: instruction = "改写下面的文字，换一种说法但保留原意。"
        case .polish: instruction = "润色下面的文字，保留原意，让表达更通顺自然。"
        case .copywriting: instruction = "根据下面的要点写一段通顺的中文。"
        case .translate: instruction = "把下面的内容翻译成英文。"
        case .custom: instruction = "按用户的指令处理下面的文字。"
        }
        return [.system(baseSystem + instruction), .user(text)]
    }

    public static func translate(text: String, from source: String, to target: String) -> [WTDeepSeekMessage] {
        [
            .system(baseSystem + "把用户提供的文本从\(source)翻译成\(target)，只输出译文。"),
            .user(text),
        ]
    }

    public static func correction(text: String) -> [WTDeepSeekMessage] {
        [
            .system(baseSystem + "改正下面文字里的错别字和用词错误，只输出改正后的整句话。"),
            .user(text),
        ]
    }

    public static func polish(text: String, style: String) -> [WTDeepSeekMessage] {
        [
            .system(baseSystem + "按「\(style)」的风格重写下面的文字，只输出重写后的整段话。"),
            .user(text),
        ]
    }

    public static func splitWords(text: String) -> [WTDeepSeekMessage] {
        [
            .system(baseSystem + "把用户的文字拆成有意义的词语，用中文逗号分隔，只输出词语列表。"),
            .user(text),
        ]
    }

    /// Splits a provider answer that uses Chinese commas, ASCII commas, or newlines.
    public static func parseWordList(_ raw: String) -> [String] {
        raw.split(whereSeparator: { "，,、\n".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
