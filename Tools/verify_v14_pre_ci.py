#!/usr/bin/env python3
from pathlib import Path
import subprocess, sys
from extract_phase14_reference_frames import load_manifest, validate_manifest

ROOT=Path(__file__).resolve().parents[1]
errors=[]

def text(rel):
    p=ROOT/rel
    if not p.exists():
        errors.append(f'missing {rel}')
        return ''
    return p.read_text(errors='ignore')

r=subprocess.run([sys.executable, str(ROOT/'Tools/verify_v13_pre_ci.py')], cwd=ROOT, capture_output=True, text=True)
if r.returncode != 0:
    errors.append('V13 pre-CI verifier regressed: '+(r.stdout+r.stderr).strip())

trusted=text('Sources/WeTypeReplicaCore/TransferTrustedDevices.swift')
service=text('iOSServices/WTKeyboardServiceBinder.swift')
network=text('iOSServices/WTBonjourTransferService.swift')
panel=text('iOSOverlay/WTDeviceSyncPanelView.swift')
for token in ['WTTrustedTransferDevice', 'WTTrustedTransferRegistry', 'recordSuccessfulTransfer', 'revoke(id:']:
    if token not in trusted: errors.append(f'trusted-device registry missing {token}')
for token in ['transferTrustedDevices', 'recordTrustedTransferPeer', 'persistTrustedTransferRegistry']:
    if token not in service and token not in text('Sources/WeTypeReplicaCore/SharedPreferences.swift'):
        errors.append(f'trusted-device persistence missing {token}')
if 'onAuthenticatedPeer?(peer)' not in network: errors.append('transfer success does not update authenticated peer history')
if 'trustedTransferDevices' not in panel or 'revokeTrustedTransferDevice' not in panel: errors.append('device UI missing trusted-device management')

batch=text('Sources/WeTypeReplicaCore/TransferBatch.swift')
share=text('iOSExtensions/WTQuickSendShareViewController.swift')
for token in ['retryableFailedIndexes', 'hasRetryableFailure', 'retryFailed(maxAttempts:']:
    if token not in batch: errors.append(f'retry-cap model missing {token}')
for token in ['maxTransferAttempts = 3', 'hasRetryableFailure(maxAttempts: maxTransferAttempts)', '已达重试上限']:
    if token not in share: errors.append(f'share retry cap missing {token}')

memory=text('Sources/WeTypeReplicaCore/MemoryPressurePolicy.swift')
runtime=text('iOSOverlay/WTKeyboardRuntime.swift')
for token in ['WTKeyboardMemoryPressureBudget', 'trimmedClipboard']:
    if token not in memory: errors.append(f'memory budget missing {token}')
if 'releaseTransientCaches(budget:' not in runtime: errors.append('runtime memory-pressure budget not wired')

profile=text('Sources/WeTypeReplicaCore/InputModeBackendProfile.swift')
bridge=text('HamsterBridge/WTHamsterRimeSessionAdapter.swift')
for token in ['WTRimeModeDescriptor', 'WTRimeBackendProfile', 'safeDefault']:
    if token not in profile: errors.append(f'Rime backend profile missing {token}')
for token in ['wtApplyModeDescriptor', 'backendProfile']:
    if token not in bridge: errors.append(f'Hamster descriptor bridge missing {token}')

reference_manifest_ok = False
try:
    reference_manifest = load_manifest(ROOT / 'ReverseEngineering/Phase14/reference_capture_manifest.json')
    manifest_errors = validate_manifest(reference_manifest)
    if manifest_errors:
        errors.extend(f'Phase14 reference manifest: {error}' for error in manifest_errors)
    elif len(reference_manifest.get('captures', [])) != 10:
        errors.append('Phase14 reference manifest: expected 10 captures')
    else:
        reference_manifest_ok = True
except (OSError, ValueError) as exc:
    errors.append(f'Phase14 reference manifest: {exc}')

if errors:
    print('V14 PRE-CI FAIL')
    for e in errors: print('-',e)
    if reference_manifest_ok:
        print('- Phase14 manifest subcheck passed: 10 captures')
    sys.exit(1)
print('V14 PRE-CI PASS')
print('- inherited V13 gates passed')
print('- trusted-device history/persistence UI path passed')
print('- bounded Share retry behavior passed')
print('- low-memory presentation budget passed')
print('- configurable Rime mode descriptor bridge passed')
print('- Phase14 manifest subcheck passed: 10 captures')
