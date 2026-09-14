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
                        .font(.system(size: fontSize(item) * runtime.fontScale, weight: .regular))
                        .foregroundStyle(textColor)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                }
                if let subtitle = subtitleText, !subtitle.isEmpty, !isEmojiKey {
                    Text(subtitle)
                        .font(.system(size: WTTheme353.keySubtitleFontSize))
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
        return style.contains("STYLE_GRAY") || style.contains("STYLE_DEL") || style.contains("STYLE_SHIFT")
    }

    private func backgroundColor(pressed: Bool) -> Color {
        if usesAccentStyle {
            return pressed ? WTThemeColor353.grayPressedKey : WTThemeColor353.accent
        }
        if pressed { return isGray ? WTThemeColor353.grayPressedKey : WTThemeColor353.normalPressedKey }
        return isGray ? WTThemeColor353.grayKey : WTThemeColor353.normalKey
    }

    private var textColor: Color {
        if usesAccentStyle { return pressing ? WTThemeColor353.primaryText : Color(wtHex: "#FEFEFE") }
        return WTThemeColor353.primaryText
    }
    private var secondaryTextColor: Color { WTThemeColor353.secondaryText }
    private var borderColor: Color { isGray ? WTThemeColor353.grayBorder : WTThemeColor353.normalBorder }
    private var shadowColor: Color { WTThemeColor353.keyShadow }

    private var subtitleText: String? {
        guard let up = WTKeyActionResolver.variant(item.upInput, state: runtime.state), !up.isEmpty else { return nil }
        return up
    }

    private func fontSize(_ item: WTKeyboardItem) -> CGFloat {
        if let raw = item.font, let first = WTRawArrayParser.values(raw).compactMap({ $0 }).first,
           let size = Double(first.filter { $0.isNumber || $0 == "." }) {
            return CGFloat(size)
        }
        if (item.style ?? "").contains("T26_LETTER") { return CGFloat(WTTheme353.letterFontSize) }
        if (item.style ?? "").contains("T9_ABC") { return 18 }
        return CGFloat(WTTheme353.functionFontSize)
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
