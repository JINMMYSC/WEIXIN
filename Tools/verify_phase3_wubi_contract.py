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
    host = (ROOT / "iOSApp/WTSettingsAppView.swift").read_text(encoding="utf-8")
    schema98_path = ROOT / "ClawBase/RimeSchemas/claw_wubi98.schema.yaml"
    generator_path = ROOT / "ClawBase/RimeSchemas/generate_wubi98_dict.py"

    for token in (
        'private static let wubiSchemeKey = "wt.wubi.scheme"',
        'private static let wubiMixKey = "wt.wubi.mix"',
        '- schema: claw_wubi98',
        'if mode == .wubi, baseSchemaID == "wubi86"',
        'preferences?.string(forKey: Self.wubiSchemeKey) == "98 版"',
        'return "claw_wubi98"',
        'if !simplifiedChinese { return "wubi_trad" }',
        'return mixed ? "wubi_pinyin" : "wubi86"',
        'bridge.setOption("zh_trad", value: !simplifiedChinese)',
        '["wubi_pinyin", "wubi_trad", "wubi86"]',
    ):
        require(token in session, f"Wubi runtime contract missing: {token}")

    for token in (
        'stringStorage("wt.wubi.scheme", "86 版")',
        'Text("86 版").tag("86 版")',
        'Text("98 版").tag("98 版")',
        'appStorage("wt.wubi.mix", defaultValue: true)',
    ):
        require(token in host, f"Host Wubi settings contract missing: {token}")

    for resource in (
        "wubi86.schema.yaml",
        "wubi86.dict.yaml",
        "wubi_pinyin.schema.yaml",
        "wubi_trad.schema.yaml",
        "claw_wubi98.schema.yaml",
        "claw_wubi98.dict.yaml",
    ):
        require(resource in prepare, f"pinned Wubi resource not required by CI: {resource}")

    require('RIME_WUBI_REPOSITORY="https://github.com/rime/rime-wubi.git"' in prepare,
            "Wubi86 must remain pinned to the public rime/rime-wubi source")
    require('RIME_WUBI_COMMIT="152a0d3f3efe40cae216d1e3b338242446848d07"' in prepare,
            "Wubi86 public revision drifted")
    require('WUBI98_REPOSITORY="https://github.com/yanhuacuo/98wubi-tables.git"' in prepare,
            "Wubi98 must use the audited public-domain source")
    require('WUBI98_COMMIT="6b8b6fb9d3c34e0d5e3b17211e1f1c100e7eb697"' in prepare,
            "Wubi98 public-domain revision drifted")
    require('WUBI98_TABLE="98五笔含词表-【单义】.txt"' in prepare,
            "Wubi98 source table drifted")
    require('grep -qi "public domain" "$WUBI98_DIR/LICENSE"' in prepare,
            "Wubi98 license audit gate missing")
    require('generate_wubi98_dict.py' in prepare,
            "Wubi98 deterministic dictionary generation missing")
    require('wubi98-license=Unlicense-public-domain' in prepare,
            "Wubi98 provenance must record public-domain license")

    require(schema98_path.is_file(), "claw_wubi98.schema.yaml missing")
    schema98 = schema98_path.read_text(encoding="utf-8")
    for token in (
        "schema_id: claw_wubi98",
        "dictionary: claw_wubi98",
        "option_name: zh_trad",
        "opencc_config: s2t.json",
        "encode_commit_history: true",
    ):
        require(token in schema98, f"Wubi98 schema contract missing: {token}")

    require(generator_path.is_file(), "Wubi98 generator missing")
    generator = generator_path.read_text(encoding="utf-8")
    for token in (
        'encoding="utf-8-sig"',
        'line.split("\\t")',
        'name: claw_wubi98',
        'columns:',
        'MIN_ENTRIES = 10000',
    ):
        require(token in generator, f"Wubi98 generator contract missing: {token}")

    print("Phase 3 Wubi contract: PASS (86/98 + Host routing + provenance)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 Wubi contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
