# V12 Hamster / librime production adapter contract

V12 reduces the final production adapter to the backend operations the overlay actually needs. The UI must never depend on Hamster concrete class names.

## Required session operations

`WTHamsterRimeSessionProtocol` now requires:

1. `wtComposition` — current preedit/composition text.
2. `wtCandidates` — visible candidate page in source order, including comments when available.
3. `wtIsComposing` — whether the session owns active composition.
4. `wtProcess(_:)` — process one key/text action through librime.
5. `wtDrainCommit()` — drain librime committed text after `process_key`; this is essential because librime commit delivery is separate from context/candidate reads.
6. `wtSetInputMode(_:)` — map logical replica modes to Hamster schema/options (26-key Pinyin, T9, Shuangpin, Wubi, stroke, English).
7. `wtSelectCandidate(at:)` — select the candidate using its original backend index and return the committed text.
8. `wtDeleteBackward()` — delete inside composition by processing BackSpace.
9. `wtReset()` — clear composition without inserting text.

## Expected librime semantics

A direct librime bridge should follow this order after a key is accepted:

`process_key` → drain `get_commit`/`free_commit` → read `get_status` and `get_context` → free returned structs.

For candidate selection, use the candidate API corresponding to the candidate page represented by `wtCandidates`, then drain the resulting commit. Do not convert the display-reordered candidate index directly to a backend index; V10/V11 already preserve `candidateSourceIndexes` for this reason.

## V12 behavior fixes that depend on this contract

- A backend commit produced by a normal key can no longer disappear: the overlay drains it into `UITextDocumentProxy`.
- Space while composing is sent to the engine first, so librime can accept the highlighted candidate. An idle space still inserts a literal space.
- Direct punctuation/symbol insertion resolves the active candidate first instead of silently discarding composition.
- Input mode changes now reach the engine (`setInputMode`) instead of changing only the visual layout.
- Host text-context transitions clear outstanding composition/candidate UI to prevent residual preedit leaking into the next field.

## Concrete revision work left for macOS/Xcode stage

The remaining adapter work is no longer UI work. On the selected public Hamster revision, implement the nine members above using that revision's wrapper/session API (or a thin direct librime C bridge), then run the 100-probe corpus and the residual-composition regression cases on-device.
