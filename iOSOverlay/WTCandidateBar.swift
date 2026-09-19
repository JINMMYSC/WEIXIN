import SwiftUI

public struct WTCandidateBar: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            if runtime.candidateExpanded { expandedGrid } else { compactRow }
            if runtime.candidateActionTarget != nil { candidateActionMenu }
        }
        // The measured 3.5.3 header shows the candidate list on the same 32 pt row as the
        // toolbar, 31 pt below the panel top; the pinyin string shares that row.
        .padding(.top, runtime.candidateExpanded ? 0 : CGFloat(WTTheme353.keyboardHeaderRowTop))
        .frame(minHeight: CGFloat(WTTheme353.keyboardHeaderHeight), alignment: .top)
        .background(WTThemeColor353.keyboardBackground)
    }

    private var compactRow: some View {
        HStack(spacing: 0) {
            if !runtime.composition.isEmpty {
                Text(runtime.composition)
                    .font(.system(size: WTTheme353.candidateFontSize * 0.8, weight: .regular))
                    .foregroundStyle(WTChrome353.primaryText.opacity(0.6))
                    .lineLimit(1)
                    .padding(.leading, CGFloat(WTMeasuredKeyboard353.candidateLeadingInset))
                    .padding(.trailing, 6)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(Array(runtime.candidates.enumerated()), id: \.offset) { index, word in
                        candidateButton(index: index, word: word)
                    }
                }
                .padding(.horizontal, 4)
            }
            if runtime.candidates.count > 2 {
                Button {
                    withAnimation(.easeOut(duration: runtime.visualCalibration.candidateExpandDuration)) {
                        runtime.candidateExpanded = true
                    }
                } label: {
                    WTBasicGlyphView(.chevronDown, tint: WTChrome353.primaryText.opacity(0.72), size: 13, lineWidth: 1.8)
                        .frame(width: 38, height: CGFloat(WTTheme353.keyboardHeaderRowHeight))
                }
                .buttonStyle(.plain)
                .background(WTThemeColor353.keyboardBackground)
            }
        }
        .frame(height: CGFloat(WTTheme353.keyboardHeaderRowHeight))
    }

    private var expandedGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button { runtime.changeCandidatePage(.previous) } label: {
                    WTBasicGlyphView(.chevronLeft, tint: runtime.candidatePageState.hasPrevious ? WTChrome353.secondary : WTChrome353.separator, size: 12, lineWidth: 1.8)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .disabled(!runtime.candidatePageState.hasPrevious)

                Text(runtime.candidatePageState.currentPage > 0 ? "候选词 · 第 \(runtime.candidatePageState.currentPage + 1) 页" : "候选词")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()

                Button { runtime.changeCandidatePage(.next) } label: {
                    WTBasicGlyphView(.chevronRight, tint: runtime.candidatePageState.hasNext ? WTChrome353.secondary : WTChrome353.separator, size: 12, lineWidth: 1.8)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .disabled(!runtime.candidatePageState.hasNext)

                Button {
                    withAnimation(.easeOut(duration: runtime.visualCalibration.candidateExpandDuration)) {
                        runtime.candidateExpanded = false
                    }
                } label: {
                    WTBasicGlyphView(.chevronUp, tint: WTChrome353.secondary, size: 13, lineWidth: 1.8)
                        .frame(width: 38, height: 34)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 34)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4), spacing: 4) {
                    ForEach(Array(runtime.candidates.enumerated()), id: \.offset) { index, word in
                        candidateButton(index: index, word: word)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(4)
            }
            .frame(maxHeight: 150)
        }
        .background(WTThemeColor353.keyboardBackground)
    }

    private func candidateButton(index: Int, word: String) -> some View {
        Button { runtime.chooseCandidate(index) } label: {
            Text(word)
                .font(.system(size: WTTheme353.candidateFontSize))
                .foregroundStyle(index == 0 ? WTChrome353.accent : WTChrome353.primaryText)
                .padding(.horizontal, 10)
                .frame(minHeight: min(CGFloat(runtime.visualCalibration.candidateHeight),
                                      CGFloat(WTTheme353.keyboardHeaderRowHeight)))
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(index == 0 ? WTChrome353.elevatedSurface : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.42).onEnded { _ in runtime.showCandidateActions(index: index) })
    }

    private var candidateActionMenu: some View {
        HStack(spacing: 0) {
            if let target = runtime.candidateActionTarget {
                Text(target.text)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                Spacer(minLength: 4)
                actionButton("置顶", system: "pin") { runtime.applyCandidatePin() }
                actionButton("删除", system: "trash", destructive: true) { runtime.applyCandidateDelete() }
                actionButton("取消", system: "xmark") { runtime.candidateActionTarget = nil }
            }
        }
        .frame(height: 40)
        .background(WTChrome353.panelBackground)
        .overlay(alignment: .top) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }

    private func actionButton(_ title: String, system: String, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                WTSemanticGlyph(name: system).font(.system(size: 11))
                Text(title).font(.system(size: 12))
            }
            .foregroundStyle(destructive ? WTThemeColor353.destructive : WTChrome353.primaryText)
            .padding(.horizontal, 8)
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }
}
