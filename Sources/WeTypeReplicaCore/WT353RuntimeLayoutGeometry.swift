import Foundation

/// Runtime geometry resolved from user-visible WeType 3.5.3 reference surfaces.
///
/// The extracted INI files contain rule-driven placeholder rectangles. Those raw rectangles are
/// evidence, but they are not always the final geometry shown by the product. This resolver keeps
/// the generated layout semantics and applies only final rectangles measured from shipped 3.5.3
/// preview/tutorial surfaces.
public enum WT353RuntimeLayoutGeometry {
    public static func primaryLayout(_ layout: WTKeyboardLayout, mode: WTInputMode) -> WTKeyboardLayout {
        switch mode {
        case .chinesePinyin26, .english26, .doublePinyin, .wubi:
            return resolvedT26(layout)
        case .chinesePinyin9, .stroke:
            return resolvedT9(layout)
        case .handwriting:
            return layout
        }
    }

    public static func resolvedT26(_ layout: WTKeyboardLayout) -> WTKeyboardLayout {
        let hidden: Set<String> = ["KEY_EMOTION", "KEY_SWITCH", "KEY_At"]
        let rects: [String: WTRect] = [
            "KEY_123": WTRect(x: 5, y: 173, width: 75, height: 46),
            "KEY_,": WTRect(x: 86, y: 173, width: 35, height: 46),
            "KEY_SPACE": WTRect(x: 127, y: 173, width: 147, height: 46),
            "KEY_CHANGE": WTRect(x: 280, y: 173, width: 46, height: 46),
            "KEY_RETURN": WTRect(x: 332, y: 173, width: 77, height: 46),
        ]
        return rebuilding(layout, hidden: hidden, rects: rects, nameSuffix: "_runtime353")
    }

    public static func resolvedT9(_ layout: WTKeyboardLayout) -> WTKeyboardLayout {
        let hidden: Set<String> = ["VIEW_LIST", "KEY_SWITCH", "KEY_EMOTION"]
        let rects: [String: WTRect] = [
            "KEY_SYMB": WTRect(x: 5, y: 171, width: 68, height: 50),
            "KEY_123": WTRect(x: 79, y: 171, width: 50, height: 50),
            "KEY_SPACE": WTRect(x: 136, y: 171, width: 142, height: 50),
            "KEY_ABC": WTRect(x: 284, y: 171, width: 50, height: 50),
            "KEY_RETURN": WTRect(x: 341, y: 115, width: 68, height: 106),
        ]
        let base = rebuilding(layout, hidden: hidden, rects: rects, nameSuffix: "_runtime353")
        let punctuation = ["，", "。", "！", "？"].enumerated().map { index, symbol in
            WTKeyboardItem(
                id: "WT353_T9_PUNCT_\(index)",
                // Measured 3.5.3 nine-key rows: the punctuation column shares the 56 pt row
                // pitch of the number grid instead of the extracted 40.5 pt placeholder.
                rect: WTRect(x: 5, y: 3 + Double(index) * 56, width: 69, height: 49.33),
                input: symbol,
                title: symbol,
                function: "funcQuote",
                style: "STYLE_GRAY"
            )
        }
        return WTKeyboardLayout(name: base.name, baseSize: base.baseSize, items: base.items + punctuation)
    }

    private static func rebuilding(
        _ layout: WTKeyboardLayout,
        hidden: Set<String>,
        rects: [String: WTRect],
        nameSuffix: String
    ) -> WTKeyboardLayout {
        let items = layout.items.compactMap { item -> WTKeyboardItem? in
            guard !hidden.contains(item.id) else { return nil }
            return copy(item, rect: rects[item.id] ?? item.rect)
        }
        return WTKeyboardLayout(name: layout.name + nameSuffix, baseSize: layout.baseSize, items: items)
    }

    private static func copy(_ item: WTKeyboardItem, rect: WTRect?) -> WTKeyboardItem {
        WTKeyboardItem(
            id: item.id,
            rect: rect,
            input: item.input,
            title: item.title,
            function: item.function,
            style: item.style,
            image: item.image,
            upInput: item.upInput,
            downInput: item.downInput,
            floatList: item.floatList,
            font: item.font,
            upFont: item.upFont,
            subtitlePosition: item.subtitlePosition,
            rule: item.rule,
            floatStyle: item.floatStyle
        )
    }
}
