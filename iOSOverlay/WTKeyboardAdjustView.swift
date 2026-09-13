import SwiftUI

public struct WTKeyboardAdjustView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var initial: WTKeyboardAdjustment
    public init(runtime: WTKeyboardRuntime) {
        self.runtime = runtime
        _initial = State(initialValue: runtime.keyboardAdjustment)
    }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "键盘调节", onBack: cancel, trailingSystemName: "arrow.counterclockwise") {
                runtime.keyboardAdjustment = .init()
            }
            VStack(spacing: 10) {
                preview
                slider("宽度", value: binding(\.widthScale), range: 0.72...1)
                slider("高度", value: binding(\.heightScale), range: 0.80...1.18)
                slider("左右位置", value: binding(\.horizontalOffset), range: -0.20...0.20)
                slider("上下位置", value: binding(\.verticalOffset), range: -0.15...0.15)
                HStack(spacing: 8) {
                    Button("取消", action: cancel).frame(maxWidth: .infinity, minHeight: 34).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 8))
                    Button("保存") { initial = runtime.keyboardAdjustment; runtime.state.back() }.buttonStyle(WTGreenPillButtonStyle()).frame(maxWidth: .infinity)
                }.buttonStyle(.plain)
            }.padding(10)
        }.background(WTChrome353.panelBackground)
    }

    private var preview: some View {
        GeometryReader { proxy in
            let w = proxy.size.width * runtime.keyboardAdjustment.widthScale
            let h = proxy.size.height * min(runtime.keyboardAdjustment.heightScale, 1.0)
            RoundedRectangle(cornerRadius: 12).fill(WTChrome353.panelBackground)
                .frame(width: w, height: h)
                .overlay { WTSemanticGlyph(name: "keyboard").font(.system(size: 25)).foregroundStyle(.secondary) }
                .position(x: proxy.size.width / 2 + proxy.size.width * runtime.keyboardAdjustment.horizontalOffset,
                          y: proxy.size.height / 2 + proxy.size.height * runtime.keyboardAdjustment.verticalOffset)
        }.frame(height: 64).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func binding(_ keyPath: WritableKeyPath<WTKeyboardAdjustment, Double>) -> Binding<Double> {
        Binding(get: { runtime.keyboardAdjustment[keyPath: keyPath] }, set: { value in
            runtime.keyboardAdjustment[keyPath: keyPath] = value
            runtime.keyboardAdjustment.clamp()
        })
    }

    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        HStack(spacing: 10) { Text(title).font(.system(size: 12)).frame(width: 62, alignment: .leading); Slider(value: value, in: range) }
            .padding(.horizontal, 10).frame(height: 34).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private func cancel() {
        runtime.keyboardAdjustment = initial
        runtime.state.back()
    }
}
