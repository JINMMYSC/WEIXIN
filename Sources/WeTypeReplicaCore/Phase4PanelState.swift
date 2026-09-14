import Foundation

/// Observable service/content state used by Phase 4 keyboard panels.
/// The replica keeps these states explicit because WeType exposes distinct loading, empty,
/// permission, offline, failure/retry and degraded/fallback surfaces instead of collapsing every
/// provider problem into an empty result.
public enum WTPanelLoadState: Equatable, Sendable {
    case idle
    case loading
    case ready
    case empty
    case permissionDenied(String)
    case offline(String)
    case failed(String)
    case fallback(String)

    public var isTerminalFailure: Bool {
        switch self {
        case .permissionDenied, .offline, .failed: return true
        default: return false
        }
    }

    public var message: String? {
        switch self {
        case .permissionDenied(let value), .offline(let value), .failed(let value), .fallback(let value):
            return value
        default:
            return nil
        }
    }
}
