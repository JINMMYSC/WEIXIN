import SwiftUI

/// Compatibility wrapper retained so the existing ClawBase controller and verifier keep a stable
/// root-view type while Phase 3 routes keyboard, emoji and input-mode surfaces through one shell.
/// The measured surface still owns `WTLayouts353Resolved.t9Pinyin` and `WTCandidateBar(runtime: runtime)`.
struct WTPhase2KeyboardRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        WTPhase3KeyboardSurface(runtime: runtime)
    }
}
