#!/usr/bin/env bash
# Build a patched, ad-free, analytics-free, fully offline Elementals Defense APK.
#
# Requirements: java 17+, curl, unzip, zip, python3, keytool.
# apktool + Android build-tools are downloaded automatically.
#
# Usage:
#   tools/build-patched.sh [original.apks|release-url] [output-dir]
#
# Signing: a local keystore is generated on first run at build/ed-release.jks.
# Never commit it. Override with KEYSTORE / KEYSTORE_PASS / KEY_ALIAS env vars.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="${1:-https://github.com/andromyth/elementals-defense-offline/releases/download/original-1.0.7/Elementals-Defense_1.0.7_apkcube.1.apks}"
OUT="${2:-$ROOT/build}"
WORK="$OUT/work"
TOOLS="$WORK/tools"
APKTOOL_VER=2.11.1
BUILD_TOOLS_ZIP=build-tools_r35_linux.zip
BUILD_TOOLS_URL="https://dl.google.com/android/repository/$BUILD_TOOLS_ZIP"

mkdir -p "$WORK" "$TOOLS" "$OUT"

fetch() { # url dest
  if [[ ! -s "$2" ]]; then
    echo "Downloading $(basename "$2") ..."
    curl -fL --connect-timeout 20 -o "$2" "$1"
  fi
}

fetch "https://github.com/iBotPeaches/Apktool/releases/download/v$APKTOOL_VER/apktool_$APKTOOL_VER.jar" "$TOOLS/apktool.jar"
fetch "$BUILD_TOOLS_URL" "$TOOLS/$BUILD_TOOLS_ZIP"
if [[ ! -x "$TOOLS/bt/zipalign" ]]; then
  unzip -q -o "$TOOLS/$BUILD_TOOLS_ZIP" -d "$TOOLS/bt"
  BT_DIR="$(find "$TOOLS/bt" -maxdepth 2 -type f -name zipalign -printf '%h\n' | head -1)"
  ln -sfn "$BT_DIR" "$TOOLS/build-tools"
fi
ZIPALIGN="$TOOLS/build-tools/zipalign"
APKSIGNER="$TOOLS/build-tools/apksigner"

if [[ "$INPUT" == http* ]]; then
  fetch "$INPUT" "$WORK/original.apks"
  INPUT="$WORK/original.apks"
fi
[[ -f "$INPUT" ]] || { echo "ERROR: input not found: $INPUT" >&2; exit 2; }
sha256sum "$INPUT" | tee "$OUT/input-sha256.txt"

rm -rf "$WORK/apks" "$WORK/decoded"
unzip -q "$INPUT" -d "$WORK/apks"
BASE="$WORK/apks/base.apk"

echo "Decoding ..."
java -Xmx3g -XX:+UseSerialGC -jar "$TOOLS/apktool.jar" d -f "$BASE" -o "$WORK/decoded" >/dev/null

echo "Applying patches ..."
python3 "$ROOT/tools/apply-patches.py" "$WORK/decoded"

echo "Rebuilding ..."
java -Xmx3g -XX:+UseSerialGC -jar "$TOOLS/apktool.jar" b -j 1 "$WORK/decoded" -o "$OUT/base-unsigned.apk" >"$OUT/build.log" 2>&1 \
  || { tail -40 "$OUT/build.log"; exit 1; }

KEYSTORE="${KEYSTORE:-$OUT/ed-release.jks}"
KEYSTORE_PASS="${KEYSTORE_PASS:-elementalsdefence}"
KEY_ALIAS="${KEY_ALIAS:-ed}"
if [[ ! -f "$KEYSTORE" ]]; then
  echo "Generating local signing key (keep it private) ..."
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KEYSTORE_PASS" -keypass "$KEYSTORE_PASS" \
    -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Elementals Defense Offline, O=Local, C=IN" >/dev/null
fi

rm -rf "$OUT/apks"
mkdir -p "$OUT/apks/splits"
"$ZIPALIGN" -p -f 4 "$OUT/base-unsigned.apk" "$OUT/base-aligned.apk"

sign() { # in out
  "$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass "pass:$KEYSTORE_PASS" --key-pass "pass:$KEYSTORE_PASS" \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --out "$2" "$1"
}

sign "$OUT/base-aligned.apk" "$OUT/apks/base.apk"
for apk in "$WORK"/apks/split_config.*.apk; do
  n="$(basename "$apk")"
  "$ZIPALIGN" -p -f 4 "$apk" "$OUT/apks/splits/$n.aligned"
  sign "$OUT/apks/splits/$n.aligned" "$OUT/apks/splits/$n"
  rm -f "$OUT/apks/splits/$n.aligned"
done

cp "$WORK/apks/APKCube.txt" "$OUT/apks/" 2>/dev/null || true
(cd "$OUT/apks" && zip -q -X -r ../elementals-defense-1.0.7-ads-free.apks base.apk splits APKCube.txt)

"$APKSIGNER" verify --print-certs "$OUT/apks/base.apk" > "$OUT/signing-cert.txt"
sha256sum "$OUT/elementals-defense-1.0.7-ads-free.apks" | tee "$OUT/output-sha256.txt"

echo
echo "Built: $OUT/elementals-defense-1.0.7-ads-free.apks"
echo "Install with a split-APK installer (SAI / APKCube), or:"
echo "  adb install-multiple $OUT/apks/base.apk $OUT/apks/splits/split_config.*.apk"
