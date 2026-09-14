#!/usr/bin/env python3
"""Deterministic Phase 3 black-box stimulus matrix.

The matrix defines inputs/actions only. It never invents WeChat expected output.
Reference observations are a separate real-device capture artifact.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
import json
from typing import Iterable


@dataclass(frozen=True)
class BlackBoxCase:
    case_id: str
    mode: str
    input: str
    actions: tuple[str, ...]
    focus: str
    reference_required: bool = True


PINYIN_CORPUS = (
    "nihao", "zhongguo", "shurufa", "weixin", "changcheng",
    "gugong", "sichoulu", "beijing", "shanghai", "guangzhou",
    "shenzhen", "xuexi", "lishi", "dili", "wenhua",
    "tianqi", "jintian", "mingtian", "pengyou", "gongzuo",
)

# Natural-code double-Pinyin stimuli. Expected reference results are deliberately absent.
DOUBLE_PINYIN_CORPUS = (
    "ni", "hk", "vsgo", "uurufa", "wwxb",
    "ihig", "gugs", "siizl", "bwjy", "uhhl",
    "gsvz", "ufvf", "xtxi", "liui", "dili",
    "wfxx", "tmqi", "jbth", "mktm", "pgpz",
)

WUBI_CORPUS = (
    "wgkq", "lwwy", "ttgy", "qyi", "gcfb",
    "ynky", "ipkh", "fghg", "dwwf", "ukqk",
    "wy", "ggtt", "nnh", "ahty", "kkhk",
    "wqiy", "ftj", "jgh", "xwy", "qajf",
)

STROKE_CORPUS = (
    "h", "s", "p", "n", "z",
    "hs", "hp", "hn", "hz", "hsp",
    "hsn", "hsz", "hspn", "hspz", "hspnz",
    "psn", "pzz", "nhs", "zhs", "spnz",
)


def t9_digits(pinyin: str) -> str:
    groups = {
        **{c: "2" for c in "abc"},
        **{c: "3" for c in "def"},
        **{c: "4" for c in "ghi"},
        **{c: "5" for c in "jkl"},
        **{c: "6" for c in "mno"},
        **{c: "7" for c in "pqrs"},
        **{c: "8" for c in "tuv"},
        **{c: "9" for c in "wxyz"},
    }
    return "".join(groups[c] for c in pinyin.lower() if c in groups)


def corpus_cases(prefix: str, mode: str, corpus: Iterable[str], *, t9: bool = False) -> list[BlackBoxCase]:
    result: list[BlackBoxCase] = []
    for index, raw in enumerate(corpus, start=1):
        value = t9_digits(raw) if t9 else raw
        result.append(
            BlackBoxCase(
                case_id=f"{prefix}-{index:03d}",
                mode=mode,
                input=value,
                actions=("type", "inspect_composition", "inspect_candidates", "select_0", "inspect_commit"),
                focus="composition_candidates_select_commit",
            )
        )
    return result


def behavior_cases() -> list[BlackBoxCase]:
    specs = (
        ("behavior-001", "chinesePinyin26", "nihao", ("type", "backspace", "inspect_composition"), "backspace"),
        ("behavior-002", "chinesePinyin26", "zhongguo", ("type", "page_next", "page_previous"), "paging"),
        ("behavior-003", "chinesePinyin26", "nihao", ("type", "space", "inspect_commit"), "space_commit"),
        ("behavior-004", "chinesePinyin26", "nihao", ("type", "return", "inspect_commit"), "return_commit"),
        ("behavior-005", "chinesePinyin26", "nihao", ("type", "reset", "inspect_composition"), "reset"),
        ("behavior-006", "chinesePinyin9", t9_digits("nihao"), ("type", "backspace", "inspect_candidates"), "t9_backspace"),
        ("behavior-007", "chinesePinyin9", t9_digits("zhongguo"), ("type", "page_next", "select_0"), "t9_paging"),
        ("behavior-008", "chinesePinyin9", t9_digits("shurufa"), ("type", "space", "inspect_commit"), "t9_space_commit"),
        ("behavior-009", "doublePinyin", "ni", ("type", "backspace", "type", "select_0"), "double_pinyin_edit"),
        ("behavior-010", "doublePinyin", "vsgo", ("type", "page_next", "page_previous"), "double_pinyin_paging"),
        ("behavior-011", "wubi", "wgkq", ("type", "backspace", "inspect_candidates"), "wubi_edit"),
        ("behavior-012", "wubi", "lwwy", ("type", "space", "inspect_commit"), "wubi_space_commit"),
        ("behavior-013", "stroke", "hspnz", ("type", "backspace", "inspect_composition"), "stroke_edit"),
        ("behavior-014", "stroke", "hs", ("type", "select_0", "inspect_commit"), "stroke_select"),
        ("behavior-015", "english26", "hello", ("type", "inspect_commit"), "english_ascii"),
        ("behavior-016", "chinesePinyin26", "hanguo", ("set_simplified", "type", "inspect_candidates"), "simplified"),
        ("behavior-017", "chinesePinyin26", "hanguo", ("set_traditional", "type", "inspect_candidates"), "traditional"),
        ("behavior-018", "chinesePinyin26", "zongguo", ("enable_fuzzy_zh_z", "type", "inspect_candidates"), "fuzzy_zh_z"),
        ("behavior-019", "chinesePinyin26", "lan", ("enable_fuzzy_l_n", "type", "inspect_candidates"), "fuzzy_l_n"),
        ("behavior-020", "chinesePinyin26", "clawtalk", ("learn_user_phrase", "reset", "type", "inspect_candidates"), "user_dictionary"),
    )
    return [BlackBoxCase(*spec) for spec in specs]


def build_cases() -> list[BlackBoxCase]:
    cases: list[BlackBoxCase] = []
    cases += corpus_cases("pinyin26", "chinesePinyin26", PINYIN_CORPUS)
    cases += corpus_cases("pinyin9", "chinesePinyin9", PINYIN_CORPUS, t9=True)
    cases += corpus_cases("double", "doublePinyin", DOUBLE_PINYIN_CORPUS)
    cases += corpus_cases("wubi", "wubi", WUBI_CORPUS)
    cases += corpus_cases("stroke", "stroke", STROKE_CORPUS)
    cases += behavior_cases()
    return cases


def export_json() -> str:
    return json.dumps({"cases": [asdict(case) for case in build_cases()]}, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    print(export_json())
