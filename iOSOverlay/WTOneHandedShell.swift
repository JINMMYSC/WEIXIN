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
            // Shipped 3.5.3 tutorial surfaces show the active keyboard at roughly 80% of the
            // full 414pt width, leaving an ~82pt control rail on the opposite side.
            let rail: CGFloat = min(82, proxy.size.width * 0.20)
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
            Spacer(minLength: 22)
            Button(action: switchSide) {
                VStack(spacing: 7) {
                    WTSemanticGlyph(name: mode == .right ? "keyboard.arrow.left" : "keyboard.arrow.right")
                        .frame(width: 24, height: 20)
                    Text(mode == .right ? "左手模式" : "右手模式")
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundStyle(WTChrome353.secondary)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: close) {
                VStack(spacing: 7) {
                    WTSemanticGlyph(name: "arrow.up.left.and.arrow.down.right")
                        .frame(width: 22, height: 20)
                    Text("全尺寸")
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundStyle(WTChrome353.secondary)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            Spacer(minLength: 27)
        }
        .frame(width: width)
        .background(WTThemeColor353.keyboardBackground)
    }
}
