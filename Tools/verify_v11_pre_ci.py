#!/usr/bin/env python3
from pathlib import Path
import re, sys, subprocess, plistlib

ROOT = Path(__file__).resolve().parents[1]
errors=[]

# 1. Minimum deployment target must match the original 3.5.3 baseline.
project=(ROOT/'XcodeIntegration/project.yml').read_text(encoding='utf-8')
config=(ROOT/'XcodeIntegration/Config.xcconfig').read_text(encoding='utf-8')
package=(ROOT/'Package.swift').read_text(encoding='utf-8')
if 'IPHONEOS_DEPLOYMENT_TARGET: 15.1' not in project:
    errors.append('project.yml global deployment target is not 15.1')
if 'deploymentTarget: "16.0"' not in project:
    errors.append('share deployment target 16.0 missing')
if 'deploymentTarget: "16.1"' not in project:
    errors.append('voice activity deployment target 16.1 missing')
if 'deploymentTarget: "17.0"' not in project:
    errors.append('widget deployment target 17.0 missing')
if 'IPHONEOS_DEPLOYMENT_TARGET = 15.1' not in config:
    errors.append('Config.xcconfig deployment target is not 15.1')
if 'platforms: [.iOS(.v15)]' not in package:
    errors.append('Swift Package iOS platform is not v15')

# 2. APIs intentionally removed/backported for iOS 15.1.
forbidden = {
    'NavigationStack': 'use NavigationView for iOS 15.1',
    '.navigationDestination(': 'use destination-based NavigationLink',
    'LabeledContent(': 'use WTLabeledValueRow',
    '.symbolEffect(': 'use custom iOS 15 animation',
    '.scrollContentBackground(': 'iOS 16-only TextEditor modifier',
}
shipping_roots=['iOSApp','iOSOverlay','iOSExtensions','iOSServices','iOSShared']
for base in shipping_roots:
    for path in (ROOT/base).rglob('*.swift'):
        text=path.read_text(encoding='utf-8')
        for token,reason in forbidden.items():
            if token in text:
                errors.append(f'{path.relative_to(ROOT)} contains {token}: {reason}')

# 3. XcodeGen source roots/files must exist.
for rel in re.findall(r'- path: \.\./([^\n]+)', project):
    rel=rel.strip()
    target=ROOT/rel
    if not target.exists():
        errors.append(f'XcodeGen source path missing: {rel}')
for rel in re.findall(r'path: (Plists/[^\n]+|Entitlements/[^\n]+)', project):
    target=ROOT/'XcodeIntegration'/rel.strip()
    if not target.exists():
        errors.append(f'Xcode integration file missing: {rel}')

# 4. App/keyboard must expose same App Group setting token.
for name in ['App-Info.plist','Keyboard-Info.plist']:
    p=ROOT/'XcodeIntegration/Plists'/name
    obj=plistlib.loads(p.read_bytes())
    if obj.get('WTAppGroupIdentifier') != '$(WT_APP_GROUP_ID)':
        errors.append(f'{name} missing WTAppGroupIdentifier build setting')

# 5. Shared settings keys used by the keyboard need to live in the core catalog.
prefs=(ROOT/'Sources/WeTypeReplicaCore/SharedPreferences.swift').read_text(encoding='utf-8')
for key in ['wt.feedback.sound','wt.feedback.haptic','wt.onehand.mode','wt.display.fontScale','wt.rect.width','wt.rect.height','wt.cloud.enabled','wt.voice.enabled','wt.clipboard.enabled','wt.toolbar.enabled']:
    if key not in prefs:
        errors.append(f'shared preference key not catalogued: {key}')

# 6. Release controller must make the missing production engine explicit; debug may use preview engine.
controller=(ROOT/'iOSExtensions/WTKeyboardInputViewController.swift').read_text(encoding='utf-8')
if 'WTPreviewIMEEngine()' not in controller or '#if DEBUG' not in controller:
    errors.append('debug preview engine fallback missing')
if 'return nil' not in controller:
    errors.append('release engine boundary is not explicit')

if errors:
    print('V11 PRE-CI FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('V11 PRE-CI PASS')
print('- iOS 15.1 deployment/backport scan passed')
print('- XcodeGen source/plist/entitlement path scan passed')
print('- App Group shared-settings contract scan passed')
print('- debug preview/release Hamster boundary scan passed')
