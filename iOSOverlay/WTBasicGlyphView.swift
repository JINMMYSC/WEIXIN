import SwiftUI

public enum WTBasicGlyph: Sendable {
    case chevronLeft, chevronRight, chevronUp, chevronDown
    case plus, minus, close, more, check, search
    case shift, delete
}

/// Small independently drawn chrome glyphs. These replace generic SF Symbol placeholders in
/// high-frequency keyboard chrome while keeping proprietary WeType PNG assets out of the project.
public struct WTBasicGlyphView: View {
    public var glyph: WTBasicGlyph
    public var tint: Color
    public var size: CGFloat
    public var lineWidth: CGFloat

    public init(_ glyph: WTBasicGlyph, tint: Color = WTChrome353.primaryText, size: CGFloat = 16, lineWidth: CGFloat = 1.7) {
        self.glyph = glyph
        self.tint = tint
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Canvas { context, canvas in
            let s = min(canvas.width, canvas.height)
            let origin = CGPoint(x: (canvas.width - s) / 2, y: (canvas.height - s) / 2)
            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: origin.x + x * s, y: origin.y + y * s) }
            var path = Path()
            switch glyph {
            case .chevronLeft:
                path.move(to: point(0.62, 0.22)); path.addLine(to: point(0.36, 0.50)); path.addLine(to: point(0.62, 0.78))
            case .chevronRight:
                path.move(to: point(0.38, 0.22)); path.addLine(to: point(0.64, 0.50)); path.addLine(to: point(0.38, 0.78))
            case .chevronUp:
                path.move(to: point(0.22, 0.62)); path.addLine(to: point(0.50, 0.36)); path.addLine(to: point(0.78, 0.62))
            case .chevronDown:
                path.move(to: point(0.22, 0.38)); path.addLine(to: point(0.50, 0.64)); path.addLine(to: point(0.78, 0.38))
            case .plus:
                path.move(to: point(0.50, 0.22)); path.addLine(to: point(0.50, 0.78))
                path.move(to: point(0.22, 0.50)); path.addLine(to: point(0.78, 0.50))
            case .minus:
                path.move(to: point(0.22, 0.50)); path.addLine(to: point(0.78, 0.50))
            case .close:
                path.move(to: point(0.27, 0.27)); path.addLine(to: point(0.73, 0.73))
                path.move(to: point(0.73, 0.27)); path.addLine(to: point(0.27, 0.73))
            case .more:
                for x in [CGFloat(0.27), 0.50, 0.73] {
                    path.addEllipse(in: CGRect(x: point(x, 0.50).x - s * 0.055, y: point(x, 0.50).y - s * 0.055, width: s * 0.11, height: s * 0.11))
                }
                context.fill(path, with: .color(tint)); return
            case .check:
                path.move(to: point(0.22, 0.52)); path.addLine(to: point(0.42, 0.70)); path.addLine(to: point(0.79, 0.30))
            case .search:
                path.addEllipse(in: CGRect(x: point(0.18, 0.18).x, y: point(0.18, 0.18).y, width: s * 0.48, height: s * 0.48))
                path.move(to: point(0.62, 0.62)); path.addLine(to: point(0.82, 0.82))
            case .shift:
                path.move(to: point(0.18, 0.52))
                path.addLine(to: point(0.50, 0.20))
                path.addLine(to: point(0.82, 0.52))
                path.addLine(to: point(0.64, 0.52))
                path.addLine(to: point(0.64, 0.80))
                path.addLine(to: point(0.36, 0.80))
                path.addLine(to: point(0.36, 0.52))
                path.closeSubpath()
            case .delete:
                path.move(to: point(0.18, 0.50))
                path.addLine(to: point(0.36, 0.28))
                path.addLine(to: point(0.82, 0.28))
                path.addQuadCurve(to: point(0.88, 0.34), control: point(0.88, 0.28))
                path.addLine(to: point(0.88, 0.66))
                path.addQuadCurve(to: point(0.82, 0.72), control: point(0.88, 0.72))
                path.addLine(to: point(0.36, 0.72))
                path.closeSubpath()
                path.move(to: point(0.52, 0.40)); path.addLine(to: point(0.72, 0.60))
                path.move(to: point(0.72, 0.40)); path.addLine(to: point(0.52, 0.60))
            }
            context.stroke(path, with: .color(tint), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
