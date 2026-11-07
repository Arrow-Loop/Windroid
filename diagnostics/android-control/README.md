# Android frame/input control

Optional development app `org.windroid.lab.control`, separate from the bundled
user app suite. It displays draw count, tap count, view dimensions and the last
touch position. The background changes each ten draws; Space pauses/resumes the
100ms animation request. Logcat tag `WindroidLab` records taps and each tenth
draw. No permissions are requested.

This provides a known Java Canvas workload for Android/Windows frame and input
comparisons. A draw callback or Android screenshot alone does not prove that
Windows received the frame. Native app compatibility requires separate evidence.

## Build locally on Linux/WSL

Requires a JDK, `aapt`, `apksigner`, an official Android platform `android.jar`
and Google's R8/D8 jar. Use verified existing downloads; the script does not
install or fetch dependencies. It caps compilation heaps at256MB.

```bash
export ANDROID_JAR=/path/to/android.jar
export D8_JAR=/path/to/r8.jar
export LAB_KEYSTORE=/path/to/local-lab-control.p12
bash diagnostics/android-control/build.sh "/absolute/output/Windroid Lab's Control.apk"
```

The script creates/reuses a local development key with alias/password
`windroid-lab`, signs the APK, verifies its signature and prints SHA256. Keep
that key to install updates to the same package. Generated APKs, signing keys
and SDK files stay outside Git. Installation is opt-in through `windroid
install <apk>`, and launch uses `windroid-app org.windroid.lab.control` as the
session user. Uninstall only this control with `waydroid app remove
org.windroid.lab.control` when finished; other app data is unaffected.

## Lab build provenance — 2026-11-07

- OpenJDK21.0.12.1, existing Ubuntu `aapt`/`apksigner`; JDK installation added
  one package with no unrelated upgrades.
- Official Android33ext3 revision3 platform archive, published SHA1
  `394bc86d8d3452aa4d419b67743025a6fb2cd9d0`; local SHA256
  `b32b10f787867987f03ae8e101d217e053a9065b7136379fb353b388379aed1d`.
- Extracted android.jar SHA256
  `fd628aa21321859a9035c6aae4b084b7d3fdb3f230be5cd5ec76541e32f7c963`.
- Official Google Maven R8 stable9.5.29, published SHA1 checked; SHA256
  `f8c762ff84640b10083b934a47278758a7665977e618fab0c927fff00521dea3`.
- Build/sign succeeded; v1/v2/v3 signatures verified. Initial local APK SHA256
  `06bce86e5d93514ccd923cb809beebb838302c24b127ecc4f67461db407ddfd5`.

Tools and exact metadata are in lab `tools/android-control`; build/install
transcripts are in `evidence/integration-2026-11-07`. Runtime results must be
recorded separately from build success.

## Observed runtime — 2026-11-07

The signed APK is installed, and Windows displayed its advancing frame count.
After recovering a separate System UI startup ANR, two mouse events reached
the control, including coordinates522,530. Space logged `animation=false` at
10:36:03 and Windows subsequently displayed paused frame987. These are bounded
nested-display frame/input observations, not seamless or Nintendo compatibility
proof. A100ms invalidation request is not a guaranteed presentation frame rate.

Installation requests are asynchronous upstream. The original Windows request
remained pending, while a direct session-user request completed2.4seconds after
return. An explicit root PackageManager diagnostic also accepted the same APK;
this is not the shipped installation path. Inspect final package metadata
before claiming completion. CLI/tray wording now reflects a request, not an
installation guarantee. No package verification or permissions were changed.
