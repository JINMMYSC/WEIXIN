# V6 Binary findings — formerly unresolved surfaces

## WBFinderView

The WeType 3.5.3 keyboard binary groups `WBFinderView` with the `WBBookVideo*` feature family rather than a generic file finder.
Static evidence includes:

- `WBBookVideoFinderModel`
- `WBBookVideoWeChatFinderSendData`
- `sendWeChatFinder:action:` / `sendWeChatFinder:open:`
- `canSendFinder` / `canSendWeChatFinder`
- `finderFeedID`, `finderNonceID`, `finderUserName`, `finderJumpInfo*`
- resource family `icon_bookvideo_ani_finder*`, `icon_bookvideo_tab_videoaccount.png`, plus public-account, mini-program, music, movie, book, Baike, stock and other BookVideo tabs.

Conclusion: this is a **WeChat rich-content/video-account surface**, not a filesystem finder. V6 maps it to the clean-room `WTBookVideoPanelView`; real search/send content stays behind `WTBookVideoService`/runtime provider hooks.

## WBTPListView / WBTPPlayerView

These two classes are not user product panels. Nearby Objective-C strings identify a developer touch-record/replay facility:

- `WBTPExporter`, `WBTPRecord`, `WBTPListStore`
- `WBTouchRecorderDelegate`
- `TPExporter:didRecordTouchEvent:`
- `TPExporter:shouldBeginRecordingWithEvent:`
- `TPRecorderDidStopRC:item:interrupted:`
- `addTPRecord:`, `updateTouchRecord:`
- `playTouchRecord:playMode:`, `nextStepPlayTouchRecord`, `stopPlayTouchRecord`
- debug preference `WBAppSettingsBit_Debug_RecordTouch`

Conclusion: V6 classifies both surfaces as **debug-only internal touch playback**, not missing shipping UI. A `#if DEBUG` clean-room `WTDebugTouchPlaybackView` is included for coverage but is not exposed from the keyboard.
