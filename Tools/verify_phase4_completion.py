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

    for token in (
        "frame(height: 40)", "frame(height: 124)", "frame(height: 204)",
        "deleteStrokeOrText", "runtime.recognizeHandwriting", "runtime.state.present(.fullSymbols)",
        "runtime.state.present(.emoji)", "runtime.submitSpace()", "runtime.submitReturn()",
    ):
        require(token in handwriting, f"handwriting control-plane mismatch: {token}")

    require("runtime.state.present(.stickers)" in emoji,
            "emoji panel does not route sticker/GIF tabs to the live Phase 4 media panel")
    require("requestClipboardAuthorization" in clipboard and "captureCurrentClipboard" in clipboard,
            "clipboard panel does not expose permission/read recovery")
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

    # Phase 3 observable-reference parity is intentionally fail-closed: the stimuli matrix exists,
    # but no WeChat expected output may be invented in Phase 4 work.
    require("Reference observations are a separate real-device capture artifact" in matrix,
            "Phase 3 reference observations must remain external real-device evidence")

    print("Phase 4 panel completion contract: PASS")
    print("Phase 3 WeChat reference-output parity remains a real-device gate and is not fabricated.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 4 panel completion contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
