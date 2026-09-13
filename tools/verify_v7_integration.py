#!/usr/bin/env python3
from pathlib import Path
import json, sys, yaml
root=Path(__file__).resolve().parents[1]
required=[
 'Sources/WeTypeReplicaCore/ProviderModels.swift',
 'Sources/WeTypeReplicaCore/ServiceMailbox.swift',
 'Sources/WeTypeReplicaCore/GeneratedIconGeometry353.swift',
 'HamsterBridge/WTCloudCandidateBinding.swift',
 'iOSServices/WTHTTPProviderServices.swift',
 'iOSServices/WTKeyboardServiceBinder.swift',
 'iOSServices/WTHostSpeechRecognitionService.swift',
 'iOSApp/WTHostVoiceCaptureView.swift',
 '.github/workflows/ios-build.yml',
 'XcodeIntegration/validate_on_mac.sh',
 'ReverseEngineering/V7/icon_geometry.json'
]
missing=[x for x in required if not (root/x).exists()]
if missing:
    print('missing:', missing); sys.exit(1)
data=json.loads((root/'ReverseEngineering/V7/icon_geometry.json').read_text())
assert data['count'] >= 180
project=yaml.safe_load((root/'XcodeIntegration/project.yml').read_text())
assert {'WeTypeReplicaApp','WeTypeReplicaKeyboard','WeTypeReplicaShare','WeTypeReplicaWidget'} <= set(project['targets'])
print(f"V7 integration OK; measured icon families={data['count']}")
