# Windroid session state

Updated 2026-11-07, America/New_York. Read this before changing files.

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

## Actual environment and rollback status
- Distro Windroid; InstallRoot: lab runtime\Windroid. WSL3.0.3/WSLg1.0.79,
  binder kernel6.18.33.1-microsoft-standard-WSL2-windroid+ in public lab directory.
- Verified GApps system20260927/vendor20261022; official feed still lists this
  vendor as latest. Keep app/account data; never automate sign-in or credentials.
- Lab fallback NESTED_WESTON=true, MULTI_WINDOWS=false. Source defaults remain
  false/true. Normal GL renderer; no temporary overlays, forced sizes, global
  DPI override, HWUI Vulkan override or Weston --debug flag remains.
- Installed helper now includes uncommitted idle-time fix, SHA256
  bdbfba689dd18116b40cb1c6f49361eb678102e91093113dbcf15055bf9c687b.
- .wslconfig remains memory=3GB, autoMemoryReclaim=gradual. Host available RAM
  was743MiB/7778 at09:27; do not raise the cap blindly.
- Old root PTY11413 ended at WSL shutdown. Current retained root PTY40201 is
  alive with HISTFILE=/dev/null; verify session IDs after resets. Reuse it to
  avoid additional VMBus allocations. No listener/monitoring service installed.
- Nintendo currently installed ABI is x86 and target remains force-stopped.

## Active investigation and last successful operations
- Seamless/stale/black presentation remains intermittent. GL/Pixman and both
  HWUI Vulkan controls do not justify a renderer-default fix. Installed HWC
  already contains upstream focus-unlock and hotplug dimension guards; no
  blind rebuild. See docs/GRAPHICS-INVESTIGATION.md.
- Bounded HWC/SF backtraces showed idle polling/work waits, not the known focus
  lock cycle. Temporary Weston diagnostics later recorded mapped Settings
  surfaces, releases and continuing commits; Settings/Battery rendered.
  All instrumentation was removed. A titlebar movement attempt was inconclusive.
- New Windows shortcut activation at09:06 reproduced order7 VMBus ring allocation
  failure and UtilAcceptVsock110; exact blocked launcher4876 was cancelled.
  Clean WSL shutdown recovered it; this is recovery, not a permanent fix.
- Rapid warm activations later passed, but memory snapshots showed free memory
  moving into file cache. Causality is unproven. Source getAppsInfo enumerates
  apps/loads labels; a catalog query measured836ms versus259ms platform property
  plus393ms targeted PM query. No root permission/probe change was justified.
- Microsoft documents dropCache as another reclaim mode; it has NOT been applied.

## Exact next action: resume control and test native resize
Own org.windroid.lab.control APK built/signed successfully and is installed.
Original Windows request session1753262248 remains pending; direct guest
session1157688239 succeeded 2.4 seconds after return. Root diagnostic PM session
1485978451 also succeeded. The initial immediate PM query caught an async gap;
do not repeat earlier claims that direct guest installation failed.
CLI/tray wording now truthfully says Installation requested; tests pass.
Control launched and Android frames advanced, but native view went black.
Fresh Windows target binding/activation revealed Weston's own idle-lock overlay.
No Windows lock/authentication dialog was automated. Ubuntu's official Weston
manual confirms default300sec blank/lock and --idle-time=0 disables that timer.
Source now adds this flag only to the Windroid-owned nested compositor, with a
regression in delayed-socket startup. No Windows security/config changes.
Linux13 tests19.707s and GitBash13/3skips49.007s pass; syntax/ShellCheck0.
Helper deployed with backup; normal stop/start/control exit0 at10:31:22.
SystemUI ANR appeared, captured target trace; Wait then close-app recovery.
Control received native taps and Space; paused frame987 visibly confirmed.
Last UI input10:36:03.476; no-input observation10:41:35 showed identical paused
frame987, no idle overlay/black screen (>331seconds). Idle control PASS.
NEXT: resume with Space, confirm frames advance; test normal native window
resize using the own control, observe dimensions and composer/framework PIDs.
Do not force Android sizes/DPI or repeat prior renderer experiments.
Install wording fix committed8d09062; PS7/5.1 CLI/tray checks and parse/BOM pass.
Optional control source committed0e43a6e; verified build/sign and native input.
Current rootPTY40201; no live background jobs at last check; compositor15347.
Own APK SHA25606bce86e5d93514ccd923cb809beebb838302c24b127ecc4f67461db407ddfd5;
SDK/R8/devkey cached under lab tools/android-control, never commit those artifacts.
## Blockers, evidence and uncommitted work
- Unresolved: seamless graphics/framework crashes, WSL fragmented-memory new
  channels, AppData kernel lookup (public path works), Nintendo cause.
- Inno compiler download/install was rejected by automatic approval review as
  'blocked by policy'. Do not retry via another launcher. Core WOW64 detection
  is verified; compiled wizard UI remains untested. No approval is pending.
- Nested idle flag/regression and docs are ready for coherent commit; optional
  control and install wording already committed. Check actual Git state.
- Reports: docs/NINTENDO-3.6.0.md, GRAPHICS-INVESTIGATION.md and
  WSL-SESSION-RELIABILITY.md. Raw evidence: lab evidence/integration-2026-11-07,
  graphics-protocol-2026-11-06, 2026-11-06-runtime and nintendo-3.6.0.
  APKs/native binaries, raw tombstones/memory and GApps images stay local-only.
- Update this checkpoint/journal after findings, mirror substantive ROADMAP/
  CHANGELOG updates into lab, and commit coherent changes. No automatic quota
  continuation was configured; docs/CONTINUATION.md explains supported resume.
