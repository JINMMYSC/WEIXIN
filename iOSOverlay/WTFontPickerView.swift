import SwiftUI

public struct WTFontPickerView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    private let values: [(String, Double)] = [("默认",1.0),("小",0.90),("标准",1.0),("大",1.10),("特大",1.18)]
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "键盘字体", onBack: { runtime.state.back() }, trailingSystemName: "xmark") { runtime.fontScale = 1.0 }
            VStack(spacing: 10) {
                Text("微信输入法").font(.system(size: 20 * runtime.fontScale, weight: .medium)).frame(maxWidth: .infinity, minHeight: 56)
                    .background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10))
                ForEach(values, id: \.0) { item in
                    Button { runtime.fontScale = item.1 } label: {
                        HStack {
                            Text(item.0).font(.system(size: 13))
                            Spacer()
                            Text("Aa 中").font(.system(size: 15 * item.1))
                            WTSemanticGlyph(name: abs(runtime.fontScale - item.1) < 0.001 ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(abs(runtime.fontScale - item.1) < 0.001 ? WTChrome353.accent : Color.secondary)
                        }.padding(.horizontal, 12).frame(height: 40).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 9))
                    }.buttonStyle(.plain)
                }
            }.padding(10)
        }.background(WTChrome353.panelBackground)
    }
}
