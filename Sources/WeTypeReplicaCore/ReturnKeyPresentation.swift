import Foundation

/// Host-context presentation for WeType 3.5.3's rule-driven return key.
/// `STYLE_RETURN` contains a neutral and a brand-green state; the keyboard host decides
/// which label/action style to expose from the active text field's return-key trait.
public enum WTReturnKeyKind: String, Codable, Sendable, CaseIterable {
    case `default`
    case go
    case google
    case join
    case next
    case route
    case search
    case send
    case yahoo
    case done
    case emergencyCall
    case `continue`
}

public struct WTReturnKeyPresentation: Codable, Equatable, Sendable {
    public var kind: WTReturnKeyKind
    public var title: String
    public var usesAccent: Bool

    public init(kind: WTReturnKeyKind = .default, title: String? = nil, usesAccent: Bool? = nil) {
        self.kind = kind
        self.title = title ?? Self.defaultTitle(for: kind)
        self.usesAccent = usesAccent ?? Self.defaultAccent(for: kind)
    }

    public static func defaultTitle(for kind: WTReturnKeyKind) -> String {
        switch kind {
        case .default: return "换行"
        case .go: return "前往"
        case .google: return "Google"
        case .join: return "加入"
        case .next: return "下一项"
        case .route: return "路线"
        case .search: return "搜索"
        case .send: return "发送"
        case .yahoo: return "Yahoo"
        case .done: return "完成"
        case .emergencyCall: return "紧急呼叫"
        case .continue: return "继续"
        }
    }

    /// WeType's original `STYLE_RETURN` has a neutral branch and a #23C891 branch.
    /// The neutral newline state stays gray; semantic action return keys use the brand branch.
    public static func defaultAccent(for kind: WTReturnKeyKind) -> Bool {
        kind != .default
    }
}
