#if canImport(ActivityKit)
import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct WTVoiceActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var phase: String
        public var partialText: String
        public var updatedAt: Date
        public var isFinal: Bool

        public init(
            phase: String,
            partialText: String = "",
            updatedAt: Date = Date(),
            isFinal: Bool = false
        ) {
            self.phase = phase
            self.partialText = partialText
            self.updatedAt = updatedAt
            self.isFinal = isFinal
        }
    }

    public var requestID: String
    public var startedAt: Date

    public init(requestID: String, startedAt: Date = Date()) {
        self.requestID = requestID
        self.startedAt = startedAt
    }
}
#endif
