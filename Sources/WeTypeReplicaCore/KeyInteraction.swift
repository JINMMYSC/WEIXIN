import Foundation

public enum WTShiftState: String, Codable, Sendable, CaseIterable {
    case off
    case once
    case locked

    public mutating func cycle() {
        switch self {
        case .off: self = .once
        case .once: self = .locked
        case .locked: self = .off
        }
    }
}

public enum WTKeyGesture: String, Codable, Sendable {
    case tap
    case swipeUp
    case swipeDown
    case longPress
}

public enum WTResolvedKeyAction: Equatable, Sendable {
    case engineInput(String)
    case directText(String)
    case function(String)
    case longPressOptions([String], defaultIndex: Int?)
    case none
}

public enum WTRawArrayParser {
    /// Parses the compact array syntax used by the 3.5.3 INI files, for example
    /// `['，','.']`, `[,'icon_keys_voice',]` and `[~,'#23C891']`.
    public static func values(_ raw: String?) -> [String?] {
        guard var raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return [] }
        guard raw.hasPrefix("[") && raw.hasSuffix("]") else {
            return [clean(raw)]
        }
        raw.removeFirst(); raw.removeLast()
        var result: [String?] = []
        var current = ""
        var quote: Character?
        var escaped = false
        for ch in raw {
            if escaped {
                current.append(ch); escaped = false; continue
            }
            if ch == "\\" { escaped = true; current.append(ch); continue }
            if let q = quote {
                current.append(ch)
                if ch == q { quote = nil }
                continue
            }
            if ch == "'" || ch == "\"" {
                quote = ch; current.append(ch); continue
            }
            if ch == "," {
                let v = clean(current)
                result.append(v.isEmpty || v == "~" ? nil : v)
                current = ""
            } else {
                current.append(ch)
            }
        }
        let v = clean(current)
        result.append(v.isEmpty || v == "~" ? nil : v)
        return result
    }

    private static func clean(_ value: String) -> String {
        var s = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.count >= 2,
           ((s.first == "'" && s.last == "'") || (s.first == "\"" && s.last == "\"")) {
            s.removeFirst(); s.removeLast()
        }
        return s.replacingOccurrences(of: "\\'", with: "'")
    }
}

public enum WTFloatListParser {
    /// `FLOATLIST` stores the visible sequence followed by two numeric metadata values.
    /// The visible sequence itself may contain punctuation including commas.
    public static func options(_ raw: String?) -> (items: [String], defaultIndex: Int?) {
        guard let raw, !raw.isEmpty else { return ([], nil) }
        let parts = raw.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 3 else { return (Array(raw).map(String.init), nil) }
        let metadata = Array(parts.suffix(2))
        let content = parts.dropLast(2).joined(separator: ",")
        let options = Array(content).map(String.init)
        let defaultIndex = Int(metadata[0])
        return (options, defaultIndex)
    }
}

public enum WTKeyActionResolver {
    public static func action(
        for item: WTKeyboardItem,
        gesture: WTKeyGesture,
        state: WTKeyboardState
    ) -> WTResolvedKeyAction {
        switch gesture {
        case .longPress:
            let parsed = WTFloatListParser.options(item.floatList)
            return parsed.items.isEmpty ? .none : .longPressOptions(parsed.items, defaultIndex: parsed.defaultIndex)
        case .swipeUp:
            return directVariant(item.upInput, state: state)
        case .swipeDown:
            return directVariant(item.downInput, state: state)
        case .tap:
            break
        }

        // Some 3.5.3 keys express their behavior entirely through style rules.
        if item.id == "KEY_CHANGE" || (item.style?.contains("STYLE_LANGSWITCH") == true) {
            return .function("langswitch")
        }
        if item.id == "KEY_SHIFT" || item.function == "shift" {
            return .function("shift")
        }

        if let fn = item.function, !fn.isEmpty {
            // funcQuote/funcAt are dynamic punctuation keys: resolve their text here.
            if fn == "funcQuote" || fn == "funcAt" {
                let value = variant(item.input, state: state)
                return value.map(WTResolvedKeyAction.directText) ?? .function(fn)
            }
            return .function(fn)
        }
        guard let value = variant(item.input, state: state), !value.isEmpty else { return .none }
        return .engineInput(applyShift(value, state: state))
    }

    public static func visibleTitle(for item: WTKeyboardItem, state: WTKeyboardState) -> String {
        if let title = variant(item.title, state: state), !title.isEmpty { return title }
        if item.id == "KEY_CHANGE" { return state.inputMode == .english26 ? "中" : "英" }
        if item.id == "KEY_SHIFT" {
            switch state.shiftState {
            case .off: return "⇧"
            case .once: return "⇧"
            case .locked: return "⇪"
            }
        }
        if let input = variant(item.input, state: state), !input.isEmpty, input.count <= 8 {
            return applyShift(input, state: state)
        }
        switch item.function {
        case "delete": return "⌫"
        case "return": return "换行"
        case "newline": return "换行"
        case "space": return "空格"
        case "emoji": return "☺︎"
        case "123": return "123"
        case "fullSymbol", "symbols": return "符号"
        case "🌐": return "◉"
        default: return ""
        }
    }

    public static func variant(_ raw: String?, state: WTKeyboardState) -> String? {
        let values = WTRawArrayParser.values(raw)
        guard !values.isEmpty else { return nil }
        if values.count == 1 { return values[0] }
        let index: Int
        switch state.inputMode {
        case .english26: index = 1
        case .wubi: index = min(2, values.count - 1)
        case .doublePinyin: index = min(4, values.count - 1)
        default: index = 0
        }
        if index < values.count, let value = values[index] { return value }
        return values.compactMap { $0 }.first
    }

    private static func directVariant(_ raw: String?, state: WTKeyboardState) -> WTResolvedKeyAction {
        guard let value = variant(raw, state: state), !value.isEmpty else { return .none }
        return .directText(value)
    }

    private static func applyShift(_ value: String, state: WTKeyboardState) -> String {
        guard state.inputMode == .english26, state.shiftState != .off else { return value.lowercased() }
        return value.uppercased()
    }
}
