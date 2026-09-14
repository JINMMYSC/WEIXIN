import SwiftUI

public struct WTVoicePanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "语音输入", onBack: { runtime.cancelVoice(); runtime.state.back() })
            let panelState = runtime.panelLoadState(.voice)
            switch panelState {
            case .permissionDenied, .offline, .failed, .fallback:
                WTPhase4PanelStateView(
                    state: panelState,
                    emptyTitle: "语音输入",
                    emptySubtitle: "语音输入需要主应用承载麦克风与系统识别权限。",
                    retry: { runtime.startVoice() },
                    requestPermission: { runtime.startVoice() }
                )
            default:
                voiceSurface
            }
        }
        .background(WTChrome353.surface)
    }

    private var voiceSurface: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 6)
            ZStack {
                Circle().fill(WTChrome353.accent.opacity(0.10)).frame(width: 80, height: 80)
                WTPulsingVoiceGlyph(name: iconName, isBusy: isBusy, isFailure: isFailure)
            }
            Text(statusText)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 26)
                .padding(.top, 8)
            if isBusy { wave }
            Spacer(minLength: 4)
            HStack(spacing: 16) {
                if isBusy {
                    Button("取消") { runtime.cancelVoice() }
                        .font(.system(size: 13, weight: .medium)).frame(width: 74, height: 34)
                        .background(WTChrome353.panelBackground).clipShape(Capsule())
                    Button("结束") { runtime.stopVoice() }.buttonStyle(WTGreenPillButtonStyle())
                } else {
                    Button("开始语音") { runtime.startVoice() }.buttonStyle(WTGreenPillButtonStyle())
                }
            }
            .buttonStyle(.plain)
            .frame(height: 48)
            .padding(.bottom, 4)
        }
    }

    private var wave: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<16, id: \.self) { i in
                Capsule().fill(WTChrome353.accent.opacity(0.75)).frame(width: 2, height: CGFloat(7 + (i % 5) * 4))
            }
        }
        .frame(height: 26).padding(.top, 4)
    }

    private var isBusy: Bool {
        switch runtime.voiceState { case .preparing, .recording, .recognizing: return true; default: return false }
    }
    private var isFailure: Bool { if case .failed = runtime.voiceState { return true }; return false }
    private var iconName: String {
        switch runtime.voiceState { case .failed: return "exclamationmark"; case .result: return "checkmark"; default: return "waveform" }
    }
    private var statusText: String {
        switch runtime.voiceState {
        case .idle: return "点击开始说话"
        case .preparing: return "正在准备语音输入…"
        case .recording(let partial): return partial.isEmpty ? "正在聆听…" : partial
        case .recognizing: return "正在识别…"
        case .result(let text): return text
        case .failed(let error): return error
        }
    }
}

private struct WTPulsingVoiceGlyph: View {
    let name: String
    let isBusy: Bool
    let isFailure: Bool
    @State private var pulse = false

    var body: some View {
        WTSemanticGlyph(name: name)
            .font(.system(size: 34, weight: .medium))
            .foregroundStyle(isFailure ? Color.red : WTChrome353.accent)
            .scaleEffect(isBusy && pulse ? 1.08 : 0.96)
            .opacity(isBusy && pulse ? 0.72 : 1.0)
            .animation(isBusy ? .easeInOut(duration: 0.72).repeatForever(autoreverses: true) : .default, value: pulse)
            .onAppear { pulse = isBusy }
            .onChange(of: isBusy) { busy in pulse = busy }
    }
}
