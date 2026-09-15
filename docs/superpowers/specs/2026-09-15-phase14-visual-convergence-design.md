# Phase 14 Visual Convergence Design

## Objective

Make the first ten high-information light-mode scenes on iPhone 15 Pro Max running iOS 26.2.1 visually converge toward WeChat Input 3.5.3, while turning the supplied original recordings into reproducible evidence. The selected scenes are `01`, `02`, `04`, `06`, `07`, `08`, `10`, `14`, `23`, and `27`.

This phase does not claim 79-scene parity. It establishes the measurement and rendering foundation required to reach it.

## Scope

### Included

- Extract stable original reference frames for the ten selected scene IDs.
- Record the exact frame source, timestamp, device pixel dimensions, and scene state in machine-readable metadata.
- Add deterministic geometry and palette assertions for the common keyboard surfaces.
- Correct the 26-key bottom-row composition after validating the runtime layout rules.
- Refine shared light keyboard colors, key geometry, shadows, labels, and toolbar geometry.
- Rebuild the Host App home screen as the observed mint background with a two-column card grid.
- Reproduce the Display Settings screen used by scene `27` with explicit rows, spacing, and typography instead of relying on default `Form` rendering.
- Preserve all existing extension lifecycle, signing, App Group, input-engine, and packaging behavior.
- Produce a signed Host + Keyboard IPA through the existing GitHub Actions path after static and Core checks pass.

### Excluded

- Dark-mode scenes `35–68` until original dark references are supplied.
- One-handed, secure-field, Spotlight, landscape, share-extension, and voice-widget work.
- Network-backed AI, translation, device-transfer, or account behavior beyond deterministic visual states.
- Replacing the input engine or changing keyboard-extension architecture.
- Declaring strict 79/79 completion.

## Reference Truth

- Original visual truth is the user's 19 unmodified HEVC recordings at 1290 x 2796 pixels.
- Target logical viewport is 430 x 932 points at 3x scale.
- Repository source truth is `JINMMYSC/WEIXIN`, branch `work/v14-phase13-static-delta`.
- The phase starts from commit `a78f7f42c970442ec200ee800b7317bc837c0811` unless the branch advances before implementation; if it advances, implementation rebases conceptually on the new branch head and records the actual parent.
- Reference screenshots remain unmodified. AssistiveTouch and recording indicators are marked as excluded comparison regions, not painted out of the source.

## Measured Visual Contract

### Shared keyboard surfaces

- Light keyboard background baseline: `#DDDEE2`.
- Normal key surface baseline: `#FFFFFF`.
- Gray function-key baseline: `#AFB4BD`.
- Brand accent starting baseline: `#1FC085`; feature-specific measurements may override it when a clean crop proves a different source color.
- Key shadows must remain subtle and must be asserted by sampled pixels outside the key body, not approximated from the resource declaration alone.

### Nine-key geometry

- Center key target width: 83.7 pt.
- Center key target height: 49.3 pt.
- Horizontal and vertical gaps: 6.3–6.7 pt.
- Left and right function columns: approximately 72 pt.
- Existing nine-key geometry is retained unless paired replica evidence shows an error above 1.5 pt.

### Twenty-six-key bottom row

The reference target is approximately:

- `123`: 74.7 pt.
- punctuation: 31.3 pt.
- space: 149.0 pt.
- language switch: 34.3 pt.
- return: 80.0 pt.

Runtime state may hide or merge resource keys. The implementation must first test the resolved bottom-row frames rather than changing only `t26_pinyin.json`. The final rendered row, not the raw JSON, is the contract.

### Host App

- Home background baseline: `#E2F1F0`.
- Home structure: brand header followed by a two-column grid of white cards.
- Cards use consistent widths, approximately 20 pt outer margins, approximately 14 pt inter-column spacing, and approximately 16 pt corner radii.
- Cards contain a dedicated leading icon area, title, secondary description, and navigation affordance matching the recording.
- Scene `27` uses a purpose-built Display Settings page. Native controls may be used internally, but row heights, separators, typography, section spacing, and background must be explicitly controlled.

## Architecture

### Reference evidence layer

Add a manifest for the ten selected scenes. Each entry records the original video filename, exact timestamp, expected state, image dimensions, exclusion masks, and measured anchors. A deterministic extraction script uses this manifest to regenerate reference PNGs without hand selection.

Reference PNGs and generated difference images are CI artifacts. They are not compiled into the application bundle. Small JSON measurement fixtures may live in the repository so tests can consume them.

### Rendering contract layer

Introduce focused value types for resolved keyboard frames and palette tokens in `WeTypeReplicaCore`. Layout resolution tests operate on these types without requiring UIKit or an iOS simulator. The keyboard extension consumes the same resolved values.

The 26-key bottom row receives a named resolver that maps semantic keys to final frames for a 430 pt viewport. This isolates state-dependent hiding and expansion from the raw extracted resource file.

### Host presentation layer

The Host App home screen uses dedicated card models and focused SwiftUI components rather than a generic single-column settings builder. The Display Settings screen is a separate view with explicit visual constants. Navigation continues through the existing settings destinations so behavior and deep links remain stable.

## Data Flow

1. The reference manifest selects a timestamp from an original MP4.
2. The extraction tool writes the canonical `REF` PNG plus metadata.
3. Core tests load measurement fixtures and validate resolved geometry and palette tokens.
4. The Host App and keyboard extension render from the tested values.
5. A device capture produces the matching `REP` PNG.
6. The comparison tool applies the same crop and exclusion masks, then emits overlay, absolute-difference image, and review JSON.
7. A scene is eligible to pass only when both images exist and the review record contains no unresolved structural mismatch.

## Error Handling

- Extraction fails if a video is missing, a timestamp is outside the media duration, or the output is not 1290 x 2796.
- Manifest validation fails on duplicate IDs, missing required fields, or unknown comparison masks.
- Layout tests fail when resolved keys overlap, leave the viewport, violate ordering, or exceed the measured tolerance.
- Visual comparison reports excluded pixels separately so the AssistiveTouch mask cannot hide application regressions.
- CI never reports a scene as passed when either `REF`, `REP`, diff, or review JSON is absent.

## Testing Strategy

### Core tests

- Verify 430 pt bottom-row frame widths and ordering.
- Verify the row fills the usable width without overlap.
- Verify nine-key geometry remains within the retained tolerance.
- Verify palette constants serialize to the expected RGB values.
- Verify reference manifest IDs and media metadata.

### Static checks

- Ensure both Host and Keyboard targets consume the canonical tokens instead of duplicating color literals.
- Ensure the Host home exposes stable accessibility identifiers for every visible card.
- Ensure no signing identity, provisioning profile, token, or user recording path is committed.

### CI and device checks

- Run Swift Package Core tests.
- Generate the Xcode project and compile all required targets.
- Build and package the signed Host + Keyboard IPA through the existing workflow.
- Install on the target device and capture the ten matching `REP` scenes.
- Generate paired overlays and difference reports before any visual-completion claim.

## Delivery Sequence

1. Reference manifest, extraction workflow, and validation tests.
2. Core palette and geometry contracts.
3. 26-key bottom-row resolver and keyboard rendering update.
4. Shared light keyboard visual refinements used by the selected scenes.
5. Host home two-column card implementation.
6. Purpose-built Display Settings screen.
7. Full CI build, signed IPA, device capture checklist, and first ten paired reviews.

Each step is independently testable and committed separately. No later step may weaken the strict evidence gate to obtain a green result.

## Acceptance Criteria

- The ten selected original target frames are reproducibly extractable from a committed manifest.
- The 26-key bottom row at 430 pt matches the measured semantic widths and order within 1.5 pt per edge.
- The nine-key geometry does not regress beyond 1.5 pt per edge.
- Shared light palette tokens match the measured starting values exactly in Core tests.
- Host home renders a two-column card grid on the target viewport and has no generic `List` or single-column fallback in the selected route.
- Scene `27` renders through the dedicated Display Settings view.
- Core tests, static checks, all required Xcode targets, packaging, and signed IPA production succeed.
- The phase is reported as partial visual convergence until ten paired `REF`/`REP` reviews exist; it never claims 79/79 completion.

