#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

CODE_RE = re.compile(r"^[a-z]+$")
MIN_ENTRIES = 10000


def fail(message: str) -> None:
    raise SystemExit(f"Wubi98 dictionary generation failed: {message}")


def main() -> int:
    if len(sys.argv) != 3:
        fail("usage: generate_wubi98_dict.py <source-table> <output-dir>")

    source = Path(sys.argv[1])
    output_dir = Path(sys.argv[2])
    if not source.is_file():
        fail(f"source table does not exist: {source}")

    rows: list[tuple[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for line_number, raw in enumerate(source.read_text(encoding="utf-8-sig").splitlines(), start=1):
        line = raw.strip("\r\n")
        if not line or line.startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) != 2:
            fail(f"line {line_number} must contain exactly text<TAB>code")
        text, code = (field.strip() for field in fields)
        if not text:
            fail(f"line {line_number} has empty text")
        if not CODE_RE.fullmatch(code):
            fail(f"line {line_number} has invalid code: {code!r}")
        row = (text, code)
        if row in seen:
            continue
        seen.add(row)
        rows.append(row)

    if len(rows) < MIN_ENTRIES:
        fail(f"only {len(rows)} unique entries; expected at least {MIN_ENTRIES}")

    output_dir.mkdir(parents=True, exist_ok=True)
    target = output_dir / "claw_wubi98.dict.yaml"
    header = [
        "# Generated deterministically from yanhuacuo/98wubi-tables.",
        "# Source revision and license are recorded in CLAW_PHASE3_PROVENANCE.txt.",
        "---",
        "name: claw_wubi98",
        'version: "2026.09.14"',
        "sort: original",
        "use_preset_vocabulary: true",
        "columns:",
        "  - text",
        "  - code",
        "...",
        "",
    ]
    body = [f"{text}\t{code}" for text, code in rows]
    target.write_text("\n".join(header + body) + "\n", encoding="utf-8", newline="\n")
    print(f"Wubi98 dictionary: PASS ({len(rows)} unique entries -> {target})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
