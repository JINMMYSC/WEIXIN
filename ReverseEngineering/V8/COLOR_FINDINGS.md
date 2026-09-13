# WeType 3.5.3 color findings (V8)

`WBColor.json` in the host app exposes the shared light/dark palette used by WeType 3.5.3. Important pairs:

| token | light | dark |
|---|---|---|
| highlight | `#DFDFDF` | `#FFFFFF0D` |
| color00 | `#000000FF` | `#FFFFFFFF` |
| color01 | `#000000E6` | `#FFFFFFE6` |
| color06 | `#00000066` | `#FFFFFF66` |
| color09 | `#0000001A` | `#FFFFFF1A` |
| color10 | `#0000000D` | `#FFFFFF0D` |
| color11 | `#FFFFFFFF` | `#000000FF` |
| color12 | `#FCFCFEFF` | `#5F5F5FFF` |
| color13 | `#B7BCC4FF` | `#4C4C4CFF` |
| brand | `#23C891FF` | `#23C891FF` |
| color15 | `#F2F2F2FF` | `#050505FF` |

The keyboard extension's `style.ini` remains the source of truth for individual key cap normal/pressed/border/shadow colors. V8 now uses the extracted light/dark pairs rather than iOS generic system colors for the overlay chrome, and uses `style.ini` pairs for key caps.
