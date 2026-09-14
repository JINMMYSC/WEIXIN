#!/usr/bin/env python3
"""Generate deterministic public-Rime fuzzy-pinyin schema variants.

The base CLAW full-pinyin schema stays strict.  Variants are generated for every
combination exposed by the Phase 3 settings surface so one toggle never silently
enables another fuzzy pair.
"""
from __future__ import annotations

from itertools import combinations
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
OUT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT
OUT.mkdir(parents=True, exist_ok=True)
BASE = (ROOT / "claw_pinyin26.schema.yaml").read_text(encoding="utf-8")

RULES = {
    "retroflex": (
        "    - derive/^zh/z/\n"
        "    - derive/^z/zh/\n"
        "    - derive/^ch/c/\n"
        "    - derive/^c/ch/\n"
        "    - derive/^sh/s/\n"
        "    - derive/^s/sh/\n"
    ),
    "nl": (
        "    - derive/^n/l/\n"
        "    - derive/^l/n/\n"
    ),
    "fh": (
        "    - derive/^f/h/\n"
        "    - derive/^h/f/\n"
    ),
    "anang": (
        "    - derive/an$/ang/\n"
        "    - derive/ang$/an/\n"
    ),
    "eneng": (
        "    - derive/en$/eng/\n"
        "    - derive/eng$/en/\n"
    ),
    "ining": (
        "    - derive/in$/ing/\n"
        "    - derive/ing$/in/\n"
    ),
}
ORDER = tuple(RULES)


def schema_id(keys: tuple[str, ...]) -> str:
    return "claw_pinyin26_fuzzy_" + "_".join(keys)


def write_variant(keys: tuple[str, ...]) -> None:
    sid = schema_id(keys)
    name = "CLAW 全拼·模糊音·" + "+".join(keys)
    rules = "".join(RULES[key] for key in keys)
    text = BASE.replace("schema_id: claw_pinyin26", f"schema_id: {sid}", 1)
    text = text.replace("name: CLAW 全拼", f"name: {name}", 1)
    marker = "\ntranslator:\n"
    if marker not in text:
        raise SystemExit("generator error: translator marker missing from claw_pinyin26 schema")
    text = text.replace(marker, "\n" + rules + marker.lstrip("\n"), 1)
    (OUT / f"{sid}.schema.yaml").write_text(text, encoding="utf-8")


for count in range(1, len(ORDER) + 1):
    for keys in combinations(ORDER, count):
        write_variant(keys)

# Stable compatibility aliases used by earlier Phase 3 builds and tests.
ALIASES = {
    "claw_pinyin26_fuzzy_zhz": ("retroflex",),
    "claw_pinyin26_fuzzy_ln": ("nl",),
    "claw_pinyin26_fuzzy_all": ORDER,
}
for alias, keys in ALIASES.items():
    source = (OUT / f"{schema_id(keys)}.schema.yaml").read_text(encoding="utf-8")
    source = source.replace(f"schema_id: {schema_id(keys)}", f"schema_id: {alias}", 1)
    (OUT / f"{alias}.schema.yaml").write_text(source, encoding="utf-8")
