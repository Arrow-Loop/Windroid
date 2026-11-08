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
- Branch: codex/lab-reliability. Development branch published; no PR/merge performed. Use command-local commit
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
- Nov8 MODAL trial STAGED, container STOPPED. NESTED_WESTON=true,
  MULTI_WINDOWS=true; Android runtime multi=true was set before stop.
- Owned source queue+modal overlay:
  /var/lib/waydroid/overlay/vendor/lib64/hw/hwcomposer.waydroid.so
  SHA256 790b3148d7007d4fbf2ee1236827d347439ddb1f2612ea38bad5f28c1164449a.
  Staging0/hash verified; no pointer patch. Prior scoped RC/library overlays
  hash-checked/removed so they cannot mask the source trial. Original images
  unchanged; original HWC SHA2563dcfbc40b2944fd02d252b06c2eddbfcfd30b926f60d52a8d75ade245c68d1d8.
- Rollback: set runtime multi=false while container responds, normal stop0,
  run lab tools/hwc-native-build/restore-scoped-fallback-modal-local.sh.
  It verifies790... and saved original/scoped hashes, removes ONLY owned HWC
  overlay, restores original nestedtrue/multifalse config backups byte-for-byte
  and prior scoped RC/shim. Then normal start/verify actual hashes/property.
- Saved scoped files in guest build root rollback-scoped:
  RC SHA256762eece58f962bd9a0dc0efcc1a9ee0b591f94a2bd769d721e6ce0eb61398ab2;
  shim SHA256c80b386d7425c4f31f3ca8f264d9028254f6657000c9d87bfa4d2c7f93150578.
  Current these are absent from overlay; do not remove unrelated overlay files.
- WSL3.0.3/WSLg1.0.79, binder6.18.33.1-windroid+, official GApps retained.
  .wslconfig original SHA256C86527AFE90712FC8B7C6CC8655A5C3F40A90A57D80F21801AE58F58C40D0879;
  eight CPUs/memory3GB/reclaimgradual. Normal GL/no size/DPI/Vulkan override.
- Retained rootPTY68395; i=Nov7 evidence, j=Nov8 evidence, b=guest native build
  root, c=lab native-build cache. No second agent/writer.
- Nintendo unchanged/force-stopped. Only own diagnostic APK updated; fault now
  disarmed after bounded intentional test, no automatic fault submission/loop.
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
Modal source790... active after normal start0 in83s; hash/runtime true/no shim verified.
Default control launch0/native frames1469->1752; tap1 at662,323, no target ANR.
NEXT armed30s fresh own Activity and one native click, then test modal presentation/Wait/cleanup.
Prior plan: normal start
nested+multi=true, verify actual candidate map/hash and no shim, confirm runtime
multi=true. Launch own diagnostic normally; then explicit fresh armed30s Activity
and ONE native click to observe whether raw ANR dialog now appears as a window,
accepts Wait/Close and is removed after recovery. Do not call prototype a fix
before this runtime comparison. Restore original scoped fallback after bounded
trial using script above regardless of outcome.

Fixture30s is validated in nested full UI: begin12:18:16.504/end12:18:46.505,
intentional MotionEvent ANR after5002ms, raw ANR layer#189/native modal visible,
auto-dismiss on recovery and second click taps2/faultoff. No spontaneous failure
count from intentional trials. Original direct source-queue trial failed startup/
focus input; rollback was verified. Evidence under Nov8 component-control.

GitHub publication authorized; actual Git push succeeded37 commits through
cde4cff71a7a3ecb869504295289323cf69f2a86; branch tracks origin/codex/lab-reliability.
User completed GCM browser sign-in (exit0); no credentials read/logged. No API
snapshot/PR/merge/force-push. PROGRESS.md and AGENTS record periodic checkpoint
pushes. First CI run42505826944 failed stubborn-child timeout at30s on new Ubuntu26 runner.
CI target now pinned to shipped Noble24.04, unchanged strict tests; local6+13 pass.
Push this coherent CI/progress update, inspect hosted result afterward.
## Blockers, validation and uncommitted work
- Open: intermittent System UI ANR, seamless stale/resize presentation, first input,
  WSL VMBus channel allocation, Nintendo native crashes and remaining integration.
- Inno compiler install was rejected by automatic approval review (blocked by
  policy); do not retry through another launcher. Wizard UI remains untested.
- Build/probe documentation committed2eb12b5; nested-service results b44949f.
  Pending: current seamless investigation/checkpoint updates.
- Raw binaries/APKs/SDKs/traces remain outside Git. No PR/merge or quota automation.
- Journal: lab journals/ENGINEERING-JOURNAL.md. Prior detailed evidence remains
  under evidence/integration-2026-11-07/{kernel-path-control,cpu-budget-control}.
