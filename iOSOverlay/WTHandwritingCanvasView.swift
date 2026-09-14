import SwiftUI

public struct WTStrokePoint: Hashable { public var point: CGPoint; public var time: TimeInterval }

/// Phase 4 handwriting surface reconstructed from the shipped 3.5.3 handwriting control plane.
/// The original panel reserves a 40pt candidate strip, a handwriting field with an upper-right
/// delete key, and a 40pt bottom control row.  Artwork remains clean-room.
public struct WTHandwritingCanvasView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var strokes: [[WTStrokePoint]] = []
    @State private var current: [WTStrokePoint] = []
    @State private var recognitionTask: Task<Void, Never>?

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            candidateStrip
                .frame(height: 40)
                .background(WTChrome353.surface)
                .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }

            ZStack(alignment: .topTrailing) {
                inkCanvas
                handwritingStatus
                Button { deleteStrokeOrText() } label: {
                    WTSemanticGlyph(name: "delete.left")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 42, height: 40)
                }
                .buttonStyle(.plain)
                .background(WTThemeColor353.grayKey)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(.trailing, 3)
            }
            .frame(height: 124)
            .background(WTChrome353.surface)

            bottomControlRow
                .frame(height: 40)
                .background(WTThemeColor353.keyboardBackground)
        }
        .frame(height: 204)
        .background(WTChrome353.surface)
        .onDisappear { recognitionTask?.cancel() }
    }

    @ViewBuilder private var candidateStrip: some View {
        if runtime.handwritingCandidates.isEmpty {
            HStack(spacing: 8) {
                Text(strokes.isEmpty ? "手写输入" : "继续书写以识别")
                    .font(.system(size: 12)).foregroundStyle(WTChrome353.secondary)
                Spacer()
                Button("清除") { clearInk() }
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(WTChrome353.accent)
                    .disabled(strokes.isEmpty && current.isEmpty)
            }
            .padding(.horizontal, 10)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(runtime.handwritingCandidates.enumerated()), id: \.offset) { _, word in
                        Button(word) {
                            runtime.insertText(word)
                            clearInk()
                        }
                        .font(.system(size: 19))
                        .foregroundStyle(WTChrome353.primaryText)
                        .buttonStyle(.plain)
                        .padding(.horizontal, 13)
                        .frame(height: 40)
                    }
                }
                .padding(.horizontal, 3)
            }
        }
    }

    private var inkCanvas: some View {
        Canvas { context, _ in
            for stroke in strokes + (current.isEmpty ? [] : [current]) {
                guard let first = stroke.first else { continue }
                var path = Path()
                path.move(to: first.point)
                for p in stroke.dropFirst() { path.addLine(to: p.point) }
                context.stroke(path, with: .color(WTChrome353.primaryText), style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round))
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
            ProgressView().tint(WTChrome353.accent).padding(.top, 48).frame(maxWidth: .infinity)
        case .failed(let message), .fallback(let message), .offline(let message), .permissionDenied(let message):
            VStack(spacing: 5) {
                WTSemanticGlyph(name: "info.circle").font(.system(size: 18)).foregroundStyle(WTChrome353.secondary)
                Text(message).font(.system(size: 10)).foregroundStyle(WTChrome353.secondary).lineLimit(2).multilineTextAlignment(.center)
            }
            .padding(.horizontal, 54).padding(.top, 38).frame(maxWidth: .infinity)
            .allowsHitTesting(false)
        default:
            EmptyView()
        }
    }

    private var bottomControlRow: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 4
            let spaceWidth = min(CGFloat(92), proxy.size.width * 0.222)
            let returnWidth = min(CGFloat(84), proxy.size.width * 0.203)
            let smallWidth = max(CGFloat(28), (proxy.size.width - spaceWidth - returnWidth - gap * 7) / 6)
            HStack(spacing: gap) {
                bottomTextKey("符号", width: smallWidth) { runtime.state.present(.fullSymbols) }
                bottomTextKey("123", width: smallWidth) { runtime.state.present(.number) }
                bottomIconKey("face.smiling", width: smallWidth) { runtime.state.present(.emoji) }
                bottomIconKey("globe", width: smallWidth) { runtime.advanceToNextInputMode() }
                bottomTextKey("英", width: smallWidth) { runtime.chooseInputMode(.english26) }
                bottomTextKey("ABC", width: smallWidth) { runtime.chooseInputMode(runtime.state.lastChineseMode) }
                bottomTextKey("空格", width: spaceWidth) { runtime.submitSpace() }
                bottomTextKey(runtime.returnKeyPresentation.title, width: returnWidth, accent: runtime.returnKeyPresentation.usesAccent) { runtime.submitReturn() }
            }
            .padding(.horizontal, 2)
            .frame(maxHeight: .infinity)
        }
    }

    private func bottomTextKey(_ title: String, width: CGFloat, accent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: title.count > 3 ? 11 : 13, weight: .medium)).lineLimit(1).minimumScaleFactor(0.65)
                .frame(width: width, height: 36)
        }
        .buttonStyle(.plain)
        .foregroundStyle(accent ? Color.white : WTChrome353.primaryText)
        .background(accent ? WTChrome353.accent : WTThemeColor353.normalKey)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private func bottomIconKey(_ name: String, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            WTSemanticGlyph(name: name).font(.system(size: 17)).frame(width: width, height: 36)
        }
        .buttonStyle(.plain)
        .foregroundStyle(WTChrome353.primaryText)
        .background(WTThemeColor353.grayKey)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
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
