#!/usr/bin/env bash
# Build an optional local diagnostic; never included in the user app suite.
set -euo pipefail
: "${ANDROID_JAR:?Set ANDROID_JAR to an installed Android SDK platform android.jar}"
: "${D8_JAR:?Set D8_JAR to the verified Google R8/D8 jar}"
: "${LAB_KEYSTORE:?Set LAB_KEYSTORE to the local development signing keystore}"
output=${1:?usage: build.sh /absolute/path/control.apk}
[[ "$output" == /* ]] || { echo 'APK output path must be absolute' >&2; exit 2; }
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
work=$(mktemp -d /tmp/windroid-control.XXXXXXXX)
cleanup() { [[ "$work" == /tmp/windroid-control.* ]] && rm -rf -- "$work"; }
trap cleanup EXIT
mkdir -p "$work/classes" "$work/dex" "$(dirname -- "$output")" "$(dirname -- "$LAB_KEYSTORE")"
javac -J-Xmx256m -source 8 -target 8 -Xlint:-options -bootclasspath "$ANDROID_JAR" \
    -d "$work/classes" "$source_dir/src/org/windroid/lab/control/MainActivity.java"
mapfile -d '' -t classes < <(find "$work/classes" -name '*.class' -print0)
java -Xmx256m -cp "$D8_JAR" com.android.tools.r8.D8 --release --min-api 23 \
    --lib "$ANDROID_JAR" --output "$work/dex" "${classes[@]}"
aapt package -f -M "$source_dir/AndroidManifest.xml" -I "$ANDROID_JAR" -F "$work/unsigned.apk"
jar uf "$work/unsigned.apk" -C "$work/dex" classes.dex
if [[ ! -f "$LAB_KEYSTORE" ]]; then
    keytool -J-Xmx128m -genkeypair -keystore "$LAB_KEYSTORE" -storetype PKCS12 \
        -storepass windroid-lab -keypass windroid-lab -alias windroid-lab \
        -keyalg RSA -keysize 2048 -validity 3650 -dname 'CN=Windroid Lab Control'
fi
apksigner sign --ks "$LAB_KEYSTORE" --ks-key-alias windroid-lab \
    --ks-pass pass:windroid-lab --key-pass pass:windroid-lab --out "$output" "$work/unsigned.apk"
apksigner verify --verbose --print-certs "$output"
sha256sum "$output"
