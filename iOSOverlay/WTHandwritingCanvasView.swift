import SwiftUI

public struct WTStrokePoint: Hashable { public var point: CGPoint; public var time: TimeInterval }

/// Screenshot-driven Phase 4 handwriting surface. The 3.5.3 reference keeps the 40pt candidate
/// strip, 124pt writing field and 40pt control row, then exposes the global globe/mic footer.
public struct WTHandwritingCanvasView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var strokes: [[WTStrokePoint]] = []
    @State private var current: [WTStrokePoint] = []
    @State private var recognitionTask: Task<Void, Never>?

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                candidateStrip
                    .frame(height: 40)
                    .background(WTChrome353.panelBackground)

                ZStack {
                    ghostKeyGrid
                    inkCanvas
                    handwritingStatus
                }
                .frame(height: 124)
                .background(WTChrome353.panelBackground)

                bottomControlRow
                    .frame(height: 40)
                    .background(WTThemeColor353.keyboardBackground)
            }
            .frame(height: 204)

            footer
                .frame(height: 46)

            Color.clear.frame(height: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WTChrome353.panelBackground)
        .onDisappear { recognitionTask?.cancel() }
    }

    @ViewBuilder private var candidateStrip: some View {
        if runtime.handwritingCandidates.isEmpty {
            HStack {
                Spacer()
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(runtime.handwritingCandidates.enumerated()), id: \.offset) { index, word in
                        Button {
                            runtime.insertText(word)
                            clearInk()
                        } label: {
                            Text(word)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(index == 0 ? WTChrome353.accent : WTChrome353.primaryText)
                                .padding(.horizontal, 11)
                                .frame(height: 40)
                                .background(index == 0 ? WTChrome353.elevatedSurface : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var ghostKeyGrid: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 5
            let margin: CGFloat = 5
            let leftWidth = max(CGFloat(54), proxy.size.width * 0.17)
            let rightX = margin + leftWidth + gap
            let rightWidth = proxy.size.width - rightX - margin
            let cellWidth = (rightWidth - gap * 3) / 4
            let cellHeight = (proxy.size.height - gap * 2) / 3

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(WTChrome353.elevatedSurface.opacity(0.72))
                    .frame(width: leftWidth, height: proxy.size.height)
                    .offset(x: margin)

                ForEach(0..<12, id: \.self) { index in
                    let row = index / 4
                    let col = index % 4
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(WTChrome353.elevatedSurface.opacity(0.72))
                        .frame(width: cellWidth, height: cellHeight)
                        .offset(
                            x: rightX + CGFloat(col) * (cellWidth + gap),
                            y: CGFloat(row) * (cellHeight + gap)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var inkCanvas: some View {
        Canvas { context, _ in
            for stroke in strokes + (current.isEmpty ? [] : [current]) {
                guard let first = stroke.first else { continue }
                var path = Path()
                path.move(to: first.point)
                for p in stroke.dropFirst() { path.addLine(to: p.point) }
                context.stroke(
                    path,
                    with: .color(WTChrome353.primaryText),
                    style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    current.append(.init(point: value.location, time: Date().timeIntervalSince1970))
                }
                .onEnded { _ in
                    if !current.isEmpty { strokes.append(current); current.removeAll() }
                    scheduleRecognition()
                }
        )
    }

    @ViewBuilder private var handwritingStatus: some View {
        let state = runtime.panelLoadState(.handwriting)
        switch state {
        case .loading:
            ProgressView().tint(WTChrome353.accent)
        case .failed(let message), .fallback(let message), .offline(let message), .permissionDenied(let message):
            Text(message)
                .font(.system(size: 10))
                .foregroundStyle(WTChrome353.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 70)
                .allowsHitTesting(false)
        default:
            if strokes.isEmpty && current.isEmpty {
                Text("字迹未消失也可以继续写")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WTChrome353.secondary)
                    .allowsHitTesting(false)
            }
        }
    }

    private var bottomControlRow: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 5
            let margin: CGFloat = 5
            let backWidth: CGFloat = 70
            let deleteWidth: CGFloat = 58
            let returnWidth: CGFloat = 70
            let fillerWidth = max(CGFloat(32), proxy.size.width - margin * 2 - gap * 4 - backWidth - deleteWidth - returnWidth)

            HStack(spacing: gap) {
                Button { runtime.state.back() } label: {
                    WTSemanticGlyph(name: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: backWidth, height: 36)
                        .background(WTChrome353.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { clearInk() } label: {
                    Color.clear.frame(width: 34, height: 36)
                        .background(WTThemeColor353.normalKey)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { runtime.submitSpace() } label: {
                    Color.clear.frame(width: fillerWidth, height: 36)
                        .background(WTThemeColor353.normalKey)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { deleteStrokeOrText() } label: {
                    WTSemanticGlyph(name: "delete.left")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: deleteWidth, height: 36)
                        .background(WTThemeColor353.grayKey)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { runtime.submitReturn() } label: {
                    Text(runtime.returnKeyPresentation.title)
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: returnWidth, height: 36)
                        .background(WTThemeColor353.grayKey)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, margin)
            .frame(maxHeight: .infinity)
        }
    }

    private var footer: some View {
        HStack {
            Button { runtime.advanceToNextInputMode() } label: {
                WTSemanticGlyph(name: "globe").font(.system(size: 22)).frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
            Spacer()
            Button { runtime.state.present(.voice) } label: {
                WTSemanticGlyph(name: "mic").font(.system(size: 22)).frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
    }

    private func deleteStrokeOrText() {
        recognitionTask?.cancel()
        if !current.isEmpty {
            current.removeAll()
            scheduleRecognition()
        } else if !strokes.isEmpty {
            strokes.removeLast()
            scheduleRecognition()
        } else {
            runtime.deleteBackward()
        }
    }

    private func scheduleRecognition() {
        recognitionTask?.cancel()
        let snapshot = strokes
        guard !snapshot.isEmpty else {
            runtime.handwritingCandidates.removeAll()
            runtime.setPanelLoadState(.idle, for: .handwriting)
            return
        }
        recognitionTask = Task {
            try? await Task.sleep(nanoseconds: 140_000_000)
            guard !Task.isCancelled else { return }
            let model = snapshot.map { stroke in
                WTHandwritingStroke(points: stroke.map { .init(x: Double($0.point.x), y: Double($0.point.y), t: $0.time) })
            }
            let result = await runtime.recognizeHandwriting(model)
            guard !Task.isCancelled else { return }
            await MainActor.run { runtime.handwritingCandidates = result }
        }
    }

    private func clearInk() {
        recognitionTask?.cancel()
        strokes.removeAll()
        current.removeAll()
        runtime.handwritingCandidates.removeAll()
        runtime.setPanelLoadState(.idle, for: .handwriting)
    }
}
