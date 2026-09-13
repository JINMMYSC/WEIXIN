import SwiftUI

public struct WTQuickSendPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "隔空传送", onBack: { runtime.state.back() })
            Spacer()
            WTSemanticGlyph(name: "paperplane.circle")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(WTChrome353.accent)
            Text("快速发送文件、图片和文字")
                .font(.system(size: 15, weight: .medium))
                .padding(.top, 12)
            Text("完整文件选择与权限流程由主应用承载，键盘侧保留与原版一致的入口和状态。")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 5)
            Button("打开传送") { runtime.openQuickSendHostApp() }
                .buttonStyle(WTGreenPillButtonStyle())
                .padding(.top, 16)
            Spacer()
        }
        .background(WTChrome353.surface)
    }
}
