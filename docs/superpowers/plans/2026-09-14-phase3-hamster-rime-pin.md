# Phase 3 Hamster/librime integration pin

Date: 2026-09-14
Branch: `work/v14-clawbase-t9-rime`

## Scope of this slice

This slice advances Phase 2 T9 and Phase 3 together without weakening the already-proven ClawBase installability chain.

The Keyboard target now compiles and drives `WTHamsterRimeSessionAdapter` through `WTHamsterRimeSessionProtocol`. The real-device smoke build starts in `.chinesePinyin9` and uses the extracted `WTLayouts353Resolved.t9Pinyin` geometry. A deterministic adapter smoke session validates both T9 (`64426` -> `你好`) and T26 (`nihao` -> `你好`) paths during the Debug simulator build.

This smoke session is **not** the production librime engine. It exists so UI/runtime work can proceed through the final typed adapter boundary while the external binary dependency is pinned and integrated separately.

## Public Hamster source pin

Reference repository:

- `https://github.com/imfuxiao/Hamster`
- inspected public source revision: `65693706d01fc6c19ed6071968e542b0a2ef3f36`

Relevant `Packages/RimeKit/Sources/Swift/Rime.swift` API surface at that revision:

- `inputKey(_:)`
- `inputKeyCode(_:modifier:)`
- `candidateList()` / `candidateListWithIndex(index:andCount:)`
- `getInputKeys()`
- `getCommitText()`
- `selectCandidate(index:)`
- `cleanComposition()`
- `status()` / `context()`
- `setSchema(_:)`
- `asciiMode(_:)`
- `setSimplifiedChineseMode(key:value:)`

The repository's `librimeFramework.sh` pins the historical framework bundle to `LibrimeKitVersion="2.4.2"`. The RimeKit package expects the generated/downloaded xcframework set under the Hamster repository's `Frameworks/` directory.

## Adapter mapping

`WTHamsterRimeSessionProtocol` remains the only UI-facing engine contract.

| V14 adapter operation | Hamster/RimeKit mapping |
| --- | --- |
| composition | `getInputKeys()` and/or `context()` preedit |
| candidates | `candidateList()` or paged `candidateListWithIndex` |
| process key | `inputKey(_:)` / `inputKeyCode` |
| drain commit | `getCommitText()` |
| select candidate | `selectCandidate(index:)` plus commit drain |
| reset composition | `cleanComposition()` |
| schema change | `setSchema(_:)` |
| ASCII/English | `asciiMode(_:)` |
| simplified/traditional | `setSimplifiedChineseMode(key:value:)` |

## Gate before claiming Phase 3 complete

Phase 3 is not complete merely because this adapter-smoke build is green. The production gate requires all of the following:

1. Pin and obtain a reproducible iOS librime/RimeKit binary dependency.
2. Verify dependency license and SHA-256 before CI use.
3. Add a concrete session wrapper around the pinned public Rime API.
4. Bundle/deploy a legal public Rime schema and dictionaries; do not use Tencent private dictionaries/models/services.
5. Pass key -> composition -> candidates -> select -> commit -> delete -> space/return -> reset on device.
6. Pass candidate paging and mode switching for T26, T9, double pinyin, Wubi, stroke, Chinese/English, simplified/traditional and fuzzy-pinyin cases.
7. Keep Keyboard memory pressure within an extension-safe budget and repeat the ClawBase dual-profile signed IPA regression.

Until those gates pass, CI/artifacts must describe this slice as `Phase 3 adapter-smoke`, not `real librime complete`.
