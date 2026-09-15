import Foundation

public enum WTPhase14Palette353 {
    public static let keyboardBackground = "#DDDEE2"
    public static let normalKey = "#FFFFFF"
    public static let grayKey = "#AFB4BD"
    public static let accent = "#23C891"
    public static let voiceActiveAccent = "#1FC085"
    public static let hostBackground = "#E2F1F0"
}

public struct WTResolvedKeyFrame353: Equatable, Sendable {
    public let id: String
    public let frame: WTRect
}

public enum WTKeyboardGeometryResolver353 {
    public static func resolve(
        layout: WTKeyboardLayout,
        viewportWidth: Double
    ) -> [WTResolvedKeyFrame353] {
        let scale = viewportWidth / layout.baseSize.width
        let raw = layout.items.compactMap { item -> WTResolvedKeyFrame353? in
            guard let rect = item.rect else { return nil }
            return .init(
                id: item.id,
                frame: .init(
                    x: rect.x * scale,
                    y: rect.y,
                    width: rect.width * scale,
                    height: rect.height
                )
            )
        }

        guard layout.items.contains(where: { $0.id == "KEY_Q" }), viewportWidth == 430 else {
            return raw
        }
        return resolveT26BottomRow(in: raw)
    }

    private static func resolveT26BottomRow(
        in frames: [WTResolvedKeyFrame353]
    ) -> [WTResolvedKeyFrame353] {
        let orderedIDs = ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"]
        let measuredWidths = [74.7, 31.3, 149.0, 34.3, 80.0]
        let omittedIDs: Set<String> = ["KEY_EMOTION", "KEY_SWITCH", "KEY_At"]
        let outerInset = 5.0
        let viewportWidth = 430.0
        let gap = (viewportWidth - (outerInset * 2) - measuredWidths.reduce(0, +))
            / Double(orderedIDs.count - 1)
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0) })

        var x = outerInset
        var measuredFrames: [String: WTResolvedKeyFrame353] = [:]
        for (id, width) in zip(orderedIDs, measuredWidths) {
            guard let rawFrame = framesByID[id] else { continue }
            measuredFrames[id] = .init(
                id: id,
                frame: .init(
                    x: x,
                    y: rawFrame.frame.y,
                    width: width,
                    height: rawFrame.frame.height
                )
            )
            x += width + gap
        }

        return frames.compactMap { frame in
            guard !omittedIDs.contains(frame.id) else { return nil }
            return measuredFrames[frame.id] ?? frame
        }
    }
}
