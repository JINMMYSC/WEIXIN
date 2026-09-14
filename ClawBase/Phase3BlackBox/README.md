# Phase 3 WeChat black-box comparison matrix

This directory defines the Phase 3 comparison contract. The test stimuli are public, generic input sequences only; they do not contain Tencent/WeChat dictionaries or private data.

`Tools/phase3_blackbox_matrix.py` deterministically defines at least 120 cases across full Pinyin, T9 Pinyin, natural-code double Pinyin, Wubi86, stroke, and cross-cutting actions such as paging, selection, backspace, space, return, reset, simplified/traditional options, fuzzy-Pinyin planning, and user-dictionary learning.

The WeChat side is intentionally **not fabricated**. A case is not considered matched until a real observation has been captured from the reference WeChat input method and recorded in an observations file. CI verifies the matrix shape and coverage, but it must not turn missing reference observations into PASS results.

Suggested observation record shape:

```json
{
  "case_id": "pinyin26-001",
  "reference": "wechat-ime",
  "composition": "nihao",
  "candidates": ["你好"],
  "commit": "你好",
  "notes": "captured on device"
}
```

The final Phase 3 parity gate requires all required observations to come from real black-box runs and then be compared against CLAW TALK/librime results.
