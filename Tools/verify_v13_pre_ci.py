#!/usr/bin/env python3
from pathlib import Path
import subprocess, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]

def text(rel):
    p=ROOT/rel
    if not p.exists():
        errors.append(f'missing {rel}')
        return ''
    return p.read_text(encoding='utf-8', errors='ignore')

r=subprocess.run([sys.executable, str(ROOT/'Tools/verify_v12_pre_ci.py')], cwd=ROOT, capture_output=True, text=True)
if r.returncode != 0:
    errors.append('V12 pre-CI verifier regressed: '+(r.stdout+r.stderr).strip())

# Candidate paging must exist end-to-end from core contract through Hamster bridge and SwiftUI.
ime=text('Sources/WeTypeReplicaCore/IMEEngine.swift')
bridge=text('HamsterBridge/WTHamsterRimeSessionAdapter.swift')
binding=text('HamsterBridge/WTKeyboardOverlayBinding.swift')
runtime=text('iOSOverlay/WTKeyboardRuntime.swift')
bar=text('iOSOverlay/WTCandidateBar.swift')
for token in ['WTCandidatePageDirection', 'WTCandidatePageState', 'moveCandidatePage']:
    if token not in ime: errors.append(f'IME paging missing {token}')
for token in ['wtCandidatePageState', 'wtMoveCandidatePage']:
    if token not in bridge: errors.append(f'Hamster paging bridge missing {token}')
for token in ['runtime.candidatePageState = context.candidatePage', 'runtime.moveCandidatePage']:
    if token not in binding: errors.append(f'overlay paging binding missing {token}')
for token in ['candidatePageState', 'changeCandidatePage']:
    if token not in runtime: errors.append(f'runtime paging missing {token}')
for token in ['changeCandidatePage(.previous)', 'changeCandidatePage(.next)']:
    if token not in bar: errors.append(f'candidate bar paging control missing {token}')

# Low-memory persistence/restoration must never persist composition/transient panels.
session=text('Sources/WeTypeReplicaCore/KeyboardSessionPersistence.swift')
service=text('iOSServices/WTKeyboardServiceBinder.swift')
controller=text('iOSExtensions/WTKeyboardInputViewController.swift')
for token in ['WTKeyboardSessionSnapshot', 'restoredState()', 'panel: .keyboard']:
    if token not in session: errors.append(f'session persistence missing {token}')
for token in ['restoreSessionState()', 'persistSessionState', 'WTKeyboardSessionPersistence.defaultsKey']:
    if token not in service: errors.append(f'service binder session restore missing {token}')
for token in ['didReceiveMemoryWarning', 'prepareForMemoryPressure', 'persistSessionState']:
    if token not in controller: errors.append(f'keyboard memory handling missing {token}')

# Share transfer has deterministic retry/cancel state and task cancellation hooks.
batch=text('Sources/WeTypeReplicaCore/TransferBatch.swift')
share=text('iOSExtensions/WTQuickSendShareViewController.swift')
shareview=text('iOSExtensions/WTQuickSendShareView.swift')
transfer=text('iOSServices/WTBonjourTransferService.swift')
for token in ['WTTransferBatch', 'retryFailed()', 'cancel()', 'overallProgress']:
    if token not in batch: errors.append(f'transfer batch missing {token}')
for token in ['sendTask?.cancel()', 'retryLastPeer()', 'cancelSending()', 'canRetry']:
    if token not in share: errors.append(f'share retry/cancel missing {token}')
for token in ['onRetry', 'Button("重试"', 'isSending ? "停止" : "取消"']:
    if token not in shareview: errors.append(f'share retry UI missing {token}')
if transfer.count('Task.checkCancellation()') < 3:
    errors.append('transfer service missing cancellation checkpoints')

if errors:
    print('V13 PRE-CI FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('V13 PRE-CI PASS')
print('- inherited V12 gates passed')
print('- candidate pagination contract/UI path passed')
print('- low-memory session restore contract passed')
print('- share retry/cancel state machine and cancellation checkpoints passed')
