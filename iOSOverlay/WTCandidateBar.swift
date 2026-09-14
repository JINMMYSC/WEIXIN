import SwiftUI

public struct WTCandidateBar: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            // The extracted 3.5.3 stack reserves an 18pt preedit strip above the 40pt
            // candidate row.  Keep that strip even while idle so the 224pt key canvas below
            // never changes height when composition begins or ends.
            compositionRow
            if runtime.candidateExpanded { expandedGrid } else { compactRow }
            if runtime.candidateActionTarget != nil { candidateActionMenu }
        }
        .background(WTChrome353.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }

    private var compositionRow: some View {
        HStack(spacing: 6) {
            Text(runtime.composition.isEmpty ? " " : runtime.composition)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .accessibilityHidden(runtime.composition.isEmpty)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: WTTheme353.compositionHeight)
    }

    private var compactRow: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(runtime.candidates.enumerated()), id: \.offset) { index, word in
                        candidateButton(index: index, word: word)
                    }
                }
            }
            if runtime.candidates.count > 4 {
                Button { withAnimation(.easeOut(duration: runtime.visualCalibration.candidateExpandDuration)) { runtime.candidateExpanded = true } } label: {
                    WTBasicGlyphView(.chevronDown, tint: WTChrome353.secondary, size: 13, lineWidth: 1.8)
                        .frame(width: 38, height: runtime.visualCalibration.candidateHeight)
                }
                .buttonStyle(.plain)
                .background(WTChrome353.surface)
            }
        }
        .frame(height: runtime.visualCalibration.candidateHeight)
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

                Button { withAnimation(.easeOut(duration: runtime.visualCalibration.candidateExpandDuration)) { runtime.candidateExpanded = false } } label: {
                    WTBasicGlyphView(.chevronUp, tint: WTChrome353.secondary, size: 13, lineWidth: 1.8)
                        .frame(width: 38, height: 34)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 34)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 4), spacing: 0) {
                    ForEach(Array(runtime.candidates.enumerated()), id: \.offset) { index, word in
                        candidateButton(index: index, word: word)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxHeight: 150)
        }
    }

    private func candidateButton(index: Int, word: String) -> some View {
        Button { runtime.chooseCandidate(index) } label: {
            Text(word)
                .font(.system(size: WTTheme353.candidateFontSize))
                .foregroundStyle(.primary)
                .padding(.horizontal, 13)
                .frame(minHeight: runtime.visualCalibration.candidateHeight)
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
