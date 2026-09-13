import SwiftUI

public struct WTFullSymbolPanelView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            WTPanelHeader(title: "符号", onBack: { runtime.state.back() })

            HStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(WTSymbolCategory.allCases, id: \.self) { category in
                            Button {
                                runtime.symbolCategory = category
                            } label: {
                                Text(category.title)
                                    .font(.system(size: 12, weight: runtime.symbolCategory == category ? .semibold : .regular))
                                    .foregroundStyle(runtime.symbolCategory == category ? WTChrome353.accent : Color.primary)
                                    .frame(width: 58, height: 34)
                                    .background(runtime.symbolCategory == category ? WTChrome353.accent.opacity(0.10) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .frame(width: 66)
                .background(WTChrome353.panelBackground)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 6), spacing: 0) {
                        ForEach(Array(WTSymbolCatalog353.values(for: runtime.symbolCategory).enumerated()), id: \.offset) { _, value in
                            Button {
                                runtime.commitDirectText(value)
                            } label: {
                                Text(value)
                                    .font(.system(size: 19))
                                    .frame(maxWidth: .infinity, minHeight: 38)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(WTChrome353.surface)
    }
}
