#if canImport(UIKit)
import UIKit
import Foundation

/// Binds App Group persistence and independently configurable providers to one keyboard runtime.
/// Phase 4 keeps the provider state observable: loading, empty, permission, offline, failed and
/// fallback are deliberately different states, matching the product-level behavior exposed by the
/// WeType 3.5.3 panel family instead of silently turning every error into an empty array/string.
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
        bindHostHandoffs()
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
        runtime.setPanelLoadState(snapshot.clipboardEnabled ? clipboardContentState : .permissionDenied("请先在主 App 的剪贴板设置中开启剪贴板功能"), for: .clipboard)
        runtime.setPanelLoadState(snapshot.voiceEnabled ? .idle : .permissionDenied("语音输入已在主 App 设置中关闭"), for: .voice)
        if !snapshot.clipboardEnabled, runtime.state.panel == .clipboard { runtime.state.back() }
        if !snapshot.voiceEnabled, runtime.state.panel == .voice { runtime.state.back() }
    }

    private var clipboardContentState: WTPanelLoadState {
        runtime.clipboardItems.isEmpty ? .empty : .ready
    }

    private func bindPersistence() {
        clipboardStore = WTSharedStoreFactory.clipboard(appGroupIdentifier: appGroupIdentifier)
        emojiStore = WTSharedStoreFactory.emoji(appGroupIdentifier: appGroupIdentifier)
        phraseStore = WTSharedStoreFactory.phrases(appGroupIdentifier: appGroupIdentifier)

        runtime.clipboardItems = clipboardStore?.items ?? []
        runtime.recentEmoji = emojiStore?.recent.map(\.symbol) ?? []
        runtime.phrases = phraseStore?.items ?? []
        runtime.setPanelLoadState(clipboardContentState, for: .clipboard)
        runtime.setPanelLoadState(runtime.phrases.isEmpty ? .empty : .ready, for: .phrases)
        runtime.setPanelLoadState(.ready, for: .emoji)
        runtime.setPanelLoadState(.ready, for: .fullSymbols)

        runtime.setClipboardPinned = { [weak self] id, pinned in
            guard let self else { return }
            self.clipboardStore?.setPinned(pinned, id: id)
            self.runtime.clipboardItems = self.clipboardStore?.items ?? []
            self.runtime.setPanelLoadState(self.clipboardContentState, for: .clipboard)
        }
        runtime.deleteClipboardItem = { [weak self] id in
            guard let self else { return }
            self.clipboardStore?.delete(id: id)
            self.runtime.clipboardItems = self.clipboardStore?.items ?? []
            self.runtime.setPanelLoadState(self.clipboardContentState, for: .clipboard)
        }
        runtime.clearClipboard = { [weak self] in
            guard let self else { return }
            self.clipboardStore?.clearUnpinned()
            self.runtime.clipboardItems = self.clipboardStore?.items ?? []
            self.runtime.setPanelLoadState(self.clipboardContentState, for: .clipboard)
        }
        runtime.captureCurrentClipboard = { [weak self] in
            guard let self else { return }
            if let defaults = UserDefaults(suiteName: self.appGroupIdentifier),
               !WTKeyboardPreferenceSnapshot(defaults: defaults).clipboardEnabled {
                self.runtime.setPanelLoadState(.permissionDenied("请先在主 App 的剪贴板设置中开启剪贴板功能"), for: .clipboard)
                return
            }
            guard UIPasteboard.general.hasStrings, let value = UIPasteboard.general.string, !value.isEmpty else {
                self.runtime.setPanelLoadState(self.clipboardContentState, for: .clipboard)
                return
            }
            self.clipboardStore?.add(value)
            self.runtime.clipboardItems = self.clipboardStore?.items ?? []
            self.runtime.clipboardAuthorizationGranted = true
            self.runtime.setPanelLoadState(.ready, for: .clipboard)
        }
        runtime.recordEmoji = { [weak self] symbol in
            guard let self else { return }
            self.emojiStore?.record(symbol)
            self.runtime.recentEmoji = self.emojiStore?.recent.map(\.symbol) ?? []
            self.runtime.setPanelLoadState(.ready, for: .emoji)
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
        runtime.setPanelLoadState(.idle, for: .handwriting)
        runtime.recognizeHandwriting = { [weak self, weak recognizer] strokes in
            guard let self, let recognizer else { return [] }
            self.runtime.setPanelLoadState(.loading, for: .handwriting)
            do {
                let candidates = try await recognizer.recognize(strokes: strokes).map(\.text)
                self.runtime.setPanelLoadState(candidates.isEmpty ? .empty : .ready, for: .handwriting)
                return candidates
            } catch {
                self.runtime.setPanelLoadState(.fallback("系统手写识别暂不可用，请重试或切换键盘"), for: .handwriting)
                return []
            }
        }

        let correction = WTLocalCorrectionService()
        correctionService = correction
        runtime.setPanelLoadState(.idle, for: .correction)
        runtime.correctionSuggestions = { [weak self, weak correction] text in
            guard let self, let correction else { return [] }
            self.runtime.setPanelLoadState(.loading, for: .correction)
            do {
                let suggestions = try await correction.suggestions(for: text).map(\.replacement)
                self.runtime.setPanelLoadState(suggestions.isEmpty ? .empty : .ready, for: .correction)
                return suggestions
            } catch {
                self.runtime.setPanelLoadState(.failed(error.localizedDescription), for: .correction)
                return []
            }
        }

        runtime.requestClipboardAuthorization = { [weak self] in
            guard let self else { return }
            self.runtime.setPanelLoadState(.loading, for: .clipboard)
            UIPasteboard.general.detectPatterns(for: [.probableWebURL, .probableWebSearch]) { result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        self.runtime.clipboardAuthorizationGranted = true
                        self.runtime.captureCurrentClipboard()
                        self.runtime.setPanelLoadState(self.clipboardContentState, for: .clipboard)
                    case .failure(let error):
                        self.runtime.clipboardAuthorizationGranted = false
                        self.runtime.setPanelLoadState(.permissionDenied(error.localizedDescription), for: .clipboard)
                    }
                }
            }
        }
    }

    private func bindNetworkProviders() {
        let configURL = WTSharedStoreFactory.providerConfigurationURL(appGroupIdentifier: appGroupIdentifier)
        let config = WTProviderConfigurationStore.load(from: configURL)

        if let endpoint = config.ai {
            let service = WTHTTPAIService(endpoint: endpoint); aiService = service
            runtime.setPanelLoadState(.idle, for: .askAI)
            runtime.setPanelLoadState(.idle, for: .textPolish)
            runtime.runAI = { [weak self, weak service] tool, text in
                guard let self, let service else { return "" }
                let panel: WTPanel = tool == .polish || tool == .rewrite ? .textPolish : .askAI
                self.runtime.setPanelLoadState(.loading, for: panel)
                do {
                    let result = try await service.run(.init(tool: tool, text: text))
                    self.runtime.setPanelLoadState(result.isEmpty ? .empty : .ready, for: panel)
                    return result
                } catch {
                    self.runtime.setPanelLoadState(Self.loadState(for: error), for: panel)
                    return ""
                }
            }
        } else {
            runtime.setPanelLoadState(.fallback("未配置 AI 服务；可在主 App 中配置自己的服务端"), for: .askAI)
            runtime.setPanelLoadState(.fallback("未配置润色服务；当前不向腾讯私有服务发起请求"), for: .textPolish)
        }

        if let endpoint = config.translation {
            let service = WTHTTPTranslationService(endpoint: endpoint); translationService = service
            runtime.setPanelLoadState(.idle, for: .translate)
            runtime.translate = { [weak self, weak service] text, source, target in
                guard let self, let service else { return "" }
                self.runtime.setPanelLoadState(.loading, for: .translate)
                do {
                    let result = try await service.translate(text, from: source, to: target).target
                    self.runtime.setPanelLoadState(result.isEmpty ? .empty : .ready, for: .translate)
                    return result
                } catch {
                    self.runtime.setPanelLoadState(Self.loadState(for: error), for: .translate)
                    return ""
                }
            }
        } else {
            runtime.setPanelLoadState(.fallback("未配置翻译服务；本地输入功能不受影响"), for: .translate)
        }

        if let endpoint = config.hotWords {
            let service = WTHTTPHotWordService(endpoint: endpoint); hotWordService = service
            runtime.setPanelLoadState(.idle, for: .hotWords)
            runtime.loadHotWords = { [weak self, weak service] in
                guard let self, let service else { return [] }
                self.runtime.setPanelLoadState(.loading, for: .hotWords)
                do {
                    let values = try await service.load()
                    self.runtime.setPanelLoadState(values.isEmpty ? .empty : .ready, for: .hotWords)
                    return values
                } catch {
                    self.runtime.setPanelLoadState(Self.loadState(for: error), for: .hotWords)
                    return []
                }
            }
        } else {
            runtime.setPanelLoadState(.fallback("未配置热词服务；仍可使用本地词库"), for: .hotWords)
        }

        if let endpoint = config.media {
            let service = WTHTTPMediaService(endpoint: endpoint); mediaService = service
            runtime.setPanelLoadState(.idle, for: .stickers)
            runtime.loadMedia = { [weak self, weak service] kind, query in
                guard let self, let service else { return [] }
                self.runtime.setPanelLoadState(.loading, for: .stickers)
                do {
                    let values = try await service.search(kind: kind, query: query)
                    self.runtime.setPanelLoadState(values.isEmpty ? .empty : .ready, for: .stickers)
                    return values
                } catch {
                    self.runtime.setPanelLoadState(Self.loadState(for: error), for: .stickers)
                    return []
                }
            }
        } else {
            runtime.setPanelLoadState(.fallback("未配置表情包/GIF 内容服务；Emoji 本地分类仍可使用"), for: .stickers)
        }

        runtime.setPanelLoadState(.fallback("微信富内容搜索需要自有 provider；不会调用腾讯私有接口"), for: .bookVideo)
    }

    private func bindTransfer() {
        guard let root = WTSharedStoreFactory.containerURL(appGroupIdentifier: appGroupIdentifier) else {
            runtime.setPanelLoadState(.failed("无法访问 App Group 共享目录"), for: .deviceSync)
            return
        }
        let code = loadOrCreateTransferPairingCode()
        runtime.transferPairing = WTTransferPairingInfo(code: code, deviceName: UIDevice.current.name)
        loadTrustedTransferRegistry()
        configureTransferService(root: root, pairingCode: code)
        runtime.setPanelLoadState(.idle, for: .deviceSync)
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
        service.onPeersChange = { [weak self] peers in
            Task { @MainActor in
                guard let self else { return }
                self.runtime.devicePeers = peers
                if peers.isEmpty, self.runtime.panelLoadState(.deviceSync) == .loading {
                    self.runtime.setPanelLoadState(.empty, for: .deviceSync)
                } else if !peers.isEmpty {
                    self.runtime.setPanelLoadState(.ready, for: .deviceSync)
                }
            }
        }
        service.onStateChange = { [weak self] state in
            Task { @MainActor in
                guard let self else { return }
                self.runtime.transferState = state
                switch state {
                case .idle: self.runtime.setPanelLoadState(.idle, for: .deviceSync)
                case .discovering, .connecting, .transferring: self.runtime.setPanelLoadState(.loading, for: .deviceSync)
                case .completed: self.runtime.setPanelLoadState(.ready, for: .deviceSync)
                case .failed(let message): self.runtime.setPanelLoadState(.failed(message), for: .deviceSync)
                }
            }
        }
        service.onReceivedFile = { [weak self] url, _ in
            Task { @MainActor in
                self?.runtime.transferLastReceivedFileName = url.lastPathComponent
                self?.runtime.setPanelLoadState(.ready, for: .deviceSync)
            }
        }
        service.onAuthenticatedPeer = { [weak self] peer in
            Task { @MainActor in self?.recordTrustedTransferPeer(peer) }
        }
        transferService = service
        runtime.startDeviceDiscovery = { [weak self, weak service] in
            self?.runtime.setPanelLoadState(.loading, for: .deviceSync)
            service?.startDiscovery()
        }
        runtime.stopDeviceDiscovery = { [weak service] in service?.stopDiscovery() }
    }

    private func bindHostHandoffs() {
        runtime.openQuickSendHostApp = { [weak self] in
            self?.openHostRoute("quick-send", panel: .quickSend, failure: "无法打开隔空传送")
        }
        runtime.openPictureHostApp = { [weak self] in
            self?.openHostRoute("picture", panel: .picture, failure: "无法打开图片功能")
        }
    }

    private func openHostRoute(_ route: String, panel: WTPanel, failure: String) {
        guard let openURL, let url = URL(string: "wtreplica://\(route)") else {
            runtime.setPanelLoadState(.fallback("请在主 App 中继续此操作"), for: panel)
            return
        }
        runtime.setPanelLoadState(.loading, for: panel)
        openURL(url) { [weak self] opened in
            Task { @MainActor in
                self?.runtime.setPanelLoadState(opened ? .ready : .failed(failure), for: panel)
            }
        }
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
              let response = try? serviceMailbox?.response(for: id) else { return }
        if let value = response.value, !value.isEmpty {
            runtime.commitDirectText(value)
            runtime.voiceState = .result(value)
            runtime.setPanelLoadState(.ready, for: .voice)
        } else if let error = response.error {
            runtime.voiceState = .failed(error)
            runtime.setPanelLoadState(.failed(error), for: .voice)
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
                self.runtime.setPanelLoadState(.permissionDenied("请先在主 App 中开启语音输入"), for: .voice)
                return
            }
            let request = WTServiceRequest(kind: .voice)
            do { try mailbox.submit(request) } catch {
                self.runtime.voiceState = .failed(error.localizedDescription)
                self.runtime.setPanelLoadState(.failed(error.localizedDescription), for: .voice)
                return
            }
            UserDefaults(suiteName: self.appGroupIdentifier)?.set(request.id.uuidString, forKey: "wt.voice.pendingRequestID")
            self.runtime.voiceState = .preparing
            self.runtime.setPanelLoadState(.loading, for: .voice)
            guard let url = URL(string: "wtreplica://voice?request=\(request.id.uuidString)"), let openURL = self.openURL else {
                self.runtime.voiceState = .failed("请在主 App 中启动语音输入")
                self.runtime.setPanelLoadState(.fallback("键盘扩展无法直接访问麦克风，请切到主 App 完成语音识别"), for: .voice)
                return
            }
            openURL(url) { [weak self] opened in
                Task { @MainActor in
                    guard let self else { return }
                    if !opened {
                        self.runtime.voiceState = .failed("无法打开语音输入")
                        self.runtime.setPanelLoadState(.failed("无法打开主 App 的语音输入页面"), for: .voice)
                    }
                }
            }
        }
        runtime.stopVoice = { }
        runtime.cancelVoice = { [weak self] in
            guard let self, let defaults = UserDefaults(suiteName: self.appGroupIdentifier),
                  let raw = defaults.string(forKey: "wt.voice.pendingRequestID"),
                  let id = UUID(uuidString: raw) else {
                self?.runtime.voiceState = .idle
                self?.runtime.setPanelLoadState(.idle, for: .voice)
                return
            }
            try? self.serviceMailbox?.remove(requestID: id)
            defaults.removeObject(forKey: "wt.voice.pendingRequestID")
            self.runtime.voiceState = .idle
            self.runtime.setPanelLoadState(.idle, for: .voice)
        }
    }

    private static func loadState(for error: Error) -> WTPanelLoadState {
        let nsError = error as NSError
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost,
                 .cannotConnectToHost, .dnsLookupFailed, .internationalRoamingOff, .dataNotAllowed:
                return .offline("网络不可用，请检查连接后重试")
            default:
                break
            }
        }
        if nsError.domain == NSURLErrorDomain {
            return .offline("网络请求失败，请稍后重试")
        }
        return .failed(error.localizedDescription)
    }
}
#endif
