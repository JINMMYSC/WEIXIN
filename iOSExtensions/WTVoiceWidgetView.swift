import SwiftUI

/// Shared visual surface for the voice-input widget/control-center target.
public struct WTVoiceWidgetView: View {
    let isRecording: Bool
    let action: () -> Void
    public init(isRecording: Bool, action: @escaping () -> Void) {
        self.isRecording = isRecording; self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color.red.opacity(0.14) : Color(red: 35/255, green: 200/255, blue: 145/255).opacity(0.14))
                    WTSemanticGlyph(name: isRecording ? "stop.fill" : "waveform")
                        .foregroundStyle(isRecording ? .red : Color(red: 35/255, green: 200/255, blue: 145/255))
                }
                .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isRecording ? "结束语音输入" : "语音输入")
                        .font(.system(size: 14, weight: .semibold))
                    Text(isRecording ? "正在听写" : "快速开始")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
        }
        .buttonStyle(.plain)
    }
}
