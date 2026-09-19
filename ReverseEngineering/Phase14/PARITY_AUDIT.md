# WeType 3.5.3 parity audit

Reference: WeChat Input 3.5.3 on iPhone 15 Pro Max (430 x 932 pt, iOS 26.2.1).
Evidence: the 19 supplied recordings, the extracted 3.5.3 INI/layout resources, the
Objective-C class and selector dumps, and the asset manifest. Replica: this repository at
`work/v14-phase13-static-delta`.

## 1. Surface ledger

`Sources/WeTypeReplicaCore/SurfaceCatalog.swift` maps 93 confirmed original classes onto
replica surfaces:

| Status | Count | Meaning |
|---|---:|---|
| `implemented` | 62 | layout and interaction exist in the replica |
| `providerRequired` | 27 | UI exists, but the online/engine behaviour behind it does not |
| `xcodeValidationRequired` | 2 | needs an iOS runtime check (pasteboard privacy, Bonjour) |
| `debugOnly` | 2 | original classes are internal touch-recording tools |

## 2. Behaviour still missing (27 surfaces)

These are the features where the official app produces content and the replica cannot yet:

| Area | Original surfaces | What is missing |
|---|---|---|
| Stickers and GIF | `WBStickerNativeView`, `WBStickerCollectionView`, `WBCustomStickerView`, `WBStickerPreviewView`, `WBStickerPageContainerView`, `WBStickerPreviewContentView` | sticker/GIF catalogue, custom stickers, preview and send bridge |
| AI | `WBAIAssistantView`, `WBAIAssistantToolSelectionView`, `WBAIAssistantAskAIView`, `WBAIAssistantRecommendView`, `WBAskAIWebView`, `WBAskAIContentView` | model provider and answer rendering |
| Rewrite | `WBRewriteNoticeView`, `WBRewriteDetailView` | rewrite provider |
| Correction | `WBCorrectionNoticeView`, `WBCorrectionDetailView`, `WBSpellPlusConfirmView` | correction provider |
| Translation | `WBTranslateView` | translation provider |
| Voice | `WBVoiceInputInteractionView` | host audio capture and recognition bridge |
| Handwriting | `WBHandwritingPanelView` | handwriting recogniser |
| Hot words | `WBHotWordListView`, `WBHotwordEditView`, `WBAddHotWordEntranceView`, `WBPasteboardHotWordShellView` | user-dictionary read/write |
| Word splitting | `WBWordSplittingView` | splitting dictionary |
| Cross-device | `WBDeviceSyncManager`, `WBOpenInWeChatPCView` | Bonjour runtime validation and desktop handoff |
| Rich content | `WBFinderView` | WeChat Finder/video-account card provider |

## 3. Original view classes with no replica counterpart

Filtering the class dump for `WB*View*` entries that are absent from the catalog leaves 93
names. Most are plumbing, but these are user-visible and unmapped:

- Toast chrome: `WBToastView`, `WBToastView2`
- Panel page chrome: `WBPageTitleView`, `WBSwiperPageTitleView`, `WBTabPageView`
- Empty states: `WBEmptyView`, `WBCorrectionDetailEmptyView`, `WBRewriteDetailEmptyView`,
  `WBPasteboardImageDetailEmptyView`
- Layout helpers used by several panels: `WBHorButtonGroupView`, `WBCommonPanelView`,
  `WBAnimationBackgroundView`
- Book/video card sub-views: `WBBookVideoBaseGenerateView`,
  `WBBookVideoMiniProgramCoverGenerateView`, `WBBookVideoStockCoverGenerateView`,
  `WBBookVideoStockGenerateTopView`, `WBBookVideoBaikeCoverGenerateView`,
  `WBBookVideoRateView`, `WBBookVideoRateStarView`, `WBBookVideoWordTransMeansView`
- Key sub-views: `WBKeyView`, `WBKeyViewButton`, `WBNewlineKeyView`, `WBReturnKeyView`,
  `WBRuleKeyView`, `WBSecKeyboardKeyView` (the replica draws one key view instead)

## 4. Visual alignment status

Measured against real 3.5.3 frames so far:

| Surface | Measured | Detail |
|---|---|---|
| 26-key rows and bottom row | yes | [README.md](README.md) tables |
| Nine-key rows, gutters and bottom row | yes | rows at canvas y 3/59/115/171 |
| Keyboard panel split and bottom bar | yes | 371 pt panel, 72.33 pt header, 298.67 pt canvas |
| Header toolbar and candidate row | yes | 32 pt row at panel-relative y 31 |
| Host home grid | yes | 20 pt margin, 14 pt column gap, 16 pt radius, `#E2F1F0` |
| Host display settings page | partially | page chrome measured, some rows still generic |
| Symbol panel | measured, not implemented | row 3 is 5 x 44.67 pt keys, resource lists six |
| Emoji, clipboard, handwriting, voice, plus panels | **not yet** | geometry never measured |
| Panel transitions, popups, expanded candidate grid | **not yet** | timing and layout unknown |

## 5. Host app settings

The 3.5.3 setup bundle names twelve pages: `SetupMain`, `SetupKeyboardSelect`, `SetupSp`,
`SetupWb`, `SetupFuzzyPinyin`, `SetupAuxiliaryInput`, `SetupDisplaySetting`,
`SetupKeystrokeEffect`, `SetupClipboard`, `SetupDesktop`, `SetupMigrationAssistant`,
`SetupPlus`. The replica now renders the home grid and the display settings page with
measured chrome; every other page still uses generic `Section`/`Toggle` rows inside the
shared measured page background.

## 6. Out of scope because no reference exists

- Dark mode: none of the recordings show it.
- Landscape, secure fields, Spotlight, and other host-app-specific environments.
- Original artwork: the replica deliberately redraws vectors and does not bundle Tencent
  images, GIFs, Lottie files or fonts.

## 7. Ordered plan

1. Measure and align the remaining keyboard panels: symbols, emoji, clipboard, handwriting,
   voice, plus, control centre.
2. Measure the settings pages that the recordings cover and rebuild each row list.
3. Add the missing shared chrome pieces: toasts, page titles, empty states.
4. Wire the provider-backed features that a clean-room build can implement offline
   (hot words, word splitting, handwriting canvas behaviour).
5. Re-capture the ten Phase 14 scenes on device and run the masked diff.
