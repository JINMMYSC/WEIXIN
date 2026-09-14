import SwiftUI
import Foundation

public struct WTControlCenterView: View {
    @ObservedObject var runtime: WTKeyboardRuntime
    @State private var page = 0

    public init(runtime: WTKeyboardRuntime) { self.runtime = runtime }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let simplifiedPreferenceKey = "wt.script.simplified"

    public var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(pages[index]) { entry in
                            tile(entry)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == page ? WTChrome353.primaryText.opacity(0.75) : WTChrome353.secondary.opacity(0.32))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 22)

            footer
        }
        .background(WTChrome353.panelBackground)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button { runtime.state.back() } label: {
                WTSemanticGlyph(name: "chevron.up")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(WTChrome353.elevatedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button { runtime.state.present(.quickSend) } label: {
                HStack(spacing: 6) {
                    WTSemanticGlyph(name: "paperplane")
                        .font(.system(size: 14, weight: .medium))
                    Text("隔空传送")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(WTChrome353.secondary)
                .padding(.horizontal, 13)
                .frame(height: 34)
                .background(WTChrome353.elevatedSurface)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button { runtime.state.present(.quickSettings) } label: {
                WTSemanticGlyph(name: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 34, height: 34)
                    .background(WTChrome353.elevatedSurface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
    }

    private var footer: some View {
        HStack {
            Button { runtime.advanceToNextInputMode() } label: {
                WTSemanticGlyph(name: "globe")
                    .font(.system(size: 22))
                    .frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)

            Spacer()

            Button { runtime.state.present(.voice) } label: {
                WTSemanticGlyph(name: "mic")
                    .font(.system(size: 22))
                    .frame(width: 54, height: 42)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
    }

    private var pages: [[WTControlCenterEntry]] {
        [
            [
                .init(id: "voice", title: "语音转文字", glyph: "mic", target: .tool(.voice)),
                .init(id: "emoji", title: "表情", glyph: "face.smiling", target: .tool(.emoji)),
                .init(id: "keyboard", title: "键盘选择", glyph: "square.grid.3x3", target: .tool(.inputMode)),
                .init(id: "toolbar", title: "定制工具栏", glyph: "wand.and.stars", target: .panel(.toolbarArrange)),
                .init(id: "clipboard", title: "剪贴板", glyph: "doc.on.clipboard", target: .tool(.clipboard)),
                .init(id: "phrases", title: "常用语", glyph: "shippingbox", target: .tool(.phrases)),
                .init(id: "handwriting", title: "手写找字", glyph: "hand.draw", target: .tool(.handwriting)),
                .init(id: "ai", title: "问 AI", glyph: "sparkles", target: .tool(.askAI)),
            ],
            [
                .init(id: "translate", title: "边写边译", glyph: "character.book.closed", target: .tool(.translate)),
                .init(id: "picture", title: "排版成图", glyph: "photo", target: .tool(.picture)),
                .init(id: "font", title: "字体滤镜", glyph: "textformat", target: .tool(.fontPicker)),
                .init(id: "adjust", title: "键盘调节", glyph: "rectangle.and.hand.point.up.left", target: .tool(.keyboardAdjust)),
                .init(id: "polish", title: "文字整理", glyph: "sparkles", target: .tool(.textPolish)),
                .init(id: "expression", title: "灵动表达", glyph: "sun.max", target: .tool(.stickers)),
                .init(id: "mini", title: "小程序", glyph: "link", target: .tool(.plus)),
                .init(id: "traditional", title: "繁体输入", glyph: "character", target: .traditional),
            ],
            [
                .init(id: "onehand", title: "单手模式", glyph: "rectangle.leftthird.inset.filled", target: .oneHanded),
            ],
        ]
    }

    private func tile(_ entry: WTControlCenterEntry) -> some View {
        Button { perform(entry.target) } label: {
            VStack(spacing: 8) {
                WTSemanticGlyph(name: entry.glyph)
                    .font(.system(size: 25, weight: .regular))
                    .foregroundStyle(entry.id == "ai" ? WTChrome353.accent : WTChrome353.primaryText.opacity(0.86))
                Text(entry.title)
                    .font(.system(size: 10.5, weight: .regular))
                    .foregroundStyle(WTChrome353.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(WTChrome353.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func perform(_ target: WTControlCenterTarget) {
        switch target {
        case .tool(let tool):
            runtime.presentTool(tool)
        case .panel(let panel):
            runtime.state.present(panel)
        case .oneHanded:
            let next: WTOneHandedMode = runtime.quickSettings.oneHandedMode == .off ? .left : .off
            runtime.toggleOneHanded(next)
            runtime.state.back()
        case .traditional:
            let defaults = UserDefaults(suiteName: "group.7518554")
            let current = (defaults?.object(forKey: simplifiedPreferenceKey) as? Bool) ?? true
            let next = !current
            defaults?.set(next, forKey: simplifiedPreferenceKey)
            NotificationCenter.default.post(
                name: Notification.Name("WTPhase3SimplifiedChanged"),
                object: NSNumber(value: next)
            )
            runtime.state.back()
        }
    }
}

private struct WTControlCenterEntry: Identifiable {
    let id: String
    let title: String
    let glyph: String
    let target: WTControlCenterTarget
}

private enum WTControlCenterTarget {
    case tool(WTKeyboardTool)
    case panel(WTPanel)
    case oneHanded
    case traditional
}
