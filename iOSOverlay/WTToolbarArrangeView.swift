import SwiftUI

public struct WTToolbarArrangeView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private var available: [WTKeyboardTool] {
        WTToolbarCatalog353.expanded.filter { !runtime.toolbarOrder.contains($0) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "自定义工具栏", onBack: { runtime.state.back() }, trailingSystemName: "arrow.counterclockwise") {
                runtime.toolbarOrder = WTToolbarCatalog353.compact
            }
            ScrollView {
                VStack(spacing: 8) {
                    Text("已显示").font(.system(size: 11)).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(Array(runtime.toolbarOrder.enumerated()), id: \.element.id) { index, tool in
                        HStack(spacing: 8) {
                            WTToolIconView(tool: tool).frame(width: 20, height: 20).frame(width: 24)
                            Text(tool.title).font(.system(size: 13))
                            Spacer()
                            Button { move(index, -1) } label: { WTBasicGlyphView(.chevronUp, size: 14) }.disabled(index == 0)
                            Button { move(index, 1) } label: { WTBasicGlyphView(.chevronDown, size: 14) }.disabled(index == runtime.toolbarOrder.count - 1)
                            Button { runtime.toolbarOrder.removeAll { $0 == tool } } label: { WTBasicGlyphView(.minus, size: 14) }.disabled(runtime.toolbarOrder.count <= 1)
                        }
                        .buttonStyle(.plain).padding(.horizontal, 10).frame(height: 38)
                        .background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 9))
                    }

                    Text("更多功能").font(.system(size: 11)).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(available) { tool in
                            Button {
                                if runtime.toolbarOrder.count < 8 { runtime.toolbarOrder.append(tool) }
                            } label: {
                                HStack(spacing: 5) { WTToolIconView(tool: tool).frame(width: 17, height: 17); Text(tool.title).lineLimit(1) }
                                    .font(.system(size: 11)).frame(maxWidth: .infinity, minHeight: 34)
                                    .background(WTChrome353.surface).clipShape(RoundedRectangle(cornerRadius: 8))
                            }.buttonStyle(.plain)
                        }
                    }
                    Text("工具栏最多显示 8 个快捷入口。").font(.system(size: 10)).foregroundStyle(.secondary)
                }.padding(10)
            }
        }.background(WTChrome353.panelBackground)
    }

    private func move(_ index: Int, _ delta: Int) {
        let target = index + delta
        guard runtime.toolbarOrder.indices.contains(index), runtime.toolbarOrder.indices.contains(target) else { return }
        runtime.toolbarOrder.swapAt(index, target)
    }
}
