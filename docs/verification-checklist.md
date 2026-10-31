# Verification checklist

Do not mark any item passed until it has been executed and evidence recorded.

## Reverse engineering
- [ ] Decode AndroidManifest.xml and record effective permissions/components.
- [ ] Identify wall health field, damage handler, and defeat condition.
- [ ] Identify active telemetry/ads/analytics initialization and call paths.
- [ ] Record APK and tool versions/hashes before changes.

## Build integrity
- [ ] Rebuild succeeds with documented tool versions.
- [ ] APK aligns and signature verifies.
- [ ] Package ID remains `com.elementals.defence`.
- [ ] App installs and launches on a clean test device.

## Gameplay
- [ ] Wall survives repeated hits without health reduction or defeat.
- [ ] Waves, minions, enemies, magic, UI, upgrades, and restart still work.
- [ ] Test multiple waves and repeated damage events.

## Offline/privacy
- [ ] Launch with Wi-Fi and mobile data disabled.
- [ ] Play through multiple waves offline.
- [ ] Capture network traffic during online and offline tests.
- [ ] Confirm no app-originated telemetry requests or queued telemetry uploads after reconnect.
- [ ] Confirm ads/analytics SDKs do not initialize or transmit.

## Release record
- [ ] Record APK SHA-256.
- [ ] Record signing certificate SHA-256 fingerprint.
- [ ] Record device/emulator and Android version.
- [ ] Attach logs and test evidence without secrets or personal data.
