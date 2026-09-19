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

/// Light-mode keyboard geometry measured from WeChat Input 3.5.3 recordings captured on
/// iPhone 15 Pro Max (430 x 932 pt, 3x). Horizontal values are final screen points; vertical
/// values are offsets inside the keyboard canvas, whose origin is the top of the key area.
///
/// Every value was read from 1290 x 2796 source frames, where 3 px equals 1 pt. The
/// measurements repeat across recordings 1, 5, 6, 7 and 8, so they describe the shipped
/// product rather than one moment of one video.
public enum WTMeasuredKeyboard353 {
    public static let viewportWidth: Double = 430
    /// Screen-space top edge and total height of the keyboard surface.
    public static let panelTop: Double = 561
    public static let panelHeight: Double = 371
    /// Header carrying either the toolbar row or the candidate row above the key area.
    public static let headerHeight: Double = 72.33
    /// Canvas holding the four key rows plus the measured bottom bar.
    public static let canvasHeight: Double = 298.67
    /// Height of the four key rows themselves, excluding the bottom bar.
    public static let keyAreaHeight: Double = 224

    public static let keyInset: Double = 5
    public static let letterKeyWidth: Double = 36
    public static let letterKeyPitch: Double = 42.667
    public static let functionKeyWidth: Double = 48.33
    public static let rowHeight: Double = 46
    /// Measured widths and origins of the 26-key bottom row, left to right.
    public static let t26BottomRowIDs = ["KEY_123", "KEY_,", "KEY_SPACE", "KEY_CHANGE", "KEY_RETURN"]
    public static let t26BottomRowWidths: [Double] = [79.33, 36, 154.33, 39.67, 85.33]
    public static let t26BottomRowOrigins: [Double] = [5, 90.67, 133, 294, 340]
    public static let t26HiddenIDs: Set<String> = ["KEY_EMOTION", "KEY_SWITCH", "KEY_At"]

    /// Measured nine-key geometry: a 72 pt gutter on each side of three 83.67 pt columns.
    public static let t9GutterWidth: Double = 72
    public static let t9NumberWidth: Double = 83.67
    public static let t9GutterLeadingX: Double = 5
    public static let t9NumberOrigins: [Double] = [83.33, 173.33, 263.67]
    public static let t9GutterTrailingX: Double = 353.33
    public static let t9BottomRowIDs = ["KEY_SYMB", "KEY_123", "KEY_SPACE", "KEY_ABC", "KEY_RETURN"]
    public static let t9BottomRowWidths: [Double] = [72, 49.33, 152, 49.33, 72]
    public static let t9BottomRowOrigins: [Double] = [5, 83.33, 139.33, 297.67, 353.33]

    /// Bottom-bar items measured below the key rows, in canvas coordinates.
    public static let bottomBarLanguageFrame = WTRect(x: 29, y: 245.33, width: 27, height: 26.67)
    public static let bottomBarVoiceFrame = WTRect(x: 378, y: 243.33, width: 18.67, height: 28.33)
}

/// Resolves the extracted INI rectangles into the frames the shipped product actually draws.
///
/// The extracted resources describe a 414 pt design grid with placeholder function keys, so
/// the resolver replaces the affected rows with frames measured from the reference device.
/// Layouts and viewport widths that were not measured keep their proportional scaling.
public enum WTKeyboardGeometryResolver353 {
    /// Layouts whose final frames were measured from the reference device.
    public static func hasMeasuredGeometry(_ layout: WTKeyboardLayout) -> Bool {
        layout.items.contains { $0.id == "KEY_Q" } || layout.items.contains { $0.id == "KEY_ABC" }
    }

    public static func resolve(
        layout: WTKeyboardLayout,
        viewportWidth: Double
    ) -> [WTResolvedKeyFrame353] {
        let raw = layout.items.compactMap { item -> WTResolvedKeyFrame353? in
            guard let rect = item.rect else { return nil }
            return WTResolvedKeyFrame353(id: item.id, frame: rect)
        }

        // Unmeasured layouts keep their resource rectangles so the canvas applies the single
        // proportional scale. Returning pre-scaled frames here would scale them twice.
        guard viewportWidth == WTMeasuredKeyboard353.viewportWidth else { return raw }
        if layout.items.contains(where: { $0.id == "KEY_Q" }) {
            return measuredT26(raw)
        }
        if layout.items.contains(where: { $0.id == "KEY_ABC" }) {
            return measuredT9(raw)
        }
        return raw
    }

    private static func measuredT26(_ frames: [WTResolvedKeyFrame353]) -> [WTResolvedKeyFrame353] {
        let measured = WTMeasuredKeyboard353.self
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0.frame) })
        let firstRow = ["KEY_Q", "KEY_W", "KEY_E", "KEY_R", "KEY_T",
                        "KEY_Y", "KEY_U", "KEY_I", "KEY_O", "KEY_P"]
        let secondRow = ["KEY_A", "KEY_S", "KEY_D", "KEY_F", "KEY_G",
                         "KEY_H", "KEY_J", "KEY_K", "KEY_L"]
        let thirdRow = ["KEY_Z", "KEY_X", "KEY_C", "KEY_V", "KEY_B", "KEY_N", "KEY_M"]

        var overrides: [String: WTRect] = [:]
        place(row: firstRow, origin: measured.keyInset, pitch: measured.letterKeyPitch,
              width: measured.letterKeyWidth, frames: framesByID, into: &overrides)

        // The extracted resource rectangles leave the second row 5.9 pt left of centre; the
        // shipped product centres it, so the row origin comes from the measured row width.
        let secondRowWidth = Double(secondRow.count) * measured.letterKeyWidth
            + Double(secondRow.count - 1) * (measured.letterKeyPitch - measured.letterKeyWidth)
        place(row: secondRow, origin: (measured.viewportWidth - secondRowWidth) / 2,
              pitch: measured.letterKeyPitch, width: measured.letterKeyWidth,
              frames: framesByID, into: &overrides)

        place(row: thirdRow, origin: measured.keyInset + measured.functionKeyWidth + 16,
              pitch: measured.letterKeyPitch, width: measured.letterKeyWidth,
              frames: framesByID, into: &overrides)
        overrideFrame("KEY_SHIFT", x: measured.keyInset, width: measured.functionKeyWidth,
                      frames: framesByID, into: &overrides)
        overrideFrame("KEY_DEL", x: 377, width: measured.functionKeyWidth,
                      frames: framesByID, into: &overrides)
        for (index, id) in measured.t26BottomRowIDs.enumerated() {
            overrideFrame(id, x: measured.t26BottomRowOrigins[index],
                          width: measured.t26BottomRowWidths[index],
                          frames: framesByID, into: &overrides)
        }

        return frames.compactMap { frame in
            guard !measured.t26HiddenIDs.contains(frame.id) else { return nil }
            guard let rect = overrides[frame.id] else { return frame }
            return WTResolvedKeyFrame353(id: frame.id, frame: rect)
        }
    }

    private static func measuredT9(_ frames: [WTResolvedKeyFrame353]) -> [WTResolvedKeyFrame353] {
        let measured = WTMeasuredKeyboard353.self
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0.frame) })
        let numberIDs = ["KEY_1", "KEY_2", "KEY_3", "KEY_4", "KEY_5", "KEY_6",
                         "KEY_7", "KEY_8", "KEY_9"]

        var overrides: [String: WTRect] = [:]
        for (index, id) in numberIDs.enumerated() {
            overrideFrame(id, x: measured.t9NumberOrigins[index % 3], width: measured.t9NumberWidth,
                          frames: framesByID, into: &overrides)
        }
        for (index, id) in measured.t9BottomRowIDs.enumerated() {
            overrideFrame(id, x: measured.t9BottomRowOrigins[index],
                          width: measured.t9BottomRowWidths[index],
                          frames: framesByID, into: &overrides)
        }
        // Remaining gutter items keep the measured column width on either side.
        for (id, frame) in framesByID where !measured.t9BottomRowIDs.contains(id) {
            if frame.x < 40 {
                overrides[id] = WTRect(x: measured.t9GutterLeadingX, y: frame.y,
                                       width: measured.t9GutterWidth, height: frame.height)
            } else if frame.x > 330 {
                overrides[id] = WTRect(x: measured.t9GutterTrailingX, y: frame.y,
                                       width: measured.t9GutterWidth, height: frame.height)
            }
        }

        return frames.map { frame in
            guard let rect = overrides[frame.id] else { return frame }
            return WTResolvedKeyFrame353(id: frame.id, frame: rect)
        }
    }

    private static func place(
        row ids: [String],
        origin: Double,
        pitch: Double,
        width: Double,
        frames: [String: WTRect],
        into overrides: inout [String: WTRect]
    ) {
        guard let rowY = frames[ids.first ?? ""]?.y else { return }
        for (index, id) in ids.enumerated() {
            overrides[id] = WTRect(
                x: origin + Double(index) * pitch,
                y: rowY,
                width: width,
                height: frames[id]?.height ?? WTMeasuredKeyboard353.rowHeight
            )
        }
    }

    private static func overrideFrame(
        _ id: String,
        x: Double,
        width: Double,
        frames: [String: WTRect],
        into overrides: inout [String: WTRect]
    ) {
        guard let frame = frames[id] else { return }
        overrides[id] = WTRect(x: x, y: frame.y, width: width, height: frame.height)
    }
}
