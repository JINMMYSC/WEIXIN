import SwiftUI

public struct WTTopBarTipsView: View {
    let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        HStack(spacing: 7) { WTSemanticGlyph(name: "info.circle"); Text(text).lineLimit(2); Spacer(minLength: 0) }
            .font(.system(size: 11)).foregroundStyle(.secondary).padding(.horizontal, 10).frame(minHeight: 30)
            .background(WTChrome353.panelBackground)
    }
}

public struct WTNetworkAlertView: View {
    let retry: () -> Void
    public init(retry: @escaping () -> Void) { self.retry = retry }
    public var body: some View {
        HStack(spacing: 8) {
            WTSemanticGlyph(name: "wifi.exclamationmark").foregroundStyle(.secondary)
            Text("网络不可用，请检查网络设置").font(.system(size: 11))
            Spacer()
            Button("重试", action: retry).font(.system(size: 11, weight: .medium)).foregroundStyle(WTChrome353.accent)
        }.padding(.horizontal, 10).frame(height: 34).background(WTChrome353.surface)
    }
}

public struct WTLicenseAlertView: View {
    let accept: () -> Void
    let cancel: () -> Void
    public init(accept: @escaping () -> Void, cancel: @escaping () -> Void) { self.accept = accept; self.cancel = cancel }
    public var body: some View {
        VStack(spacing: 10) {
            Text("服务说明").font(.system(size: 15, weight: .semibold))
            Text("使用在线能力前需要阅读并同意对应服务说明与隐私规则。")
                .font(.system(size: 11)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            HStack(spacing: 8) { Button("取消", action: cancel).buttonStyle(.bordered); Button("同意", action: accept).buttonStyle(WTGreenPillButtonStyle()) }
        }.padding(16).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(radius: 12)
    }
}
