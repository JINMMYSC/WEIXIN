import SwiftUI

/// Phase 3 shell keeps the extracted 414x224 WeType keyboard canvas at its measured aspect,
/// and routes the now-live emoji and input-mode panels without importing the later Phase 4 panel root.
struct WTPhase3KeyboardSurface: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        Group {
            switch runtime.state.panel {
            case .emoji:
                WTEmojiPanelView(runtime: runtime)
            case .inputModeSwitcher:
                WTInputModeSwitcherView(runtime: runtime)
            default:
                keyboardSurface
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WTThemeColor353.keyboardBackground)
    }

    private var keyboardSurface: some View {
        VStack(spacing: 0) {
            WTCandidateBar(runtime: runtime)
            WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
                .frame(height: CGFloat(keyboardLayout.baseSize.height))
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var keyboardLayout: WTKeyboardLayout {
        switch runtime.state.panel {
        case .number:
            return WTLayouts353Resolved.t26Number
        case .symbols, .fullSymbols:
            return WTLayouts353Resolved.t26Symbol
        default:
            break
        }
        switch runtime.state.inputMode {
        case .chinesePinyin9:
            return WTLayouts353Resolved.t9Pinyin
        case .english26:
            return WTLayouts353Resolved.t26En
        case .wubi:
            return WTLayouts353Resolved.t26Wubi
        case .stroke:
            return WTLayouts353Resolved.t9Stroke
        case .chinesePinyin26, .doublePinyin, .handwriting:
            return WTLayouts353Resolved.t26Pinyin
        }
    }
}
