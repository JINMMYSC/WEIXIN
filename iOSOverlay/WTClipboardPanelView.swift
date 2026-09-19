import SwiftUI

public struct WTClipboardPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "剪贴板", onBack: { runtime.state.back() }, trailingSystemName: "ellipsis") {
                runtime.captureCurrentClipboard()
            }

            HStack(spacing: 8) {
                WTSemanticGlyph(name: "info.circle").foregroundStyle(.secondary)
                Text("点击内容直接上屏；固定内容不会被自动清理")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
                Spacer()
                Button { runtime.state.present(.pasteboardImage) } label: { WTSemanticGlyph(name: "photo") }
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(WTChrome353.accent)
                Button("读取") { runtime.captureCurrentClipboard() }
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(WTChrome353.accent)
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(WTChrome353.panelBackground)

            content
        }
        .background(WTChrome353.panelBackground)
    }

    @ViewBuilder private var content: some View {
        let state = runtime.panelLoadState(.clipboard)
        switch state {
        case .loading, .permissionDenied, .offline, .failed, .fallback:
            WTPhase4PanelStateView(
                state: state,
                emptyTitle: "暂无剪贴板记录",
                emptySubtitle: "复制文字后打开键盘，即可保存在这里。",
                retry: { runtime.captureCurrentClipboard() },
                requestPermission: { runtime.requestClipboardAuthorization() }
            )
        case .idle, .empty:
            WTPhase4PanelStateView(
                state: .empty,
                emptyTitle: "暂无剪贴板记录",
                emptySubtitle: "复制文字后点击读取；需要时系统会显示剪贴板授权提示。",
                requestPermission: { runtime.requestClipboardAuthorization() }
            )
        case .ready:
            if runtime.clipboardItems.isEmpty {
                WTPhase4PanelStateView(state: .empty, emptyTitle: "暂无剪贴板记录", emptySubtitle: "复制文字后点击读取。")
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView {
            // Measured 3.5.3 clipboard panel: 47.5 pt rows separated by 8 pt.
            LazyVStack(spacing: CGFloat(WTMeasuredPanels353.clipboardRowSpacing)) {
                ForEach(runtime.clipboardItems) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Button { runtime.insertClipboard(entry) } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                if entry.pinned {
                                    HStack(spacing: 4) { WTSemanticGlyph(name: "pin.fill"); Text("已固定") }
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundStyle(WTChrome353.accent)
                                }
                                Text(entry.text)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)

                        Menu {
                            Button(entry.pinned ? "取消固定" : "固定") {
                                runtime.setClipboardPinned(entry.id, !entry.pinned)
                            }
                            Button("删除", role: .destructive) { runtime.deleteClipboardItem(entry.id) }
                        } label: {
                            WTSemanticGlyph(name: "ellipsis")
                                .font(.system(size: 15))
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding(10)
                    .frame(minHeight: CGFloat(WTMeasuredPanels353.clipboardRowHeight))
                    .background(WTChrome353.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(8)
        }
    }
}
