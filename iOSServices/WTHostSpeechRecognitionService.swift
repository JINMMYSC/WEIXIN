#if canImport(Speech) && canImport(AVFoundation)
import Foundation
import Speech
import AVFoundation

@MainActor
public final class WTHostSpeechRecognitionService: NSObject, WTVoiceService {
    public private(set) var state: WTVoiceState = .idle { didSet { onStateChange?(state) } }
    public var onStateChange: ((WTVoiceState) -> Void)?

    private let localeIdentifier: String
    private var recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    public init(localeIdentifier: String = "zh-CN") {
        self.localeIdentifier = localeIdentifier
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        super.init()
    }

    public func start() {
        guard case .idle = state else {
            if case .result = state { state = .idle } else { return }
            return start()
        }
        state = .preparing
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                guard status == .authorized else {
                    self.state = .failed("未获得语音识别权限")
                    return
                }
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else { self.state = .failed("未获得麦克风权限"); return }
                        self.beginRecording()
                    }
                }
            }
        }
    }

    public func stop() {
        guard audioEngine.isRunning else { return }
        request?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        state = .recognizing
    }

    public func cancel() {
        task?.cancel(); task = nil
        request?.endAudio(); request = nil
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        state = .idle
    }

    private func beginRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            task?.cancel()
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if #available(iOS 13.0, *), recognizer?.supportsOnDeviceRecognition == true {
                request.requiresOnDeviceRecognition = false
            }
            self.request = request

            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
                request?.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            state = .recording(partial: "")

            task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let result {
                        let text = result.bestTranscription.formattedString
                        if result.isFinal {
                            self.finish(text: text)
                        } else {
                            self.state = .recording(partial: text)
                        }
                    } else if let error {
                        self.finish(error: error.localizedDescription)
                    }
                }
            }
        } catch {
            finish(error: error.localizedDescription)
        }
    }

    private func finish(text: String) {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio(); request = nil; task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        state = .result(text)
    }

    private func finish(error: String) {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio(); request = nil; task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        state = .failed(error)
    }
}
#endif
