# Verification checklist

Do not mark any item passed until it has been executed and evidence recorded.

## Reverse engineering
- [x] Decode AndroidManifest.xml and record effective permissions/components.
- [x] Identify wall health field, damage handler, and defeat condition.
  (`wallHP`/`wallMax`; damage enters through `hitWall()`; defeat at `wallHP <= 0`.)
- [x] Identify active telemetry/ads/analytics initialization and call paths.
- [x] Record APK and tool versions/hashes before changes.

## Build integrity
- [x] Rebuild succeeds with documented tool versions.
- [x] APK aligns and signature verifies.
- [x] Package ID remains `com.elementals.defence`.
- [x] App installs and launches on a clean test device (arm64, Android 13).

## Gameplay
- [x] Wall replenishes to 100% after a completed wave (verified in-engine:
      209/300 -> 300/300 on wave win).
- [ ] Waves, minions, enemies, magic, UI, upgrades, and restart still work
      (manual full-run test outstanding).
- [x] Test multiple waves and repeated damage events.

## Offline/privacy
- [x] `INTERNET` permission removed from the patched manifest.
- [x] Ad SDK auto-init ContentProviders removed from the manifest.
- [x] AppLovin/MAX initialization disabled in code.
- [x] Firebase/AppMetrica/Crashlytics/remote-config init skipped in `App.onCreate`.
- [x] `EDAM` analytics dispatcher and Yandex ad wrapper replaced with no-ops.
- [x] Launch with network enabled; no ad/analytics SDK activity in logcat.
- [ ] Capture network traffic during a full play session (no `INTERNET`
      permission makes app-originated sockets impossible).

## Release record
- [x] Record APK SHA-256 (`199117745075d2aa3945aceee4000330d4f9ad636a851961cf49db7152fcc3fb`).
- [x] Record signing certificate SHA-256 fingerprint
      (`55:61:B7:E1:DE:7F:12:93:D4:3F:48:FD:1E:80:20:4C:09:86:E9:9C:33:BB:1E:76:FB:3F:03:23:5C:FA:E6:99`).
- [x] Record device/emulator and Android version (Xiaomi M2101K7BI, Android 13, arm64-v8a).
- [x] Attach logs and test evidence without secrets or personal data.
