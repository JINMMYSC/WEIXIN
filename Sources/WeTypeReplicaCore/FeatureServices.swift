import Foundation

public enum WTVoiceState: Equatable, Sendable {
    case idle
    case preparing
    case recording(partial: String)
    case recognizing
    case result(String)
    case failed(String)
}

public protocol WTVoiceService: AnyObject {
    var state: WTVoiceState { get }
    func start()
    func stop()
    func cancel()
}

public struct WTTranslationResult: Equatable, Sendable {
    public let source: String
    public let target: String
    public let sourceLanguage: String
    public let targetLanguage: String
    public init(source: String, target: String, sourceLanguage: String, targetLanguage: String) {
        self.source = source; self.target = target
        self.sourceLanguage = sourceLanguage; self.targetLanguage = targetLanguage
    }
}

public protocol WTTranslationService: AnyObject {
    func translate(_ text: String, from source: String, to target: String) async throws -> WTTranslationResult
}

public enum WTAITool: String, Codable, Sendable {
    case askAI
    case rewrite
    case polish
    case copywriting
    case translate
    case custom
}

public struct WTAIRequest: Equatable, Sendable {
    public let tool: WTAITool
    public let text: String
    public let instruction: String?
    public init(tool: WTAITool, text: String, instruction: String? = nil) {
        self.tool = tool; self.text = text; self.instruction = instruction
    }
}

public protocol WTAIService: AnyObject {
    func run(_ request: WTAIRequest) async throws -> String
}

public struct WTCorrectionSuggestion: Equatable, Sendable {
    public let range: Range<String.Index>
    public let original: String
    public let replacement: String
    public init(range: Range<String.Index>, original: String, replacement: String) {
        self.range = range; self.original = original; self.replacement = replacement
    }
}

public protocol WTCorrectionService: AnyObject {
    func suggestions(for text: String) async throws -> [WTCorrectionSuggestion]
}

public struct WTClipboardItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var text: String
    public var createdAt: Date
    public var pinned: Bool
    public init(id: UUID = UUID(), text: String, createdAt: Date = Date(), pinned: Bool = false) {
        self.id = id; self.text = text; self.createdAt = createdAt; self.pinned = pinned
    }
}

public protocol WTClipboardStore: AnyObject {
    var items: [WTClipboardItem] { get }
    func add(_ text: String)
    func setPinned(_ pinned: Bool, id: UUID)
    func delete(id: UUID)
    func clearUnpinned()
}

public struct WTEmojiUsage: Codable, Hashable, Sendable {
    public var symbol: String
    public var count: Int
    public var lastUsedAt: Date
    public init(symbol: String, count: Int = 1, lastUsedAt: Date = Date()) {
        self.symbol = symbol; self.count = count; self.lastUsedAt = lastUsedAt
    }
}

public protocol WTEmojiStore: AnyObject {
    var recent: [WTEmojiUsage] { get }
    func record(_ symbol: String)
}

public struct WTHandwritingStroke: Codable, Hashable, Sendable {
    public struct Point: Codable, Hashable, Sendable {
        public let x: Double
        public let y: Double
        public let t: Double
        public init(x: Double, y: Double, t: Double) { self.x = x; self.y = y; self.t = t }
    }
    public var points: [Point]
    public init(points: [Point]) { self.points = points }
}

public protocol WTHandwritingRecognizer: AnyObject {
    func recognize(strokes: [WTHandwritingStroke]) async throws -> [WTCandidate]
}

public enum WTTransferState: Equatable, Sendable {
    case idle
    case discovering
    case connecting(peer: String)
    case transferring(peer: String, progress: Double)
    case completed(peer: String)
    case failed(String)
}

public struct WTPeerDevice: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public init(id: String, name: String) { self.id = id; self.name = name }
}

public protocol WTDeviceTransferService: AnyObject {
    var state: WTTransferState { get }
    var peers: [WTPeerDevice] { get }
    func startDiscovery()
    func stopDiscovery()
    func send(file: URL, to peer: WTPeerDevice) async throws
}
