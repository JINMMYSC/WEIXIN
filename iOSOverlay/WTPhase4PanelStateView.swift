import SwiftUI

/// Shared Phase 4 state surface.  WeType exposes distinct loading/empty/permission/network/error
/// states; keeping them explicit prevents an unavailable provider from looking like a valid empty
/// result. Artwork is independently drawn through WTSemanticGlyph.
public struct WTPhase4PanelStateView: View {
    public let state: WTPanelLoadState
    public var emptyTitle: String
    public var emptySubtitle: String
    public var retry: (() -> Void)?
    public var requestPermission: (() -> Void)?

    public init(
        state: WTPanelLoadState,
        emptyTitle: String,
        emptySubtitle: String,
        retry: (() -> Void)? = nil,
        requestPermission: (() -> Void)? = nil
    ) {
        self.state = state
        self.emptyTitle = emptyTitle
        self.emptySubtitle = emptySubtitle
        self.retry = retry
        self.requestPermission = requestPermission
    }

    public var body: some View {
        VStack(spacing: 9) {
            Spacer(minLength: 0)
            stateGlyph
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WTChrome353.primaryText)
                .multilineTextAlignment(.center)
            if !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(WTChrome353.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)
            }
            actionButton
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WTChrome353.surface)
    }

    @ViewBuilder private var stateGlyph: some View {
        switch state {
        case .loading:
            ProgressView().tint(WTChrome353.accent).scaleEffect(0.9)
        case .permissionDenied:
            WTSemanticGlyph(name: "lock.shield").font(.system(size: 30)).foregroundStyle(WTChrome353.secondary)
        case .offline:
            WTSemanticGlyph(name: "wifi.slash").font(.system(size: 30)).foregroundStyle(WTChrome353.secondary)
        case .failed:
            WTSemanticGlyph(name: "exclamationmark.triangle").font(.system(size: 30)).foregroundStyle(WTChrome353.secondary)
        case .fallback:
            WTSemanticGlyph(name: "info.circle").font(.system(size: 30)).foregroundStyle(WTChrome353.secondary)
        case .idle, .ready, .empty:
            WTSemanticGlyph(name: "tray").font(.system(size: 30)).foregroundStyle(WTChrome353.secondary)
        }
    }

    private var title: String {
        switch state {
        case .loading: return "加载中"
        case .permissionDenied: return "需要权限"
        case .offline: return "网络不可用"
        case .failed: return "加载失败"
        case .fallback: return "当前使用兼容模式"
        case .idle, .ready, .empty: return emptyTitle
        }
    }

    private var detail: String {
        switch state {
        case .loading: return ""
        case .permissionDenied(let message), .offline(let message), .failed(let message), .fallback(let message): return message
        case .idle, .ready, .empty: return emptySubtitle
        }
    }

    @ViewBuilder private var actionButton: some View {
        switch state {
        case .permissionDenied where requestPermission != nil:
            Button("去授权") { requestPermission?() }.buttonStyle(WTGreenPillButtonStyle())
        case .offline, .failed where retry != nil:
            Button("重试") { retry?() }.buttonStyle(WTGreenPillButtonStyle())
        default:
            EmptyView()
        }
    }
}
