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
    home = (ROOT / "iOSApp/WTHostHomeParityView.swift").read_text(encoding="utf-8")

    for path in (
        "../iOSApp/WTSettingsAppView.swift",
        "../iOSApp/WTHostHomeParityView.swift",
        "../iOSShared/WTSemanticGlyph.swift",
        "../Sources/WeTypeReplicaCore",
    ):
        require(path in project, f"Host target lost required V14 source: {path}")

    require("UIHostingController(rootView: WTHostHomeParityView())" in scene,
            "ClawBase Host root must use the measured 3.5.3 parity home")
    require("WTSettingsDetailView(destination:" in home,
            "Measured Host home must keep the real Phase 3 settings destinations reachable")
    require("WTAppGroupIdentifier" in info and "$(WT_APP_GROUP_ID)" in info,
            "Host Info.plist must expose the shared App Group identifier")

    # Device-reference geometry from the supplied 430pt-wide WeType 3.5.3 captures.
    for token in (
        '.padding(.horizontal, 20)',
        'GridItem(.flexible(), spacing: 14)',
        '.frame(height: compact ? 94 : 134',
        'Color(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0)',
        'Color(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0)',
        'Color(red: 35.0/255.0, green: 200.0/255.0, blue: 145.0/255.0)',
        'Text("微信输入法")',
        'Text("简洁、好用、打字快")',
        'Text("设置")',
        'Text("更多")',
        'Text("隔空传送")',
        'title: "关联其他设备"',
        'title: "传给其他人"',
    ):
        require(token in home, f"Measured Host home/reference contract missing: {token}")

    for token in (
        'Bundle.main.object(forInfoDictionaryKey: "WTAppGroupIdentifier")',
        'UserDefaults(suiteName: group)',
        'private var sharedSettingsDefaults: UserDefaults { sharedTransferDefaults }',
        'let defaults = sharedSettingsDefaults',
    ):
        require(token in settings, f"Host App Group settings bridge missing: {token}")

    # Phase 3 settings remain implemented by the existing V14 detail surface and must stay
    # reachable from the new measured home rather than being duplicated or replaced.
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

    print("Phase 3 Host settings surface gate: PASS (measured home + App Group + Phase 3 controls)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 Host settings surface gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
