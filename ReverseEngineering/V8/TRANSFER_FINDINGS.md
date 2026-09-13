# WeType 3.5.3 transfer/device-sync findings (V8)

Static Objective-C metadata from the user-supplied 3.5.3 keyboard binary confirms that the shipping transfer feature is materially richer than a simple Bonjour file copy.

## Product/backend model evidence

Classes include:

- `WBDeviceSyncInfo`, `WBDeviceSyncManager`, `WBFileTransferInviteStayToolBarButton`
- `GetBoundDeviceListReq/Rsp`
- `GetP2PDispatchReq/Rsp`, `P2PPeerInfo`
- `GenP2PTransferCodeReq/Rsp`, `P2PTransferSession`
- `JoinP2PTransferReq/Rsp`, `GetP2PTransferPeerReq/Rsp`, `InitP2PTransferReq/Rsp`
- `NotifyFastTransferPermissionReq/Rsp`, `PushP2PTransferInvite`, `P2PTransferControlEnvelope`

Selectors/ivars include `currentTransferCode`, `generateDeviceCode`, `didReceiveFileTransferInvite:`, `hasPendingTransferInvite`, `GetFileMD5:`, `expectedMD5`, `enableMD5Verification`, `taskChecksum`, `contentSHA1`, authentication policy/type/state, `secureConnectTookTime`, and URL-session resume callbacks.

## What V8 now matches clean-room

- visible pairing/device code state in keyboard and host settings;
- nearby-device discovery;
- streaming instead of loading a whole file into extension memory;
- resumable `.part` receives;
- SHA-256 end-to-end integrity verification;
- optional pairing-code HMAC authentication;
- final sender acknowledgement and progress state;
- received-file status surfaced into keyboard runtime.

## What is still intentionally different

The original appears to use Tencent-owned bound-device/P2P dispatch APIs and transfer-code sessions. V8 uses a self-owned LAN provider. The current transport is plain TCP plus HMAC authentication; it does **not** yet provide transport encryption/TLS. Therefore the UI/state model can be made equivalent, but the server/control plane and wire protocol are not the Tencent implementation.
