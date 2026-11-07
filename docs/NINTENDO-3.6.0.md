# Nintendo Switch App 3.6.0: lab reproduction

Status: startup failure reproduced on 2026-11-06; root cause unresolved.

## Artifact identity

The user supplied the APKMirror bundle for `com.nintendo.znca`, version 3.6.0,
version code 14330. The base manifest declares minimum SDK 28 and target SDK 36.
The bundle contains base plus 35 configuration splits, including native x86_64
and x86. No ARM translation was needed for the reproduced x86_64 case.

| Item | SHA-256 |
|---|---|
| APKM bundle | `bb97fcb5123085bf3fe7793724bec516bb2b10a3e74358997d31c8ab6775cc95` |
| Signing certificate | `1bc2c25d008bfd03023c1ba60140dfd2c17f850a4ad5250388e2cf292e02167d` |
| x86_64 libpairipcore.so | `86e614d73b7a8ecb0b930a0859935271ad1d86e11c73fdaea7cbc5154d5f6b8e` |

The bundle hash and certificate fingerprint match the
[distributor's listing](https://www.apkmirror.com/apk/nintendo-co-ltd/nintendo-switch-online/nintendo-switch-app-3-6-0-release/nintendo-switch-app-3-6-0-android-apk-download/).
`apksigner verify` succeeded for the base and selected x86_64, mdpi and English
splits; all used the same certificate with Nintendo's organization name. APK v3
signatures verified. The installed SDK verifier reported an unknown Google
SourceStamp attribute and did not verify SourceStamp. This evidence establishes
consistency/integrity of the supplied distribution, not a blanket safety claim.

APKs were installed unchanged with Android Package Manager's create/write/commit
session API. No repacking, signing changes, installer-origin spoofing, hooks or
protection bypasses were used. No Nintendo account sign-in was performed.

## Environment

- Surface Book 3, Intel i5-1035G7, about 8 GB physical RAM; WSL memory cap 3 GB.
- Windows 11 Pro build 26200.9711, WSL 3.0.3, WSLg 1.0.79.
- Windroid binder kernel `6.18.33.1-microsoft-standard-WSL2-windroid+`.
- Android 13, LineageOS 20 GApps system image dated 2026-09-27; official MAINLINE
  vendor image dated 2026-10-22, with Windroid helper changes from this branch.
- Nested Weston fallback enabled during this app test; seamless mode remains
  unresolved. Google Play Services package presence was confirmed without
  inspecting accounts. GApps installer smoke/integration validation is pending.
- Installed inspection tools from Ubuntu packages: aapt, apksigner and Java;
  dependency installation also updated guest Mesa packages. Exact package
  changes are retained in the local apk-tools-install transcript.

## Reproduction and result

1. Verify/extract the supplied APKM; retain each original APK unchanged.
2. Verify base and selected configuration signatures, then install base,
   `split_config.x86_64.apk`, mdpi and English splits in one package session.
3. Check installed metadata: version 3.6.0 / 14330, primary ABI x86_64.
4. Launch `com.nintendo.znca/com.nintendo.coral.ui.boot.BootActivity` with
   Android `am start -W -n`.
5. Collect only tombstones whose Cmdline is `com.nintendo.znca`.

The launch produced native crashes with process uptimes of one to two seconds.
Twelve target tombstone records were collected during one launch window; these
are not twelve independently controlled test runs. Every collected first frame
was `split_config.x86_64.apk!libpairipcore.so + 0x794cb`, APK offset `0xc000`,
with SIGSEGV / SEGV_ACCERR. This matches the original handoff's fault location.
The raw renderer labels the signal number as zero while naming SIGSEGV; preserve
that anomaly instead of silently rewriting the raw report.

The library is ELF64 / machine x86-64, and the fault PC falls within its
file-declared executable load segment. That alone does not establish which
runtime memory operation failed or whether a protection check was intentional.

## Controls and limitations

An official signed x86 split comparison also failed at startup. Initial transfer
from Windows failed with `sendfile: ENOMEM`; that incomplete session was
abandoned. A subsequent attempt found Android's package service unavailable.
After recovering the container, installation from Linux-staged files succeeded
with `pm install-create -r --user 0 --abi x86` (session 2058170059). Metadata
confirmed primary ABI x86 and the same version/code; app data was preserved.

The first four-second observation found a process and no x86 tombstone. A longer
check disproved survival: ActivityManager repeatedly restarted BootActivity,
with successive processes dying about 0.13 seconds apart. A scoped log for
PID 20270 reports `invalid pointer ... (page signature mismatch)` followed by
`recursed signal handler call, aborting`; Zygote and target ApplicationExitInfo
confirm signal 6. No matching x86 tombstone was collected. Thus absence of a
tombstone or presence of a PID is not evidence of successful app startup.
The target was force-stopped at 20:17:06 local to end the restart loop.

The contained Android screen also showed a System UI ANR. This limits visual
validation and does not establish the cause of either app's native failure.
Neither ABI is a working compatibility result, and x86 is not a workaround.

Separately, SurfaceFlinger produced a DEAD_OBJECT HIDL composer abort during this
period. Recovery exposed another Windroid defect: the nested compositor's socket
appeared after the fixed two-second delay, so the session process exited before
it existed. The branch now explicitly names the socket and waits for readiness,
with a delayed-compositor regression test. No causal link between the Nintendo
crash and the compositor failure has been established.

Next: investigate allocator/runtime conditions using upstream sources and
ordinary unmodified control apps; preserve target evidence and app data. Do not
repeat the restart loop without a specific diagnostic hypothesis. A stock
supported-device control or publisher diagnosis would be needed to establish an
intentional rejection. The 32-bit abort alone does not explain the x86_64 fault.

## Local evidence

Lab `evidence/nintendo-3.6.0` holds bundle/APK inventories, verification outputs,
install-session logs, target tombstones, parsed crash summary, native library
hash/ELF metadata and system-failure summaries. APKs, native binaries and raw
memory dumps stay local; they are not committed to this repository.
