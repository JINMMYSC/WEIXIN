import SwiftUI

public struct WTStrokeFilterView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    private let strokes = ["一", "丨", "丿", "丶", "乛"]
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        HStack(spacing: 6) {
            Text("筛选").font(.system(size: 10)).foregroundStyle(.secondary)
            ForEach(strokes, id: \.self) { stroke in
                Button { toggle(stroke) } label: {
                    Text(stroke).font(.system(size: 15, weight: .medium)).frame(width: 32, height: 28)
                        .background(runtime.strokeFilter.contains(stroke) ? WTChrome353.accent.opacity(0.16) : WTChrome353.panelBackground)
                        .foregroundStyle(runtime.strokeFilter.contains(stroke) ? WTChrome353.accent : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }.buttonStyle(.plain)
            }
            Button("清除") { runtime.strokeFilter.removeAll(); runtime.strokeFilterDidChange([]) }
                .font(.system(size: 10)).foregroundStyle(.secondary).frame(width: 36, height: 28)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8).frame(height: 36).background(WTChrome353.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }

    private func toggle(_ stroke: String) {
        if let i = runtime.strokeFilter.firstIndex(of: stroke) { runtime.strokeFilter.remove(at: i) }
        else { runtime.strokeFilter.append(stroke) }
        runtime.strokeFilterDidChange(runtime.strokeFilter)
    }
}
