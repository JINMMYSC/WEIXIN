import SwiftUI

public struct WTGuideAuthView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "功能授权", onBack: { runtime.state.back() })
            VStack(spacing: 12) {
                card("剪贴板", system: "doc.on.clipboard", body: "读取复制内容并显示历史记录", enabled: runtime.clipboardAuthorizationGranted) {
                    runtime.requestClipboardAuthorization()
                    runtime.clipboardAuthorizationGranted = true
                }
                card("语音输入", system: "mic", body: "语音功能需要由主 App 完成麦克风与语音识别授权", enabled: false) { runtime.openQuickSendHostApp() }
                card("隔空传送", system: "paperplane", body: "发现局域网设备并发送文件", enabled: true) { runtime.state.present(.deviceSync) }
            }.padding(10)
            Spacer(minLength: 0)
        }.background(WTChrome353.panelBackground)
    }

    private func card(_ title: String, system: String, body: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 11) {
            WTSemanticGlyph(name: system).font(.system(size: 19)).frame(width: 30)
            VStack(alignment: .leading, spacing: 3) { Text(title).font(.system(size: 14, weight: .medium)); Text(body).font(.system(size: 11)).foregroundStyle(.secondary) }
            Spacer()
            Button(enabled ? "已开启" : "去开启", action: action).font(.system(size: 11, weight: .medium)).foregroundStyle(enabled ? .secondary : WTChrome353.accent)
        }.padding(12).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
