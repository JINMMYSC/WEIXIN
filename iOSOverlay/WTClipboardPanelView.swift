import SwiftUI
import Foundation

public struct WTClipboardPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            header
            content
            footer
        }
        .background(WTChrome353.panelBackground)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button { runtime.state.back() } label: {
                WTSemanticGlyph(name: "chevron.up")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(WTChrome353.elevatedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(spacing: 0) {
                Text("剪贴板")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WTChrome353.primaryText)
                    .frame(width: 66, height: 30)
                    .background(WTChrome353.elevatedSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Button("常用语") { runtime.state.present(.phrases) }
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WTChrome353.primaryText)
                    .frame(width: 66, height: 30)
                    .buttonStyle(.plain)
            }
            .padding(3)
            .background(WTChrome353.surface)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Spacer(minLength: 0)

            Menu {
                Button("读取剪贴板") { runtime.captureCurrentClipboard() }
                Button("图片剪贴板") { runtime.state.present(.pasteboardImage) }
                Button("清除未固定内容", role: .destructive) { runtime.clearClipboard() }
            } label: {
                WTSemanticGlyph(name: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(WTChrome353.elevatedSurface)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
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
            if runtime.clipboardItems.isEmpty {
                WTPhase4PanelStateView(
                    state: .empty,
                    emptyTitle: "暂无剪贴板记录",
                    emptySubtitle: "复制文字后点击读取；需要时系统会显示剪贴板授权提示。",
                    requestPermission: { runtime.requestClipboardAuthorization() }
                )
            } else {
                list
            }
        case .ready:
            if runtime.clipboardItems.isEmpty {
                WTPhase4PanelStateView(state: .empty, emptyTitle: "暂无剪贴板记录", emptySubtitle: "复制文字后点击读取。")
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(Array(runtime.clipboardItems.enumerated()), id: \.element.id) { index, entry in
                    if shouldShowDayDivider(before: index) {
                        HStack(spacing: 8) {
                            Rectangle().fill(WTChrome353.separator).frame(height: 0.5)
                            Text("以下为 1 天前的内容")
                                .font(.system(size: 10.5))
                                .foregroundStyle(WTChrome353.secondary)
                                .fixedSize()
                            Rectangle().fill(WTChrome353.separator).frame(height: 0.5)
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 2)
                    }
                    card(entry)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    private func card(_ entry: WTClipboardItem) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Button { runtime.insertClipboard(entry) } label: {
                VStack(alignment: .leading, spacing: 5) {
                    if entry.pinned {
                        Text("已固定")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(WTChrome353.accent)
                    }
                    Text(entry.text)
                        .font(.system(size: 15))
                        .foregroundStyle(WTChrome353.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 2)
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
                    .foregroundStyle(WTChrome353.secondary)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(WTChrome353.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func shouldShowDayDivider(before index: Int) -> Bool {
        guard runtime.clipboardItems.indices.contains(index), index > 0 else { return false }
        let calendar = Calendar.current
        let previous = runtime.clipboardItems[index - 1].createdAt
        let current = runtime.clipboardItems[index].createdAt
        return !calendar.isDate(previous, inSameDayAs: current)
    }

    private var footer: some View {
        HStack {
            Button { runtime.advanceToNextInputMode() } label: {
                WTSemanticGlyph(name: "globe").font(.system(size: 22)).frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
            Spacer()
            Button { runtime.state.present(.voice) } label: {
                WTSemanticGlyph(name: "mic").font(.system(size: 22)).frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
    }
}
