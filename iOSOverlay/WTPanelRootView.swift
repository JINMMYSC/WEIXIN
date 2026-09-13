import SwiftUI

public struct WTPanelRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        Group {
            if isKeyboardSurface && runtime.quickSettings.oneHandedMode != .off {
                WTOneHandedShell(
                    mode: runtime.quickSettings.oneHandedMode,
                    close: { runtime.toggleOneHanded(.off) },
                    switchSide: { runtime.toggleOneHanded(runtime.quickSettings.oneHandedMode == .left ? .right : .left) }
                ) { panelStack }
            } else {
                panelStack
            }
        }
        .background(WTChrome353.surface)
        .animation(.easeOut(duration: runtime.visualCalibration.panelTransitionDuration), value: runtime.state.panel)
    }

    private var panelStack: some View {
        VStack(spacing: 0) {
            if shouldShowCandidateBar { WTCandidateBar(runtime: runtime) }
            if runtime.toolbarEnabled && runtime.state.panel == .keyboard && runtime.composition.isEmpty { WTFunctionToolbarView(runtime: runtime) }
            panelBody
        }
    }

    @ViewBuilder private var panelBody: some View {
        switch runtime.state.panel {
        case .keyboard:
            VStack(spacing: 0) {
                if runtime.state.inputMode == .stroke { WTStrokeFilterView(runtime: runtime) }
                WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
            }
        case .number:
            WTKeyboardCanvasView(layout: numberLayout, runtime: runtime)
        case .symbols:
            WTKeyboardCanvasView(layout: symbolLayout, runtime: runtime)
        case .emoji:
            WTEmojiPanelView(runtime: runtime)
        case .clipboard:
            WTClipboardPanelView(runtime: runtime)
        case .phrases:
            WTPhrasesPanelView(runtime: runtime)
        case .handwriting:
            WTHandwritingCanvasView(runtime: runtime)
        case .voice:
            WTVoicePanelView(runtime: runtime)
        case .translate:
            WTTranslatePanelView(runtime: runtime)
        case .correction:
            WTCorrectionPanelView(runtime: runtime)
        case .askAI:
            WTAIPanelView(runtime: runtime)
        case .controlCenter:
            WTControlCenterView(runtime: runtime)
        case .inputModeSwitcher:
            WTInputModeSwitcherView(runtime: runtime)
        case .quickSettings:
            WTQuickSettingsView(runtime: runtime)
        case .fullSymbols:
            WTFullSymbolPanelView(runtime: runtime)
        case .deviceSync:
            WTDeviceSyncPanelView(runtime: runtime)
        case .quickSend:
            WTQuickSendPanelView(runtime: runtime)
        case .textPolish:
            WTTextPolishPanelView(runtime: runtime)
        case .picture:
            WTPicturePanelView(runtime: runtime)
        case .hotWords:
            WTHotWordPanelView(runtime: runtime)
        case .stickers:
            WTStickerGIFPanelView(runtime: runtime)
        case .wordSplitting:
            WTWordSplittingView(runtime: runtime)
        case .fontPicker:
            WTFontPickerView(runtime: runtime)
        case .keyboardAdjust:
            WTKeyboardAdjustView(runtime: runtime)
        case .guide:
            WTGuideAuthView(runtime: runtime)
        case .pasteboardImage:
            WTPasteboardImageDetailView(runtime: runtime)
        case .plus:
            WTPlusPanelView(runtime: runtime)
        case .toolbarArrange:
            WTToolbarArrangeView(runtime: runtime)
        case .bookVideo:
            WTBookVideoPanelView(runtime: runtime)
        }
    }

    private var isKeyboardSurface: Bool {
        switch runtime.state.panel {
        case .keyboard, .number, .symbols: return true
        default: return false
        }
    }

    private var shouldShowCandidateBar: Bool { isKeyboardSurface }

    private var keyboardLayout: WTKeyboardLayout {
        switch runtime.state.inputMode {
        case .chinesePinyin26: return WTLayouts353Resolved.t26Pinyin
        case .chinesePinyin9: return WTLayouts353Resolved.t9Pinyin
        case .english26: return WTLayouts353Resolved.t26En
        case .doublePinyin: return WTLayouts353Resolved.t26Pinyin
        case .wubi: return WTLayouts353Resolved.t26Wubi
        case .stroke: return WTLayouts353Resolved.t9Stroke
        case .handwriting: return WTLayouts353Resolved.t26InnerHw
        }
    }

    private var numberLayout: WTKeyboardLayout {
        switch runtime.state.inputMode {
        case .chinesePinyin9, .stroke: return WTLayouts353Resolved.t9Number
        default: return WTLayouts353Resolved.t9Number26
        }
    }

    private var symbolLayout: WTKeyboardLayout {
        switch runtime.state.inputMode {
        case .english26: return WTLayouts353Resolved.t26EnSymbol
        case .chinesePinyin9, .stroke: return WTLayouts353Resolved.fullSymbol2
        default: return WTLayouts353Resolved.t26CnSymbol
        }
    }
}
