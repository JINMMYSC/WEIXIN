import SwiftUI

public struct WTVoicePanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        let panelState = runtime.panelLoadState(.voice)
        Group {
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
                inlineVoiceKeyboard
            }
        }
        .background(WTChrome353.panelBackground)
        .onAppear {
            if isIdle { runtime.startVoice() }
        }
    }

    private var inlineVoiceKeyboard: some View {
        VStack(spacing: 0) {
            statusBar
                .frame(height: 58)
                .background(WTThemeColor353.keyboardBackground)

            WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
                .frame(height: CGFloat(keyboardLayout.baseSize.height))
                .overlay(alignment: .bottom) {
                    if isBusy {
                        Button { runtime.stopVoice() } label: {
                            Text("轻触结束")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(WTChrome353.secondary)
                                .frame(width: 184, height: 38)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 3)
                    }
                }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 44)
            VStack(spacing: 2) {
                Text(primaryStatus)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WTChrome353.secondary)
                    .lineLimit(1)
                Text(secondaryStatus)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WTChrome353.secondary.opacity(0.72))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            Button { isBusy ? runtime.stopVoice() : runtime.startVoice() } label: {
                ZStack {
                    Circle()
                        .fill(WTChrome353.accent.opacity(0.20))
                        .frame(width: 44, height: 44)
                    Circle()
                        .fill(WTChrome353.accent)
                        .frame(width: 34, height: 34)
                    WTSemanticGlyph(name: "mic")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
        }
    }

    private var isIdle: Bool {
        if case .idle = runtime.voiceState { return true }
        return false
    }

    private var isBusy: Bool {
        switch runtime.voiceState {
        case .preparing, .recording, .recognizing: return true
        default: return false
        }
    }

    private var primaryStatus: String {
        switch runtime.voiceState {
        case .idle: return "语音转文字"
        case .preparing, .recording, .recognizing: return "语音转文字中…"
        case .result(let text): return text.isEmpty ? "语音转文字" : text
        case .failed(let message): return message
        }
    }

    private var secondaryStatus: String {
        switch runtime.voiceState {
        case .preparing, .recording, .recognizing: return "轻触结束"
        case .idle: return "轻触开始"
        case .result: return "识别完成"
        case .failed: return "轻触重试"
        }
    }

    private var keyboardLayout: WTKeyboardLayout {
        let raw: WTKeyboardLayout
        switch runtime.state.inputMode {
        case .chinesePinyin26: raw = WTLayouts353Resolved.t26Pinyin
        case .chinesePinyin9: raw = WTLayouts353Resolved.t9Pinyin
        case .english26: raw = WTLayouts353Resolved.t26En
        case .doublePinyin: raw = WTLayouts353Resolved.t26Pinyin
        case .wubi: raw = WTLayouts353Resolved.t26Wubi
        case .stroke: raw = WTLayouts353Resolved.t9Stroke
        case .handwriting: raw = WTLayouts353Resolved.t26InnerHw
        }
        return WT353RuntimeLayoutGeometry.primaryLayout(raw, mode: runtime.state.inputMode)
    }
}
