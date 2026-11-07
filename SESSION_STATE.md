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
  Experimental composer-only queue overlay is active as detailed below.
- Installed helper includes committed idle-time fixbd8d2b6, SHA256
  bdbfba689dd18116b40cb1c6f49361eb678102e91093113dbcf15055bf9c687b.
- .wslconfig remains memory=3GB, autoMemoryReclaim=gradual. Host available RAM
  was743MiB/7778 at09:27; do not raise the cap blindly.
- Old root PTYs11413/40201 ended at WSL shutdown. Retained rootPTY1497 is alive
  with HISTFILE=/dev/null; verify session IDs after resets. Reuse it to
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

## Exact next action: bounded four-vCPU System UI startup control
Native queue diagnostic committed59f93f8; newer scoped source pending commit.
NDK25c ZIP SHA256769ee342ea75f80619d985c2da990c48b3d8eaf45f48783a2d48870d04b46108;
cached labtools/android-control, extracted /opt/windroid-lab-tools/android-ndk-r25c.
Original native20000-request stress: shared3/3alarm142; private3/3pass; broad
shim3/3pass. Broad prototype affected registryinit, so it was removed, not shipped.
Seamless broad trial: ready15:14:02, launch0. InitialwhiteWindowsframe was
confounded by SystemUIANR. After verified SystemUI495 TERM15:17:32, nativefull
controlvisible; tap377/883 andSpacepausedframe883 passed. Maximize15:21:06
recreatedActivity/view3000x1810, but Windows retainedold927x1553pausedview over
newupdatingview. Androidscreenshotonlynewview. Headerdragmovementinconclusive.
OldPID84tracequarantined wrong-pid84; actualcomposer85traceused. NoNintendochange.

Fallback restoration complete15:24:35: config/cfg byte-matchbackups in lab
kernel-path-control; runtime multi=false; broad overlay files hashchecked/removed.
New SCOPED shim uses privatequeue only for window::create, passes othercalls to
original; no hard-coded addresses, logsfirstpath. Source compiledstrictwarnings.
RealHWC84 logged originalinit15:26:35.852 thenprivatewindow15:26:35.857. Ready
15:28:36/control0 15:28:44; Windowscounter1291visible with separateSystemUIANR.
Warm own-probe outsideWindow callprintsoriginshim/originalbranch thenalarm142,
confirmingpass-through; firstboot-timeprobe0bytes is inconclusive, notqueueproof.

EXPERIMENT ACTIVE, composer-only LD_PRELOAD via two owned files:
- /var/lib/waydroid/overlay/system/etc/init/init.waydroid.rc
  SHA256762eece58f962bd9a0dc0efcc1a9ee0b591f94a2bd769d721e6ce0eb61398ab2
- /var/lib/waydroid/overlay/vendor/lib64/libwindroid_queue.so
  SHA256c80b386d7425c4f31f3ca8f264d9028254f6657000c9d87bfa4d2c7f93150578
Original image files unchanged. ActiveRCbackup init.waydroid.rc.before-shim in
lab evidence/integration-2026-11-07/kernel-path-control. ROLLBACK normalstop,
verifythesehashes/removeonly2files, normalstart and compareoriginalRC/no shimmap.
No globalpreload, privilege/security/renderer/DPI/size change. Source product
false/true defaults retained; lab nestedtrue/multifalse restored. RootPTY1497
alive, sourcehelperbdbfba... unchanged; Androidcontrol1673/SF106/SystemUI493.

NEXT: prepare one processors=4 .wslconfig trial with rawbackup/hash, retaining
memory3GB/reclaimgradual/kernel paths/nestedfallback/scopedshim. Baseline8vCPU
ready134sec andSystemUIKeyguardANR15:27:48. SystemUIalreadyAOTspeed/prebuilt,
so don'trecompile. CurrentSwiftShaderprimarysource defaults workerpool to logical
CPUcount (inference, notexactbinarysourceproof); baselineHWC had8workerthreads.
Hypothesis: fewerworkers reduce oversubscription/pressure on4physical-core/8GB
host. Microsoftdocuments processors key. Stopnormally/checkpoint/shutdownWSL,
which endsPTY1497. StartviarealWindowsCLI, verify nproc4/ready/ANR/UI; restore
original.wslconfig afterboundedtrialregardlessofresult. No CPUconfigchange yet.

## Blockers and evidence
- Unresolved: startupSystemUIANR, stalepresentation/resize, WSLmemorychannels,
  Nintendo nativecrashes. Queue intervention is diagnostic, not shipped fix.
- Inno install rejected by automatic approval review ('blocked by policy'); do
  not retry through another launcher. Compiled wizard UI remains untested.
- Pending: scopedshim source + docs/checkpoint; inspectdiffbeforecommit.
- Reports/evidence and journal retain exactcommands/results. Rawbinaries/APKs/
  SDKs/keys/memorytraces remain outsideGit. No push/PR or quota automation.