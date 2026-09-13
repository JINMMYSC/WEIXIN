#if canImport(UIKit) && canImport(Vision)
import UIKit
import Vision
import Foundation

/// Local handwriting fallback built from the clean-room stroke stream. The strokes are
/// rasterized to a temporary monochrome image and passed through Vision text recognition.
/// A dedicated CJK handwriting model can replace this provider without changing UI code.
public final class WTVisionHandwritingRecognizer: WTHandwritingRecognizer {
    public init() {}

    public func recognize(strokes: [WTHandwritingStroke]) async throws -> [WTCandidate] {
        guard let image = render(strokes: strokes)?.cgImage else { return [] }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error { continuation.resume(throwing: error); return }
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                var seen = Set<String>()
                let values = observations.flatMap { $0.topCandidates(8) }
                    .map(\.string)
                    .filter { !$0.isEmpty && seen.insert($0).inserted }
                    .prefix(20)
                    .enumerated()
                    .map { offset, text in WTCandidate(text: text, comment: nil, sourceIndex: offset) }
                continuation.resume(returning: Array(values))
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
            request.usesLanguageCorrection = true
            do { try VNImageRequestHandler(cgImage: image).perform([request]) }
            catch { continuation.resume(throwing: error) }
        }
    }

    private func render(strokes: [WTHandwritingStroke]) -> UIImage? {
        let all = strokes.flatMap(\.points)
        guard !all.isEmpty else { return nil }
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(18)
            context.setLineCap(.round); context.setLineJoin(.round)
            for stroke in strokes where !stroke.points.isEmpty {
                let pts = stroke.points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
                context.beginPath(); context.move(to: pts[0])
                for p in pts.dropFirst() { context.addLine(to: p) }
                context.strokePath()
            }
        }
    }
}
#endif
