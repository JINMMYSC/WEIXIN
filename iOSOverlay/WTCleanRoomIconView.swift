import SwiftUI

/// Independently drawn vector glyphs for keyboard chrome. These paths do not embed or trace
/// Tencent image bytes; they use the measured 3.5.3 canvas/glyph bounds only for sizing.
public struct WTToolIconView: View {
    public let tool: WTKeyboardTool
    public var controlCenter: Bool
    public var tint: Color

    public init(tool: WTKeyboardTool, controlCenter: Bool = false, tint: Color = WTChrome353.primaryText) {
        self.tool = tool
        self.controlCenter = controlCenter
        self.tint = tint
    }

    public var body: some View {
        let measured = WTChrome353.measuredGlyphSize(tool, controlCenter: controlCenter)
        WTToolGlyphCanvas(tool: tool, tint: tint)
            .frame(width: max(12, measured.width), height: max(12, measured.height))
            .accessibilityHidden(true)
    }
}

private struct WTToolGlyphCanvas: View {
    let tool: WTKeyboardTool
    let tint: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let line = max(1.15, min(w, h) * 0.075)
            let inset = line * 0.75
            let rect = CGRect(x: inset, y: inset, width: max(0, w - inset * 2), height: max(0, h - inset * 2))
            let stroke = GraphicsContext.Shading.color(tint)

            func drawLine(_ a: CGPoint, _ b: CGPoint, width: CGFloat = line) {
                var p = Path(); p.move(to: a); p.addLine(to: b)
                context.stroke(p, with: stroke, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func strokePath(_ p: Path, width: CGFloat = line) {
                context.stroke(p, with: stroke, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func ellipse(_ r: CGRect, width: CGFloat = line) {
                context.stroke(Path(ellipseIn: r), with: stroke, style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
            func rounded(_ r: CGRect, radius: CGFloat, width: CGFloat = line) {
                context.stroke(Path(roundedRect: r, cornerRadius: radius), with: stroke, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            func spark(_ center: CGPoint, radius: CGFloat) {
                drawLine(CGPoint(x: center.x, y: center.y - radius), CGPoint(x: center.x, y: center.y + radius), width: line * 0.9)
                drawLine(CGPoint(x: center.x - radius, y: center.y), CGPoint(x: center.x + radius, y: center.y), width: line * 0.9)
            }

            switch tool {
            case .emoji:
                ellipse(rect.insetBy(dx: line * 0.4, dy: line * 0.4))
                let ey = rect.minY + rect.height * 0.38
                ellipse(CGRect(x: rect.minX + rect.width * 0.27, y: ey, width: line * 1.15, height: line * 1.15), width: line * 0.8)
                ellipse(CGRect(x: rect.minX + rect.width * 0.66, y: ey, width: line * 1.15, height: line * 1.15), width: line * 0.8)
                var smile = Path()
                smile.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.60))
                smile.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.minY + rect.height * 0.60), control: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.12))
                strokePath(smile)

            case .clipboard:
                rounded(CGRect(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.12, width: rect.width * 0.76, height: rect.height * 0.80), radius: line * 1.4)
                rounded(CGRect(x: rect.minX + rect.width * 0.30, y: rect.minY, width: rect.width * 0.40, height: rect.height * 0.24), radius: line)

            case .phrases:
                rounded(rect, radius: line * 1.4)
                for f in [0.32, 0.50, 0.68] as [CGFloat] {
                    drawLine(CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * f), CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * f), width: line * 0.82)
                }

            case .handwriting:
                var p = Path()
                p.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.72))
                p.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.60, y: rect.minY + rect.height * 0.66), control1: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.25), control2: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY))
                p.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.minY + rect.height * 0.50), control1: CGPoint(x: rect.minX + rect.width * 0.72, y: rect.minY + rect.height * 0.45), control2: CGPoint(x: rect.minX + rect.width * 0.82, y: rect.minY + rect.height * 0.83))
                strokePath(p)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.14), CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.minY + rect.height * 0.56), width: line * 1.15)

            case .voice:
                rounded(CGRect(x: rect.minX + rect.width * 0.34, y: rect.minY, width: rect.width * 0.32, height: rect.height * 0.58), radius: rect.width * 0.18)
                var arc = Path()
                arc.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.43))
                arc.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.43), control: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.90))
                strokePath(arc)
                drawLine(CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.70), CGPoint(x: rect.midX, y: rect.maxY))
                drawLine(CGPoint(x: rect.minX + rect.width * 0.34, y: rect.maxY), CGPoint(x: rect.maxX - rect.width * 0.34, y: rect.maxY))

            case .translate:
                rounded(rect, radius: line * 1.2)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.31), CGPoint(x: rect.minX + rect.width * 0.52, y: rect.minY + rect.height * 0.31), width: line * 0.8)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.18), CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.57), width: line * 0.8)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.49), CGPoint(x: rect.minX + rect.width * 0.48, y: rect.minY + rect.height * 0.49), width: line * 0.8)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.72), CGPoint(x: rect.minX + rect.width * 0.74, y: rect.minY + rect.height * 0.42), width: line * 0.9)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.74, y: rect.minY + rect.height * 0.42), CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.72), width: line * 0.9)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.64, y: rect.minY + rect.height * 0.61), CGPoint(x: rect.maxX - rect.width * 0.14, y: rect.minY + rect.height * 0.61), width: line * 0.8)

            case .askAI:
                spark(CGPoint(x: rect.midX, y: rect.midY), radius: min(rect.width, rect.height) * 0.28)
                spark(CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.24), radius: min(rect.width, rect.height) * 0.10)
                spark(CGPoint(x: rect.maxX - rect.width * 0.14, y: rect.maxY - rect.height * 0.18), radius: min(rect.width, rect.height) * 0.08)

            case .correction:
                ellipse(rect)
                var p = Path()
                p.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.44, y: rect.maxY - rect.height * 0.25))
                p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.25))
                strokePath(p, width: line * 1.15)

            case .inputMode:
                rounded(rect, radius: line * 1.1)
                let cols = 4
                let rows = 3
                for y in 0..<rows {
                    for x in 0..<cols {
                        let cx = rect.minX + rect.width * (CGFloat(x) + 0.5) / CGFloat(cols)
                        let cy = rect.minY + rect.height * (CGFloat(y) + 0.5) / CGFloat(rows)
                        ellipse(CGRect(x: cx - line * 0.35, y: cy - line * 0.35, width: line * 0.7, height: line * 0.7), width: line * 0.55)
                    }
                }

            case .oneHanded:
                rounded(CGRect(x: rect.minX + rect.width * 0.24, y: rect.minY, width: rect.width * 0.54, height: rect.height), radius: line * 1.2)
                drawLine(CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.minX + rect.width * 0.28, y: rect.midY))
                drawLine(CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY - rect.height * 0.12), CGPoint(x: rect.minX, y: rect.midY))
                drawLine(CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY + rect.height * 0.12), CGPoint(x: rect.minX, y: rect.midY))

            case .deviceSync:
                rounded(CGRect(x: rect.minX, y: rect.minY + rect.height * 0.12, width: rect.width * 0.62, height: rect.height * 0.58), radius: line)
                drawLine(CGPoint(x: rect.minX - rect.width * 0.04, y: rect.minY + rect.height * 0.80), CGPoint(x: rect.minX + rect.width * 0.66, y: rect.minY + rect.height * 0.80))
                rounded(CGRect(x: rect.maxX - rect.width * 0.32, y: rect.minY + rect.height * 0.32, width: rect.width * 0.30, height: rect.height * 0.62), radius: line)

            case .quickSend:
                var p = Path()
                p.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.42))
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.63, y: rect.maxY))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.43, y: rect.minY + rect.height * 0.60))
                p.closeSubpath()
                strokePath(p)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.43, y: rect.minY + rect.height * 0.60), CGPoint(x: rect.maxX, y: rect.minY))

            case .textPolish:
                drawLine(CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY - rect.height * 0.10), CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.minY + rect.height * 0.12), width: line * 1.15)
                spark(CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.minY + rect.height * 0.14), radius: min(rect.width, rect.height) * 0.12)
                spark(CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.28), radius: min(rect.width, rect.height) * 0.08)

            case .picture:
                rounded(rect, radius: line * 1.2)
                ellipse(CGRect(x: rect.maxX - rect.width * 0.30, y: rect.minY + rect.height * 0.16, width: rect.width * 0.14, height: rect.width * 0.14), width: line * 0.75)
                var p = Path()
                p.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY - rect.height * 0.10))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.48))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.70))
                p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.72, y: rect.minY + rect.height * 0.55))
                p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.maxY - rect.height * 0.10))
                strokePath(p)

            case .fullSymbols:
                for x in [0.37, 0.63] as [CGFloat] {
                    drawLine(CGPoint(x: rect.minX + rect.width * x, y: rect.minY), CGPoint(x: rect.minX + rect.width * (x - 0.08), y: rect.maxY))
                }
                for y in [0.38, 0.64] as [CGFloat] {
                    drawLine(CGPoint(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * y), CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.minY + rect.height * (y - 0.05)))
                }

            case .quickSettings:
                for y in [0.24, 0.50, 0.76] as [CGFloat] {
                    drawLine(CGPoint(x: rect.minX, y: rect.minY + rect.height * y), CGPoint(x: rect.maxX, y: rect.minY + rect.height * y), width: line * 0.85)
                }
                ellipse(CGRect(x: rect.minX + rect.width * 0.24, y: rect.minY + rect.height * 0.18, width: line * 1.5, height: line * 1.5), width: line * 0.8)
                ellipse(CGRect(x: rect.minX + rect.width * 0.66, y: rect.minY + rect.height * 0.44, width: line * 1.5, height: line * 1.5), width: line * 0.8)
                ellipse(CGRect(x: rect.minX + rect.width * 0.42, y: rect.minY + rect.height * 0.70, width: line * 1.5, height: line * 1.5), width: line * 0.8)

            case .hotWords:
                var p = Path()
                p.move(to: CGPoint(x: rect.midX, y: rect.minY))
                p.addCurve(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.maxY - rect.height * 0.18), control1: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.30), control2: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.72))
                p.addQuadCurve(to: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.maxY - rect.height * 0.18), control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.06))
                p.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.62), control2: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.40))
                strokePath(p)

            case .stickers:
                rounded(rect, radius: rect.width * 0.22)
                ellipse(CGRect(x: rect.minX + rect.width * 0.24, y: rect.minY + rect.height * 0.28, width: line, height: line), width: line * 0.75)
                ellipse(CGRect(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.28, width: line, height: line), width: line * 0.75)
                var smile = Path(); smile.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.62)); smile.addQuadCurve(to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.minY + rect.height * 0.62), control: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.12)); strokePath(smile)

            case .wordSplitting:
                for i in 0..<3 {
                    let cw = rect.width / 3.5
                    let x = rect.minX + CGFloat(i) * (cw + rect.width * 0.075)
                    rounded(CGRect(x: x, y: rect.minY + rect.height * 0.22, width: cw, height: rect.height * 0.56), radius: line * 0.7, width: line * 0.8)
                }

            case .fontPicker:
                drawLine(CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY), width: line * 1.1)
                drawLine(CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.maxX - rect.width * 0.14, y: rect.maxY), width: line * 1.1)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.29, y: rect.minY + rect.height * 0.62), CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.minY + rect.height * 0.62), width: line * 0.9)

            case .keyboardAdjust:
                rounded(CGRect(x: rect.minX + rect.width * 0.16, y: rect.minY + rect.height * 0.18, width: rect.width * 0.68, height: rect.height * 0.64), radius: line)
                drawLine(CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX + rect.width * 0.24, y: rect.minY))
                drawLine(CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.24))
                drawLine(CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.maxX - rect.width * 0.24, y: rect.maxY))
                drawLine(CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.24))

            case .plus:
                ellipse(rect)
                drawLine(CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.25), CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.25), width: line * 1.1)
                drawLine(CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY), CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.midY), width: line * 1.1)
            }
        }
    }
}
