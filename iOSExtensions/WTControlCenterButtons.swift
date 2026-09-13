import SwiftUI

public struct WTControlCenterButtons: View {
    let onVoice: () -> Void
    let onWrite: () -> Void
    let onQuickSend: () -> Void

    public init(onVoice: @escaping () -> Void, onWrite: @escaping () -> Void, onQuickSend: @escaping () -> Void) {
        self.onVoice = onVoice; self.onWrite = onWrite; self.onQuickSend = onQuickSend
    }

    public var body: some View {
        HStack(spacing: 10) {
            control("语音", "waveform", onVoice)
            control("手写", "scribble", onWrite)
            control("快传", "paperplane", onQuickSend)
        }
    }

    private func control(_ title: String, _ icon: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                WTSemanticGlyph(name: icon).font(.system(size: 20))
                Text(title).font(.system(size: 10))
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
