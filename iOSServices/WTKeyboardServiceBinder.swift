#if canImport(UIKit)
import UIKit
import Foundation

/// Binds App Group persistence and independently configurable providers to one keyboard runtime.
/// This keeps the UI usable with local-only features and upgrades network features when endpoints
/// are configured by the containing app.
@MainActor
public final class WTKeyboardServiceBinder {
    private let runtime: WTKeyboardRuntime
    private let appGroupIdentifier: String
    private let openURL: ((URL, @escaping (Bool) -> Void) -> Void)?
    private var clipboardStore: WTJSONClipboardStore?
    private var emojiStore: WTJSONEmojiStore?
    private var phraseStore: WTJSONPhraseStore?
    private var transferService: WTBonjourTransferService?
    private var handwritingRecognizer: WTVisionHandwritingRecognizer?
    private var correctionService: WTLocalCorrectionService?
    private var aiService: WTHTTPAIService?
    private var translationService: WTHTTPTranslationService?
    private var hotWordService: WTHTTPHotWordService?
    private var mediaService: WTHTTPMediaService?
    private var serviceMailbox: WTJSONServiceMailbox?
    private var feedbackService: WTKeyboardFeedbackService?
    private var trustedTransferRegistry = WTTrustedTransferRegistry()

    public init(
        runtime: WTKeyboardRuntime,
        appGroupIdentifier: String,
        openURL: ((URL, @escaping (Bool) -> Void) -> Void)? = nil
    ) {
        self.runtime = runtime
        self.appGroupIdentifier = appGroupIdentifier
        self.openURL = openURL
    }

    public static func cloudCandidateService(appGroupIdentifier: String) -> WTCloudCandidateService? {
        if let defaults = UserDefaults(suiteName: appGroupIdentifier),
           !WTKeyboardPreferenceSnapshot(defaults: defaults).cloudEnabled { return nil }
        let url = WTSharedStoreFactory.providerConfigurationURL(appGroupIdentifier: appGroupIdentifier)
        let config = WTProviderConfigurationStore.load(from: url)
        guard let endpoint = config.cloudCandidate else { return nil }
        return WTHTTPCloudCandidateService(endpoint: endpoint)
    }

    public func bind() {
        restoreSessionState()
        reloadSharedSettings()
        bindPersistence()
        bindLocalServices()
        bindNetworkProviders()
        bindTransfer()
        bindVoiceBridge()
    }


    public func restoreSessionState() {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: WTKeyboardSessionPersistence.defaultsKey),
              let snapshot = try? WTKeyboardSessionPersistence.decode(data) else {
            runtime.stateDidChange = { [weak self] state in self?.persistSessionState(state) }
            return
        }
        runtime.state = snapshot.restoredState()
        runtime.inputModeDidChange(runtime.state.inputMode)
        runtime.stateDidChange = { [weak self] state in self?.persistSessionState(state) }
    }

    public func persistSessionState(_ state: WTKeyboardState? = nil) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        let snapshot = WTKeyboardSessionSnapshot(state: state ?? runtime.state)
        guard let data = try? WTKeyboardSessionPersistence.encode(snapshot) else { return }
        defaults.set(data, forKey: WTKeyboardSessionPersistence.defaultsKey)
    }

    public func reloadSharedSettings() {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        let snapshot = WTKeyboardPreferenceSnapshot(defaults: defaults)
        runtime.quickSettings.keySoundEnabled = snapshot.keySoundEnabled
        runtime.quickSettings.hapticEnabled = snapshot.hapticEnabled
        runtime.quickSettings.oneHandedMode = snapshot.oneHandedMode
        runtime.hapticIntensity = snapshot.hapticLevel
        runtime.fontScale = snapshot.fontScale
        runtime.keyboardAdjustment = snapshot.keyboardAdjustment
        runtime.toolbarEnabled = snapshot.toolbarEnabled
        if !snapshot.clipboardEnabled, runtime.state.panel == .clipboard { runtime.state.back() }
        if !snapshot.voiceEnabled, runtime.state.panel == .voice { runtime.state.back() }
    }

    private func bindPersistence() {
        clipboardStore = WTSharedStoreFactory.clipboard(appGroupIdentifier: appGroupIdentifier)
        emojiStore = WTSharedStoreFactory.emoji(appGroupIdentifier: appGroupIdentifier)
        phraseStore = WTSharedStoreFactory.phrases(appGroupIdentifier: appGroupIdentifier)

        runtime.clipboardItems = clipboardStore?.items ?? []
        runtime.recentEmoji = emojiStore?.recent.map(\.symbol) ?? []
        runtime.phrases = phraseStore?.items ?? []

        runtime.setClipboardPinned = { [weak self] id, pinned in
            self?.clipboardStore?.setPinned(pinned, id: id)
            self?.runtime.clipboardItems = self?.clipboardStore?.items ?? []
        }
        runtime.deleteClipboardItem = { [weak self] id in
            self?.clipboardStore?.delete(id: id)
            self?.runtime.clipboardItems = self?.clipboardStore?.items ?? []
        }
        runtime.clearClipboard = { [weak self] in
            self?.clipboardStore?.clearUnpinned()
            self?.runtime.clipboardItems = self?.clipboardStore?.items ?? []
        }
        runtime.captureCurrentClipboard = { [weak self] in
            guard let self else { return }
            if let defaults = UserDefaults(suiteName: self.appGroupIdentifier),
               !WTKeyboardPreferenceSnapshot(defaults: defaults).clipboardEnabled { return }
            guard UIPasteboard.general.hasStrings, let value = UIPasteboard.general.string else { return }
            self.clipboardStore?.add(value)
            self.runtime.clipboardItems = self.clipboardStore?.items ?? []
        }
        runtime.recordEmoji = { [weak self] symbol in
            self?.emojiStore?.record(symbol)
            self?.runtime.recentEmoji = self?.emojiStore?.recent.map(\.symbol) ?? []
        }
    }

    private func bindLocalServices() {
        let feedback = WTKeyboardFeedbackService()
        feedbackService = feedback
        runtime.performKeyFeedback = { [weak self, weak feedback] isDelete in
            guard let self, let feedback else { return }
            if isDelete { feedback.deletePressed(settings: self.runtime.quickSettings, intensity: self.runtime.hapticIntensity) }
            else { feedback.keyPressed(settings: self.runtime.quickSettings, intensity: self.runtime.hapticIntensity) }
        }

        let recognizer = WTVisionHandwritingRecognizer()
        handwritingRecognizer = recognizer
        runtime.recognizeHandwriting = { [weak recognizer] strokes in
            (try? await recognizer?.recognize(strokes: strokes))?.map(\.text) ?? []
        }

        let correction = WTLocalCorrectionService()
        correctionService = correction
        runtime.correctionSuggestions = { [weak correction] text in
            (try? await correction?.suggestions(for: text))?.map(\.replacement) ?? []
        }

        runtime.requestClipboardAuthorization = { [weak self] in
            guard let self else { return }
            _ = UIPasteboard.general.detectPatterns(for: [.probableWebURL, .probableWebSearch]) { _ in
                Task { @MainActor in
                    self.runtime.clipboardAuthorizationGranted = true
                    self.runtime.captureCurrentClipboard()
                }
            }
        }
    }

    private func bindNetworkProviders() {
        let configURL = WTSharedStoreFactory.providerConfigurationURL(appGroupIdentifier: appGroupIdentifier)
        let config = WTProviderConfigurationStore.load(from: configURL)
        if let endpoint = config.ai {
            let service = WTHTTPAIService(endpoint: endpoint); aiService = service
            runtime.runAI = { [weak service] tool, text in
                (try? await service?.run(.init(tool: tool, text: text))) ?? ""
            }
        }
        if let endpoint = config.translation {
            let service = WTHTTPTranslationService(endpoint: endpoint); translationService = service
            runtime.translate = { [weak service] text, source, target in
                (try? await service?.translate(text, from: source, to: target).target) ?? ""
            }
        }
        if let endpoint = config.hotWords {
            let service = WTHTTPHotWordService(endpoint: endpoint); hotWordService = service
            runtime.loadHotWords = { [weak service] in (try? await service?.load()) ?? [] }
        }
        if let endpoint = config.media {
            let service = WTHTTPMediaService(endpoint: endpoint); mediaService = service
            runtime.loadMedia = { [weak service] kind, query in (try? await service?.search(kind: kind, query: query)) ?? [] }
        }
    }

    private func bindTransfer() {
        guard let root = WTSharedStoreFactory.containerURL(appGroupIdentifier: appGroupIdentifier) else { return }
        let code = loadOrCreateTransferPairingCode()
        runtime.transferPairing = WTTransferPairingInfo(code: code, deviceName: UIDevice.current.name)
        loadTrustedTransferRegistry()
        configureTransferService(root: root, pairingCode: code)
        runtime.regenerateTransferPairingCode = { [weak self] in
            guard let self else { return }
            let next = Self.makePairingCode()
            UserDefaults(suiteName: self.appGroupIdentifier)?.set(next, forKey: WTSharedPreferenceKey.transferPairingCode)
            self.transferService?.stopDiscovery()
            self.transferService?.stopHosting()
            self.runtime.devicePeers = []
            self.runtime.transferPairing = WTTransferPairingInfo(code: next, deviceName: UIDevice.current.name)
            self.configureTransferService(root: root, pairingCode: next)
            self.runtime.startDeviceDiscovery()
        }
    }

    private func configureTransferService(root: URL, pairingCode: String) {
        let service = WTBonjourTransferService(
            deviceName: UIDevice.current.name,
            receiveDirectory: root.appendingPathComponent("WeTypeReplica/Received", isDirectory: true),
            pairingCode: pairingCode
        )
        service.onPeersChange = { [weak self] peers in Task { @MainActor in self?.runtime.devicePeers = peers } }
        service.onStateChange = { [weak self] state in Task { @MainActor in self?.runtime.transferState = state } }
        service.onReceivedFile = { [weak self] url, _ in
            Task { @MainActor in self?.runtime.transferLastReceivedFileName = url.lastPathComponent }
        }
        service.onAuthenticatedPeer = { [weak self] peer in
            Task { @MainActor in self?.recordTrustedTransferPeer(peer) }
        }
        transferService = service
        runtime.startDeviceDiscovery = { [weak service] in service?.startDiscovery() }
        runtime.stopDeviceDiscovery = { [weak service] in service?.stopDiscovery() }
    }

    private func loadTrustedTransferRegistry() {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        if let data = defaults?.data(forKey: WTSharedPreferenceKey.transferTrustedDevices),
           let decoded = try? WTTrustedTransferRegistry.decode(data) {
            trustedTransferRegistry = decoded
        } else {
            trustedTransferRegistry = .init()
        }
        runtime.trustedTransferDevices = trustedTransferRegistry.activeDevices
        runtime.revokeTrustedTransferDevice = { [weak self] id in
            guard let self else { return }
            self.trustedTransferRegistry.revoke(id: id)
            self.persistTrustedTransferRegistry()
        }
    }

    private func recordTrustedTransferPeer(_ peer: WTPeerDevice) {
        trustedTransferRegistry.recordSuccessfulTransfer(to: peer)
        persistTrustedTransferRegistry()
    }

    private func persistTrustedTransferRegistry() {
        if let data = try? trustedTransferRegistry.encoded() {
            UserDefaults(suiteName: appGroupIdentifier)?.set(data, forKey: WTSharedPreferenceKey.transferTrustedDevices)
        }
        runtime.trustedTransferDevices = trustedTransferRegistry.activeDevices
    }


    private func loadOrCreateTransferPairingCode() -> String {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        if let current = defaults?.string(forKey: WTSharedPreferenceKey.transferPairingCode),
           WTTransferPairingInfo(code: current, deviceName: UIDevice.current.name).isUsable {
            return WTTransferPairingInfo.normalized(current)
        }
        let code = Self.makePairingCode()
        defaults?.set(code, forKey: WTSharedPreferenceKey.transferPairingCode)
        return code
    }

    private static func makePairingCode() -> String {
        String(format: "%06d", Int.random(in: 0...999_999))
    }
    public func consumeServiceResponses() {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let idString = defaults.string(forKey: "wt.voice.pendingRequestID"),
              let id = UUID(uuidString: idString),
              let response = try? serviceMailbox?.response(for: id),
              let response else { return }
        if let value = response.value, !value.isEmpty {
            runtime.commitDirectText(value)
            runtime.voiceState = .result(value)
        } else if let error = response.error {
            runtime.voiceState = .failed(error)
        }
        try? serviceMailbox?.remove(requestID: id)
        defaults.removeObject(forKey: "wt.voice.pendingRequestID")
    }

    private func bindVoiceBridge() {
        serviceMailbox = WTSharedStoreFactory.serviceMailbox(appGroupIdentifier: appGroupIdentifier)
        runtime.startVoice = { [weak self] in
            guard let self, let mailbox = self.serviceMailbox else { return }
            if let defaults = UserDefaults(suiteName: self.appGroupIdentifier),
               !WTKeyboardPreferenceSnapshot(defaults: defaults).voiceEnabled {
                self.runtime.voiceState = .failed("语音输入已在设置中关闭")
                return
            }
            let request = WTServiceRequest(kind: .voice)
            do { try mailbox.submit(request) } catch {
                self.runtime.voiceState = .failed(error.localizedDescription)
                return
            }
            UserDefaults(suiteName: self.appGroupIdentifier)?.set(request.id.uuidString, forKey: "wt.voice.pendingRequestID")
            self.runtime.voiceState = .preparing
            guard let url = URL(string: "wtreplica://voice?request=\(request.id.uuidString)"), let openURL = self.openURL else {
                self.runtime.voiceState = .failed("请在主 App 中启动语音输入")
                return
            }
            openURL(url) { [weak self] opened in
                Task { @MainActor in
                    if !opened { self?.runtime.voiceState = .failed("无法打开语音输入") }
                }
            }
        }
        runtime.stopVoice = { }
        runtime.cancelVoice = { [weak self] in
            guard let self, let defaults = UserDefaults(suiteName: self.appGroupIdentifier),
                  let raw = defaults.string(forKey: "wt.voice.pendingRequestID"),
                  let id = UUID(uuidString: raw) else { self?.runtime.voiceState = .idle; return }
            try? self.serviceMailbox?.remove(requestID: id)
            defaults.removeObject(forKey: "wt.voice.pendingRequestID")
            self.runtime.voiceState = .idle
        }
    }

}
#endif
