#!/usr/bin/env python3
"""Apply deterministic Phase 13 clean-room release refinements before the final Xcode build.

This intentionally changes only independently implemented replica source. It does not import
private Tencent assets, binaries, models, fonts, endpoints, or code.
"""
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        if new in text:
            return
        raise RuntimeError(f"expected source pattern not found in {path.relative_to(ROOT)}: {old[:120]!r}")
    if text.count(old) != 1:
        raise RuntimeError(f"source pattern is not unique in {path.relative_to(ROOT)}: {old[:120]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def patch_keyboard() -> None:
    path = ROOT / "iOSOverlay/WTKeyboardCanvasView.swift"
    replace_once(
        path,
        '    private var styleValues: [String: String] { WTStyleCatalog353.values(for: item.style) }\n',
        '    private var styleValues: [String: String] { WTStyleCatalog353.values(for: item.style) }\n'
        '    private let gestureCalibration = WT353GestureCalibration()\n',
    )
    replace_once(
        path,
        '            LongPressGesture(minimumDuration: 0.36, maximumDistance: 14)\n',
        '            LongPressGesture(\n'
        '                minimumDuration: gestureCalibration.longPressDuration,\n'
        '                maximumDistance: CGFloat(gestureCalibration.longPressMaximumDistance)\n'
        '            )\n',
    )
    replace_once(
        path,
        '''                let dx = value.translation.width\n                let dy = value.translation.height\n                if abs(dy) > abs(dx), dy < -18 {\n                    runtime.handle(item, gesture: .swipeUp)\n                } else if abs(dy) > abs(dx), dy > 18 {\n                    runtime.handle(item, gesture: .swipeDown)\n                } else {\n                    runtime.handle(item, gesture: .tap)\n                }\n''',
        '''                switch WT353GestureModel.directionalGesture(\n                    dx: Double(value.translation.width),\n                    dy: Double(value.translation.height),\n                    calibration: gestureCalibration\n                ) {\n                case .swipeUp:\n                    runtime.handle(item, gesture: .swipeUp)\n                case .swipeDown:\n                    runtime.handle(item, gesture: .swipeDown)\n                case .tap:\n                    runtime.handle(item, gesture: .tap)\n                }\n''',
    )
    replace_once(
        path,
        '''        let delta = Int((value.translation.width / 33).rounded())\n        let index = min(max(longPressGlideOriginIndex + delta, 0), popup.items.count - 1)\n''',
        '''        let index = WT353GestureModel.longPressIndex(\n            origin: longPressGlideOriginIndex,\n            translationX: Double(value.translation.width),\n            itemCount: popup.items.count,\n            calibration: gestureCalibration\n        )\n''',
    )
    replace_once(
        path,
        '        let clear = dy < -28 && abs(dy) > abs(dx) * 0.72\n',
        '''        let clear = WT353GestureModel.deleteClearIsArmed(\n            dx: Double(dx),\n            dy: Double(dy),\n            calibration: gestureCalibration\n        )\n''',
    )
    replace_once(
        path,
        '''        let targetSteps: Int\n        if dx < -10, abs(dx) >= abs(dy) {\n            targetSteps = min(24, max(0, Int((-dx - 10) / 22) + 1))\n        } else if abs(dx) >= abs(dy) {\n            targetSteps = 0\n        } else {\n            targetSteps = deleteDeletedSteps\n        }\n''',
        '''        let targetSteps = WT353GestureModel.deleteTargetSteps(\n            dx: Double(dx),\n            dy: Double(dy),\n            currentSteps: deleteDeletedSteps,\n            calibration: gestureCalibration\n        )\n''',
    )
    replace_once(
        path,
        '        let shouldClear = deleteClearArmed || (dy < -28 && abs(dy) > abs(dx) * 0.72)\n',
        '''        let shouldClear = deleteClearArmed || WT353GestureModel.deleteClearIsArmed(\n            dx: Double(dx),\n            dy: Double(dy),\n            calibration: gestureCalibration\n        )\n''',
    )
    replace_once(
        path,
        '''        } else if !deleteGestureDidMutate && deleteDeletedSteps == 0 && abs(dx) < 10 && abs(dy) < 10 {\n            runtime.performKeyFeedback(true)\n            runtime.handle(item, gesture: .tap)\n        }\n''',
        '''        } else if WT353GestureModel.isTapDelete(\n            dx: Double(dx),\n            dy: Double(dy),\n            mutated: deleteGestureDidMutate,\n            deletedSteps: deleteDeletedSteps,\n            calibration: gestureCalibration\n        ) {\n            runtime.performKeyFeedback(true)\n            runtime.handle(item, gesture: .tap)\n        }\n''',
    )
    replace_once(
        path,
        '            try? await Task.sleep(nanoseconds: 110_000_000)\n',
        '            try? await Task.sleep(nanoseconds: UInt64(max(0, gestureCalibration.deleteRepeatInitialDelay) * 1_000_000_000))\n',
    )
    replace_once(
        path,
        '                try? await Task.sleep(nanoseconds: 78_000_000)\n',
        '                try? await Task.sleep(nanoseconds: UInt64(max(0, gestureCalibration.deleteRepeatInterval) * 1_000_000_000))\n',
    )


def patch_host_local_actions() -> None:
    path = ROOT / "iOSApp/WTSettingsAppView.swift"
    replace_once(path, 'import SwiftUI\nimport Foundation\n', 'import SwiftUI\nimport Foundation\nimport UIKit\n')
    replace_once(path, '            Section { Button("恢复默认") {} }\n', '            Section { Button("恢复默认") { resetKeyboardAdjustment() } }\n')
    replace_once(path, '            Section { Button("打开系统设置") {} }\n', '            Section { Button("打开系统设置") { openSystemSettings() } }\n')
    replace_once(
        path,
        '                HStack { Text("版本"); Spacer(); Text("3.5.3 replica").foregroundStyle(.secondary) }\n',
        '                HStack { Text("版本"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "3.5.3").foregroundStyle(.secondary) }\n',
    )
    replace_once(
        path,
        '    private var sharedTransferDefaults: UserDefaults {\n',
        '''    private func resetKeyboardAdjustment() {\n        let defaults = sharedSettingsDefaults\n        defaults.set(1.0, forKey: "wt.rect.width")\n        defaults.set(1.0, forKey: "wt.rect.height")\n        defaults.set(0.0, forKey: "wt.rect.x")\n        defaults.set(0.0, forKey: "wt.rect.y")\n    }\n\n    private func openSystemSettings() {\n        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }\n        UIApplication.shared.open(url, options: [:], completionHandler: nil)\n    }\n\n    private var sharedTransferDefaults: UserDefaults {\n''',
    )


def main() -> None:
    patch_keyboard()
    patch_host_local_actions()
    print("Phase 13 release source patch: PASS")


if __name__ == "__main__":
    main()
