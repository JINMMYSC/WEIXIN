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
    setup_main_path = ROOT / "iOSApp/WTHostHome353View.swift"
    require(setup_main_path.is_file(), "observed 3.5.3 SetupMain renderer is missing")
    setup_main = setup_main_path.read_text(encoding="utf-8")

    for path in (
        "../iOSApp/WTSettingsAppView.swift",
        "../iOSApp/WTHostSettings353View.swift",
        "../iOSApp/WTHostHome353View.swift",
        "../iOSApp/WTDisplaySettings353View.swift",
        "../iOSShared/WTSemanticGlyph.swift",
        "../Sources/WeTypeReplicaCore",
    ):
        require(path in project, f"Host target lost required source: {path}")

    require("UIHostingController(rootView: WTHostHome353View())" in scene,
            "ClawBase Host root must use the observed Phase14 two-column home")
    require("WTSettingsDetailView(destination: destination)" in setup_main,
            "Phase14 home must remain wired to V14 detail settings controls")
    require("WTAppGroupIdentifier" in info and "$(WT_APP_GROUP_ID)" in info,
            "Host Info.plist must expose the shared App Group identifier")

    for token in (
        'Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier")',
        'UserDefaults(suiteName: group)',
        'private var sharedSettingsDefaults: UserDefaults { sharedTransferDefaults }',
        'let defaults = sharedSettingsDefaults',
    ):
        require(token in settings, f"Host App Group settings bridge missing: {token}")

    # Phase 3 detail controls must remain reachable behind the observed 3.5.3 SetupMain root
    # and use the exact preference keys consumed by the Release keyboard session.
    for token in (
        'case .pinyin:', 'case .fuzzyPinyin:', 'case .doublePinyin:', 'case .wubi:', 'case .stroke:',
        '"wt.pinyin.blur"', '"wt.fuzzy.z_zh"', '"wt.fuzzy.c_ch"', '"wt.fuzzy.s_sh"',
        '"wt.fuzzy.n_l"', '"wt.fuzzy.f_h"', '"wt.fuzzy.an_ang"', '"wt.fuzzy.en_eng"', '"wt.fuzzy.in_ing"',
        '"wt.double.scheme"',
        'stringStorage("wt.wubi.scheme", "86 版")', 'Text("98 版").tag("98 版")',
        'appStorage("wt.wubi.mix", defaultValue: true)',
        'appStorage("wt.stroke.wildcard", defaultValue: true)',
    ):
        require(token in settings, f"Host Phase 3 setting missing: {token}")

    print("Phase 3 Host settings surface gate: PASS (Phase14 shipping home + App Group + V14 detail controls)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 Host settings surface gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
