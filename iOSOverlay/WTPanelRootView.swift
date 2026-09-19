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
        .background(WTThemeColor353.keyboardBackground)
        .animation(.easeOut(duration: runtime.visualCalibration.panelTransitionDuration), value: runtime.state.panel)
    }

    private var panelStack: some View {
        VStack(spacing: 0) {
            if isKeyboardSurface {
                if runtime.composition.isEmpty && runtime.candidates.isEmpty {
                    WTIdleInputBar353(runtime: runtime)
                } else {
                    WTCandidateBar(runtime: runtime)
                }
            }
            panelBody
        }
    }

    @ViewBuilder private var panelBody: some View {
        switch runtime.state.panel {
        case .keyboard:
            VStack(spacing: 0) {
                if runtime.state.inputMode == .stroke { WTStrokeFilterView(runtime: runtime) }
                WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
                    .frame(height: CGFloat(WTTheme353.keyboardCanvasHeight))
            }
        case .number:
            WTKeyboardCanvasView(layout: numberLayout, runtime: runtime)
                .frame(height: CGFloat(WTTheme353.keyboardCanvasHeight))
        case .symbols:
            WTKeyboardCanvasView(layout: symbolLayout, runtime: runtime)
                .frame(height: CGFloat(WTTheme353.keyboardCanvasHeight))
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

/// Idle 3.5.3 input chrome. The original keyboard does not reserve a blank white preedit row when
/// there is no composition; it shows the gray keyboard chrome with the product entry on the left.
/// The mark below is independently drawn text/vector chrome and does not bundle Tencent artwork.
private struct WTIdleInputBar353: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    private var buttonSize: CGFloat { CGFloat(WTMeasuredKeyboard353.toolButtonSize) }
    private var toolGap: CGFloat {
        CGFloat(WTMeasuredKeyboard353.toolSlotPitch - WTMeasuredKeyboard353.toolButtonSize)
    }
    private var trailingInset: CGFloat {
        CGFloat(WTMeasuredKeyboard353.viewportWidth - WTMeasuredKeyboard353.toolRowTrailingX)
    }
    /// The measured 3.5.3 toolbar keeps at most seven right-aligned slots.
    private var visibleTools: [WTKeyboardTool] { Array(runtime.toolbarOrder.suffix(7)) }

    var body: some View {
        HStack(spacing: 0) {
            Button { runtime.state.present(.controlCenter) } label: {
                ZStack {
                    Circle()
                        .fill(WTChrome353.elevatedSurface)
                        .frame(width: buttonSize, height: buttonSize)
                    Text("P")
                        .font(.system(size: 20, weight: .heavy, design: .rounded).italic())
                        .foregroundStyle(WTChrome353.accent)
                        .offset(x: -1, y: -1)
                }
                .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .padding(.leading, CGFloat(WTMeasuredKeyboard353.productButtonX))

            if runtime.toolbarEnabled {
                Spacer(minLength: 0)
                HStack(spacing: toolGap) {
                    ForEach(visibleTools) { tool in
                        Button { runtime.presentTool(tool) } label: {
                            WTToolIconView(
                                tool: tool,
                                tint: tool == .askAI ? WTChrome353.accent : WTChrome353.primaryText.opacity(0.82)
                            )
                            .frame(width: buttonSize, height: buttonSize)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.trailing, trailingInset)
            } else {
                Spacer(minLength: 0)
            }
        }
        .frame(height: CGFloat(WTTheme353.keyboardHeaderRowHeight))
        .padding(.top, CGFloat(WTTheme353.keyboardHeaderRowTop))
        .frame(height: CGFloat(WTTheme353.keyboardHeaderHeight), alignment: .top)
        .background(WTThemeColor353.keyboardBackground)
    }
}
