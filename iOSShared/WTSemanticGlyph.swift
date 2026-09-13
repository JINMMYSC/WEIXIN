import SwiftUI

/// Clean-room semantic glyph used in places that previously relied on SF Symbols.
/// It intentionally draws simple geometric icons so release UI does not depend on Apple symbol artwork
/// and can later be tuned against measured WeType 3.5.3 geometry.
public struct WTSemanticGlyph: View {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public var body: some View {
        ZStack {
            if WTGlyphShape.shouldFill(name) {
                WTGlyphShape(name: name, overlayOnly: false)
                    .fill(style: FillStyle(eoFill: false, antialiased: true))
            } else {
                WTGlyphShape(name: name, overlayOnly: false)
                    .stroke(style: StrokeStyle(lineWidth: 1.65, lineCap: .round, lineJoin: .round))
            }
            if WTGlyphShape.hasOverlay(name) {
                WTGlyphShape(name: name, overlayOnly: true)
                    .stroke(style: StrokeStyle(lineWidth: 1.65, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}

private struct WTGlyphShape: Shape {
    let name: String
    let overlayOnly: Bool

    static func shouldFill(_ name: String) -> Bool {
        name.hasSuffix(".fill") || name == "star.fill" || name == "stop.fill" || name == "keyboard.fill"
    }

    static func hasOverlay(_ name: String) -> Bool {
        name.contains("checkmark") || name.contains("badge.magnifyingglass") || name.contains("arrow") ||
        name.contains("clipboard") || name.contains("pencil") || name.contains("exclamationmark") ||
        name.contains("radiowaves") || name.contains("shield") || name.contains("seal") ||
        name.contains("paperplane") || name.contains("laptopcomputer") || name.contains("delete") ||
        name.contains("waveform") || name.contains("keyboard") || name.contains("globe") ||
        name.contains("face") || name.contains("hand") || name.contains("photo") ||
        name.contains("textformat") || name.contains("wand") || name.contains("spark") ||
        name.contains("plus") || name.contains("ellipsis") || name.contains("chevron") ||
        name.contains("star") || name.contains("network") || name.contains("wifi") ||
        name.contains("book") || name.contains("music") || name.contains("film") ||
        name.contains("car") || name.contains("fork") || name.contains("lightbulb") ||
        name.contains("heart") || name.contains("pawprint") || name.contains("pin")
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: max(0.8, rect.width * 0.08), dy: max(0.8, rect.height * 0.08))
        var p = Path()
        let n = name.lowercased()

        func line(_ a: CGPoint, _ b: CGPoint) { p.move(to: a); p.addLine(to: b) }
        func ellipse(_ rr: CGRect) { p.addEllipse(in: rr) }
        func rounded(_ rr: CGRect, _ radius: CGFloat) { p.addRoundedRect(in: rr, cornerSize: .init(width: radius, height: radius)) }

        if overlayOnly {
            // Overlays / inner marks.
            if n.contains("checkmark") {
                line(.init(x: r.minX + r.width * 0.22, y: r.midY), .init(x: r.minX + r.width * 0.43, y: r.maxY - r.height * 0.25))
                line(.init(x: r.minX + r.width * 0.43, y: r.maxY - r.height * 0.25), .init(x: r.maxX - r.width * 0.18, y: r.minY + r.height * 0.24))
            } else if n.contains("magnifyingglass") {
                ellipse(.init(x: r.minX + r.width * 0.38, y: r.minY + r.height * 0.38, width: r.width * 0.38, height: r.height * 0.38))
                line(.init(x: r.minX + r.width * 0.68, y: r.minY + r.height * 0.68), .init(x: r.maxX, y: r.maxY))
            } else if n.contains("arrow.left.arrow.right") {
                line(.init(x: r.minX, y: r.minY + r.height * 0.35), .init(x: r.maxX, y: r.minY + r.height * 0.35))
                line(.init(x: r.minX, y: r.minY + r.height * 0.35), .init(x: r.minX + r.width * 0.18, y: r.minY + r.height * 0.18))
                line(.init(x: r.minX, y: r.minY + r.height * 0.35), .init(x: r.minX + r.width * 0.18, y: r.minY + r.height * 0.52))
                line(.init(x: r.maxX, y: r.minY + r.height * 0.68), .init(x: r.minX, y: r.minY + r.height * 0.68))
                line(.init(x: r.maxX, y: r.minY + r.height * 0.68), .init(x: r.maxX - r.width * 0.18, y: r.minY + r.height * 0.51))
                line(.init(x: r.maxX, y: r.minY + r.height * 0.68), .init(x: r.maxX - r.width * 0.18, y: r.minY + r.height * 0.85))
            } else if n.contains("arrow.clockwise") || n.contains("arrow.counterclockwise") || n.contains("circlepath") {
                p.addArc(center: .init(x: r.midX, y: r.midY), radius: r.width * 0.36, startAngle: .degrees(-40), endAngle: .degrees(250), clockwise: false)
                line(.init(x: r.minX + r.width * 0.12, y: r.minY + r.height * 0.34), .init(x: r.minX + r.width * 0.12, y: r.minY + r.height * 0.08))
                line(.init(x: r.minX + r.width * 0.12, y: r.minY + r.height * 0.08), .init(x: r.minX + r.width * 0.36, y: r.minY + r.height * 0.13))
            } else if n.contains("arrow") || n.contains("chevron") {
                if n.contains("right") {
                    line(.init(x: r.minX + r.width * 0.32, y: r.minY + r.height * 0.18), .init(x: r.maxX - r.width * 0.24, y: r.midY))
                    line(.init(x: r.maxX - r.width * 0.24, y: r.midY), .init(x: r.minX + r.width * 0.32, y: r.maxY - r.height * 0.18))
                } else if n.contains("left") {
                    line(.init(x: r.maxX - r.width * 0.26, y: r.minY + r.height * 0.18), .init(x: r.minX + r.width * 0.26, y: r.midY))
                    line(.init(x: r.minX + r.width * 0.26, y: r.midY), .init(x: r.maxX - r.width * 0.26, y: r.maxY - r.height * 0.18))
                } else {
                    line(.init(x: r.midX, y: r.maxY), .init(x: r.midX, y: r.minY))
                    line(.init(x: r.midX, y: r.minY), .init(x: r.minX + r.width * 0.3, y: r.minY + r.height * 0.24))
                    line(.init(x: r.midX, y: r.minY), .init(x: r.maxX - r.width * 0.3, y: r.minY + r.height * 0.24))
                }
            } else if n.contains("ellipsis") {
                for x in [0.24, 0.50, 0.76] as [CGFloat] { ellipse(.init(x: r.minX + r.width * x - 1, y: r.midY - 1, width: 2, height: 2)) }
            } else if n.contains("delete") {
                rounded(.init(x: r.minX + r.width * 0.18, y: r.minY + r.height * 0.18, width: r.width * 0.72, height: r.height * 0.64), r.width * 0.08)
                line(.init(x: r.minX + r.width * 0.48, y: r.minY + r.height * 0.37), .init(x: r.minX + r.width * 0.68, y: r.minY + r.height * 0.63))
                line(.init(x: r.minX + r.width * 0.68, y: r.minY + r.height * 0.37), .init(x: r.minX + r.width * 0.48, y: r.minY + r.height * 0.63))
            } else if n.contains("waveform") || n.contains("mic") {
                let xs: [CGFloat] = [0.14,0.30,0.46,0.62,0.78,0.92]
                let hs: [CGFloat] = [0.22,0.55,0.82,0.62,0.38,0.20]
                for (x,h) in zip(xs, hs) { line(.init(x:r.minX+r.width*x,y:r.midY-r.height*h*0.34), .init(x:r.minX+r.width*x,y:r.midY+r.height*h*0.34)) }
            } else if n.contains("globe") {
                ellipse(r)
                ellipse(.init(x: r.minX + r.width * 0.28, y: r.minY, width: r.width * 0.44, height: r.height))
                line(.init(x:r.minX,y:r.midY), .init(x:r.maxX,y:r.midY))
            } else if n.contains("keyboard") {
                for row in 0..<3 { for col in 0..<5 {
                    let x = r.minX + r.width * (CGFloat(col)+0.5)/5
                    let y = r.minY + r.height * (CGFloat(row)+0.5)/3
                    rounded(.init(x:x-r.width*0.055,y:y-r.height*0.055,width:r.width*0.11,height:r.height*0.11), r.width*0.02)
                }}
            } else if n.contains("face") {
                ellipse(r)
                ellipse(.init(x:r.minX+r.width*0.28,y:r.minY+r.height*0.34,width:1.5,height:1.5))
                ellipse(.init(x:r.minX+r.width*0.68,y:r.minY+r.height*0.34,width:1.5,height:1.5))
                p.addArc(center:.init(x:r.midX,y:r.minY+r.height*0.53), radius:r.width*0.22, startAngle:.degrees(20), endAngle:.degrees(160), clockwise:false)
            } else if n.contains("hand") {
                rounded(.init(x:r.minX+r.width*0.28,y:r.minY+r.height*0.32,width:r.width*0.48,height:r.height*0.52), r.width*0.12)
                for x in [0.30,0.43,0.56,0.69] as [CGFloat] { line(.init(x:r.minX+r.width*x,y:r.minY+r.height*0.34), .init(x:r.minX+r.width*x,y:r.minY+r.height*0.06)) }
            } else if n.contains("photo") {
                rounded(r, r.width*0.08)
                ellipse(.init(x:r.minX+r.width*0.62,y:r.minY+r.height*0.18,width:r.width*0.13,height:r.height*0.13))
                p.move(to:.init(x:r.minX+r.width*0.08,y:r.maxY-r.height*0.16)); p.addLine(to:.init(x:r.minX+r.width*0.38,y:r.minY+r.height*0.53)); p.addLine(to:.init(x:r.minX+r.width*0.55,y:r.minY+r.height*0.70)); p.addLine(to:.init(x:r.minX+r.width*0.72,y:r.minY+r.height*0.48)); p.addLine(to:.init(x:r.maxX-r.width*0.06,y:r.maxY-r.height*0.12))
            } else if n.contains("textformat") || n.contains("character") {
                line(.init(x:r.minX+r.width*0.18,y:r.minY+r.height*0.15), .init(x:r.maxX-r.width*0.18,y:r.minY+r.height*0.15))
                line(.init(x:r.midX,y:r.minY+r.height*0.15), .init(x:r.midX,y:r.maxY-r.height*0.10))
                line(.init(x:r.minX+r.width*0.30,y:r.maxY-r.height*0.10), .init(x:r.maxX-r.width*0.30,y:r.maxY-r.height*0.10))
            } else if n.contains("wand") || n.contains("spark") {
                line(.init(x:r.minX+r.width*0.20,y:r.maxY-r.height*0.15), .init(x:r.maxX-r.width*0.18,y:r.minY+r.height*0.20))
                for c in [CGPoint(x:r.minX+r.width*0.22,y:r.minY+r.height*0.25), CGPoint(x:r.maxX-r.width*0.16,y:r.minY+r.height*0.58)] {
                    line(.init(x:c.x,y:c.y-r.height*0.09), .init(x:c.x,y:c.y+r.height*0.09)); line(.init(x:c.x-r.width*0.09,y:c.y), .init(x:c.x+r.width*0.09,y:c.y))
                }
            } else if n.contains("plus") {
                line(.init(x:r.midX,y:r.minY+r.height*0.18), .init(x:r.midX,y:r.maxY-r.height*0.18))
                line(.init(x:r.minX+r.width*0.18,y:r.midY), .init(x:r.maxX-r.width*0.18,y:r.midY))
            } else if n.contains("paperplane") {
                p.move(to:r.origin); p.addLine(to:.init(x:r.maxX,y:r.minY)); p.addLine(to:.init(x:r.minX+r.width*0.62,y:r.maxY)); p.closeSubpath()
                line(.init(x:r.minX+r.width*0.18,y:r.minY+r.height*0.23), .init(x:r.maxX-r.width*0.16,y:r.minY+r.height*0.13))
            } else if n.contains("shield") || n.contains("seal") {
                p.move(to:.init(x:r.midX,y:r.minY)); p.addLine(to:.init(x:r.maxX-r.width*0.10,y:r.minY+r.height*0.18)); p.addLine(to:.init(x:r.maxX-r.width*0.18,y:r.maxY-r.height*0.24)); p.addLine(to:.init(x:r.midX,y:r.maxY)); p.addLine(to:.init(x:r.minX+r.width*0.18,y:r.maxY-r.height*0.24)); p.addLine(to:.init(x:r.minX+r.width*0.10,y:r.minY+r.height*0.18)); p.closeSubpath()
            } else if n.contains("star") {
                p = starPath(in: r)
            } else if n.contains("book") {
                rounded(.init(x:r.minX+r.width*0.08,y:r.minY+r.height*0.08,width:r.width*0.84,height:r.height*0.84), r.width*0.05)
                line(.init(x:r.midX,y:r.minY+r.height*0.10), .init(x:r.midX,y:r.maxY-r.height*0.08))
            } else if n.contains("music") {
                line(.init(x:r.minX+r.width*0.55,y:r.minY+r.height*0.12), .init(x:r.minX+r.width*0.55,y:r.maxY-r.height*0.22))
                line(.init(x:r.minX+r.width*0.55,y:r.minY+r.height*0.12), .init(x:r.maxX-r.width*0.08,y:r.minY+r.height*0.06))
                ellipse(.init(x:r.minX+r.width*0.20,y:r.maxY-r.height*0.28,width:r.width*0.34,height:r.height*0.22))
            } else if n.contains("film") {
                rounded(r, r.width*0.06)
                line(.init(x:r.minX+r.width*0.22,y:r.minY), .init(x:r.minX+r.width*0.22,y:r.maxY)); line(.init(x:r.maxX-r.width*0.22,y:r.minY), .init(x:r.maxX-r.width*0.22,y:r.maxY))
            } else if n.contains("car") {
                rounded(.init(x:r.minX+r.width*0.10,y:r.minY+r.height*0.40,width:r.width*0.80,height:r.height*0.38), r.width*0.08)
                line(.init(x:r.minX+r.width*0.28,y:r.minY+r.height*0.40), .init(x:r.minX+r.width*0.40,y:r.minY+r.height*0.18)); line(.init(x:r.minX+r.width*0.40,y:r.minY+r.height*0.18), .init(x:r.maxX-r.width*0.28,y:r.minY+r.height*0.18)); line(.init(x:r.maxX-r.width*0.28,y:r.minY+r.height*0.18), .init(x:r.maxX-r.width*0.16,y:r.minY+r.height*0.40))
                ellipse(.init(x:r.minX+r.width*0.22,y:r.maxY-r.height*0.16,width:r.width*0.14,height:r.height*0.14)); ellipse(.init(x:r.maxX-r.width*0.36,y:r.maxY-r.height*0.16,width:r.width*0.14,height:r.height*0.14))
            } else if n.contains("fork") {
                line(.init(x:r.minX+r.width*0.28,y:r.minY+r.height*0.06), .init(x:r.minX+r.width*0.28,y:r.maxY-r.height*0.06)); line(.init(x:r.minX+r.width*0.18,y:r.minY+r.height*0.06), .init(x:r.minX+r.width*0.18,y:r.minY+r.height*0.38)); line(.init(x:r.minX+r.width*0.38,y:r.minY+r.height*0.06), .init(x:r.minX+r.width*0.38,y:r.minY+r.height*0.38)); line(.init(x:r.maxX-r.width*0.30,y:r.minY+r.height*0.06), .init(x:r.maxX-r.width*0.30,y:r.maxY-r.height*0.06))
            } else if n.contains("lightbulb") {
                ellipse(.init(x:r.minX+r.width*0.22,y:r.minY,width:r.width*0.56,height:r.height*0.62)); line(.init(x:r.minX+r.width*0.38,y:r.minY+r.height*0.68), .init(x:r.maxX-r.width*0.38,y:r.minY+r.height*0.68)); line(.init(x:r.minX+r.width*0.42,y:r.minY+r.height*0.82), .init(x:r.maxX-r.width*0.42,y:r.minY+r.height*0.82))
            } else if n.contains("heart") {
                p.move(to:.init(x:r.midX,y:r.maxY)); p.addCurve(to:.init(x:r.minX,y:r.minY+r.height*0.28), control1:.init(x:r.minX+r.width*0.18,y:r.maxY-r.height*0.18), control2:.init(x:r.minX,y:r.minY+r.height*0.62)); p.addCurve(to:.init(x:r.midX,y:r.minY+r.height*0.30), control1:.init(x:r.minX,y:r.minY), control2:.init(x:r.minX+r.width*0.36,y:r.minY)); p.addCurve(to:.init(x:r.maxX,y:r.minY+r.height*0.28), control1:.init(x:r.maxX-r.width*0.36,y:r.minY), control2:.init(x:r.maxX,y:r.minY)); p.addCurve(to:.init(x:r.midX,y:r.maxY), control1:.init(x:r.maxX,y:r.minY+r.height*0.62), control2:.init(x:r.maxX-r.width*0.18,y:r.maxY-r.height*0.18))
            } else if n.contains("pin") {
                ellipse(.init(x:r.minX+r.width*0.33,y:r.minY+r.height*0.08,width:r.width*0.34,height:r.height*0.34)); line(.init(x:r.midX,y:r.minY+r.height*0.42), .init(x:r.midX,y:r.maxY-r.height*0.08))
            } else if n.contains("wifi") || n.contains("network") {
                p.addArc(center:.init(x:r.midX,y:r.maxY-r.height*0.14), radius:r.width*0.44, startAngle:.degrees(205), endAngle:.degrees(335), clockwise:false); p.addArc(center:.init(x:r.midX,y:r.maxY-r.height*0.14), radius:r.width*0.27, startAngle:.degrees(205), endAngle:.degrees(335), clockwise:false); ellipse(.init(x:r.midX-1.2,y:r.maxY-r.height*0.16,width:2.4,height:2.4))
            } else if n.contains("clipboard") || n.contains("doc") {
                rounded(.init(x:r.minX+r.width*0.16,y:r.minY+r.height*0.12,width:r.width*0.68,height:r.height*0.80), r.width*0.06)
                rounded(.init(x:r.minX+r.width*0.34,y:r.minY,width:r.width*0.32,height:r.height*0.24), r.width*0.04)
            } else if n.contains("laptopcomputer") {
                rounded(.init(x:r.minX,y:r.minY+r.height*0.12,width:r.width*0.66,height:r.height*0.52),r.width*0.05); rounded(.init(x:r.maxX-r.width*0.30,y:r.minY+r.height*0.36,width:r.width*0.28,height:r.height*0.54),r.width*0.05); line(.init(x:r.minX,y:r.minY+r.height*0.76), .init(x:r.minX+r.width*0.68,y:r.minY+r.height*0.76))
            } else if n.contains("radiowaves") {
                ellipse(.init(x:r.midX-1.3,y:r.midY-1.3,width:2.6,height:2.6)); p.addArc(center:.init(x:r.midX,y:r.midY),radius:r.width*0.26,startAngle:.degrees(-55),endAngle:.degrees(55),clockwise:false); p.addArc(center:.init(x:r.midX,y:r.midY),radius:r.width*0.42,startAngle:.degrees(-55),endAngle:.degrees(55),clockwise:false)
            } else if n.contains("speaker") {
                p.move(to:.init(x:r.minX,y:r.midY-r.height*0.14)); p.addLine(to:.init(x:r.minX+r.width*0.22,y:r.midY-r.height*0.14)); p.addLine(to:.init(x:r.minX+r.width*0.48,y:r.minY+r.height*0.18)); p.addLine(to:.init(x:r.minX+r.width*0.48,y:r.maxY-r.height*0.18)); p.addLine(to:.init(x:r.minX+r.width*0.22,y:r.midY+r.height*0.14)); p.addLine(to:.init(x:r.minX,y:r.midY+r.height*0.14)); p.closeSubpath(); p.addArc(center:.init(x:r.minX+r.width*0.48,y:r.midY),radius:r.width*0.28,startAngle:.degrees(-50),endAngle:.degrees(50),clockwise:false)
            } else {
                // Stable clean-room fallback: rounded tile with a central mark.
                rounded(r, r.width * 0.14)
                ellipse(.init(x: r.midX - 1.2, y: r.midY - 1.2, width: 2.4, height: 2.4))
            }
            return p
        }

        // Base silhouette layer.
        if n == "circle" || n.contains("circle") || n.contains("checkmark") || n.contains("face") {
            ellipse(r)
        } else if n.contains("star") {
            p = starPath(in: r)
        } else if n.contains("stop") {
            rounded(.init(x:r.minX+r.width*0.18,y:r.minY+r.height*0.18,width:r.width*0.64,height:r.height*0.64), r.width*0.05)
        } else if n.contains("rectangle") || n.contains("square") || n.contains("doc") || n.contains("keyboard") || n.contains("photo") || n.contains("book") || n.contains("film") {
            rounded(r, r.width * 0.10)
        } else if n.contains("paperplane") {
            p.move(to:r.origin); p.addLine(to:.init(x:r.maxX,y:r.minY)); p.addLine(to:.init(x:r.minX+r.width*0.62,y:r.maxY)); p.closeSubpath()
        } else if n.contains("plus.circle") {
            ellipse(r)
        } else if n.contains("xmark") {
            line(.init(x:r.minX,y:r.minY), .init(x:r.maxX,y:r.maxY)); line(.init(x:r.maxX,y:r.minY), .init(x:r.minX,y:r.maxY))
        } else if n.contains("clock") {
            ellipse(r); line(.init(x:r.midX,y:r.midY), .init(x:r.midX,y:r.minY+r.height*0.23)); line(.init(x:r.midX,y:r.midY), .init(x:r.maxX-r.width*0.23,y:r.midY))
        } else if n.contains("info") {
            ellipse(r); line(.init(x:r.midX,y:r.minY+r.height*0.42), .init(x:r.midX,y:r.maxY-r.height*0.18)); ellipse(.init(x:r.midX-0.9,y:r.minY+r.height*0.20,width:1.8,height:1.8))
        } else if n.contains("magnifyingglass") {
            ellipse(.init(x:r.minX,y:r.minY,width:r.width*0.70,height:r.height*0.70)); line(.init(x:r.minX+r.width*0.62,y:r.minY+r.height*0.62), .init(x:r.maxX,y:r.maxY))
        } else if n.contains("ellipsis") {
            for x in [0.24,0.50,0.76] as [CGFloat] { ellipse(.init(x:r.minX+r.width*x-1.2,y:r.midY-1.2,width:2.4,height:2.4)) }
        } else if n.contains("arrow") || n.contains("chevron") || n.contains("delete") || n.contains("waveform") || n.contains("mic") || n.contains("globe") || n.contains("hand") || n.contains("textformat") || n.contains("wand") || n.contains("spark") || n.contains("plus") || n.contains("shield") || n.contains("seal") || n.contains("music") || n.contains("car") || n.contains("fork") || n.contains("lightbulb") || n.contains("heart") || n.contains("pawprint") || n.contains("pin") || n.contains("wifi") || n.contains("network") || n.contains("clipboard") || n.contains("laptopcomputer") || n.contains("radiowaves") || n.contains("speaker") {
            // These are drawn entirely by the overlay layer to avoid duplicate paths.
        } else {
            rounded(r, r.width * 0.14)
        }
        return p
    }

    private func starPath(in r: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: r.midX, y: r.midY)
        let outer = min(r.width, r.height) * 0.50
        let inner = outer * 0.44
        for i in 0..<10 {
            let angle = -Double.pi / 2 + Double(i) * Double.pi / 5
            let radius = i.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }
}
