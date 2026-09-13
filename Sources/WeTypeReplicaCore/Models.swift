import Foundation

public struct WTPoint: Codable, Hashable, Sendable {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) { self.x = x; self.y = y }
}

public struct WTSize: Codable, Hashable, Sendable {
    public var width: Double
    public var height: Double
    public init(width: Double, height: Double) { self.width = width; self.height = height }
}

public struct WTRect: Codable, Hashable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x; self.y = y; self.width = width; self.height = height
    }
    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
    public var center: WTPoint { WTPoint(x: x + width / 2, y: y + height / 2) }
}

/// Effective key description after the original INI inheritance chain has been resolved.
/// Raw strings are intentionally retained for fields where WeType uses rule-driven arrays.
public struct WTKeyboardItem: Codable, Hashable, Sendable {
    public let id: String
    public let rect: WTRect?
    public let input: String?
    public let title: String?
    public let function: String?
    public let style: String?
    public let image: String?
    public let upInput: String?
    public let downInput: String?
    public let floatList: String?
    public let font: String?
    public let upFont: String?
    public let subtitlePosition: String?
    public let rule: String?
    public let floatStyle: String?

    public init(
        id: String,
        rect: WTRect?,
        input: String? = nil,
        title: String? = nil,
        function: String? = nil,
        style: String? = nil,
        image: String? = nil,
        upInput: String? = nil,
        downInput: String? = nil,
        floatList: String? = nil,
        font: String? = nil,
        upFont: String? = nil,
        subtitlePosition: String? = nil,
        rule: String? = nil,
        floatStyle: String? = nil
    ) {
        self.id = id
        self.rect = rect
        self.input = input
        self.title = title
        self.function = function
        self.style = style
        self.image = image
        self.upInput = upInput
        self.downInput = downInput
        self.floatList = floatList
        self.font = font
        self.upFont = upFont
        self.subtitlePosition = subtitlePosition
        self.rule = rule
        self.floatStyle = floatStyle
    }
}

public struct WTKeyboardLayout: Codable, Hashable, Sendable {
    public let name: String
    public let baseSize: WTSize
    public let items: [WTKeyboardItem]
    public init(name: String, baseSize: WTSize, items: [WTKeyboardItem]) {
        self.name = name; self.baseSize = baseSize; self.items = items
    }

    public func item(id: String) -> WTKeyboardItem? { items.first { $0.id == id } }
}
