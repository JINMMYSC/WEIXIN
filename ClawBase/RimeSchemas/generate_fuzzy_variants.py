#!/usr/bin/env python3
"""Generate deterministic public-Rime fuzzy-pinyin schema variants.

The base CLAW full-pinyin schema stays strict.  These variants add only the
fuzzy pairs Phase 3 exposes at runtime, so toggling a fuzzy option never
silently changes the strict schema.
"""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
OUT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT
OUT.mkdir(parents=True, exist_ok=True)
BASE = (ROOT / "claw_pinyin26.schema.yaml").read_text(encoding="utf-8")

ZH_Z = (
    "    - derive/^zh/z/\n"
    "    - derive/^z/zh/\n"
    "    - derive/^ch/c/\n"
    "    - derive/^c/ch/\n"
    "    - derive/^sh/s/\n"
    "    - derive/^s/sh/\n"
)
L_N = (
    "    - derive/^n/l/\n"
    "    - derive/^l/n/\n"
)


def write_variant(schema_id: str, name: str, rules: str) -> None:
    text = BASE.replace("schema_id: claw_pinyin26", f"schema_id: {schema_id}", 1)
    text = text.replace("name: CLAW 全拼", f"name: {name}", 1)
    marker = "\ntranslator:\n"
    if marker not in text:
        raise SystemExit("generator error: translator marker missing from claw_pinyin26 schema")
    text = text.replace(marker, "\n" + rules + marker.lstrip("\n"), 1)
    (OUT / f"{schema_id}.schema.yaml").write_text(text, encoding="utf-8")


write_variant("claw_pinyin26_fuzzy_zhz", "CLAW 全拼·翘舌模糊", ZH_Z)
write_variant("claw_pinyin26_fuzzy_ln", "CLAW 全拼·L/N 模糊", L_N)
write_variant("claw_pinyin26_fuzzy_all", "CLAW 全拼·模糊音", ZH_Z + L_N)
