#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    source = (ROOT / "Sources/WeTypeReplicaCore/KeyInteraction.swift").read_text(encoding="utf-8")
    generated = (ROOT / "Sources/WeTypeReplicaCore/GeneratedLayoutsV3.swift").read_text(encoding="utf-8")

    # Preserve the extracted 3.5.3 raw layout as evidence; compatibility belongs in the resolver.
    require('name: "t9_stroke"' in generated, "extracted t9_stroke layout missing")
    require('input: "PQRS"' in generated, "expected extracted KEY_7 placeholder changed")
    require('input: "null"' in generated, "expected extracted KEY_9 sentinel changed")

    # Public rime-stroke contract: h/s/p/n/z = horizontal/vertical/left-falling/dot/fold.
    expected = {
        'case "KEY_1": return .engineInput("h")': "horizontal",
        'case "KEY_2": return .engineInput("s")': "vertical",
        'case "KEY_3": return .engineInput("p")': "left-falling",
        'case "KEY_4": return .engineInput("n")': "dot/right-falling",
        'case "KEY_5": return .engineInput("z")': "fold",
    }
    for token, meaning in expected.items():
        require(token in source, f"stroke mapping missing: {meaning}")

    require('case "KEY_6": return .none' in source,
            "wildcard must fail closed until the public backend has an audited wildcard contract")
    require('case "KEY_7", "KEY_9": return .none' in source,
            "migration placeholders must never reach librime")
    require('state.inputMode == .stroke, item.id == "KEY_7" || item.id == "KEY_9"' in source,
            "placeholder keys must render blank")
    require('if s.caseInsensitiveCompare("null") == .orderedSame { return "" }' in source,
            "literal null sentinel must never be rendered/committed")

    print("Phase 3 stroke compatibility gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 stroke compatibility gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
