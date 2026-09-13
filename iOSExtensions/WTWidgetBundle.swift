#if canImport(WidgetKit) && canImport(SwiftUI)
import WidgetKit
import SwiftUI

private struct WTWidgetEntry: TimelineEntry { let date: Date }
private struct WTWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WTWidgetEntry { .init(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (WTWidgetEntry) -> Void) { completion(.init(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WTWidgetEntry>) -> Void) {
        completion(.init(entries: [.init(date: .now)], policy: .never))
    }
}

struct WTVoiceEntryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WTVoiceEntryWidget", provider: WTWidgetProvider()) { _ in
            WTWidgetRootView()
        }
        .configurationDisplayName("语音输入")
        .description("快速进入语音输入。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct WTWidgetRootView: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(.fill.tertiary, for: .widget)
        } else {
            content.padding(4).background(Color(uiColor: .secondarySystemBackground))
        }
    }
    private var content: some View {
        Link(destination: URL(string: "wtreplica://voice")!) {
            WTVoiceWidgetView(isRecording: false, action: {})
        }
    }
}

@main
struct WTReplicaWidgetBundle: WidgetBundle {
    var body: some Widget { WTVoiceEntryWidget() }
}
#endif
