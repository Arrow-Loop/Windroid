# Isolated Android composer build

This is a lab feasibility build, not an installer input or a released vendor
binary. Original vendor images remain unchanged. It avoids a full AOSP checkout.
All cached inputs and reproducible local scripts are retained in lab
`tools/hwc-native-build`; build outputs are under guest
`/opt/windroid-lab-tools/hwc-native-build`. Evidence is in lab
`evidence/integration-2026-11-07/kernel-path-control`.

## Inputs and configuration

| Input | Reference |
|---|---|
| HWC source | waydroid/android_hardware_waydroid a575cfcc12ab79a122844218f2c6df5bd208cca0 |
| VNDK33 headers | AOSP prebuilts/vndk/v33 d79ad875113d34c9665a65b8a33dcf7a4fb7dcf1 |
| Wayland 1.19 | AOSP external/wayland 21f44c8186caa56b3e01a99554f22ab1aa74094d |
| Waydroid fractional-scale patch | android_vendor_waydroid 4dced17d9528ba07f6a6eab11b78a8ed38a36067, base-patches-33 |
| minigbm headers | android_external_minigbm e5a7769a4892cd1b6c61c56a8bedfc9b93584704 |
| libdrm headers | android_external_libdrm 6bfcfc725fbe0ece0918535556d61ee567b1ffff |
| libffi, xkbcommon, protocols, HIDL base, graphics HAL and sync header | AOSP android-13.0.0_r75, cached archive hashes |
| Compiler | verified NDK r25c, x86_64-linux-android33-clang / clang++ |
| Shared libraries | copies of unchanged installed vendor/VNDK33/runtime libraries; hashes retained |

`SHA256SUMS.txt` records downloaded archive content. These source references do
not establish exact provenance or bit reproducibility of the installed binary.
The baseline SHA256 is
`74fbd6efe5d09ccb4560337ea2702174de90e8e5b8dc6bd35a4e5b54034525f5`.
The queue-only candidate SHA256 is
`4bdce01b33e7a3907f44e1387cc9f64ff078533d20b4b89a5819822e7fcf310d`.

## Build corrections and limitations

Ubuntu Wayland scanner1.22 emits marshal calls absent from Wayland1.19. The
scanner was therefore compiled from the pinned1.19 source and regenerated all
protocol files. Waydroid's existing fractional-scale patch supplies its XML.

Ubuntu hidl-gen10 generates the eight Waydroid interfaces and missing composer
interfaces. Existing VNDK33 generated headers take precedence. Local generated
enum specializations are normalized to `template<> inline constexpr`, matching
the Android13 snapshot; the older generator otherwise causes duplicate symbols.
Thirty declarations changed. Generated headers use system include treatment;
composer source retains `-Wall -Werror`. This is a documented lab toolchain
adaptation, not a full Android build-system reproduction.

C++ uses C++17, PIC, O1/debug, no RTTI/exceptions, VNDK/vendor macros, and the
snapshot's platform libc++ headers. Static Wayland/libffi/xkbcommon/protocol
archives follow their Android.bp source lists. Legacy libffi emits deprecated
API warnings; its upstream Android.bp suppresses those. Shared link uses copied
installed libraries, `-nostdlib++`, `--no-undefined`, `-z defs`, explicit SONAME
and SHA1 build ID. As-needed linking omits unused original shared dependencies.
No host Linux library is linked into Android output.

## Completed validation

- All12 unchanged composer translation units compile; native static dependencies
  compile. Strict baseline link passes.
- Baseline isolated Android `load` succeeds0. It never calls a HAL open method.
- Baseline stress20000: shared queue exits142 in3/3; private passes0 in3/3.
  This reproduces the installed-library mechanism without replacing a service.
- Queue-only and combined queue/pointer candidates compile/strict-link and isolated
  Android load passes0 for both. Combined SHA256
  f6c05f8119a386a853cdc570420af3a60aad1f55f188f0cdc3e387c9d823715a.
- Probe's optional absolute library path selects owned copies; relative path is
  rejected with exit2. Default installed-library selection is preserved.

Compilation/load success does not prove runtime ABI, framework startup, window
creation, pointer input, disconnect handling, scaling or seamless resize. Native
Windows checks resumed November8 after unlock; results follow below. Do not
label the patch a complete graphics fix.

## Reproduce cached build

Run guest `bash` on the lab's `compile-hwc-local.sh`, then `link-hwc-local.sh`.
For the candidate, pass `source-queue` and `obj-queue` directories to the compiler
script; pass `obj-queue` and an explicit output filename to the link script.
`prepare-local.sh` builds the matching scanner and protocols; HIDL generation
commands and normalization are recorded in the journal/evidence. Reuse verified
cached archives. A live service experiment must preserve original image hashes,
remove the scoped diagnostic preload to isolate source behavior, and checkpoint
owned overlay paths plus rollback before a normal stop/start.

## November8 nested service comparison

Both rebuilt baseline and queue-only candidate ran as the actual composer via
one owned vendor overlay, with original images unchanged and no diagnostic
preload. Active file hashes and service mappings were verified. Lab nested
fallback, eight CPUs, 3GB memory and normal GL remained identical.

| Result | Unchanged baseline | Queue-only source candidate |
|---|---|---|
| Normal start | exit0,58s | exit0,83s |
| Control launch | exit0,11:28:08 | exit0,11:33:01 |
| Native frames | 100 through475 observed | 288 through1011 observed |
| Native mouse | tap1 at674,409 visible | tap1 at512,367 visible |
| Keyboard | Android animation=false logged | native paused frame1011 confirmed |
| SystemUI ANR | none in captured startup events | none in captured startup events |

The baseline's short successful run prevents treating the candidate's short
success as causal reliability proof. The paired startup times do not establish
an improvement. Full disconnect/scaling/error and long-session tests remain.
Evidence is retained in lab evidence/integration-2026-11-08/component-control.

## Direct startup and modal visibility follow-up

The subsequent direct-WSLg run failed live readiness at180s. A later app-list
query also timed out at15s, while root PackageManager and an explicit launch of
the owned control Activity responded. This remains a launcher/framework failure.
The raw Activity launch omitted Waydroid's normal `waydroid.active_apps` step;
app_manager.py confirms that property precedes its normal app launch. Applying
the same documented property for the owned diagnostic produced a native control
window with advancing frames. This does not validate the failed launcher route.

Android captured a SystemUI ANR modal over the control, while Windows rendered
only the control. A native click did not reach the app. The hidden modal is an
input confound, distinct from a pointer-coordinate failure. SystemUI's later
sampled main thread was polling; the ANR dialog still existed in WindowManager.
Composer samples showed idle Binder work/default Wayland dispatch rather than
a window-creation roundtrip. These samples are not proof against every deadlock.
One verified SystemUI recovery is being used to continue graphics diagnostics;
startup success must not be claimed after that intervention.

The verified SystemUI493 TERM occurred11:53:15, and SystemUI2955 restarted.
Control Activity recreated in the same process2816. Input still failed: Android
reported its ANR at11:53:47, waiting5002ms for `FocusEvent(hasFocus=true)`.
Its later sampled main thread was idle in Looper polling, so that late sample
does not establish the cause of the earlier timeout. Its ANR modal was likewise
absent from the Windows control window. No additional process recovery or
resize result was attempted. Runtime multi=false was restored and normal stop
returned0. Rollback of config/source experiment is recorded in the checkpoint.

## November8 raw-ANR routing prototype

Queue+modal binary SHA256
790b3148d7007d4fbf2ee1236827d347439ddb1f2612ea38bad5f28c1164449a
ran as the actual composer, without preload, NESTED_WESTON=true and
MULTI_WINDOWS=true. Normal startup passed0 in83s and default control input
passed. This isolates multi-window routing inside nested Weston; direct WSLg
presentation remains unvalidated for this prototype.

An explicit30s owned-control fault produced the raw ANR window. Native Windows
showed the dialog and open_windows changed1->2->1 on automatic recovery. The
first attempted button click occurred after auto-dismiss and was only another
app tap, so it is not counted as a dialog-button pass.

A bounded explicit90s fault then held the dialog long enough for native input.
At12:57:59, clicking its Close app button caused ActivityManager to kill only
org.windroid.lab.control PID3389, reason "user request after error". Its process
was absent and open_windows0 at12:58:01. Normal launcher relaunch returned0,
created PID3526 with fault off, rendered advancing frames and accepted tap1 at
662,323. Thus dialog presentation, Android Close app and cleanup pass this
bounded comparison. Wait, native titlebar close, placement/scaling, multiple
simultaneous dialogs and direct WSLg remain unvalidated. This is a candidate,
not a shipped or complete graphics reliability fix.

Runtime multi=false was restored, normal stop0 completed, and the hash-checked
restore script returned0. Original config backups were restored byte-for-byte;
only the owned candidate overlay was removed. The earlier scoped lab RC/shim
was restored, not a pristine production environment. Subsequent fallback
startup verification is recorded in SESSION_STATE.md and the lab journal.
