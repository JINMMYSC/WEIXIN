import SwiftUI

/// Compact toolbar modeled after the WeType 3.5.3 keyboard chrome. Product-tool artwork uses
/// independently drawn vector glyphs sized from measured 3.5.3 canvas geometry; proprietary
/// Tencent image resources are not bundled.
public struct WTFunctionToolbarView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        HStack(spacing: 0) {
            Button {
                runtime.state.present(.controlCenter)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(WTChrome353.accent.opacity(0.12))
                        .frame(width: 30, height: 30)
                    WTToolIconView(tool: .plus, tint: WTChrome353.accent, size: 17)
                }
                .frame(width: 42, height: runtime.visualCalibration.toolbarHeight)
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(runtime.toolbarOrder) { tool in
                        Button {
                            runtime.presentTool(tool)
                        } label: {
                            WTToolIconView(tool: tool, tint: tool == .askAI ? WTChrome353.accent : WTChrome353.primaryText.opacity(0.82))
                                .frame(width: 40, height: runtime.visualCalibration.toolbarHeight)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                runtime.state.present(.controlCenter)
            } label: {
                WTBasicGlyphView(.chevronDown, tint: WTChrome353.secondary, size: 13, lineWidth: 1.8)
                    .frame(width: 36, height: runtime.visualCalibration.toolbarHeight)
            }
            .buttonStyle(.plain)
        }
        .frame(height: runtime.visualCalibration.toolbarHeight)
        .background(WTChrome353.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }
}
