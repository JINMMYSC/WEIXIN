import SwiftUI

struct WTPhase2KeyboardRootView: View {
    @ObservedObject var runtime: WTKeyboardRuntime

    var body: some View {
        Group {
            if runtime.state.panel == .inputModeSwitcher {
                phase3InputModeSwitcher
            } else {
                VStack(spacing: 0) {
                    WTCandidateBar(runtime: runtime)
                    WTKeyboardCanvasView(layout: keyboardLayout, runtime: runtime)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WTThemeColor353.keyboardBackground)
    }

    private var phase3InputModeSwitcher: some View {
        VStack(spacing: 12) {
            HStack {
                Text("输入方式")
                    .font(.headline)
                Spacer()
                Button("返回") {
                    runtime.state.returnToKeyboard()
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                modeButton("九宫格拼音", .chinesePinyin9)
                modeButton("26键拼音", .chinesePinyin26)
            }
            HStack(spacing: 10) {
                modeButton("双拼", .doublePinyin)
                modeButton("五笔86", .wubi)
            }
            HStack(spacing: 10) {
                modeButton("笔画", .stroke)
                modeButton("英文", .english26)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private func modeButton(_ title: String, _ mode: WTInputMode) -> some View {
        Button {
            runtime.chooseInputMode(mode)
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Spacer(minLength: 4)
                if runtime.state.inputMode == mode {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundStyle(WTThemeColor353.primaryText)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(WTThemeColor353.normalKey)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var keyboardLayout: WTKeyboardLayout {
        // Phase 3 still uses the measured V14 key canvases. Previously the runtime changed
        // `state.panel`, but this root ignored it, so 123/symbol/back keys appeared to do nothing.
        switch runtime.state.panel {
        case .number:
            switch runtime.state.inputMode {
            case .chinesePinyin9, .stroke:
                return WTLayouts353Resolved.t9Number
            default:
                return WTLayouts353Resolved.t9Number26
            }
        case .symbols:
            return runtime.state.inputMode == .english26
                ? WTLayouts353Resolved.t26EnSymbol
                : WTLayouts353Resolved.t26CnSymbol
        case .fullSymbols:
            return WTLayouts353Resolved.fullSymbol2
        default:
            break
        }

        switch runtime.state.inputMode {
        case .chinesePinyin9:
            return WTLayouts353Resolved.t9Pinyin
        case .english26:
            return WTLayouts353Resolved.t26En
        case .wubi:
            return WTLayouts353Resolved.t26Wubi
        case .stroke:
            return WTLayouts353Resolved.t9Stroke
        case .chinesePinyin26, .doublePinyin, .handwriting:
            return WTLayouts353Resolved.t26Pinyin
        }
    }
}
