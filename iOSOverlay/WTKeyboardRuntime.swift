import SwiftUI

public struct WTCandidateActionTarget: Equatable {
    public var displayIndex: Int
    public var sourceIndex: Int
    public var text: String
    public init(displayIndex: Int, sourceIndex: Int, text: String) {
        self.displayIndex = displayIndex; self.sourceIndex = sourceIndex; self.text = text
    }
}

public struct WTLongPressPopupState: Equatable {
    public var keyID: String
    public var items: [String]
    public var defaultIndex: Int?
    public var sourceRect: WTRect?
}

@MainActor
public final class WTKeyboardRuntime: ObservableObject {
    @Published public var state: WTKeyboardState
    @Published public var candidates: [String]
    @Published public var candidateSourceIndexes: [Int]
    @Published public var candidatePageState: WTCandidatePageState = .singlePage
    @Published public var composition: String
    @Published public var candidateExpanded = false
    @Published public var candidateActionTarget: WTCandidateActionTarget?
    @Published public var longPressPopup: WTLongPressPopupState?
    @Published public var clipboardItems: [WTClipboardItem]
    @Published public var phrases: [WTPhraseItem]
    @Published public var recentEmoji: [String]
    @Published public var handwritingCandidates: [String]
    @Published public var voiceState: WTVoiceState
    @Published public var toolbarExpanded = false
    @Published public var toolbarEnabled = true
    @Published public var hapticIntensity: Double = 0.5
    @Published public var quickSettings = WTQuickSettingState()
    @Published public var symbolCategory: WTSymbolCategory = .common
    @Published public var devicePeers: [WTPeerDevice] = []
    @Published public var transferState: WTTransferState = .idle
    @Published public var hotWords: [WTHotWordItem] = []
    @Published public var mediaCards: [WTMediaCard] = []
    @Published public var wordSplitOptions: [WTWordSplitOption] = []
    @Published public var keyboardAdjustment = WTKeyboardAdjustment()
    @Published public var fontScale: Double = 1.0
    @Published public var clipboardAuthorizationGranted = false
    @Published public var toolbarOrder: [WTKeyboardTool] = WTToolbarCatalog353.compact
    @Published public var strokeFilter: [String] = []
    @Published public var bookVideoCards: [WTBookVideoCard] = []
    @Published public var visualCalibration = WTVisualCalibrationProfile()
    @Published public var returnKeyPresentation = WTReturnKeyPresentation()
    @Published public var transferPairing = WTTransferPairingInfo(code: "", deviceName: "")
    @Published public var transferLastReceivedFileName: String?
    @Published public var trustedTransferDevices: [WTTrustedTransferDevice] = []
    /// Phase 4 deliberately exposes provider/content states instead of treating every provider
    /// failure as an empty list. Keys use WTPanel.rawValue so the model stays Codable-independent.
    @Published public var phase4PanelStates: [String: WTPanelLoadState] = [:]

    public var insertText: (String) -> Void
    public var commitDirectText: (String) -> Void
    public var deleteBackward: () -> Void
    public var submitReturn: () -> Void
    public var submitSpace: () -> Void
    public var advanceToNextInputMode: () -> Void
    public var sendCharacterToRime: (String) -> Void
    public var selectCandidate: (Int) -> Void
    public var moveCandidatePage: (WTCandidatePageDirection) -> Void
    public var pinCandidate: (Int, String) -> Void
    public var deleteCandidate: (Int, String) -> Void
    public var refreshIMEContext: () -> Void
    public var inputModeDidChange: (WTInputMode) -> Void
    public var performKeyFeedback: (Bool) -> Void
    public var stateDidChange: (WTKeyboardState) -> Void

    public var setClipboardPinned: (UUID, Bool) -> Void
    public var deleteClipboardItem: (UUID) -> Void
    public var clearClipboard: () -> Void
    public var captureCurrentClipboard: () -> Void
    public var recordEmoji: (String) -> Void

    public var recognizeHandwriting: ([WTHandwritingStroke]) async -> [String]
    public var startVoice: () -> Void
    public var stopVoice: () -> Void
    public var cancelVoice: () -> Void
    public var translate: (String, String, String) async -> String
    public var runAI: (WTAITool, String) async -> String
    public var correctionSuggestions: (String) async -> [String]
    public var startDeviceDiscovery: () -> Void
    public var stopDeviceDiscovery: () -> Void
    public var regenerateTransferPairingCode: () -> Void
    public var revokeTrustedTransferDevice: (String) -> Void
    public var openQuickSendHostApp: () -> Void
    public var openPictureHostApp: () -> Void
    public var loadHotWords: () async -> [WTHotWordItem]
    public var loadMedia: (WTMediaContentKind, String) async -> [WTMediaCard]
    public var sendMedia: (WTMediaCard) -> Void
    public var splitWords: (String) async -> [WTWordSplitOption]
    public var requestClipboardAuthorization: () -> Void
    public var strokeFilterDidChange: ([String]) -> Void
    public var addHotWord: (String) -> Void
    public var deleteHotWord: (String) -> Void
    public var searchBookVideoProvider: (String, Set<WTBookVideoKind>) async -> [WTBookVideoCard]
    public var performBookVideoProvider: (WTBookVideoAction, WTBookVideoCard) async -> Void

    public init(
        state: WTKeyboardState = .init(),
        candidates: [String] = [],
        composition: String = "",
        clipboardItems: [WTClipboardItem] = [],
        phrases: [WTPhraseItem] = [],
        recentEmoji: [String] = [],
        insertText: @escaping (String) -> Void = { _ in },
        commitDirectText: ((String) -> Void)? = nil,
        deleteBackward: @escaping () -> Void = {},
        submitReturn: @escaping () -> Void = {},
        submitSpace: @escaping () -> Void = {},
        advanceToNextInputMode: @escaping () -> Void = {},
        sendCharacterToRime: @escaping (String) -> Void = { _ in },
        selectCandidate: @escaping (Int) -> Void = { _ in },
        moveCandidatePage: @escaping (WTCandidatePageDirection) -> Void = { _ in },
        pinCandidate: @escaping (Int, String) -> Void = { _, _ in },
        deleteCandidate: @escaping (Int, String) -> Void = { _, _ in },
        refreshIMEContext: @escaping () -> Void = {},
        inputModeDidChange: @escaping (WTInputMode) -> Void = { _ in },
        performKeyFeedback: @escaping (Bool) -> Void = { _ in },
        stateDidChange: @escaping (WTKeyboardState) -> Void = { _ in },
        setClipboardPinned: @escaping (UUID, Bool) -> Void = { _, _ in },
        deleteClipboardItem: @escaping (UUID) -> Void = { _ in },
        clearClipboard: @escaping () -> Void = {},
        captureCurrentClipboard: @escaping () -> Void = {},
        recordEmoji: @escaping (String) -> Void = { _ in },
        recognizeHandwriting: @escaping ([WTHandwritingStroke]) async -> [String] = { _ in [] },
        startVoice: @escaping () -> Void = {},
        stopVoice: @escaping () -> Void = {},
        cancelVoice: @escaping () -> Void = {},
        translate: @escaping (String, String, String) async -> String = { _, _, _ in "" },
        runAI: @escaping (WTAITool, String) async -> String = { _, _ in "" },
        correctionSuggestions: @escaping (String) async -> [String] = { _ in [] },
        startDeviceDiscovery: @escaping () -> Void = {},
        stopDeviceDiscovery: @escaping () -> Void = {},
        regenerateTransferPairingCode: @escaping () -> Void = {},
        revokeTrustedTransferDevice: @escaping (String) -> Void = { _ in },
        openQuickSendHostApp: @escaping () -> Void = {},
        openPictureHostApp: @escaping () -> Void = {},
        loadHotWords: @escaping () async -> [WTHotWordItem] = { [] },
        loadMedia: @escaping (WTMediaContentKind, String) async -> [WTMediaCard] = { _, _ in [] },
        sendMedia: @escaping (WTMediaCard) -> Void = { _ in },
        splitWords: @escaping (String) async -> [WTWordSplitOption] = { _ in [] },
        requestClipboardAuthorization: @escaping () -> Void = {},
        strokeFilterDidChange: @escaping ([String]) -> Void = { _ in },
        addHotWord: @escaping (String) -> Void = { _ in },
        deleteHotWord: @escaping (String) -> Void = { _ in },
        searchBookVideoProvider: @escaping (String, Set<WTBookVideoKind>) async -> [WTBookVideoCard] = { _, _ in [] },
        performBookVideoProvider: @escaping (WTBookVideoAction, WTBookVideoCard) async -> Void = { _, _ in }
    ) {
        self.state = state
        self.candidates = candidates
        self.candidateSourceIndexes = Array(candidates.indices)
        self.composition = composition
        self.clipboardItems = clipboardItems
        self.phrases = phrases
        self.recentEmoji = recentEmoji
        self.handwritingCandidates = []
        self.voiceState = .idle
        self.insertText = insertText
        self.commitDirectText = commitDirectText ?? insertText
        self.deleteBackward = deleteBackward
        self.submitReturn = submitReturn
        self.submitSpace = submitSpace
        self.advanceToNextInputMode = advanceToNextInputMode
        self.sendCharacterToRime = sendCharacterToRime
        self.selectCandidate = selectCandidate
        self.moveCandidatePage = moveCandidatePage
        self.pinCandidate = pinCandidate
        self.deleteCandidate = deleteCandidate
        self.refreshIMEContext = refreshIMEContext
        self.inputModeDidChange = inputModeDidChange
        self.performKeyFeedback = performKeyFeedback
        self.stateDidChange = stateDidChange
        self.setClipboardPinned = setClipboardPinned
        self.deleteClipboardItem = deleteClipboardItem
        self.clearClipboard = clearClipboard
        self.captureCurrentClipboard = captureCurrentClipboard
        self.recordEmoji = recordEmoji
        self.recognizeHandwriting = recognizeHandwriting
        self.startVoice = startVoice
        self.stopVoice = stopVoice
        self.cancelVoice = cancelVoice
        self.translate = translate
        self.runAI = runAI
        self.correctionSuggestions = correctionSuggestions
        self.startDeviceDiscovery = startDeviceDiscovery
        self.stopDeviceDiscovery = stopDeviceDiscovery
        self.regenerateTransferPairingCode = regenerateTransferPairingCode
        self.revokeTrustedTransferDevice = revokeTrustedTransferDevice
        self.openQuickSendHostApp = openQuickSendHostApp
        self.openPictureHostApp = openPictureHostApp
        self.loadHotWords = loadHotWords
        self.loadMedia = loadMedia
        self.sendMedia = sendMedia
        self.splitWords = splitWords
        self.requestClipboardAuthorization = requestClipboardAuthorization
        self.strokeFilterDidChange = strokeFilterDidChange
        self.addHotWord = addHotWord
        self.deleteHotWord = deleteHotWord
        self.searchBookVideoProvider = searchBookVideoProvider
        self.performBookVideoProvider = performBookVideoProvider
    }

    public func panelLoadState(_ panel: WTPanel) -> WTPanelLoadState {
        phase4PanelStates[panel.rawValue] ?? .idle
    }

    public func setPanelLoadState(_ value: WTPanelLoadState, for panel: WTPanel) {
        phase4PanelStates[panel.rawValue] = value
    }

    public func handle(_ item: WTKeyboardItem, gesture: WTKeyGesture = .tap) {
        let action = WTKeyActionResolver.action(for: item, gesture: gesture, state: state)
        handle(action, sourceItem: item)
    }

    public func handle(_ action: WTResolvedKeyAction, sourceItem: WTKeyboardItem? = nil) {
        switch action {
        case .none:
            return
        case .engineInput(let text):
            sendCharacterToRime(text)
            state.consumeOneShotShiftIfNeeded()
            refreshIMEContext()
        case .directText(let text):
            commitDirectText(text)
            state.consumeOneShotShiftIfNeeded()
            refreshIMEContext()
        case .longPressOptions(let items, let defaultIndex):
            longPressPopup = .init(keyID: sourceItem?.id ?? "", items: items, defaultIndex: defaultIndex, sourceRect: sourceItem?.rect)
        case .function(let fn):
            handleFunction(fn)
        }
    }

    public func selectLongPressText(_ text: String) {
        longPressPopup = nil
        commitDirectText(text)
        refreshIMEContext()
    }

    public func chooseCandidate(_ index: Int) {
        guard candidates.indices.contains(index) else { return }
        let sourceIndex = candidateSourceIndexes.indices.contains(index) ? candidateSourceIndexes[index] : index
        if sourceIndex < 0 {
            commitDirectText(candidates[index])
        } else {
            selectCandidate(sourceIndex)
        }
        candidateExpanded = false
        candidateActionTarget = nil
        refreshIMEContext()
    }

    public func showCandidateActions(index: Int) {
        guard candidates.indices.contains(index) else { return }
        let sourceIndex = candidateSourceIndexes.indices.contains(index) ? candidateSourceIndexes[index] : index
        candidateActionTarget = .init(displayIndex: index, sourceIndex: sourceIndex, text: candidates[index])
    }

    public func applyCandidatePin() {
        guard let target = candidateActionTarget else { return }
        pinCandidate(target.sourceIndex, target.text)
        candidateActionTarget = nil
        refreshIMEContext()
    }

    public func applyCandidateDelete() {
        guard let target = candidateActionTarget else { return }
        deleteCandidate(target.sourceIndex, target.text)
        candidateActionTarget = nil
        refreshIMEContext()
    }

    public func chooseEmoji(_ symbol: String) {
        insertText(symbol)
        recordEmoji(symbol)
        recentEmoji.removeAll { $0 == symbol }
        recentEmoji.insert(symbol, at: 0)
        if recentEmoji.count > 48 { recentEmoji.removeLast(recentEmoji.count - 48) }
    }

    public func insertClipboard(_ item: WTClipboardItem) { insertText(item.text) }
    public func insertPhrase(_ item: WTPhraseItem) { insertText(item.text) }

    public func chooseInputMode(_ mode: WTInputMode) {
        state.switchInputMode(to: mode)
        inputModeDidChange(mode)
        stateDidChange(state)
        refreshIMEContext()
    }

    public func toggleOneHanded(_ side: WTOneHandedMode) {
        quickSettings.oneHandedMode = side
    }

    public func presentTool(_ tool: WTKeyboardTool) {
        switch tool {
        case .emoji: state.present(.emoji)
        case .clipboard: state.present(.clipboard)
        case .phrases: state.present(.phrases)
        case .handwriting: state.present(.handwriting)
        case .voice: state.present(.voice)
        case .translate: state.present(.translate)
        case .askAI: state.present(.askAI)
        case .correction: state.present(.correction)
        case .inputMode: state.present(.inputModeSwitcher)
        case .oneHanded: state.present(.quickSettings)
        case .deviceSync: state.present(.deviceSync)
        case .quickSend: state.present(.quickSend)
        case .textPolish: state.present(.textPolish)
        case .picture: state.present(.picture)
        case .fullSymbols: state.present(.fullSymbols)
        case .quickSettings: state.present(.quickSettings)
        case .hotWords: state.present(.hotWords)
        case .stickers: state.present(.stickers)
        case .wordSplitting: state.present(.wordSplitting)
        case .fontPicker: state.present(.fontPicker)
        case .keyboardAdjust: state.present(.keyboardAdjust)
        case .plus: state.present(.plus)
        }
    }

    public func changeCandidatePage(_ direction: WTCandidatePageDirection) {
        switch direction {
        case .previous where !candidatePageState.hasPrevious: return
        case .next where !candidatePageState.hasNext: return
        default: break
        }
        candidateActionTarget = nil
        moveCandidatePage(direction)
    }

    public func releaseTransientCaches(budget: WTKeyboardMemoryPressureBudget = .extensionWarning) {
        candidateExpanded = false
        candidateActionTarget = nil
        longPressPopup = nil
        handwritingCandidates.removeAll(keepingCapacity: false)
        mediaCards.removeAll(keepingCapacity: false)
        wordSplitOptions.removeAll(keepingCapacity: false)
        bookVideoCards.removeAll(keepingCapacity: false)
        devicePeers.removeAll(keepingCapacity: false)
        candidates = Array(candidates.prefix(budget.maxVisibleCandidates))
        candidateSourceIndexes = Array(candidateSourceIndexes.prefix(candidates.count))
        clipboardItems = budget.trimmedClipboard(clipboardItems)
        phrases = Array(phrases.prefix(budget.maxPhrases))
        recentEmoji = Array(recentEmoji.prefix(budget.maxRecentEmoji))
        toolbarExpanded = false
        if state.panel != .keyboard { state.returnToKeyboard() }
    }

    public func searchBookVideo(_ query: String, _ kinds: Set<WTBookVideoKind>) async -> [WTBookVideoCard] {
        await searchBookVideoProvider(query, kinds)
    }

    public func performBookVideo(_ action: WTBookVideoAction, card: WTBookVideoCard) async {
        await performBookVideoProvider(action, card)
    }

    private func handleFunction(_ fn: String) {
        switch fn {
        case "delete": deleteBackward(); refreshIMEContext()
        case "return", "newline": submitReturn(); refreshIMEContext()
        case "space": submitSpace(); refreshIMEContext()
        case "emoji": state.present(.emoji)
        case "clipboard": state.present(.clipboard)
        case "phrases": state.present(.phrases)
        case "handwriting": state.present(.handwriting)
        case "voice": state.present(.voice)
        case "translate": state.present(.translate)
        case "askAI": state.present(.askAI)
        case "correction": state.present(.correction)
        case "fullSymbol", "symbols": state.present(.symbols)
        case "controlCenter", "plus": state.present(.controlCenter)
        case "inputMode", "keyboard": state.present(.inputModeSwitcher)
        case "quickSettings", "settings": state.present(.quickSettings)
        case "fullSymbols": state.present(.fullSymbols)
        case "deviceSync", "equipment": state.present(.deviceSync)
        case "quickSend", "transmission": state.present(.quickSend)
        case "textPolish", "polish": state.present(.textPolish)
        case "picture": state.present(.picture)
        case "hotWords", "hotword": state.present(.hotWords)
        case "sticker", "stickers", "gif": state.present(.stickers)
        case "wordSplitting", "splitWords", "findwords": state.present(.wordSplitting)
        case "font", "fontPicker": state.present(.fontPicker)
        case "keyboardAdjust", "rectSetting": state.present(.keyboardAdjust)
        case "guide", "authGuide": state.present(.guide)
        case "pasteboardImage": state.present(.pasteboardImage)
        case "plusConfig", "wetypePlus": state.present(.plus)
        case "toolbarArrange", "arrange": state.present(.toolbarArrange)
        case "bookVideo", "finder", "wechatContent": state.present(.bookVideo)
        case "123": state.present(.number)
        case "back", "backToInput": state.back()
        case "langswitch":
            state.toggleLanguage()
            inputModeDidChange(state.inputMode)
            stateDidChange(state)
            refreshIMEContext()
        case "shift": state.cycleShift()
        case "🌐": advanceToNextInputMode()
        default: break
        }
    }
}
