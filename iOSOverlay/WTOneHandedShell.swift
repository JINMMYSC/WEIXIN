import SwiftUI

public struct WTOneHandedShell<Content: View>: View {
    let mode: WTOneHandedMode
    let close: () -> Void
    let switchSide: () -> Void
    @ViewBuilder let content: () -> Content

    public init(mode: WTOneHandedMode, close: @escaping () -> Void, switchSide: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.mode = mode; self.close = close; self.switchSide = switchSide; self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let rail: CGFloat = min(48, proxy.size.width * 0.14)
            HStack(spacing: 0) {
                if mode == .right { railView(width: rail) }
                content().frame(width: proxy.size.width - rail)
                if mode == .left { railView(width: rail) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: mode == .left ? .leading : .trailing)
        }
    }

    private func railView(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            Button(action: switchSide) { WTSemanticGlyph(name: mode == .left ? "arrow.right" : "arrow.left").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Divider()
            Button(action: close) { WTSemanticGlyph(name: "arrow.up.left.and.arrow.down.right").frame(maxWidth: .infinity, maxHeight: .infinity) }
        }
        .font(.system(size: 15, weight: .medium)).buttonStyle(.plain).frame(width: width)
        .background(WTChrome353.panelBackground)
    }
}
