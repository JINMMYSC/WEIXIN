import SwiftUI
import UIKit

public struct WTKeyboardCanvasView: View {
    public let layout: WTKeyboardLayout
    @ObservedObject public var runtime: WTKeyboardRuntime
    @State private var keyPopup: WTKeyTapPopupState?

    public init(layout: WTKeyboardLayout, runtime: WTKeyboardRuntime) {
        self.layout = layout
        self.runtime = runtime
    }

    public var body: some View {
        GeometryReader { proxy in
            let sx = (proxy.size.width * runtime.keyboardAdjustment.widthScale) / layout.baseSize.width
            let sy = (proxy.size.height * runtime.keyboardAdjustment.heightScale) / layout.baseSize.height
            let contentWidth = layout.baseSize.width * sx
            let contentHeight = layout.baseSize.height * sy
            let originX = (proxy.size.width - contentWidth) / 2 + proxy.size.width * runtime.keyboardAdjustment.horizontalOffset
            let originY = (proxy.size.height - contentHeight) / 2 + proxy.size.height * runtime.keyboardAdjustment.verticalOffset
            ZStack(alignment: .topLeading) {
                WTThemeColor353.keyboardBackground
                ForEach(layout.items, id: \.id) { item in
                    if let r = item.rect {
                        WTKeyCap(
                            item: item,
                            runtime: runtime,
                            onTapPopupChanged: { visible, title in
                                withAnimation(.easeOut(duration: runtime.visualCalibration.keyPopupDuration)) {
                                    keyPopup = visible ? WTKeyTapPopupState(keyID: item.id, title: title, sourceRect: r) : nil
                                }
                            }
                        )
                        .frame(width: r.width * sx, height: r.height * sy)
                        .position(
                            x: originX + (r.x + r.width / 2) * sx,
                            y: originY + (r.y + r.height / 2) * sy
                        )
                        .zIndex(keyPopup?.keyID == item.id ? 40 : 0)
                    }
                }
                if let popup = keyPopup {
                    let keyWidth = popup.sourceRect.width * sx
                    let keyHeight = popup.sourceRect.height * sy
                    let popupWidth = max(46, keyWidth * runtime.visualCalibration.keyPopupScale)
                    let popupHeight = max(54, keyHeight * 1.34 * runtime.visualCalibration.keyPopupScale)
                    let centerX = originX + (popup.sourceRect.x + popup.sourceRect.width / 2) * sx
                    let clampedX = min(max(centerX, popupWidth / 2 + 2), proxy.size.width - popupWidth / 2 - 2)
                    let keyTop = originY + popup.sourceRect.y * sy
                    WTKeyTapPopupView(title: popup.title)
                        .frame(width: popupWidth, height: popupHeight)
                        .position(x: clampedX, y: keyTop - popupHeight / 2 + 7)
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottom)))
                        .zIndex(45)
                        .allowsHitTesting(false)
                }
                if let popup = runtime.longPressPopup, let rect = popup.sourceRect {
                    WTLongPressPopupView(runtime: runtime, popup: popup)
                        .position(
                            x: min(max(originX + (rect.x + rect.width / 2) * sx, 90), proxy.size.width - 90),
                            y: originY + (rect.y - 26) * sy
                        )
                        .zIndex(50)
                }
            }
        }
        // Intentionally not clipped: the measured key popup rises above the 224pt key canvas.
    }
}

private struct WTKeyTapPopupState: Equatable {
    let keyID: String
    let title: String
    let sourceRect: WTRect
}

private struct WTKeyCap: View {
    let item: WTKeyboardItem
    @ObservedObject var runtime: WTKeyboardRuntime
    let onTapPopupChanged: (Bool, String) -> Void
    @GestureState private var pressing = false
    @Environment(\.colorScheme) private var colorScheme

    private var styleValues: [String: String] {
        WTStyleCatalog353.values(for: item.style)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: runtime.visualCalibration.keyCornerRadius, style: .continuous)
                .fill(backgroundColor(pressed: pressing))
                .overlay(
                    RoundedRectangle(cornerRadius: runtime.visualCalibration.keyCornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 0.35)
                )
                .shadow(color: shadowColor, radius: 0.5, y: 1)
            VStack(spacing: 0) {
                if isEmojiKey {
                    WTToolIconView(tool: .emoji, tint: textColor)
                } else {
                    Text(displayTitle)
                        .font(.system(size: fontSize(item) * runtime.fontScale, weight: fontWeight))
                        .foregroundStyle(textColor)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                }
                if let subtitle = subtitleText, !subtitle.isEmpty, !isEmojiKey {
                    Text(subtitle)
                        .font(.system(size: subtitleFontSize))
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.36, maximumDistance: 14)
                .onEnded { _ in
                    onTapPopupChanged(false, displayTitle)
                    runtime.performKeyFeedback(isDeleteKey)
                    runtime.handle(item, gesture: .longPress)
                }
        )
        .accessibilityLabel(displayTitle)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($pressing) { _, state, _ in state = true }
            .onChanged { _ in
                guard shouldShowTapPopup, runtime.longPressPopup?.keyID != item.id else { return }
                onTapPopupChanged(true, displayTitle)
            }
            .onEnded { value in
                onTapPopupChanged(false, displayTitle)
                if runtime.longPressPopup?.keyID == item.id { return }
                runtime.performKeyFeedback(isDeleteKey)
                let dx = value.translation.width
                let dy = value.translation.height
                if abs(dy) > abs(dx), dy < -18 {
                    runtime.handle(item, gesture: .swipeUp)
                } else if abs(dy) > abs(dx), dy > 18 {
                    runtime.handle(item, gesture: .swipeDown)
                } else {
                    runtime.handle(item, gesture: .tap)
                }
            }
    }

    private var shouldShowTapPopup: Bool {
        guard (item.style ?? "").contains("T26_LETTER") else { return false }
        switch WTKeyActionResolver.action(for: item, gesture: .tap, state: runtime.state) {
        case .engineInput(let value), .directText(let value): return value.count == 1
        default: return false
        }
    }

    private var isDeleteKey: Bool {
        item.function == "delete" || item.id.uppercased().contains("DEL") || item.id.uppercased().contains("BACKSPACE")
    }

    private var isEmojiKey: Bool { item.function == "emoji" }

    private var isReturnKey: Bool {
        item.id == "KEY_RETURN" || item.function == "return" || item.function == "newline"
    }

    private var displayTitle: String {
        if isReturnKey { return runtime.returnKeyPresentation.title }
        let resolved = WTKeyActionResolver.visibleTitle(for: item, state: runtime.state)
        if (item.style ?? "").contains("STYLE_T9_ABC") { return resolved.uppercased() }
        return resolved
    }

    private var usesAccentStyle: Bool {
        if isReturnKey { return runtime.returnKeyPresentation.usesAccent }
        let style = item.style ?? ""
        return style.contains("STYLE_GREEN") || style.contains("STYLE_BACK_GREEN")
    }

    private var isGray: Bool {
        let style = item.style ?? ""
        if isReturnKey { return !runtime.returnKeyPresentation.usesAccent }
        return style.contains("STYLE_GRAY") || style.contains("STYLE_DEL") || style.contains("STYLE_SHIFT") || style.contains("STYLE_123") || style.contains("STYLE_SYM") || style.contains("STYLE_RETYPE")
    }

    private func backgroundColor(pressed: Bool) -> Color {
        let fallback: Color
        if usesAccentStyle {
            fallback = pressed ? WTThemeColor353.grayPressedKey : WTThemeColor353.accent
        } else if pressed {
            fallback = isGray ? WTThemeColor353.grayPressedKey : WTThemeColor353.normalPressedKey
        } else {
            fallback = isGray ? WTThemeColor353.grayKey : WTThemeColor353.normalKey
        }
        return extractedColor(for: pressed ? "HLBG" : "BG", fallback: fallback)
    }

    private var textColor: Color {
        let fallback: Color
        if usesAccentStyle {
            fallback = pressing ? WTThemeColor353.primaryText : Color(wtHex: "#FEFEFE")
        } else {
            fallback = WTThemeColor353.primaryText
        }
        if pressing, let highlighted = extractedColorIfSimple(for: "HLTINT") { return highlighted }
        return extractedColor(for: "TINT", fallback: fallback)
    }

    private var secondaryTextColor: Color {
        extractedColor(for: "STINT", fallback: WTThemeColor353.secondaryText)
    }

    private var borderColor: Color {
        extractedColor(for: "BORDER", fallback: isGray ? WTThemeColor353.grayBorder : WTThemeColor353.normalBorder)
    }

    private var shadowColor: Color {
        extractedColor(for: "SHADOW", fallback: WTThemeColor353.keyShadow)
    }

    private var subtitleText: String? {
        guard let up = WTKeyActionResolver.variant(item.upInput, state: runtime.state), !up.isEmpty else { return nil }
        return up
    }

    private var subtitleFontSize: CGFloat {
        if let raw = item.upFont ?? styleValues["UPFONT"], let size = numericFontSize(raw, stateAware: true) {
            return size
        }
        return CGFloat(WTTheme353.keySubtitleFontSize)
    }

    private var fontWeight: Font.Weight {
        let raw = item.font ?? styleValues["FONT"] ?? ""
        return raw.lowercased().contains("medium") ? .medium : .regular
    }

    private func fontSize(_ item: WTKeyboardItem) -> CGFloat {
        if let raw = item.font, let size = numericFontSize(raw, stateAware: true) { return size }
        if let raw = styleValues["FONT"], let size = numericFontSize(raw, stateAware: true) { return size }
        if (item.style ?? "").contains("T26_LETTER") { return CGFloat(WTTheme353.letterFontSize) }
        if (item.style ?? "").contains("T9_ABC") { return 18 }
        return CGFloat(WTTheme353.functionFontSize)
    }

    private func numericFontSize(_ raw: String, stateAware: Bool) -> CGFloat? {
        let selected = stateAware ? (WTKeyActionResolver.variant(raw, state: runtime.state) ?? raw) : raw
        let components = selected.split(separator: ",").map(String.init)
        for component in components.reversed() {
            let numeric = component.filter { $0.isNumber || $0 == "." }
            if let value = Double(numeric), value > 0 { return CGFloat(value) }
        }
        return nil
    }

    /// style.ini mostly stores a light,dark pair directly (for example
    /// `#FFFFFF,#BBBBBB66`). Rule-driven bracket arrays are mode/state expressions rather than
    /// appearance pairs; those deliberately fall back to the existing state machine.
    private func extractedColor(for key: String, fallback: Color) -> Color {
        extractedColorIfSimple(for: key) ?? fallback
    }

    private func extractedColorIfSimple(for key: String) -> Color? {
        guard let raw = styleValues[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty, !raw.hasPrefix("[") else { return nil }
        let parts = raw.split(separator: ",", omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasPrefix("#") }
        guard let light = parts.first else { return nil }
        let selected = colorScheme == .dark && parts.count > 1 ? parts[1] : light
        return Color(wtHex: selected)
    }
}

private struct WTKeyTapPopupView: View {
    let title: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(WTChrome353.elevatedSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(WTThemeColor353.normalBorder, lineWidth: 0.35)
                )
                .shadow(color: WTThemeColor353.keyShadow, radius: 2.2, y: 1.4)
            Text(title)
                .font(.system(size: 29, weight: .regular))
                .foregroundStyle(WTChrome353.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

private struct WTLongPressPopupView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    let popup: WTLongPressPopupState
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(popup.items.enumerated()), id: \.offset) { index, text in
                Button { runtime.selectLongPressText(text) } label: {
                    Text(text)
                        .font(.system(size: 22))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 44)
                        .background(index == popup.defaultIndex ? Color.secondary.opacity(0.18) : Color.clear)
                }
            }
        }
        .padding(.horizontal, 4)
        .background(WTChrome353.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: runtime.visualCalibration.panelCornerRadius, style: .continuous))
        .shadow(radius: 4, y: 2)
    }
}
