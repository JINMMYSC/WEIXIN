import SwiftUI

public struct WTPasteboardImageDetailView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }
    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "剪贴板图片", onBack: { runtime.state.back() })
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14).fill(WTChrome353.panelBackground).frame(width: 150, height: 116)
                    .overlay { WTSemanticGlyph(name: "photo").font(.system(size: 34)).foregroundStyle(.secondary) }
                Text("图片剪贴板").font(.system(size: 14, weight: .semibold))
                Text("Keyboard Extension 对系统图片剪贴板的读取和发送需要完整访问权限；这里保留与原版对应的详情和授权流程。")
                    .font(.system(size: 11)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 28)
                Button("前往授权") { runtime.state.present(.guide) }.buttonStyle(WTGreenPillButtonStyle())
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.background(WTChrome353.surface)
    }
}
