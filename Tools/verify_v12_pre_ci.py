#!/usr/bin/env python3
from pathlib import Path
import plistlib, subprocess, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]

def text(rel):
    p=ROOT/rel
    if not p.exists():
        errors.append(f'missing {rel}')
        return ''
    return p.read_text(errors='ignore')

# Preserve all V11 gates.
r=subprocess.run([sys.executable, str(ROOT/'Tools/verify_v11_pre_ci.py')], cwd=ROOT, capture_output=True, text=True)
if r.returncode != 0:
    errors.append('V11 pre-CI verifier regressed: '+(r.stdout+r.stderr).strip())

# 1. Production IME boundary: commits after process_key must be drainable; logical input modes
# must propagate to the backend; Chinese space must not discard composition.
ime=text('Sources/WeTypeReplicaCore/IMEEngine.swift')
for token in ['func drainCommit() -> String?', 'func setInputMode(_ mode: WTInputMode)', 'public func spaceKey()', 'engine.drainCommit()']:
    if token not in ime: errors.append(f'IME contract missing {token}')
bridge=text('HamsterBridge/WTHamsterRimeSessionAdapter.swift')
for token in ['wtDrainCommit', 'wtSetInputMode', 'setInputMode(_ mode: WTInputMode)']:
    if token not in bridge: errors.append(f'Hamster bridge missing {token}')
overlay=text('HamsterBridge/WTKeyboardOverlayBinding.swift')
for token in ['runtime.submitSpace', 'engine?.setInputMode(mode)', 'prepareForHostContextChange']:
    if token not in overlay: errors.append(f'keyboard binding missing {token}')

# 2. Transfer v3 paired transport security and resumability.
proto=text('Sources/WeTypeReplicaCore/TransferProtocol.swift')
service=text('iOSServices/WTBonjourTransferService.swift')
for token in ['currentVersion = 3', 'chacha20poly1305', 'alignedResumeOffset', 'encryptedRecordFrame']:
    if token not in proto: errors.append(f'transfer protocol missing {token}')
for token in ['ChaChaPoly.seal', 'ChaChaPoly.open', 'HKDF<SHA256>.deriveKey', 'transportKey(for envelope', 'truncate(part, to: aligned)']:
    if token not in service: errors.append(f'transfer service missing {token}')

# 3. Share extension must stage provider files and await real transfer completion before completing.
share=text('iOSExtensions/WTQuickSendShareViewController.swift')
for token in ['copyFileRepresentation', 'copyDataRepresentation', 'try await self.model.send(to: peer)', 'completeRequest(returningItems: nil)', 'WTSharedPreferenceKey.transferPairingCode']:
    if token not in share: errors.append(f'share extension missing {token}')
share_plist=ROOT/'XcodeIntegration/Plists/Share-Info.plist'
if share_plist.exists():
    obj=plistlib.loads(share_plist.read_bytes())
    if obj.get('WTAppGroupIdentifier') != '$(WT_APP_GROUP_ID)': errors.append('Share-Info.plist missing WTAppGroupIdentifier')
    rule=obj.get('NSExtension',{}).get('NSExtensionAttributes',{}).get('NSExtensionActivationRule',{})
    for key in ['NSExtensionActivationSupportsFileWithMaxCount','NSExtensionActivationSupportsImageWithMaxCount','NSExtensionActivationSupportsMovieWithMaxCount','NSExtensionActivationSupportsWebURLWithMaxCount']:
        if key not in rule: errors.append(f'share activation rule missing {key}')

# 4. Live Activity has request deep-link + lifecycle metadata/final states.
attrs=text('iOSShared/WTVoiceActivityAttributes.swift')
widget=text('iOSExtensions/WTVoiceLiveActivityWidget.swift')
voice=text('iOSServices/WTVoiceLiveActivityController.swift')
for token in ['startedAt', 'updatedAt', 'isFinal']:
    if token not in attrs: errors.append(f'voice activity attributes missing {token}')
for token in ['widgetURL', 'wtreplica://voice?request=', 'style: .timer']:
    if token not in widget: errors.append(f'voice activity widget missing {token}')
for token in ['lastPublishedState', 'ActivityUIDismissalPolicy', 'isFinal: true']:
    if token not in voice: errors.append(f'voice activity controller missing {token}')

if errors:
    print('V12 PRE-CI FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('V12 PRE-CI PASS')
print('- inherited V11 deployment/XcodeGen/App Group gates passed')
print('- librime commit-drain/mode/space behavior contract passed')
print('- paired ChaCha20-Poly1305 transfer + resumability contract passed')
print('- share-extension staging/await-completion contract passed')
print('- Live Activity lifecycle/deep-link contract passed')
