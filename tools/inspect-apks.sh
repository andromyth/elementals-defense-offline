#!/usr/bin/env bash
set -euo pipefail

# Usage: bash tools/inspect-apks.sh /path/to/original.apks [output-dir]
# Assumptions: Java, unzip, apktool, and jadx are installed and on PATH.
INPUT="${1:?Usage: $0 original.apks [output-dir]}"
OUT="${2:-analysis-output}"
WORK="$OUT/work"
mkdir -p "$WORK" "$OUT"

for tool in java unzip apktool jadx sha256sum; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: required tool not found: $tool" >&2
    exit 2
  }
done

test -f "$INPUT" || { echo "ERROR: input not found: $INPUT" >&2; exit 2; }
sha256sum "$INPUT" > "$OUT/input-sha256.txt"
unzip -o "$INPUT" -d "$WORK/apks" >/dev/null

BASE="$(find "$WORK/apks" -maxdepth 2 -type f -name base.apk -print -quit)"
if [[ -z "$BASE" ]]; then
  echo "ERROR: no base.apk found in bundle" >&2
  exit 3
fi

sha256sum "$BASE" > "$OUT/base-apk-sha256.txt"
apktool d -f "$BASE" -o "$WORK/decoded" >/dev/null
jadx --show-bad-code -d "$WORK/jadx" "$BASE" >/dev/null 2>&1

{
  echo "# Android manifest permissions"
  grep -oE 'android.permission.[A-Z_]+' "$WORK/decoded/AndroidManifest.xml" | sort -u || true
  echo
  echo "# Potential analytics / advertising references (leads only)"
  grep -RniE 'firebase.analytics|crashlytics|appmetrica|applovin|chartboost|ironsource|levelplay|vungle|facebook.ads|google.android.gms.ads|mbridge|bidmachine|adjust|appsflyer' "$WORK/jadx" \
    --include='*.java' --include='*.kt' | head -n 500 || true
  echo
  echo "# Potential wall / health references (leads only)"
  grep -RniE 'wall|health|damage|hitPoints|hit_points|baseHealth|castle' "$WORK/jadx" \
    --include='*.java' --include='*.kt' | head -n 500 || true
} > "$OUT/initial-findings.txt"

echo "Inspection complete. Review:"
echo "  $OUT/input-sha256.txt"
echo "  $OUT/base-apk-sha256.txt"
echo "  $OUT/initial-findings.txt"
echo "Decoded files are under $WORK; do not commit extracted game content."
