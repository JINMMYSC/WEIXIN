#if canImport(ActivityKit) && canImport(WidgetKit) && canImport(SwiftUI)
import ActivityKit
import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 16.1, *)
struct WTVoiceLiveActivityWidget: Widget {
    private let brand = Color(red: 35/255, green: 200/255, blue: 145/255)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WTVoiceActivityAttributes.self) { context in
            WTVoiceActivityCompactView(attributes: context.attributes, state: context.state, brand: brand)
                .activityBackgroundTint(Color.black.opacity(0.82))
                .activitySystemActionForegroundColor(.white)
                .widgetURL(deepLink(context.attributes))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    WTSemanticGlyph(name: phaseGlyph(for: context.state))
                        .foregroundStyle(context.state.phase == "failed" ? .red : brand)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.startedAt, style: .timer)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(title(for: context.state)).font(.system(size: 13, weight: .semibold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.partialText.isEmpty ? subtitle(for: context.state) : context.state.partialText)
                            .font(.system(size: 12)).lineLimit(2)
                        if context.state.phase == "recording" {
                            HStack(spacing: 3) {
                                ForEach(0..<9, id: \.self) { index in
                                    Capsule()
                                        .fill(brand.opacity(index.isMultiple(of: 2) ? 0.95 : 0.55))
                                        .frame(width: 3, height: CGFloat(5 + (index % 4) * 3))
                                }
                            }
                            .frame(height: 16)
                        }
                    }
                }
            } compactLeading: {
                WTSemanticGlyph(name: phaseGlyph(for: context.state))
                    .foregroundStyle(context.state.phase == "failed" ? .red : brand)
            } compactTrailing: {
                Text(shortPhase(for: context.state)).font(.caption2)
            } minimal: {
                WTSemanticGlyph(name: phaseGlyph(for: context.state))
                    .foregroundStyle(context.state.phase == "failed" ? .red : brand)
            }
            .widgetURL(deepLink(context.attributes))
        }
    }

    private func deepLink(_ attributes: WTVoiceActivityAttributes) -> URL? {
        URL(string: "wtreplica://voice?request=\(attributes.requestID)")
    }

    private func phaseGlyph(for state: WTVoiceActivityAttributes.ContentState) -> String {
        switch state.phase {
        case "result", "ended": return "checkmark"
        case "failed": return "xmark"
        default: return "waveform"
        }
    }

    private func title(for state: WTVoiceActivityAttributes.ContentState) -> String {
        switch state.phase {
        case "preparing": return "正在准备"
        case "recording": return "正在听写"
        case "recognizing": return "正在识别"
        case "result": return "识别完成"
        case "failed": return "语音输入失败"
        case "ended": return "语音输入完成"
        default: return "语音输入"
        }
    }

    private func subtitle(for state: WTVoiceActivityAttributes.ContentState) -> String {
        switch state.phase {
        case "preparing": return "正在准备麦克风…"
        case "recognizing": return "正在整理识别结果…"
        case "result", "ended": return "返回键盘后自动上屏"
        case "failed": return "点按返回语音输入"
        default: return "返回键盘后自动上屏"
        }
    }

    private func shortPhase(for state: WTVoiceActivityAttributes.ContentState) -> String {
        switch state.phase {
        case "recording": return "听写"
        case "recognizing": return "识别"
        case "result", "ended": return "完成"
        case "failed": return "失败"
        default: return "语音"
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
private struct WTVoiceActivityCompactView: View {
    let attributes: WTVoiceActivityAttributes
    let state: WTVoiceActivityAttributes.ContentState
    let brand: Color

    var body: some View {
        HStack(spacing: 10) {
            WTSemanticGlyph(name: state.phase == "failed" ? "xmark" : (state.isFinal ? "checkmark" : "waveform"))
                .foregroundStyle(state.phase == "failed" ? .red : brand)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold))
                if !state.partialText.isEmpty {
                    Text(state.partialText).font(.caption).lineLimit(1).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !state.isFinal {
                Text(attributes.startedAt, style: .timer)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
    }

    private var title: String {
        switch state.phase {
        case "recording": return "正在听写"
        case "recognizing": return "正在识别"
        case "result", "ended": return "识别完成"
        case "failed": return "语音输入失败"
        default: return "语音输入"
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
@main
struct WTVoiceActivityWidgetBundle: WidgetBundle {
    var body: some Widget { WTVoiceLiveActivityWidget() }
}
#endif
