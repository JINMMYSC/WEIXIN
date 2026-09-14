import SwiftUI

/// Compatibility wrapper retained so the ClawBase controller keeps its stable root type.
/// Phase 3 now renders through the complete V14 panel router: the extracted keyboard geometry,
/// candidate bar, Emoji, language switcher, number/symbol surfaces and the already migrated
/// keyboard-control panels all share one observable runtime instead of silently falling back to
/// the keyboard when a function key changes `state.panel`.
struct WTPhase2KeyboardRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        WTPanelRootView(runtime: runtime)
    }
}
