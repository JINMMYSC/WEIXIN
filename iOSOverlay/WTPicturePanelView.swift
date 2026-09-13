import SwiftUI

public struct WTPicturePanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "图片", onBack: { runtime.state.back() })
            WTEmptyPanelState(systemName: "photo.on.rectangle.angled", title: "发送图片", subtitle: "从主应用选择图片后，可通过共享数据回到键盘继续发送。")
            Button("打开图片选择") { runtime.openPictureHostApp() }
                .buttonStyle(WTGreenPillButtonStyle())
                .padding(.bottom, 14)
        }
        .background(WTChrome353.surface)
    }
}
