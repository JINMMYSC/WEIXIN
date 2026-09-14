import SwiftUI

struct WTPhase2KeyboardRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        VStack(spacing: 0) {
            WTCandidateBar(runtime: runtime)
            WTKeyboardCanvasView(layout: WTLayouts353Resolved.t26Pinyin, runtime: runtime)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WTThemeColor353.keyboardBackground)
    }
}
