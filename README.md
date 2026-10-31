# Elementals Defense — Offline / Invincible-Wall Research

Private reverse-engineering workspace for the user-provided Android package `com.elementals.defence`.

## Required outcomes

1. Preserve the original game's presentation and gameplay.
2. Make the wall invulnerable without breaking wave progression or other combat logic.
3. Remove or disable telemetry, ads, analytics, and tracking SDK initialization where feasible.
4. Verify that gameplay works with network access disabled and that the app makes no outbound connections.
5. Produce a signed APK and document the signing key/fingerprint and test results.

## Current status

- Original bundle provided in chat: `Elementals-Defense_1.0.7_apkcube (1).apks`.
- Bundle inspection found a base APK with five DEX files and no obvious native `.so` libraries.
- DEX strings suggest several ad/analytics SDKs are bundled; bundled strings alone do not prove that data was transmitted.
- The binary Android manifest has not yet been fully decoded.
- Wall-health/damage implementation has not yet been identified.
- **No patched APK has been built or tested.** This repository currently contains project notes only.

## Next workflow

1. Place the user-provided original bundle in a trusted local Android reverse-engineering environment; do not commit signing keys or credentials.
2. Extract the base/split APKs and decode with current `apktool`; inspect code with `jadx`.
3. Trace wall damage and health state from gameplay entry points. Make the smallest targeted patch and verify edge cases (wall hit, multiple hits, wave transitions, restart).
4. Identify telemetry initialization/calls and disable them surgically. Review permissions and manifest components; do not treat removing `INTERNET` alone as proof that all telemetry is gone.
5. Rebuild, align, sign, and test on an emulator/device. Validate offline launch, full gameplay, invulnerable wall, and outbound network traffic.
6. Record exact tool versions, source hashes, APK hashes, test steps/results, and signing certificate fingerprint.

## Security and provenance

- Keep this repository private.
- Never commit keystores, passwords, OAuth tokens, or personal data.
- Do not distribute the original or modified game publicly without confirming the applicable rights and license.
- A private repository does not by itself grant rights to modify or redistribute the game.
