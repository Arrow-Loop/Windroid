# Windroid session state

Updated 2026-11-08, America/New_York. Read this before changing files.

## Objective and scope
Make Windroid reliable and investigate Nintendo Switch App startup on this
explicitly authorized development laptop. Continue without routine approval.
Preserve Android app/account data and upstream compatibility. No protection
bypass, unrelated accounts/machines, quota polling, credit/reset purchases,
API fallback or second agent against this worktree.

## Workspace and references
- Repository: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Handoff: lab HANDOFF.md; journal: lab journals/ENGINEERING-JOURNAL.md.
- Read AGENTS.md, ROADMAP.md, CHANGELOG.md, docs/CONTINUATION.md, README.md and
  docs/PLAN.md. Check actual Git status, branch, recent commits and diff.
- Branch: codex/lab-reliability. No push/PR performed. Use command-local commit
  identity only; Git already exists at C:\Program Files\Git\cmd\git.exe.
- Use PowerShell 7.6.9 (bundled). Windows PowerShell 5.1 is a test target.
- Windows Python is bundled at C:\Users\sdelo\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe.
  Set WINDROID_TEST_BASH=C:\Program Files\Git\bin\bash.exe for Windows fixtures.
  PATH python is a nonworking Store alias; do not repeat discovery/install.

## Completed coherent changes
- Earlier commits fix Sysnative detection, artifact cache/hash discovery,
  GApps configuration gating/flavour/locking/retry, duplicate INI properties,
  CLI APK paths, lifecycle locking, live framework checks and socket readiness.
  Real VANILLA install/smoke/network/uninstall and resumed GApps smoke/integration
  passed. Verified official artifacts remain local; do not download them again.
- 974d6c5: tray failure notifications and literal APK paths. PS7/5.1 focused
  command/callback checks pass; no live tray file-picker/balloon proof claimed.
- 0c6ff1a: wait for nested Weston exit; replace an existing compositor that
  disappears while waiting for its socket. Three new regressions fail old code.
  All13 Linux lifecycle checks pass; Git Bash passes with3 Linux-only skips.
  Syntax/ShellCheck pass. Actual normal immediate restart: stop6s, no old
  compositor, new PID, live readiness88s, exit0; Settings and IP/DNS controls pass.
- 2e39eb0: Windows tray link lives in <DistroName> Tools, outside WSLg's managed
  app folder. WSLg removed the old link and its referenced root icon. Installer
  repairs/migrates the link even after completed integration; preserves unrelated
  legacy/Tools files. Tray and link prefer staged bin icon. PS7/5.1 tests pass.
  Actual completed-installer resume repaired it without repeating WSL stages.
- New Tools link/bin icon survived WSLg resync after shutdown. Actual Windows
  Settings shortcut cold-started the user session/DBus/Android and rendered
  Settings (ready09:20:40, app START09:20:44). Two rapid warm activations reached
  Android09:28:24/26, with unchanged Weston/SF and no VMBus errors.
- Lab-only bindfs shared-storage reads/writes passed; temporary mount/empty
  Android directory removed. Personal Downloads was not inspected/remounted.
  Six awake IP/DNS samples across five minutes passed all12 ping commands.
- Passive Nintendo analysis/report committed: unchanged x86_64 app fails at
  libpairipcore+0x794cb; x86 also fails with allocator abort/restart loop. In all
  twelve existing x64 records, runtime instruction bytes match file bytes: an
  eight-byte data read into a no-access mapping, with PC in executable memory.
  Missing reported fault address limits confirmation; cause/intent unresolved.
  No new Nintendo launch, APK modification or protection change.

## Actual environment and active experiment
- Distro Windroid; InstallRoot: lab runtime\Windroid. WSL 3.0.3 / WSLg 1.0.79,
  binder kernel 6.18.33.1-microsoft-standard-WSL2-windroid+ in public lab path.
- Verified GApps system 20260927 / vendor 20261022. Preserve app/account data.
- Lab fallback NESTED_WESTON=true, MULTI_WINDOWS=false; Android persist multi=false.
  Source defaults remain false/true. Normal GL; no size, DPI or Vulkan override.
- Original .wslconfig restored byte-for-byte after the CPU comparison:
  SHA256 C86527AFE90712FC8B7C6CC8655A5C3F40A90A57D80F21801AE58F58C40D0879.
  processors key absent (8 logical CPUs); memory=3GB / autoMemoryReclaim=gradual.
- Installed helper SHA256 bdbfba689dd18116b40cb1c6f49361eb678102e91093113dbcf15055bf9c687b.
- Retained root PTY 68395 verified alive at 16:03; HISTFILE=/dev/null. Prior
  PTYs 1497/56941 ended at WSL shutdown. Reuse current terminal where available.
  Its variable i points to lab evidence/integration-2026-11-07.
- Nintendo installed ABI x86 remains force-stopped. Do not repeat launches blindly.
- ACTUAL VERIFIED Nov8 11:34: container RUNNING. Queue-only source candidate is
  active at /var/lib/waydroid/overlay/vendor/lib64/hw/hwcomposer.waydroid.so,
  SHA256 4bdce01b33e7a3907f44e1387cc9f64ff078533d20b4b89a5819822e7fcf310d.
  Nov7 normal stop0 and stage0 completed, but checkpoint was interrupted before
  recording them. Do not repeat staging/removal. Scoped RC/library overlays were
  hash-checked and removed. Original image unchanged. Baseline trial passed short frame/input controls.
- Backup in /opt/windroid-lab-tools/hwc-native-build/rollback-scoped:
  hwcomposer.original.so SHA256 3dcfbc40b2944fd02d252b06c2eddbfcfd30b926f60d52a8d75ade245c68d1d8;
  init.waydroid.rc SHA256 762eece58f962bd9a0dc0efcc1a9ee0b591f94a2bd769d721e6ce0eb61398ab2;
  libwindroid_queue.so SHA256 c80b386d7425c4f31f3ca8f264d9028254f6657000c9d87bfa4d2c7f93150578.
  Rollback: stop normally, verify/remove ONLY the owned baseline HWC overlay,
  restore saved RC/library to their original overlay paths and verify hashes.
## Latest findings and last successful operations
- Native installed-library stress: 20,000 requests, shared queue hangs 3/3;
  private queue passes 3/3. Scoped interposer source committed f7d3d48.
  Actual composer logs verify original initialization and private window calls.
  This is diagnostic evidence, not a shipped compositor fix.
- Seamless control rendered/received mouse and Space after one verified System UI
  recovery. Maximize recreated an updating view but retained an old-size view in
  Windows. Nested fallback/config/runtime property subsequently restored.
- Paired cold starts: four CPUs ready 15:41:30 (~90s); restored eight CPUs ready
  15:49:48 (~85s), CLI exit0 at 15:49:53. Both rendered the control without System
  UI recovery in the captured observation; eight-CPU native frame651 seen 15:52.
  Four/eight worker counts verified. No causal CPU fix; original config retained.
- First four-CPU click arrived0,0, next at correct662,313. Upstream pointer-enter
  handler ignores sx/sy. Candidate pointer and window-sync source patches apply
  and reverse individually/combined at a575cfcc12ab79a122844218f2c6df5bd208cca0.
  Both candidates compile/strict-link and isolated-load; no service runtime proof yet.
- NDK r25c cached/verified and extracted at /opt/windroid-lab-tools/android-ndk-r25c.
  ZIP SHA256 769ee342ea75f80619d985c2da990c48b3d8eaf45f48783a2d48870d04b46108.
- Small component-build feasibility now active: pinned VNDK33 header snapshot
  d79ad875113d34c9665a65b8a33dcf7a4fb7dcf1 downloaded to lab tools/hwc-native-build.
  Installed hidl-gen, libwayland-bin and dependency android-libboringssl, exit0;
  zero upgrades/removals. Plan/install logs retained in kernel-path-control.

## Exact next action
Queue-only candidate4bdce0... staged after baseline normal stop0/hash checks;
scoped preload files absent. Root PTY68395 alive. Nov8 start0 in83s; active HWC hash/maps verified, control0 at11:33:01.
Native frames288->630 and click512,367/taps1 observed. No SystemUI ANR captured.
Keyboard native pause confirmed frame1011. NEXT bounded seamless trial: backups
under Nov8 component-control; set Android persist.waydroid.multi_windows=true,
normal stop0, change only NESTED_WESTON=false/MULTI_WINDOWS=true in verified
/etc/windroid/windroid.conf, start/launch control. Keep queue-only candidate.
Restore both config backups and runtime false after trial, regardless of result.
Collect
exit/readiness timing, active HWC hash/maps, launch own control, native frames and
mouse/Space. Then bounded seamless window lifecycle comparison if stable.
Baseline74fbd6... trial: start0 in58s, control0, native frames100->475/tap674,409;
Android keyboard animation=false11:29:40.061. No SystemUI ANR in captured events.
This is a short baseline pass, so no candidate causal claim yet.

Evidence Nov8: lab evidence/integration-2026-11-08/component-control.
Build scripts/cache: lab tools/hwc-native-build; guest /opt/windroid-lab-tools/
hwc-native-build. See diagnostics/wayland-roundtrip/NATIVE-BUILD.md.
User unlocked Windows; refreshed native window usable. Prior handles expire on
normal restart. Original CPU/RAM/renderer/lab nested settings retained.
## Blockers, validation and uncommitted work
- Open: intermittent System UI ANR, seamless stale/resize presentation, first input,
  WSL VMBus channel allocation, Nintendo native crashes and remaining integration.
- Inno compiler install was rejected by automatic approval review (blocked by
  policy); do not retry through another launcher. Wizard UI remains untested.
- CPU comparison/source candidates committed ecbf33c. Pending:
  native probe/build documentation. Load-only is not service runtime validation.
- Raw binaries/APKs/SDKs/traces remain outside Git. No push/PR or quota automation.
- Journal: lab journals/ENGINEERING-JOURNAL.md. Prior detailed evidence remains
  under evidence/integration-2026-11-07/{kernel-path-control,cpu-budget-control}.
