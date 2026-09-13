# V14 Hamster / librime production adapter contract

V14 keeps the Overlay independent of concrete Hamster class names, but adds a declarative mode mapping so the final public-revision integration no longer needs to hard-code schema names into UI code.

## Session surface

`WTHamsterRimeSessionProtocol` covers:

1. `wtComposition`
2. `wtCandidates`
3. `wtIsComposing`
4. `wtCandidatePageState`
5. `wtProcess(_:)`
6. `wtDrainCommit()`
7. `wtSetInputMode(_:)`
8. `wtApplyModeDescriptor(_:logicalMode:)`
9. `wtMoveCandidatePage(_:)`
10. `wtSelectCandidate(at:)`
11. `wtDeleteBackward()`
12. `wtReset()`

The default `wtApplyModeDescriptor` falls back to `wtSetInputMode`, so older/public wrappers can conform incrementally.

## Backend profile

`WTRimeBackendProfile` maps each logical `WTInputMode` to a `WTRimeModeDescriptor` containing optional:

- `schemaID`
- `options: [String: Bool]`
- `properties: [String: String]`

`safeDefault` changes only the common `ascii_mode` option. It intentionally does **not** guess schema IDs for Pinyin/T9/Shuangpin/Wubi/Stroke, because Hamster users may install different Rime schemas.

At final integration, define an override profile for the actual bundled/selected schemas and make Hamster's concrete session apply schema/options/properties through its public librime wrapper.

## Ordering rules

Normal key:

`process key -> drain commit -> read context/status -> render`

Candidate page:

`page up/down -> read context -> render`

Candidate select:

`select using backend source index -> drain commit -> read context -> render`

Never feed a visually reordered compatibility/pinned/cloud display index directly to the backend.
