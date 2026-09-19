"""Guard against unbalanced Swift sources that only a macOS toolchain would catch.

The Phase 14 work is edited on a Windows host without a Swift compiler, and a stray
closing brace already reached CI once. This check strips comments and single-line string
literals, skips files that use multi-line or raw string literals, and asserts that the
remaining braces, parentheses and brackets balance.
"""
from pathlib import Path
from unittest import TestCase

ROOT = Path(__file__).resolve().parents[2]
SOURCE_ROOTS = [
    "Sources/WeTypeReplicaCore",
    "iOSOverlay",
    "iOSApp",
    "iOSShared",
    "ClawBase",
    "iOSExtensions",
    "iOSServices",
    "HamsterBridge",
    "Tests/WeTypeReplicaCoreTests",
]


def strip_comments_and_strings(text: str) -> str:
    out: list[str] = []
    index = 0
    length = len(text)
    while index < length:
        char = text[index]
        if char == '"':
            index += 1
            while index < length and text[index] != '"':
                if text[index] == "\\":
                    index += 1
                index += 1
            index += 1
            continue
        if char == "/" and index + 1 < length and text[index + 1] == "/":
            while index < length and text[index] != "\n":
                index += 1
            continue
        if char == "/" and index + 1 < length and text[index + 1] == "*":
            index += 2
            while index + 1 < length and not (text[index] == "*" and text[index + 1] == "/"):
                index += 1
            index += 2
            continue
        out.append(char)
        index += 1
    return "".join(out)


def swift_sources() -> list[Path]:
    files: list[Path] = []
    for root in SOURCE_ROOTS:
        files.extend(sorted((ROOT / root).rglob("*.swift")))
    return files


class SwiftSourceBalanceTests(TestCase):
    def test_shipping_swift_sources_balance(self):
        self.assertTrue(swift_sources(), "no Swift sources were discovered")
        problems = []
        for path in swift_sources():
            raw = path.read_text(encoding="utf-8", errors="replace")
            if '"""' in raw or '#"' in raw:
                continue
            code = strip_comments_and_strings(raw)
            delta = {
                "braces": code.count("{") - code.count("}"),
                "parentheses": code.count("(") - code.count(")"),
                "brackets": code.count("[") - code.count("]"),
            }
            if any(delta.values()):
                problems.append(f"{path.relative_to(ROOT)}: {delta}")
        self.assertEqual(problems, [], "unbalanced Swift sources: " + "; ".join(problems))
