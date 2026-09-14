#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import plistlib
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "ReverseEngineering/Phase7/original-353-contract.json"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def expect(actual, expected, label: str) -> None:
    if actual != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual!r}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("ipa", type=Path, help="Path to the untouched WeChat IME 3.5.3 IPA")
    args = parser.parse_args()

    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    ipa = args.ipa
    expect(sha256_bytes(ipa.read_bytes()), contract["ipa_sha256"], "IPA SHA-256")
    expect(ipa.stat().st_size, contract["ipa_size"], "IPA size")

    with tempfile.TemporaryDirectory() as temp_dir:
        with zipfile.ZipFile(ipa) as archive:
            archive.extractall(temp_dir)
        payload = Path(temp_dir) / "Payload"
        apps = list(payload.glob("*.app"))
        expect(len(apps), 1, "host app count")
        app = apps[0]

        with (app / "Info.plist").open("rb") as handle:
            host = plistlib.load(handle)
        host_contract = contract["host"]
        expect(host.get("CFBundleIdentifier"), host_contract["bundle_id"], "host bundle id")
        expect(host.get("CFBundleShortVersionString"), host_contract["short_version"], "host short version")
        expect(host.get("CFBundleVersion"), host_contract["build"], "host build")
        expect(host.get("MinimumOSVersion"), host_contract["minimum_os"], "host minimum OS")

        for name, extension_contract in contract["extensions"].items():
            with (app / "PlugIns" / name / "Info.plist").open("rb") as handle:
                info = plistlib.load(handle)
            extension = info.get("NSExtension", {})
            expect(info.get("CFBundleIdentifier"), extension_contract["bundle_id"], f"{name} bundle id")
            expect(info.get("CFBundleShortVersionString"), extension_contract["short_version"], f"{name} short version")
            expect(info.get("CFBundleVersion"), extension_contract["build"], f"{name} build")
            expect(info.get("MinimumOSVersion"), extension_contract["minimum_os"], f"{name} minimum OS")
            expect(extension.get("NSExtensionPointIdentifier"), extension_contract["extension_point"], f"{name} extension point")
            if "principal_class" in extension_contract:
                expect(extension.get("NSExtensionPrincipalClass"), extension_contract["principal_class"], f"{name} principal class")
            if "display_name" in extension_contract:
                expect(info.get("CFBundleDisplayName"), extension_contract["display_name"], f"{name} display name")
            if "activation_rule" in extension_contract:
                expect(extension.get("NSExtensionAttributes", {}).get("NSExtensionActivationRule"), extension_contract["activation_rule"], f"{name} activation rule")
            if "supports_live_activities" in extension_contract:
                expect(info.get("NSSupportsLiveActivities"), extension_contract["supports_live_activities"], f"{name} live activity flag")
            if "attributes" in extension_contract:
                expect(extension.get("NSExtensionAttributes", {}), extension_contract["attributes"], f"{name} attributes")
            if "app_group_key" in extension_contract and extension_contract["app_group_key"] not in info:
                raise AssertionError(f"{name}: missing {extension_contract['app_group_key']}")

        keyboard = app / "PlugIns" / "wxkb_plugin.appex"
        for name, file_contract in contract["keyboard_layout_files"].items():
            data = (keyboard / name).read_bytes()
            expect(len(data), file_contract["size"], f"{name} size")
            expect(sha256_bytes(data), file_contract["sha256"], f"{name} SHA-256")

    print("WECHAT 3.5.3 ORIGINAL IPA CONTRACT: PASS")
    print(
        f"Verified IPA SHA-256 plus {len(contract['extensions'])} extensions "
        f"and {len(contract['keyboard_layout_files'])} layout/style files"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, OSError, KeyError, ValueError, zipfile.BadZipFile) as exc:
        print(f"WECHAT 3.5.3 ORIGINAL IPA CONTRACT: FAIL: {exc}")
        raise SystemExit(1)
