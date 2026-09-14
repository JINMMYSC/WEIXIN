import SwiftUI

struct WTPhase2KeyboardRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        VStack(spacing: 0) {
            WTCandidateBar(runtime: runtime)
            WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WTThemeColor353.keyboardBackground)
    }

    private var keyboardLayout: WTKeyboardLayout {
        // Phase 3 still uses the measured V14 key canvases. Previously the runtime changed
        // `state.panel`, but this root ignored it, so 123/symbol/back keys appeared to do nothing.
        switch runtime.state.panel {
        case .number:
            switch runtime.state.inputMode {
            case .chinesePinyin9, .stroke:
                return WTLayouts353Resolved.t9Number
            default:
                return WTLayouts353Resolved.t9Number26
            }
        case .symbols:
            return runtime.state.inputMode == .english26
                ? WTLayouts353Resolved.t26EnSymbol
                : WTLayouts353Resolved.t26CnSymbol
        case .fullSymbols:
            return WTLayouts353Resolved.fullSymbol2
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
