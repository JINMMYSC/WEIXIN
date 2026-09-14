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
        switch runtime.state.inputMode {
        case .chinesePinyin9:
            return WTLayouts353Resolved.t9Pinyin
        case .english26:
            return WTLayouts353Resolved.t26En
        default:
            return WTLayouts353Resolved.t26Pinyin
        }
    }
}
