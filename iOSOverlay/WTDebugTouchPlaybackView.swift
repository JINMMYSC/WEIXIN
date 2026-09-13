#if DEBUG
import SwiftUI

/// Developer-only reconstruction for WBTPListView / WBTPPlayerView.
/// Reverse-engineering evidence shows TP means touch recording/playback tooling:
/// WBTPExporter, WBTPRecord, WBTouchRecorderDelegate, playTouchRecord and stopPlayTouchRecord.
/// It is deliberately not exposed in the shipping keyboard UI.
public struct WTDebugTouchPlaybackView: View {
    public struct Record: Identifiable, Hashable {
        public let id: UUID
        public var name: String
        public var eventCount: Int
        public init(id: UUID = UUID(), name: String, eventCount: Int) { self.id = id; self.name = name; self.eventCount = eventCount }
    }
    @State private var records: [Record] = []
    @State private var playing: UUID?
    public init() {}
    public var body: some View {
        NavigationView {
            List(records) { record in
                HStack {
                    VStack(alignment: .leading) { Text(record.name); Text("\(record.eventCount) touch events").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    Button(playing == record.id ? "停止" : "回放") { playing = playing == record.id ? nil : record.id }
                }
            }
            .overlay { if records.isEmpty { VStack(spacing: 8) { WTSemanticGlyph(name: "hand.tap").frame(width: 28, height: 28); Text("没有触控录制").foregroundStyle(.secondary) } } }
            .navigationTitle("Touch Playback")
        }
    }
}
#endif
