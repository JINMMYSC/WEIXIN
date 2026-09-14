import SwiftUI

public struct WTQuickSendPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "隔空传送", onBack: { runtime.state.back() })
            let state = runtime.panelLoadState(.quickSend)
            switch state {
            case .loading, .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(
                    state: state,
                    emptyTitle: "隔空传送",
                    emptySubtitle: "文件、图片和文字选择由主应用继续完成。",
                    retry: { runtime.openQuickSendHostApp() }
                )
            case .idle, .ready, .empty:
                VStack(spacing: 0) {
                    Spacer()
                    WTSemanticGlyph(name: "paperplane.circle")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(WTChrome353.accent)
                    Text("快速发送文件、图片和文字")
                        .font(.system(size: 15, weight: .medium)).padding(.top, 12)
                    Text("在主应用选择内容后，通过共享状态回到键盘继续传送。")
                        .font(.system(size: 12)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        .padding(.horizontal, 40).padding(.top, 5)
                    Button("打开传送") { runtime.openQuickSendHostApp() }
                        .buttonStyle(WTGreenPillButtonStyle()).padding(.top, 16)
                    Spacer()
                }
            }
        }
        .background(WTChrome353.surface)
    }
}
