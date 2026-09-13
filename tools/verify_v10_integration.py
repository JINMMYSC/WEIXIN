#!/usr/bin/env python3
from pathlib import Path
import json, re, sys
root=Path(__file__).resolve().parents[1]
errors=[]

def need(path):
    p=root/path
    if not p.exists(): errors.append(f'missing {path}')
    return p

need(Path('Sources/WeTypeReplicaCore/GeneratedHostSetupGeometry353.swift'))
need(Path('Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift'))
need(Path('Sources/WeTypeReplicaCore/IMECompatibilityProfile.swift'))
need(Path('Tools/build_ime_compatibility_profile.py'))
need(Path('ReverseEngineering/V10/host_setup_geometry_353.json'))
need(Path('ReverseEngineering/V10/visual_capture_manifest_v10.json'))

geom_path=root/'ReverseEngineering/V10/host_setup_geometry_353.json'
if geom_path.exists():
    d=json.load(open(geom_path,encoding='utf-8'))
    expected={'SetupAuxiliaryInput','SetupClipboard','SetupDesktop','SetupDisplaySetting','SetupFuzzyPinyin','SetupKeyboardSelect','SetupKeystrokeEffect','SetupMain','SetupMigrationAssistant','SetupPlus','SetupSp','SetupWb'}
    if set(d.get('screens',{}))!=expected:
        errors.append('host setup screen inventory mismatch')
    if d.get('recordCount',0)<300:
        errors.append('expected >=300 measured setup asset variants')

settings=need(Path('iOSApp/WTSettingsAppView.swift'))
if settings.exists():
    text=settings.read_text(errors='ignore')
    for token in ['fuzzyPinyin','auxiliaryInput','displaySetting','keystrokeEffect','desktop','migrationAssistant','featureBannerStrip']:
        if token not in text: errors.append(f'settings missing {token}')

bridge=need(Path('HamsterBridge/WTKeyboardOverlayBinding.swift'))
if bridge.exists():
    text=bridge.read_text(errors='ignore')
    for token in ['compatibilityProfile','candidatePreferenceStore','displayedLocal']:
        if token not in text: errors.append(f'bridge missing {token}')

manifest=root/'ReverseEngineering/V10/visual_capture_manifest_v10.json'
if manifest.exists():
    d=json.load(open(manifest,encoding='utf-8'))
    if len(d.get('cases',[]))<75: errors.append('visual capture manifest too small')
    surfaces={x.get('surface') for x in d.get('cases',[])}
    for s in ['settingsDisplay','settingsFuzzyPinyin','settingsMigration','settingsDesktop']:
        if s not in surfaces: errors.append(f'missing visual surface {s}')

if errors:
    print('V10 integration verification FAILED')
    for e in errors: print('-',e)
    sys.exit(1)
print('PASS: V10 host-app parity + IME compatibility integration checks passed')
