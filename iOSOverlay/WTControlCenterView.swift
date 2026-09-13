import SwiftUI

public struct WTControlCenterView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "更多功能", onBack: { runtime.state.back() }, trailingSystemName: "slider.horizontal.3") {
                runtime.state.present(.toolbarArrange)
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(WTToolbarCatalog353.expanded) { tool in
                        Button {
                            runtime.presentTool(tool)
                        } label: {
                            VStack(spacing: 5) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(WTChrome353.surface)
                                        .frame(width: 48, height: 48)
                                    WTToolIconView(tool: tool, controlCenter: true, tint: tool == .askAI ? WTChrome353.accent : WTChrome353.primaryText)
                                }
                                Text(tool.title)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 72)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .background(WTChrome353.panelBackground)
    }
}
