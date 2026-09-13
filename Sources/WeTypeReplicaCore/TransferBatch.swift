import Foundation

public enum WTTransferBatchItemStatus: Codable, Equatable, Sendable {
    case pending
    case transferring(progress: Double)
    case completed
    case failed(message: String)
    case cancelled

    public var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled: return true
        case .pending, .transferring: return false
        }
    }
}

public struct WTTransferBatchItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var status: WTTransferBatchItemStatus
    public var attempts: Int

    public init(id: UUID = UUID(), name: String, status: WTTransferBatchItemStatus = .pending, attempts: Int = 0) {
        self.id = id
        self.name = name
        self.status = status
        self.attempts = max(0, attempts)
    }
}

/// Pure state machine for Share Extension multi-file transfer. Keeping this logic in Core makes
/// cancellation/retry deterministic and testable without Network.framework or an iPhone runtime.
public struct WTTransferBatch: Codable, Equatable, Sendable {
    public private(set) var items: [WTTransferBatchItem]
    public private(set) var cancelled: Bool

    public init(names: [String]) {
        self.items = names.map { WTTransferBatchItem(name: $0) }
        self.cancelled = false
    }

    public var nextPendingIndex: Int? { cancelled ? nil : items.firstIndex { $0.status == .pending } }
    public var failedIndexes: [Int] { items.indices.filter { if case .failed = items[$0].status { return true }; return false } }
    public func retryableFailedIndexes(maxAttempts: Int) -> [Int] {
        let cap = max(1, maxAttempts)
        return failedIndexes.filter { items[$0].attempts < cap }
    }
    public func hasRetryableFailure(maxAttempts: Int) -> Bool { !retryableFailedIndexes(maxAttempts: maxAttempts).isEmpty }
    public var completedCount: Int { items.filter { $0.status == .completed }.count }
    public var isFinished: Bool { !items.isEmpty && items.allSatisfy { $0.status.isTerminal } }
    public var overallProgress: Double {
        guard !items.isEmpty else { return 0 }
        let sum = items.reduce(0.0) { partial, item in
            switch item.status {
            case .completed: return partial + 1
            case .transferring(let progress): return partial + min(max(progress, 0), 1)
            default: return partial
            }
        }
        return sum / Double(items.count)
    }

    @discardableResult
    public mutating func beginNext() -> Int? {
        guard let index = nextPendingIndex else { return nil }
        items[index].attempts += 1
        items[index].status = .transferring(progress: 0)
        return index
    }

    public mutating func updateProgress(_ progress: Double, at index: Int) {
        guard items.indices.contains(index), !cancelled else { return }
        guard case .transferring = items[index].status else { return }
        items[index].status = .transferring(progress: min(max(progress, 0), 1))
    }

    public mutating func markCompleted(_ index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].status = .completed
    }

    public mutating func markFailed(_ index: Int, message: String) {
        guard items.indices.contains(index) else { return }
        items[index].status = .failed(message: message)
    }

    public mutating func retryFailed() { retryFailed(maxAttempts: .max) }

    public mutating func retryFailed(maxAttempts: Int) {
        guard !cancelled else { return }
        let cap = max(1, maxAttempts)
        for index in failedIndexes where items[index].attempts < cap { items[index].status = .pending }
    }

    public mutating func cancel() {
        cancelled = true
        for index in items.indices {
            switch items[index].status {
            case .pending, .transferring: items[index].status = .cancelled
            case .completed, .failed, .cancelled: break
            }
        }
    }
}
