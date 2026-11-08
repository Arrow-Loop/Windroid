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
Windows checks paused when Windows locked. Do not label the patch a fix yet.

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
