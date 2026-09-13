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
                Text("点击内容直接上屏；长内容最多显示四行")
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

            if runtime.clipboardItems.isEmpty {
                WTEmptyPanelState(systemName: "doc.on.clipboard", title: "暂无剪贴板记录", subtitle: "复制文字后打开键盘，即可保存在这里。")
            } else {
                ScrollView {
                    LazyVStack(spacing: 7) {
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
                                        if let i = runtime.clipboardItems.firstIndex(where: { $0.id == entry.id }) { runtime.clipboardItems[i].pinned.toggle() }
                                    }
                                    Button("删除", role: .destructive) {
                                        runtime.deleteClipboardItem(entry.id)
                                        runtime.clipboardItems.removeAll { $0.id == entry.id }
                                    }
                                } label: {
                                    WTSemanticGlyph(name: "ellipsis")
                                        .font(.system(size: 15))
                                        .frame(width: 28, height: 28)
                                }
                            }
                            .padding(10)
                            .background(WTChrome353.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(8)
                }
            }
        }
        .background(WTChrome353.panelBackground)
    }
}
