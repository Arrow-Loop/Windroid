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
- Nov8 rollback completed0: container RUNNING in restored fallback. Lab NESTED_WESTON=true,
  MULTI_WINDOWS=false; runtime multi=false restored before stop. Config files
  byte-match Nov8 before-seamless backups. Source defaults remain false/true.
- Removed hash-verified owned HWC source-candidate overlay. Original vendor
  image remains unchanged, original HWC SHA256
  3dcfbc40b2944fd02d252b06c2eddbfcfd30b926f60d52a8d75ade245c68d1d8.
- Prior scoped composer-only preload restored from verified backups:
  /var/lib/waydroid/overlay/system/etc/init/init.waydroid.rc
  SHA256 762eece58f962bd9a0dc0efcc1a9ee0b591f94a2bd769d721e6ce0eb61398ab2;
  /var/lib/waydroid/overlay/vendor/lib64/libwindroid_queue.so
  SHA256 c80b386d7425c4f31f3ca8f264d9028254f6657000c9d87bfa4d2c7f93150578.
  Original RC backup in lab evidence/integration-2026-11-07/kernel-path-control/
  init.waydroid.rc.before-shim. Rollback this experiment by normal stop,
  hash-check/remove ONLY these two files and normal start.
- Windroid distro / lab runtime\Windroid, WSL3.0.3/WSLg1.0.79, binder kernel
  6.18.33.1-microsoft-standard-WSL2-windroid+. Official GApps images retained.
- Original .wslconfig SHA256 C86527AFE90712FC8B7C6CC8655A5C3F40A90A57D80F21801AE58F58C40D0879;
  eight CPUs, memory3GB/reclaimgradual. Normal GL; no size/DPI/Vulkan override.
- Installed helper SHA256 bdbfba689dd18116b40cb1c6f49361eb678102e91093113dbcf15055bf9c687b.
- Retained root PTY68395 alive. Variables i=Nov7 integration evidence,
  j=Nov8 integration evidence; b=guest native build root; c=lab build cache.
- Nintendo installed ABI x86 remains force-stopped. No protected app change.
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
Restoration validated: original HWC hash3dcfbc... and scoped shim mapping verified;
runtime multi=false; fallback start0 (11:58:13->12:00:07,114s), control0, native
frames460->2146, mouse512,375/taps1. Keyboard pause logged12:05:33.381; confirm
native paused frame if needed. IP/DNS each2/2 pass; no target ANR in captured log.

NEXT build a deterministic OWN-control input-block diagnostic (explicit intent
extra, off by default, one bounded block) to reproduce ANR modal visibility and
collect actual SurfaceFlinger layer metadata. Current HWC multi-window get_window
accepts TID layers and only InputMethod raw layers; other RawName layers are
ignored. This supports a modal-routing hypothesis, but actual ANR layer names
were not captured yet. Avoid a speculative routing patch before collecting them.
Keep existing verified SDK/jars/signing key; do not reinstall/redownload.

Original target ANR extracted only PID2816 from retained Nov8 11:53:48 trace.
Main nativePollOnce/JNI-end and render observer waiting at dump time; does not
prove cause at input timeout. Primary issue713 led to old per-layer fence fix
6aafe205; current source already has releaseFenceFd=-1 and no old per-buffer
fence timeline. Do not reapply old fix or reset Android data based on comments.
Evidence Nov8 component-control; source build/cache paths unchanged.
## Blockers, validation and uncommitted work
- Open: intermittent System UI ANR, seamless stale/resize presentation, first input,
  WSL VMBus channel allocation, Nintendo native crashes and remaining integration.
- Inno compiler install was rejected by automatic approval review (blocked by
  policy); do not retry through another launcher. Wizard UI remains untested.
- Build/probe documentation committed2eb12b5; nested-service results b44949f.
  Pending: current seamless investigation/checkpoint updates.
- Raw binaries/APKs/SDKs/traces remain outside Git. No push/PR or quota automation.
- Journal: lab journals/ENGINEERING-JOURNAL.md. Prior detailed evidence remains
  under evidence/integration-2026-11-07/{kernel-path-control,cpu-budget-control}.
