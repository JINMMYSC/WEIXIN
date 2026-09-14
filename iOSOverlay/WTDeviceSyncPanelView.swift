import SwiftUI

public struct WTDeviceSyncPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "设备", onBack: {
                runtime.stopDeviceDiscovery()
                runtime.state.back()
            }, trailingSystemName: "arrow.clockwise") {
                runtime.startDeviceDiscovery()
            }

            let state = runtime.panelLoadState(.deviceSync)
            if case .failed = state {
                WTPhase4PanelStateView(state: state, emptyTitle: "暂无附近设备", emptySubtitle: "保持两台设备在同一局域网。", retry: { runtime.startDeviceDiscovery() })
            } else if case .offline = state {
                WTPhase4PanelStateView(state: state, emptyTitle: "暂无附近设备", emptySubtitle: "请检查网络连接。", retry: { runtime.startDeviceDiscovery() })
            } else {
                content
            }
        }
        .background(WTChrome353.panelBackground)
        .onAppear { runtime.startDeviceDiscovery() }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 10) {
                pairingCard
                transferStatusCard
                trustedSection
                peerSection
                if let name = runtime.transferLastReceivedFileName {
                    HStack(spacing: 8) {
                        WTSemanticGlyph(name: "checkmark.circle.fill").foregroundStyle(WTThemeColor353.accent)
                        Text("已接收 \(name)").font(.system(size: 12)).lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(WTChrome353.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
            .padding(10)
        }
    }

    private var pairingCard: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 7) {
                    WTToolIconView(tool: .deviceSync).frame(width: 19, height: 19)
                    Text("设备配对码").font(.system(size: 13, weight: .medium))
                }
                Spacer()
                Button("更换") { runtime.regenerateTransferPairingCode() }
                    .font(.system(size: 11)).buttonStyle(.plain).foregroundStyle(WTThemeColor353.accent)
            }
            HStack(spacing: 5) {
                ForEach(Array(runtime.transferPairing.code.enumerated()), id: \.offset) { _, char in
                    Text(String(char))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(width: 32, height: 36)
                        .background(WTChrome353.panelBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
            }
            Text("两台设备使用相同配对码后，在附近设备中选择目标设备。")
                .font(.system(size: 10)).foregroundStyle(WTThemeColor353.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder private var transferStatusCard: some View {
        switch runtime.transferState {
        case .idle: EmptyView()
        case .discovering: statusRow(title: "正在查找附近设备", detail: "保持两台设备在同一局域网", progress: nil)
        case .connecting(let peer): statusRow(title: "正在连接 \(peer)", detail: "正在校验配对信息", progress: nil)
        case .transferring(let peer, let progress): statusRow(title: "正在与 \(peer) 传输", detail: "\(Int((progress * 100).rounded()))%", progress: progress)
        case .completed(let peer): statusRow(title: "传输完成", detail: peer, progress: 1)
        case .failed(let reason): statusRow(title: "传输失败", detail: reason, progress: nil)
        }
    }

    private func statusRow(title: String, detail: String, progress: Double?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.system(size: 12, weight: .medium))
                Spacer()
                Text(detail).font(.system(size: 10)).foregroundStyle(WTThemeColor353.secondaryText).lineLimit(1)
            }
            if let progress { ProgressView(value: min(max(progress, 0), 1)).tint(WTThemeColor353.accent) }
        }
        .padding(10).background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder private var trustedSection: some View {
        if !runtime.trustedTransferDevices.isEmpty {
            VStack(spacing: 1) {
                HStack { Text("已配对设备").font(.system(size: 11)).foregroundStyle(WTThemeColor353.secondaryText); Spacer() }.padding(.horizontal, 2)
                ForEach(runtime.trustedTransferDevices) { device in
                    HStack(spacing: 12) {
                        WTToolIconView(tool: .deviceSync).frame(width: 21, height: 21).frame(width: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(device.name).font(.system(size: 14, weight: .medium))
                            Text("成功传输 \(device.successfulTransfers) 次").font(.system(size: 10)).foregroundStyle(WTThemeColor353.secondaryText)
                        }
                        Spacer()
                        Button("移除") { runtime.revokeTrustedTransferDevice(device.id) }.font(.system(size: 11)).buttonStyle(.plain).foregroundStyle(WTThemeColor353.secondaryText)
                    }
                    .padding(.horizontal, 12).frame(height: 54).background(WTChrome353.surface)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    @ViewBuilder private var peerSection: some View {
        if runtime.devicePeers.isEmpty {
            let state = runtime.panelLoadState(.deviceSync)
            WTPhase4PanelStateView(
                state: state == .loading ? .loading : .empty,
                emptyTitle: "暂无附近设备",
                emptySubtitle: "在另一台设备打开输入法，并保持在同一局域网。",
                retry: { runtime.startDeviceDiscovery() }
            )
            .frame(minHeight: 112)
        } else {
            VStack(spacing: 1) {
                HStack { Text("附近设备").font(.system(size: 11)).foregroundStyle(WTThemeColor353.secondaryText); Spacer() }.padding(.horizontal, 2)
                ForEach(runtime.devicePeers) { peer in
                    HStack(spacing: 12) {
                        WTToolIconView(tool: .deviceSync).frame(width: 21, height: 21).frame(width: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(peer.name).font(.system(size: 14, weight: .medium))
                            Text(peer.id).font(.system(size: 10)).foregroundStyle(WTThemeColor353.secondaryText).lineLimit(1)
                        }
                        Spacer()
                        WTBasicGlyphView(.chevronRight, tint: WTThemeColor353.secondaryText, size: 12)
                    }
                    .padding(.horizontal, 12).frame(height: 54).background(WTChrome353.surface)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}
