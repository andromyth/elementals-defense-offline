# Releases

Binary artifacts are published on GitHub Releases, not committed to this
repository. Build outputs in `build/` are git-ignored.

## patched-1.0.7-gold-wave

URL: https://github.com/andromyth/elementals-defense-offline/releases/tag/patched-1.0.7-gold-wave

Built with commit `9149c9c` from the original 1.0.7 bundle using
`tools/build-patched.sh` and `tools/apply-patches.py`.

| File | SHA-256 |
|---|---|
| `elementals-defense-1.0.7-ads-free.apks` | `0d6347e4c1f687feba2dca14868c10376fdbf7eb0332741c39b5e4f29941cdf6` |
| `base.apk` | `866ce5947dfc01c61f0f21dacf96a5fad83be56c119c70488370df1c860127db` |
| `original.apks` (input) | `3ada0631a5cd752d92d3c7f498a8494e942e5a185f17aedb5da0948deb2823c2` |

Signing certificate SHA-256:
`55:61:B7:E1:DE:7F:12:93:D4:3F:48:FD:1E:80:20:4C:09:86:E9:9C:33:BB:1E:76:FB:3F:03:23:5C:FA:E6:99`

Included patches:

- wall refills to full after every completed wave
- +1000 gold after every completed wave
- interstitial completion callback (fixes an earlier play hang)
- ads, analytics and telemetry disabled; `INTERNET` permission removed
- PairIP license check disabled

Install with a split-APK installer or:

```bash
adb install-multiple base.apk splits/split_config.*.apk
```

## offline-1.0.7-r2

URL: https://github.com/andromyth/elementals-defense-offline/releases/tag/offline-1.0.7-r2

Published by the `build-release.yml` workflow with a freshly generated signing
key. Its bundle SHA-256 is
`53b56aadaa21acfc4f9c80268bc1e63d2a20250db370b0a5b1ba6d7b767084db`.
Because the signing identity differs, uninstall any previously installed build
before installing this one. The workflow assets include `output-sha256.txt` and
`signing-cert.txt`.

## original-1.0.7

URL: https://github.com/andromyth/elementals-defense-offline/releases/tag/original-1.0.7

The untouched original bundle, kept as the reproducible build input.
