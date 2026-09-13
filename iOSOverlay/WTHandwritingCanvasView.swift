import SwiftUI

public struct WTStrokePoint: Hashable { public var point: CGPoint; public var time: TimeInterval }

public struct WTHandwritingCanvasView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var strokes: [[WTStrokePoint]] = []
    @State private var current: [WTStrokePoint] = []
    @State private var recognitionTask: Task<Void, Never>?

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    public var body: some View {
        VStack(spacing: 0) {
            if !runtime.handwritingCandidates.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(runtime.handwritingCandidates.enumerated()), id: \.offset) { _, word in
                            Button(word) {
                                runtime.insertText(word)
                                clearInk()
                            }
                            .font(.system(size: 19))
                            .buttonStyle(.plain)
                            .padding(.horizontal, 10)
                            .frame(height: 34)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .frame(height: 36)
            }

            Canvas { context, _ in
                for stroke in strokes + (current.isEmpty ? [] : [current]) {
                    guard let first = stroke.first else { continue }
                    var path = Path()
                    path.move(to: first.point)
                    for p in stroke.dropFirst() { path.addLine(to: p.point) }
                    context.stroke(path, with: .color(.primary), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
            }
            .background(WTChrome353.surface)
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

            HStack(spacing: 4) {
                Button("符号") { runtime.state.present(.symbols) }
                Button("123") { runtime.state.present(.number) }
                Button("☺︎") { runtime.state.present(.emoji) }
                Button { runtime.advanceToNextInputMode() } label: { WTSemanticGlyph(name: "globe") }
                Spacer()
                Button("撤销") {
                    if !strokes.isEmpty { strokes.removeLast(); scheduleRecognition() }
                }
                Button("清除") { clearInk() }
                Button("ABC") { runtime.state.back() }
            }
            .buttonStyle(.borderless)
            .font(.system(size: 14))
            .padding(.horizontal, 8)
            .frame(height: 44)
        }
        .onDisappear { recognitionTask?.cancel() }
    }

    private func scheduleRecognition() {
        recognitionTask?.cancel()
        let snapshot = strokes
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
        strokes.removeAll(); current.removeAll(); runtime.handwritingCandidates.removeAll()
    }
}
