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
    /// Measured cap height of the 26-key rows; the extracted INI uses 46.
    public static let t26RowHeight: Double = 45.33
    public static let rowHeight: Double = 45.33

    /// Header content row shared by the toolbar and the candidate list. Both sit at
    /// panel-relative y 31 with a 32 pt row, whatever the header is showing.
    public static let headerRowTop: Double = 31
    public static let headerRowHeight: Double = 32
    public static let productButtonX: Double = 13
    public static let productButtonSize: Double = 32
    public static let toolButtonSize: Double = 32
    public static let toolSlotPitch: Double = 46
    /// The trailing tool slot ends here, so tools fill the row from the right.
    public static let toolRowTrailingX: Double = 417
    public static let candidateLeadingInset: Double = 13
    public static let candidateFontSize: Double = 20
    /// Measured radius of the keyboard surface's top corners on iOS 26.
    public static let panelTopCornerRadius: Double = 28
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
    public static let t9RowTops: [Double] = [3, 59, 115, 171]
    public static let t9RowHeight: Double = 49.33
    public static let t9BottomRowIDs = ["KEY_SYMB", "KEY_123", "KEY_SPACE", "KEY_ABC", "KEY_RETURN"]
    public static let t9BottomRowWidths: [Double] = [72, 49.33, 152, 49.33, 72]
    public static let t9BottomRowOrigins: [Double] = [5, 83.33, 139.33, 297.67, 353.33]

    /// Bottom-bar items measured below the key rows, in canvas coordinates.
    public static let bottomBarLanguageFrame = WTRect(x: 29, y: 245.33, width: 27, height: 26.67)
    public static let bottomBarVoiceFrame = WTRect(x: 378, y: 243.33, width: 18.67, height: 28.33)

    /// Chinese symbol panel row 3 measured on the six-key page: shift, six 43.33 pt
    /// punctuation keys from x 69.33 on a 49.67 pt pitch, then delete.
    public static let symbolKeyOrigin: Double = 69.33
    public static let symbolKeyWidth: Double = 43.33
    public static let symbolKeyPitch: Double = 49.67
}

/// Host settings chrome measured from the same 3.5.3 recordings. Every setup page shares one
/// Panel bodies measured from the same frames. Each value is the final drawn geometry, not a
/// design-grid placeholder.
public enum WTMeasuredPanels353 {
    /// Emoji panel: nine columns, 46.2 pt pitch, 40 pt rows.
    public static let emojiColumns = 9
    public static let emojiColumnPitch: Double = 46.2
    public static let emojiRowPitch: Double = 40
    public static let emojiSymbolSize: Double = 29
    public static let emojiFirstRowTop: Double = 626.33

    /// Plus panel: four 81.67 pt square cards on a 102.67 pt pitch.
    public static let plusCardSize: Double = 81.67
    public static let plusCardSpacing: Double = 21
    public static let plusLeadingInset: Double = 23.67
    public static let plusFirstRowTop: Double = 643.67
    public static let plusCardBackground = "#F7F6F8"

    /// Clipboard panel: 47.5 pt rows with 8 pt gaps.
    public static let clipboardRowHeight: Double = 47.5
    public static let clipboardRowSpacing: Double = 8
    public static let clipboardFirstRowTop: Double = 645.33
    public static let clipboardCardBackground = "#FFFFFF"
}

/// Host settings chrome measured from the same 3.5.3 recordings. Every setup page shares one
/// background, one card radius and one row rhythm; only the rows themselves differ.
public enum WTHostSettingsChrome353 {
    public static let pageBackground = "#F0F0F0"
    public static let cardBackground = "#FFFFFF"
    public static let cardCornerRadius: Double = 14
    public static let sideMargin: Double = 20
    public static let groupSpacing: Double = 16
    public static let rowHeight: Double = 44
    public static let tallRowHeight: Double = 64
    /// Measured home-grid rhythm, kept next to the page chrome it belongs to.
    public static let homeCardCornerRadius: Double = 16
    public static let homeColumnSpacing: Double = 14
}

/// Resolves the extracted INI rectangles into the frames the shipped product actually draws.
///
/// The extracted resources describe a 414 pt design grid with placeholder function keys, so
/// the resolver replaces the affected rows with frames measured from the reference device.
/// Layouts and viewport widths that were not measured keep their proportional scaling.
public enum WTKeyboardGeometryResolver353 {
    /// Layouts whose final frames were measured from the reference device.
    public static func hasMeasuredGeometry(_ layout: WTKeyboardLayout) -> Bool {
        layout.items.contains { $0.id == "KEY_Q" }
            || layout.items.contains { $0.id == "KEY_ABC" }
            || layout.items.contains { $0.id == "KEY_33" }
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
            return measuredT26(raw, viewportWidth: viewportWidth,
                               designWidth: layout.baseSize.width)
        }
        if layout.items.contains(where: { $0.id == "KEY_ABC" }) {
            return measuredT9(raw, viewportWidth: viewportWidth,
                              designWidth: layout.baseSize.width)
        }
        if layout.items.contains(where: { $0.id == "KEY_33" }) {
            return measuredSymbol(raw, viewportWidth: viewportWidth,
                                  designWidth: layout.baseSize.width)
        }
        return raw
    }

    /// Items outside the measured rows keep their design rectangle, scaled once to the
    /// viewport, because the canvas renders measured layouts without a second scale.
    private static func assemble(
        _ frames: [WTResolvedKeyFrame353],
        overrides: [String: WTRect],
        hidden: Set<String> = [],
        viewportWidth: Double,
        designWidth: Double
    ) -> [WTResolvedKeyFrame353] {
        let scale = viewportWidth / designWidth
        return frames.compactMap { frame in
            guard !hidden.contains(frame.id) else { return nil }
            if let rect = overrides[frame.id] {
                return WTResolvedKeyFrame353(id: frame.id, frame: rect)
            }
            return WTResolvedKeyFrame353(
                id: frame.id,
                frame: WTRect(
                    x: frame.frame.x * scale,
                    y: frame.frame.y,
                    width: frame.frame.width * scale,
                    height: frame.frame.height
                )
            )
        }
    }

    /// Chinese symbol panel measured on the same frames: rows 1 and 2 repeat the letter-key
    /// grid and row 3 is a 48.33 pt switch plus six 43.33 pt punctuation keys on a 49.67 pt
    /// pitch, which is the page the extracted resource describes. The recording also contains
    /// a second page with only five punctuation keys in that row.
    private static func measuredSymbol(
        _ frames: [WTResolvedKeyFrame353],
        viewportWidth: Double,
        designWidth: Double
    ) -> [WTResolvedKeyFrame353] {
        let measured = WTMeasuredKeyboard353.self
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0.frame) })
        let firstRow = ["KEY_11", "KEY_12", "KEY_13", "KEY_14", "KEY_15",
                        "KEY_16", "KEY_17", "KEY_18", "KEY_19", "KEY_10"]
        let secondRow = ["KEY_21", "KEY_22", "KEY_23", "KEY_24", "KEY_25",
                         "KEY_26", "KEY_27", "KEY_28", "KEY_29", "KEY_20"]
        let punctuation = ["KEY_33", "KEY_34", "KEY_35", "KEY_36", "KEY_37", "KEY_38"]

        var overrides: [String: WTRect] = [:]
        place(row: firstRow, origin: measured.keyInset, pitch: measured.letterKeyPitch,
              width: measured.letterKeyWidth, frames: framesByID, into: &overrides)
        place(row: secondRow, origin: measured.keyInset, pitch: measured.letterKeyPitch,
              width: measured.letterKeyWidth, frames: framesByID, into: &overrides)

        if let rowY = framesByID["KEY_SYMB"]?.y {
            overrides["KEY_SYMB"] = WTRect(x: measured.keyInset, y: rowY,
                                           width: measured.functionKeyWidth,
                                           height: measured.t26RowHeight)
            let origin = measured.symbolKeyOrigin
            let width = measured.symbolKeyWidth
            for (index, id) in punctuation.enumerated() {
                overrides[id] = WTRect(x: origin + Double(index) * measured.symbolKeyPitch, y: rowY,
                                       width: width, height: measured.t26RowHeight)
            }
            overrides["KEY_DEL"] = WTRect(x: 377, y: rowY, width: measured.functionKeyWidth,
                                          height: measured.t26RowHeight)
        }

        return assemble(frames, overrides: overrides,
                        viewportWidth: viewportWidth, designWidth: designWidth)
    }

    private static func measuredT26(
        _ frames: [WTResolvedKeyFrame353],
        viewportWidth: Double,
        designWidth: Double
    ) -> [WTResolvedKeyFrame353] {
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

        return assemble(frames, overrides: overrides, hidden: measured.t26HiddenIDs,
                        viewportWidth: viewportWidth, designWidth: designWidth)
    }

    private static func measuredT9(
        _ frames: [WTResolvedKeyFrame353],
        viewportWidth: Double,
        designWidth: Double
    ) -> [WTResolvedKeyFrame353] {
        let measured = WTMeasuredKeyboard353.self
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0.frame) })
        let numberIDs = ["KEY_1", "KEY_2", "KEY_3", "KEY_4", "KEY_5", "KEY_6",
                         "KEY_7", "KEY_8", "KEY_9"]

        // The extracted rectangles merge the first number key and the list cell into one tall
        // block; the shipped product draws four separate rows of 49.33 pt at y 3, 59, 115, 171.
        func rowTop(for sourceY: Double) -> Double {
            measured.t9RowTops.min { abs($0 - sourceY) < abs($1 - sourceY) } ?? sourceY
        }
        func normalized(_ id: String, x: Double, width: Double) -> WTRect? {
            guard let frame = framesByID[id] else { return nil }
            return WTRect(x: x, y: rowTop(for: frame.y), width: width,
                          height: measured.t9RowHeight)
        }

        var overrides: [String: WTRect] = [:]
        for (index, id) in numberIDs.enumerated() {
            overrides[id] = normalized(id, x: measured.t9NumberOrigins[index % 3],
                                       width: measured.t9NumberWidth)
        }
        for (index, id) in measured.t9BottomRowIDs.enumerated() {
            overrides[id] = normalized(id, x: measured.t9BottomRowOrigins[index],
                                       width: measured.t9BottomRowWidths[index])
        }
        // Remaining gutter items keep the measured column width on either side.
        for (id, frame) in framesByID
        where !measured.t9BottomRowIDs.contains(id) && overrides[id] == nil {
            if frame.x < 40 {
                overrides[id] = normalized(id, x: measured.t9GutterLeadingX,
                                           width: measured.t9GutterWidth)
            } else if frame.x > 330 {
                overrides[id] = normalized(id, x: measured.t9GutterTrailingX,
                                           width: measured.t9GutterWidth)
            }
        }

        return assemble(frames, overrides: overrides,
                        viewportWidth: viewportWidth, designWidth: designWidth)
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
                height: WTMeasuredKeyboard353.t26RowHeight
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
        overrides[id] = WTRect(x: x, y: frame.y, width: width,
                               height: WTMeasuredKeyboard353.t26RowHeight)
    }
}
