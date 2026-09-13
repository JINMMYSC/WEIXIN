import SwiftUI

/// Share-extension surface reconstructed from the 3.5.3 file-transfer resources.
/// The view deliberately keeps transfer lifetime/status visible so the extension is not completed
/// before the underlying file transfer has actually acknowledged success.
public struct WTQuickSendShareView: View {
    public struct Item: Identifiable, Hashable {
        public let id: UUID
        public let name: String
        public let detail: String
        public init(id: UUID = UUID(), name: String, detail: String) {
            self.id = id; self.name = name; self.detail = detail
        }
    }

    let items: [Item]
    let peers: [WTPeerDevice]
    let isLoading: Bool
    let isSending: Bool
    let statusText: String
    let errorText: String?
    let progress: Double
    let canRetry: Bool
    let onCancel: () -> Void
    let onSend: (WTPeerDevice) -> Void
    let onRetry: () -> Void

    public init(
        items: [Item],
        peers: [WTPeerDevice],
        isLoading: Bool = false,
        isSending: Bool = false,
        statusText: String = "",
        errorText: String? = nil,
        progress: Double = 0,
        canRetry: Bool = false,
        onCancel: @escaping () -> Void,
        onSend: @escaping (WTPeerDevice) -> Void,
        onRetry: @escaping () -> Void = {}
    ) {
        self.items = items; self.peers = peers
        self.isLoading = isLoading; self.isSending = isSending
        self.statusText = statusText; self.errorText = errorText; self.progress = progress; self.canRetry = canRetry
        self.onCancel = onCancel; self.onSend = onSend; self.onRetry = onRetry
    }

    public var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 10) {
                        if isLoading || isSending { ProgressView().controlSize(.small) }
                        Text(statusText.isEmpty ? "隔空传送" : statusText)
                            .font(.subheadline)
                        Spacer()
                    }
                    if isSending {
                        ProgressView(value: max(0, min(1, progress)))
                    }
                    if let errorText {
                        HStack {
                            Text(errorText).font(.caption).foregroundStyle(.red)
                            Spacer()
                            if canRetry && !isSending {
                                Button("重试", action: onRetry)
                                    .font(.caption.weight(.medium))
                            }
                        }
                    }
                }

                Section("待发送") {
                    if items.isEmpty && !isLoading {
                        Text("没有可发送的内容").foregroundStyle(.secondary)
                    }
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            WTSemanticGlyph(name: "doc")
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name).lineLimit(1)
                                Text(item.detail).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("附近设备") {
                    if peers.isEmpty {
                        HStack {
                            ProgressView().controlSize(.small)
                            Text("正在查找设备…").foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(peers) { peer in
                            Button { onSend(peer) } label: {
                                HStack {
                                    WTSemanticGlyph(name: "laptopcomputer.and.iphone")
                                    Text(peer.name)
                                    Spacer()
                                    WTSemanticGlyph(name: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                                }
                            }
                            .disabled(isLoading || isSending || items.isEmpty)
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("隔空传送")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isSending ? "停止" : "取消", action: onCancel)
                }
            }
        }
        .tint(Color(red: 35/255, green: 200/255, blue: 145/255))
    }
}
