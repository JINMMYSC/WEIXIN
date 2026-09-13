# V13 Hamster / librime production adapter contract

The replica UI still does not depend on concrete Hamster class names. V13 expands the V12 bridge so candidate paging is no longer a UI-only approximation.

## Required session surface

`WTHamsterRimeSessionProtocol` now covers:

1. `wtComposition`
2. `wtCandidates`
3. `wtIsComposing`
4. `wtCandidatePageState`
5. `wtProcess(_:)`
6. `wtDrainCommit()`
7. `wtSetInputMode(_:)`
8. `wtMoveCandidatePage(_:)`
9. `wtSelectCandidate(at:)`
10. `wtDeleteBackward()`
11. `wtReset()`

Public Hamster revisions that do not expose candidate-page metadata through their wrapper can temporarily inherit the single-page default, but production parity requires mapping Rime candidate menu page number / page size / previous-next availability and page movement.

## librime ordering rule

Normal key:

`process_key -> drain get_commit/free_commit -> get_status/get_context -> render`

Candidate page move:

`page_up/page_down or equivalent Rime key event -> get_context -> render`

Candidate select:

`select candidate using backend source index -> drain commit -> get_context -> render`

Never use the visually reordered display index directly as a backend candidate index. Compatibility/pin/cloud layers keep `candidateSourceIndexes` for this reason.

## V13 additional runtime rule

Keyboard-extension restart restoration only restores logical input mode (`inputMode` + `lastChineseMode`). It intentionally never restores composition/candidate menu because that content belongs to the previous host text session and can create residual preedit in a new field.
