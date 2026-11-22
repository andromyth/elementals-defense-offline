# Elementals Defense — Offline / Invincible-Wall Research

Private reverse-engineering workspace for the user-provided Android package `com.elementals.defence`.

## Required outcomes

1. Preserve the original game's presentation and gameplay.
2. Make the wall invulnerable without breaking wave progression or other combat logic.
3. Remove or disable telemetry, ads, analytics, and tracking SDK initialization where feasible.
4. Verify that gameplay works with network access disabled and that the app makes no outbound connections.
5. Produce a signed APK and document the signing key/fingerprint and test results.

## Current status

A patched, signed, fully offline, ad-free build now exists.

- Original bundle: `Elementals-Defense_1.0.7_apkcube (1).apks`
  (SHA-256 `3ada0631a5cd752d92d3c7f498a8494e942e5a185f17aedb5da0948deb2823c2`).
- Patch script: `tools/apply-patches.py`. Reproducible build: `tools/build-patched.sh`.
- The game is a WebView game; gameplay and wall logic live in `assets/index.html`.
- Wall health was only restored by `3% × wallRep` after a wave, so it never refilled.
  It is now set to full after every completed wave.
- Ads: `INTERNET` permission removed, ad SDK auto-init providers removed, AppLovin
  initialization disabled, `GG_ADS_OFF`/`GG_REWARDS_OFF` forced on, Yandex/ad JS
  wrapper replaced with a no-op.
- Analytics: `App.onCreate` telemetry init (Firebase, Crashlytics, AppMetrica,
  remote config) skipped, Firebase/AppMetrica init providers removed, `EDAM`
  analytics dispatcher replaced with a no-op.
- PairIP license check is patched to a no-op so the re-signed APK can start.
- Wave gold: `winOrNext()` awards `waveEarned + 1000` instead of `waveEarned`,
  so every completed wave (including skipped waves and a world's final wave)
  grants an extra 1000 gold.
- The Yandex interstitial wrapper now calls its completion callback; this fixes
  a play hang seen in an earlier build where the callback was never invoked.
- Verified on a physical arm64 Android 13 device: installs, launches, renders at
  60 fps, no crash, no ad/analytics SDK log activity.

## Releases

Published artifacts and their hashes are recorded in `docs/releases.md`.

Current patched release:
[patched-1.0.7-gold-wave](https://github.com/andromyth/elementals-defense-offline/releases/tag/patched-1.0.7-gold-wave)

- `elementals-defense-1.0.7-ads-free.apks` — SHA-256
  `0d6347e4c1f687feba2dca14868c10376fdbf7eb0332741c39b5e4f29941cdf6`
- Base APK SHA-256 `866ce5947dfc01c61f0f21dacf96a5fad83be56c119c70488370df1c860127db`
- Signing certificate SHA-256
  `55:61:B7:E1:DE:7F:12:93:D4:3F:48:FD:1E:80:20:4C:09:86:E9:9C:33:BB:1E:76:FB:3F:03:23:5C:FA:E6:99`

The earlier build without the wave-gold patch had bundle SHA-256
`199117745075d2aa3945aceee4000330d4f9ad636a851961cf49db7152fcc3fb`.

## Build

```bash
tools/build-patched.sh          # downloads original bundle + tools, builds and signs
```

Build requirements: JDK 17+, curl, unzip, zip, python3, keytool. Apktool 2.11.1 and
Android build-tools 35 are fetched into `build/work/tools`. A local keystore is
generated at `build/ed-release.jks` (git-ignored; never commit it).

## Next workflow

1. Install `elementals-defense-1.0.7-ads-free.apks` with a split-APK installer
   (SAI/APKCube), or `adb install-multiple`.
2. Test a full run: several waves, boss wave, world transition, restart.
3. Confirm the wall is full after every wave.
4. Capture device traffic while playing and confirm there is none (no `INTERNET`
   permission means the app cannot open sockets at all).

## Security and provenance

- Keep this repository private.
- Never commit keystores, passwords, OAuth tokens, or personal data.
- Do not distribute the original or modified game publicly without confirming the applicable rights and license.
- A private repository does not by itself grant rights to modify or redistribute the game.
