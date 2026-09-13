import Foundation

public enum WTInputMode: String, Codable, Sendable, CaseIterable {
    case chinesePinyin26
    case chinesePinyin9
    case english26
    case doublePinyin
    case wubi
    case stroke
    case handwriting

    public var isChineseFamily: Bool {
        switch self {
        case .english26: return false
        default: return true
        }
    }
}

public enum WTPanel: String, Codable, Sendable, CaseIterable {
    case keyboard
    case number
    case symbols
    case emoji
    case clipboard
    case phrases
    case handwriting
    case voice
    case translate
    case correction
    case askAI
    case controlCenter
    case inputModeSwitcher
    case quickSettings
    case fullSymbols
    case deviceSync
    case quickSend
    case textPolish
    case picture
    case hotWords
    case stickers
    case wordSplitting
    case fontPicker
    case keyboardAdjust
    case guide
    case pasteboardImage
    case plus
    case toolbarArrange
    case bookVideo
}

/// Centralized state for panel return behavior, language toggling and shift.
/// The goal is to keep panel transitions from silently forcing a different IME mode.
public struct WTKeyboardState: Codable, Sendable, Equatable {
    public private(set) var inputMode: WTInputMode
    public private(set) var panel: WTPanel
    public private(set) var shiftState: WTShiftState
    public private(set) var lastChineseMode: WTInputMode
    private var returnStack: [WTPanel]

    public init(
        inputMode: WTInputMode = .chinesePinyin26,
        panel: WTPanel = .keyboard,
        shiftState: WTShiftState = .off,
        lastChineseMode: WTInputMode? = nil
    ) {
        self.inputMode = inputMode
        self.panel = panel
        self.shiftState = shiftState
        self.lastChineseMode = lastChineseMode ?? (inputMode.isChineseFamily ? inputMode : .chinesePinyin26)
        self.returnStack = []
    }

    public mutating func switchInputMode(to mode: WTInputMode) {
        inputMode = mode
        if mode.isChineseFamily { lastChineseMode = mode }
        if mode != .english26 { shiftState = .off }
        panel = .keyboard
        returnStack.removeAll(keepingCapacity: true)
    }

    /// Matches the expected language key behavior: Chinese family -> English,
    /// English -> the last Chinese-family layout (26/9/Wubi/Double Pinyin/etc.).
    public mutating func toggleLanguage() {
        if inputMode == .english26 {
            inputMode = lastChineseMode
            shiftState = .off
        } else {
            if inputMode.isChineseFamily { lastChineseMode = inputMode }
            inputMode = .english26
            shiftState = .off
        }
        panel = .keyboard
        returnStack.removeAll(keepingCapacity: true)
    }

    public mutating func cycleShift() {
        guard inputMode == .english26 else { return }
        shiftState.cycle()
    }

    public mutating func consumeOneShotShiftIfNeeded() {
        if shiftState == .once { shiftState = .off }
    }

    public mutating func present(_ next: WTPanel) {
        if panel != next { returnStack.append(panel) }
        panel = next
    }

    public mutating func back() {
        panel = returnStack.popLast() ?? .keyboard
    }

    public mutating func returnToKeyboard() {
        panel = .keyboard
        returnStack.removeAll(keepingCapacity: true)
    }
}
