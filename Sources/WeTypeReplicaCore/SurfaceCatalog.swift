import Foundation

public enum WTSurfaceImplementationStatus: String, Codable, Sendable {
    case implemented
    case providerRequired
    case xcodeValidationRequired
    case notYetImplemented
    case debugOnly
}

public struct WTUISurfaceMapping: Identifiable, Codable, Hashable, Sendable {
    public var id: String { originalClass }
    public let originalClass: String
    public let replicaSurface: String
    public let status: WTSurfaceImplementationStatus
    public let note: String
    public init(_ originalClass: String, _ replicaSurface: String, _ status: WTSurfaceImplementationStatus = .implemented, _ note: String = "") {
        self.originalClass = originalClass; self.replicaSurface = replicaSurface; self.status = status; self.note = note
    }
}

/// Clean-room UI coverage ledger for surfaces confirmed by class names/selectors in WeType 3.5.3.
/// It deliberately records class/surface identity only; no proprietary implementation code or assets are copied.
public enum WTUISurfaceCatalog353 {
    public static let mappings: [WTUISurfaceMapping] = [
        .init("WBRootInputView", "WTPanelRootView"),
        .init("WBMainInputView", "WTPanelRootView"),
        .init("WBT26Panel", "WTKeyboardCanvasView"),
        .init("WBT9Panel", "WTKeyboardCanvasView"),
        .init("WBKeyboardView", "WTKeyboardCanvasView"),
        .init("WBKeyPopupView", "WTLongPressPopupView"),
        .init("WBKeyPopupSliderItemView", "WTLongPressPopupView"),
        .init("WBCandidateView", "WTCandidateBar"),
        .init("WBCandidateExpandView", "WTCandidateBar.expandedGrid"),
        .init("WBSplitCandidateView", "WTCandidateBar"),
        .init("WBMoreCandidateBaseView", "WTCandidateBar"),
        .init("WBCustomToolBarView", "WTFunctionToolbarView"),
        .init("WBArrangeView", "WTToolbarArrangeView"),
        .init("WBArrangeCell", "WTToolbarArrangeView"),
        .init("WBControlCenterView", "WTControlCenterView"),
        .init("WBCCMainView", "WTControlCenterView"),
        .init("WBQuickSettingView", "WTQuickSettingsView"),
        .init("WBLanguageSwitchView", "WTInputModeSwitcherView"),
        .init("WBSymbolListView", "WTFullSymbolPanelView"),
        .init("WBSymbolExpandTabView", "WTFullSymbolPanelView"),
        .init("WBSymbolExpandNewTabView", "WTFullSymbolPanelView"),
        .init("WBFullSymbolPanel2", "WTFullSymbolPanelView"),
        .init("WBEmojiPageView", "WTEmojiPanelView"),
        .init("WBEmojiPageContainerView", "WTEmojiPanelView"),
        .init("WBWechatEmojiPageView", "WTEmojiPanelView"),
        .init("WBEmotionPageView", "WTEmojiPanelView"),
        .init("WBStickerNativeView", "WTStickerGIFPanelView", .providerRequired, "online/custom sticker content provider"),
        .init("WBCustomStickerView", "WTStickerGIFPanelView", .providerRequired, "custom sticker provider"),
        .init("WBStickerCollectionView", "WTStickerGIFPanelView", .providerRequired, "online/custom sticker content provider"),
        .init("WBStickerPreviewView", "WTStickerGIFPanelView.preview", .providerRequired, "media provider/send bridge"),
        .init("WBStickerPageEmptyView", "WTStickerGIFPanelView.emptyState"),
        .init("WBPasteboardListView", "WTClipboardPanelView"),
        .init("WBPasteboardAuthHeaderView", "WTGuideAuthView"),
        .init("WBPasteboardImageDetailView", "WTPasteboardImageDetailView", .xcodeValidationRequired, "pasteboard privacy requires iOS runtime"),
        .init("WBHotWordListView", "WTHotWordPanelView", .providerRequired, "hotword dictionary provider"),
        .init("WBHotwordEditView", "WTHotWordPanelView", .providerRequired, "user dictionary mutation bridge"),
        .init("WBAddHotWordEntranceView", "WTHotWordPanelView", .providerRequired, "user dictionary mutation bridge"),
        .init("WBHandwritingPanelView", "WTHandwritingCanvasView", .providerRequired, "handwriting recognizer"),
        .init("WBHandWritingInkLikeOverlayView", "WTHandwritingCanvasView"),
        .init("WBStrokeFilterView", "WTStrokeFilterView"),
        .init("WBFontFilterPickerView", "WTFontPickerView"),
        .init("WBWordSplittingView", "WTWordSplittingView", .providerRequired, "word-splitting dictionary provider"),
        .init("WBVoiceInputInteractionView", "WTVoicePanelView", .providerRequired, "host-app audio/recognition bridge"),
        .init("WBVoiceInputWaveView", "WTVoicePanelView"),
        .init("WBTranslateView", "WTTranslatePanelView", .providerRequired, "translation provider"),
        .init("WBAIAssistantView", "WTAIPanelView", .providerRequired, "AI provider"),
        .init("WBAIAssistantToolSelectionView", "WTAIPanelView", .providerRequired, "AI provider"),
        .init("WBAskAIWebView", "WTAIPanelView", .providerRequired, "AI provider"),
        .init("WBCorrectionNoticeView", "WTCorrectionPanelView", .providerRequired, "correction provider"),
        .init("WBCorrectionDetailView", "WTCorrectionPanelView", .providerRequired, "correction provider"),
        .init("WBRewriteNoticeView", "WTTextPolishPanelView", .providerRequired, "rewrite provider"),
        .init("WBRewriteDetailView", "WTTextPolishPanelView", .providerRequired, "rewrite provider"),
        .init("WBDeviceSyncManager", "WTDeviceSyncPanelView", .xcodeValidationRequired, "Bonjour/Network.framework runtime"),
        .init("WBAuthGuideView", "WTGuideAuthView"),
        .init("WBGuidePageView", "WTGuideAuthView"),
        .init("WBPlusConfigView", "WTPlusPanelView"),
        .init("WBRectSettingView", "WTKeyboardAdjustView"),
        .init("WBRectSettingOperationView", "WTKeyboardAdjustView"),
        .init("WBOpenInWeChatPCView", "WTQuickSendPanelView", .providerRequired, "host app / desktop handoff"),
        .init("WBPendingInputView", "WTCandidateBar"),
        .init("WBMenuView", "WTCandidateBar / contextual menus"),
        .init("WBAIAssistantAskAIView", "WTAIPanelView", .providerRequired, "AI provider"),
        .init("WBAIAssistantRecommendView", "WTAIPanelView", .providerRequired, "AI recommendation provider"),
        .init("WBAskAIContentView", "WTAIPanelView", .providerRequired, "AI provider"),
        .init("WBCCPresentingView", "WTControlCenterView"),
        .init("WBCustomToolBarScrolView", "WTFunctionToolbarView"),
        .init("WBEditorInputView", "WTAIPanelView / WTTranslatePanelView"),
        .init("WBFloatingSingleView", "WTLongPressPopupView"),
        .init("WBPopupShapeView", "WTLongPressPopupView"),
        .init("WBHandWritingBaseOverlayView", "WTHandwritingCanvasView"),
        .init("WBInnerHWPanelView", "WTHandwritingCanvasView"),
        .init("WBLicenseAlertView", "WTLicenseAlertView"),
        .init("WBMicroPhoneView", "WTVoicePanelView"),
        .init("WBMultipleTextTableView", "WTPhrasesPanelView / WTClipboardPanelView"),
        .init("WBNetworkAlertView", "WTNetworkAlertView"),
        .init("WBPasteboardHotWordShellView", "WTHotWordPanelView", .providerRequired, "hotword mutation bridge"),
        .init("WBPlusConfigAbilityItemView", "WTPlusPanelView"),
        .init("WBPlusConfigHeaderView", "WTPlusPanelView"),
        .init("WBPlusEntranceView", "WTPlusPanelView"),
        .init("WBPlusSelectionView", "WTPlusPanelView"),
        .init("WBPlusStatementView", "WTPlusPanelView"),
        .init("WBQuickSettingItemView", "WTQuickSettingsView"),
        .init("WBQuickSettingSectionView", "WTQuickSettingsView"),
        .init("WBSegmentedView", "WTStickerGIFPanelView / WTPlusPanelView"),
        .init("WBSpellPlusConfirmView", "WTCorrectionPanelView", .providerRequired, "correction provider"),
        .init("WBStickerPageContainerView", "WTStickerGIFPanelView", .providerRequired, "sticker provider"),
        .init("WBStickerPreviewContentView", "WTStickerGIFPanelView.preview", .providerRequired, "sticker provider"),
        .init("WBSubPanelView", "WTPanelRootView"),
        .init("WBTopBarTipsView", "WTTopBarTipsView"),
        .init("WBTranslateViewToolBar", "WTTranslatePanelView"),
        .init("WBFinderView", "WTBookVideoPanelView", .providerRequired, "WeChat Finder/video-account rich-content card; host handoff provider required"),
        .init("WBTPListView", "WTDebugTouchPlaybackView", .debugOnly, "internal touch-recording list; evidence: WBTPRecord/WBTPExporter/WBTouchRecorderDelegate"),
        .init("WBTPPlayerView", "WTDebugTouchPlaybackView", .debugOnly, "internal touch-record playback; evidence: playTouchRecord/stopPlayTouchRecord")
    ]

    public static func mapping(for originalClass: String) -> WTUISurfaceMapping? {
        mappings.first { $0.originalClass == originalClass }
    }
}
