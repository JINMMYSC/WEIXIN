# Phase 14 visual evidence

Phase 14 compares same-device captures from WeChat Input 3.5.3 and WeTypeReplica on iPhone 15 Pro Max.

Each selected scene uses this artifact tree:

```text
Phase6Evidence/01-keyboard26-light/
  REF-01-keyboard26-light.png
  REP-01-keyboard26-light.png
  overlay.png
  absolute_difference.png
  rgba_difference.png
  metrics.json
  review.json
```

Apply the same naming rule to scenes `02`, `04`, `06`, `07`, `08`, `10`, `14`, `23`, and `27`.

AssistiveTouch rectangles from `reference_capture_manifest.json` are exclusion masks only. They must never cover keyboard or Host UI pixels.

`review.json` is fail-closed: missing REF, REP, metrics, or a canonical strict reference produces `incomplete`. A complete comparison starts at `needs-review`; tooling never marks a scene `pass` automatically.

Scene `01` remains geometry-only because the current source capture is English 26-key. It is not eligible for strict Chinese 26-key review until a canonical Chinese frame is supplied.

## Measured keyboard geometry (iPhone 15 Pro Max, 430 x 932 pt)

The light-mode keyboard geometry below was measured directly from the supplied 3.5.3
recordings. Source frames are 1290 x 2796 px, so 3 px equals 1 pt. Every value repeated
across recordings 1, 5, 6, 7 and 8, and the tool that produced them is
`Tools/measure_reference_keyboard.py`.

### Panel split

| Region | Measured | Notes |
|---|---:|---|
| Keyboard surface | y 561..932 (371 pt) | `#DDDEE2` appears only while a keyboard panel is shown |
| Header above the key area | 72.33 pt | carries the toolbar row or the candidate row |
| Canvas | 298.67 pt | key rows plus the bottom bar |
| Key rows | 224 pt | four rows of 46 pt design height |
| Bottom bar | 74.67 pt | language switch on the left, voice input on the right |

### 26-key rows

Rows start at canvas y 5, 61, 117 and 173 (screen y 638.33, 694.33, 750.33, 806.33) and
measure 45.33 pt tall, so the row pitch is 56 pt.

| Row | Keys | Origin | Key width |
|---|---|---:|---:|
| QWERTY | 10 | 5 pt | 36 pt, 42.667 pt pitch |
| ASDF | 9 | 26.33 pt (centred) | 36 pt, 42.667 pt pitch |
| ZXCV | shift 48.33 pt + 7 keys + delete 48.33 pt | 69.33 pt | 36 pt, 42.667 pt pitch |
| Bottom | 5 | 5, 90.67, 133, 294, 340 pt | 79.33, 36, 154.33, 39.67, 85.33 pt |

The bottom row uses the same ~6.33 pt gaps as the letter rows. An earlier revision of
`Phase14VisualContract.swift` carried 74.7 / 31.3 / 149 / 34.3 / 80 pt with equal
12.675 pt gaps; direct measurement of eleven frames across three recordings contradicts
that, and the measured frames are now the contract.

### Nine-key rows

Rows start at canvas y 3, 59, 115 and 171 (screen y 636.33, 692.33, 748.33, 804.33) and
measure 49.33 pt tall. The layout is a 72 pt gutter on each side of three 83.67 pt
columns at x 83.33, 173.33 and 263.67, with the trailing gutter at x 353.33. The space
variant of the bottom row measures 72 / 49.33 / 152 / 49.33 / 72 pt.

### Bottom bar

Below the key rows every keyboard panel draws a language indicator and a voice control.
The measured frames are 27 x 26.67 pt at x 29, y 877 and 18.67 x 28.33 pt at x 378,
y 876.67. The emoji panel widens the left item to x 21..56, which is why the band is
treated as keyboard chrome rather than host content.

## Known remaining gaps

These were measured at the same time but are not yet implemented:

- The header still renders a 58 pt product button and 42 pt scroll items. The reference
  draws 32 x 32 pt items on a 48 pt pitch, the first at x 13 and the remainder
  right-aligned to x 417.
- The reference candidate row occupies panel-relative y 26..63; the replica centres its
  header content inside the 72.33 pt header instead.
- Nine-key punctuation keys in the reference align to the 56 pt row pitch from canvas
  y 3; the replica still places them on a 40.5 pt pitch.
- Reference key caps are 45.33 pt tall for the 26-key rows; the replica keeps the
  extracted 46 pt design height.
