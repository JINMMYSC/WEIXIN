#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    session = (ROOT / "ClawBase/Keyboard/WTLibrimeRimeSession.swift").read_text(encoding="utf-8")
    prepare = (ROOT / "ClawBase/ci_prepare_librimekit.sh").read_text(encoding="utf-8")

    for token in (
        'private static let wubiMixKey = "wt.wubi.mix"',
        'if mode == .wubi, baseSchemaID == "wubi86"',
        'if !simplifiedChinese { return "wubi_trad" }',
        'return mixed ? "wubi_pinyin" : "wubi86"',
        'bridge.setOption("zh_trad", value: !simplifiedChinese)',
        '["wubi_pinyin", "wubi_trad", "wubi86"]',
    ):
        require(token in session, f"Wubi runtime contract missing: {token}")

    for resource in ("wubi86.schema.yaml", "wubi86.dict.yaml", "wubi_pinyin.schema.yaml", "wubi_trad.schema.yaml"):
        require(resource in prepare, f"pinned Wubi resource not required by CI: {resource}")

    require('RIME_WUBI_REPOSITORY="https://github.com/rime/rime-wubi.git"' in prepare,
            "Wubi must remain pinned to the public rime/rime-wubi source")
    require('RIME_WUBI_COMMIT="152a0d3f3efe40cae216d1e3b338242446848d07"' in prepare,
            "Wubi public revision drifted")

    print("Phase 3 Wubi contract: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 Wubi contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
