#if canImport(SwiftUI) && canImport(Speech) && canImport(AVFoundation)
import SwiftUI

public struct WTHostVoiceCaptureView: View {
    let requestID: UUID
    let mailbox: WTServiceMailbox?
    @Environment(\.dismiss) private var dismiss
    @State private var state: WTVoiceState = .idle
    private let service: WTHostSpeechRecognitionService
    @State private var liveActivityController: WTVoiceLiveActivityController?

    public init(requestID: UUID, mailbox: WTServiceMailbox?) {
        self.requestID = requestID
        self.mailbox = mailbox
        self.service = WTHostSpeechRecognitionService()
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                WTSemanticGlyph(name: icon)
                    .font(.system(size: 54, weight: .medium))
                    .foregroundStyle(state.isFailure ? Color.red : Color(red: 35/255, green: 200/255, blue: 145/255))
                Text(status).font(.system(size: 17)).multilineTextAlignment(.center).padding(.horizontal, 28)
                Spacer()
                HStack(spacing: 18) {
                    Button("取消") { service.cancel(); finish(error: "用户取消") }
                    if state.isBusy {
                        Button("结束") { service.stop() }.buttonStyle(.borderedProminent)
                    } else if !state.isResult {
                        Button("开始") { service.start() }.buttonStyle(.borderedProminent)
                    }
                }
                .padding(.bottom, 28)
            }
            .navigationTitle("语音输入")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if #available(iOS 16.1, *) {
                let controller = WTVoiceLiveActivityController()
                liveActivityController = controller
                controller.start(requestID: requestID)
            }
            service.onStateChange = { next in
                state = next
                if #available(iOS 16.1, *) { liveActivityController?.update(next) }
                if case .result(let text) = next { finish(value: text) }
                if case .failed(let message) = next { finish(error: message, dismissImmediately: false) }
            }
            service.start()
        }
        .onDisappear { service.cancel() }
    }

    private var icon: String {
        switch state { case .result: return "checkmark.circle.fill"; case .failed: return "exclamationmark.triangle.fill"; default: return "waveform.circle.fill" }
    }
    private var status: String {
        switch state {
        case .idle: return "准备语音输入"
        case .preparing: return "正在申请权限并准备麦克风…"
        case .recording(let partial): return partial.isEmpty ? "正在聆听…" : partial
        case .recognizing: return "正在识别…"
        case .result(let text): return text
        case .failed(let error): return error
        }
    }

    private func finish(value: String) {
        if #available(iOS 16.1, *) { liveActivityController?.end(finalText: value) }
        try? mailbox?.complete(.init(requestID: requestID, value: value))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { dismiss() }
    }

    private func finish(error: String, dismissImmediately: Bool = true) {
        if #available(iOS 16.1, *) { liveActivityController?.end() }
        try? mailbox?.complete(.init(requestID: requestID, error: error))
        if dismissImmediately { dismiss() }
    }
}

private extension WTVoiceState {
    var isBusy: Bool { if case .preparing = self { return true }; if case .recording = self { return true }; if case .recognizing = self { return true }; return false }
    var isResult: Bool { if case .result = self { return true }; return false }
    var isFailure: Bool { if case .failed = self { return true }; return false }
}
#endif
