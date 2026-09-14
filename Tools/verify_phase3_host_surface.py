#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    project = (ROOT / "ClawBase/project.yml").read_text(encoding="utf-8")
    scene = (ROOT / "ClawBase/Host/SceneDelegate.swift").read_text(encoding="utf-8")
    info = (ROOT / "ClawBase/Host/Info.plist").read_text(encoding="utf-8")
    settings = (ROOT / "iOSApp/WTSettingsAppView.swift").read_text(encoding="utf-8")

    for path in (
        "../iOSApp/WTSettingsAppView.swift",
        "../iOSShared/WTSemanticGlyph.swift",
        "../Sources/WeTypeReplicaCore",
    ):
        require(path in project, f"Host target lost required V14 source: {path}")

    require("UIHostingController(rootView: WTSettingsAppView())" in scene,
            "ClawBase Host root must be the real V14 settings surface")
    require("WTAppGroupIdentifier" in info and "$(WT_APP_GROUP_ID)" in info,
            "Host Info.plist must expose the shared App Group identifier")

    # Phase 3 settings must be user reachable from the Host surface.
    for token in (
        'case .pinyin:', 'case .fuzzyPinyin:', 'case .doublePinyin:', 'case .wubi:', 'case .stroke:',
        '"wt.pinyin.blur"', '"wt.fuzzy.z_zh"', '"wt.fuzzy.c_ch"', '"wt.fuzzy.s_sh"',
        '"wt.fuzzy.n_l"', '"wt.fuzzy.f_h"', '"wt.fuzzy.an_ang"', '"wt.fuzzy.en_eng"', '"wt.fuzzy.in_ing"',
        '"wt.double.scheme"', '"wt.wubi.mix"',
    ):
        require(token in settings, f"Host Phase 3 setting missing: {token}")

    print("Phase 3 Host settings surface gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 Host settings surface gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
