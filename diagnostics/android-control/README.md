# Android frame/input control

Optional development app `org.windroid.lab.control`, separate from the bundled
user app suite. It displays draw count, tap count, view dimensions and the last
touch position. The background changes each ten draws; Space pauses/resumes the
100ms animation request. Logcat tag `WindroidLab` records taps and each tenth
draw. No permissions are requested.

This provides a known Java Canvas workload for Android/Windows frame and input
comparisons. A draw callback or Android screenshot alone does not prove that
Windows received the frame. Native app compatibility requires separate evidence.

## Explicit one-shot input fault

For ANR/modal-routing diagnostics only, launch a fresh Activity with boolean
intent extra `lab.block_input_once=true`. Its visible status says the fault is
armed. The first click blocks this test app's UI thread for30seconds by default, with
`intentional_block_begin` / `intentional_block_end` log markers. Android may show
an input ANR dialog. Further clicks do not block; Activity recreation disables
the fault. A normal launch leaves it off. No other app/process is changed.
Optional integer extra `lab.block_input_ms` accepts10000..90000ms; an out-of-range
value disables the fault. A longer interval permits manual dialog-button tests
before automatic recovery.

Keep intentional ANR records separate from spontaneous failures. Capture Android
and native Windows presentation plus actual SurfaceFlinger layer names before
changing modal routing. Stop/relaunch only this diagnostic after the experiment;
do not clear app data or dismiss unrelated prompts.

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

## Intentional ANR control — November8

The explicit30s build signs with the existing lab key; its SHA256 is
`3e63c05f81ae631c33c8bb037a872431ab21c6aa05d5c35e5c7012d972779076`.
Original installed control APK was backed up; matching signer verified before
root-PM diagnostic update. This does not validate the asynchronous installer.
Default launch/click showed fault off and responsive input.

An initial12s variant generated an ANR but resumed before a persistent modal was
observed. The30s trial began12:18:16.504 and ended12:18:46.505. Android reported
an intentional MotionEvent ANR after5002ms. Nested Windows and Android both
showed the ANR dialog during the block. SurfaceFlinger listed the raw layer
`Application Not Responding: org.windroid.lab.control#189`, alongside the app's
TID-prefixed layer. The dialog disappeared after recovery without a UI action;
a second click counted2 with fault off and no second block.

These deliberate fault records must not be counted as spontaneous failures.
They provide repeatable layer/input evidence for modal-routing investigation,
not proof that a candidate composer fix works in multi-window mode.
