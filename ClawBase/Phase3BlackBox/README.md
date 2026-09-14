# Phase 3 black-box parity corpus

`Tools/phase3_blackbox_matrix.py` deterministically defines at least 120 input/action cases spanning:

- 26-key full Pinyin
- 9-key/T9 Pinyin
- natural-code double Pinyin
- Wubi86 plus an explicit Wubi98 schema-selection stimulus
- stroke input
- candidate paging and selection
- backspace/delete, space, return and reset
- simplified/traditional behavior
- fuzzy-Pinyin planning
- user-dictionary learning

The current matrix contains 122 cases after adding explicit Wubi86/Wubi98 selection coverage.

The WeChat reference side is intentionally **not fabricated**. A case is not considered matched until a real-device observation from the reference WeChat input method is recorded in `observations.json` and compared with the CLAW result. CI validates corpus shape and coverage, while reference parity remains pending until those observations are captured.
