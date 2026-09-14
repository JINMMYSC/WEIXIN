#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    state = text("Sources/WeTypeReplicaCore/Phase4PanelState.swift")
    runtime = text("iOSOverlay/WTKeyboardRuntime.swift")
    binder = text("iOSServices/WTKeyboardServiceBinder.swift")
    root = text("iOSOverlay/WTPanelRootView.swift")
    control = text("iOSOverlay/WTControlCenterView.swift")
    handwriting = text("iOSOverlay/WTHandwritingCanvasView.swift")
    emoji = text("iOSOverlay/WTEmojiPanelView.swift")
    clipboard = text("iOSOverlay/WTClipboardPanelView.swift")
    phrases = text("iOSOverlay/WTPhrasesPanelView.swift")
    voice = text("iOSOverlay/WTVoicePanelView.swift")
    translate = text("iOSOverlay/WTTranslatePanelView.swift")
    ai = text("iOSOverlay/WTAIPanelView.swift")
    polish = text("iOSOverlay/WTTextPolishPanelView.swift")
    correction = text("iOSOverlay/WTCorrectionPanelView.swift")
    stickers = text("iOSOverlay/WTStickerGIFPanelView.swift")
    hotwords = text("iOSOverlay/WTHotWordPanelView.swift")
    picture = text("iOSOverlay/WTPicturePanelView.swift")
    quicksend = text("iOSOverlay/WTQuickSendPanelView.swift")
    devices = text("iOSOverlay/WTDeviceSyncPanelView.swift")
    words = text("iOSOverlay/WTWordSplittingView.swift")
    book = text("iOSOverlay/WTBookVideoPanelView.swift")
    scene = text("ClawBase/Host/SceneDelegate.swift")
    plist = text("ClawBase/Host/Info.plist")
    project = text("ClawBase/project.yml")
    matrix = text("Tools/phase3_blackbox_matrix.py")

    for token in (
        "case idle", "case loading", "case ready", "case empty",
        "case permissionDenied(String)", "case offline(String)",
        "case failed(String)", "case fallback(String)",
    ):
        require(token in state, f"Phase 4 panel state missing: {token}")
    require("phase4PanelStates" in runtime and "panelLoadState" in runtime and "setPanelLoadState" in runtime,
            "runtime does not expose Phase 4 panel states")

    routed = {
        ".emoji": "WTEmojiPanelView", ".clipboard": "WTClipboardPanelView",
        ".phrases": "WTPhrasesPanelView", ".handwriting": "WTHandwritingCanvasView",
        ".voice": "WTVoicePanelView", ".translate": "WTTranslatePanelView",
        ".correction": "WTCorrectionPanelView", ".askAI": "WTAIPanelView",
        ".deviceSync": "WTDeviceSyncPanelView", ".quickSend": "WTQuickSendPanelView",
        ".textPolish": "WTTextPolishPanelView", ".picture": "WTPicturePanelView",
        ".hotWords": "WTHotWordPanelView", ".stickers": "WTStickerGIFPanelView",
        ".wordSplitting": "WTWordSplittingView", ".bookVideo": "WTBookVideoPanelView",
        ".fullSymbols": "WTFullSymbolPanelView",
    }
    for panel, view in routed.items():
        require(f"case {panel}:" in root and f"{view}(runtime: runtime)" in root,
                f"live Phase 4 route missing: {panel} -> {view}")

    panel_sources = [clipboard, phrases, voice, translate, ai, polish, correction, stickers, hotwords, picture, quicksend, devices, words, book]
    require(sum("WTPhase4PanelStateView" in source for source in panel_sources) >= 12,
            "Phase 4 panels do not expose enough loading/empty/error/retry surfaces")

    for token in (
        "setPanelLoadState(.loading", ".permissionDenied(", ".offline(", ".failed(", ".fallback(",
        "openQuickSendHostApp", "openPictureHostApp", "bindHostHandoffs", "bindVoiceBridge",
        "WTHTTPAIService", "WTHTTPTranslationService", "WTHTTPHotWordService", "WTHTTPMediaService",
    ):
        require(token in binder, f"Phase 4 binder missing state/provider behavior: {token}")

    # Reference-capture structural checks. These are deliberately not called pixel parity.
    for token in (
        "TabView(selection: $page)", 'title: "语音转文字"', 'title: "定制工具栏"',
        'title: "边写边译"', 'title: "繁体输入"', 'title: "单手模式"', 'Text("隔空传送")',
    ):
        require(token in control, f"control-center reference structure missing: {token}")

    for token in (
        'Text("表情符号与人物")', 'Text("定制表情")', "count: 8",
        "runtime.state.present(.stickers)", "runtime.deleteBackward()", "runtime.advanceToNextInputMode()",
    ):
        require(token in emoji, f"emoji reference structure missing: {token}")

    for token in (
        'Text("剪贴板")', 'Button("常用语")', 'Text("以下为 1 天前的内容")',
        "requestClipboardAuthorization", "captureCurrentClipboard", "runtime.state.present(.pasteboardImage)",
    ):
        require(token in clipboard, f"clipboard reference structure missing: {token}")

    for token in (
        "frame(height: 40)", "frame(height: 124)", "frame(height: 204)",
        "ghostKeyGrid", 'Text("字迹未消失也可以继续写")', "deleteStrokeOrText",
        "runtime.recognizeHandwriting", "runtime.submitSpace()", "runtime.submitReturn()",
        "runtime.advanceToNextInputMode()", "runtime.state.present(.voice)",
    ):
        require(token in handwriting, f"handwriting reference structure missing: {token}")

    for token in (
        "inlineVoiceKeyboard", "WTKeyboardCanvasView", 'return "语音转文字中…"',
        'return "轻触结束"', "runtime.stopVoice()", "runtime.startVoice()", "WTPhase4PanelStateView",
    ):
        require(token in voice, f"voice reference structure missing: {token}")

    require("runtime.loadMedia" in stickers and "runtime.sendMedia" in stickers,
            "sticker/GIF panel is not wired to provider/send hooks")
    require("localFallback" in words and "WTWordSplitOption" in words,
            "word splitting has no local fallback")

    for token in ("wtreplica", "openURLContexts", "WTHostVoiceCaptureView", "WTHostPhase4RouteView"):
        require(token in scene, f"ClawBase Host route missing: {token}")
    for token in ("NSMicrophoneUsageDescription", "NSSpeechRecognitionUsageDescription", "CFBundleURLTypes", "wtreplica"):
        require(token in plist, f"Host plist missing Phase 4 permission/route: {token}")
    for source in (
        "../iOSApp/WTHostVoiceCaptureView.swift", "../iOSApp/WTHostPhase4HandoffView.swift",
        "../iOSServices/WTHostSpeechRecognitionService.swift", "../iOSServices/WTVoiceLiveActivityController.swift",
        "../iOSShared/WTVoiceActivityAttributes.swift",
    ):
        require(source in project, f"Host target does not compile Phase 4 bridge source: {source}")

    # Phase 3 observable-reference parity stays fail-closed: no expected WeChat output is invented.
    require("Reference observations are a separate real-device capture artifact" in matrix,
            "Phase 3 reference observations must remain external real-device evidence")

    print("Phase 4 screenshot-reference structural contract: PASS")
    print("This is a structural gate, not pixel-identity certification.")
    print("Phase 3 WeChat reference-output parity remains a real-device gate and is not fabricated.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 4 screenshot-reference structural contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
