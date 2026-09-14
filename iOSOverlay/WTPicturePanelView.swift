import SwiftUI

public struct WTPicturePanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "图片", onBack: { runtime.state.back() })
            let state = runtime.panelLoadState(.picture)
            switch state {
            case .loading, .permissionDenied, .offline, .failed:
                WTPhase4PanelStateView(state: state, emptyTitle: "发送图片", emptySubtitle: "从主应用选择图片后回到键盘继续发送。", retry: { runtime.openPictureHostApp() })
            case .fallback:
                WTPhase4PanelStateView(state: state, emptyTitle: "发送图片", emptySubtitle: "需要主应用承载图片选择。", retry: { runtime.openPictureHostApp() })
            case .idle, .ready, .empty:
                VStack(spacing: 12) {
                    Spacer()
                    WTSemanticGlyph(name: "photo.on.rectangle.angled")
                        .font(.system(size: 48, weight: .light)).foregroundStyle(WTChrome353.accent)
                    Text("发送图片").font(.system(size: 15, weight: .medium))
                    Text("图片选择由主应用承载，完成后通过 App Group 返回键盘。")
                        .font(.system(size: 12)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 38)
                    Button("打开图片选择") { runtime.openPictureHostApp() }.buttonStyle(WTGreenPillButtonStyle())
                    Spacer()
                }
            }
        }
        .background(WTChrome353.surface)
    }
}
