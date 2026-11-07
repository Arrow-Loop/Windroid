# Windroid session state

Updated 2026-11-07 (America/New_York).

## Objective and scope
Make Windroid reliable and investigate Nintendo Switch App startup. Work only
in this dedicated lab and Windroid repositories. Preserve upstream compatibility
and Android app/account data. No account automation, protected APK modification,
quota polling, retry submissions, paid-credit fallback, or parallel agents.

## Workspace and resume references
- Repository: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Handoff: lab HANDOFF.md; engineering journal: lab journals/ENGINEERING-JOURNAL.md.
- Read AGENTS.md, ROADMAP.md, CHANGELOG.md, docs/CONTINUATION.md, README.md and
  docs/PLAN.md, then actual Git branch/status/log/diff before modifying files.
- Branch codex/lab-reliability. No push/PR performed. Git is already installed
  at C:\Program Files\Git\cmd\git.exe. Use command-local commit identity only.
- Development shell is PowerShell7.6.9 (bundled); Windows PowerShell5.1 is a
  compatibility target. Do not reinstall tools for missing standard pwsh path.

## Completed work
- WSL prerequisites resolved after two Windows reboots. Verified release v0.1.0
  retained locally. VANILLA source install, smoke, integration, IP/DNS and
  uninstall validated; removed only that baseline after preserving evidence.
- Installer fixes: artifact discovery/cache/hash checks; GApps configuration
  gate, flavour stamp, initialization locking/retry; duplicate INI normalization;
  explicit SkipWslUpdate. Real resumed GApps smoke/integration completed exit0.
- CLI APK paths/error handling fixed. Core Sysnative WSL detection tested in a
  real32bit Windows PowerShell process: redirected System32 absent, Sysnative
  present and --status exit0. Compiled wizard page remains untested.
- Session helper fixes committed: lifecycle serialization, failure propagation,
  explicit nested socket readiness, live framework/package response required
  beyond stale ready log, bounded health query with TERM-to-KILL escalation.
  Thirteen Linux lifecycle tests and applicable Git Bash checks pass; ShellCheck and
  Bash syntax pass. Commits include db3d92c,4d2a694,83a4ca9; inspect actual log.
- Nintendo3.6.0/14330 unchanged signed x86_64 splits reproduce libpairipcore
  SEGV_ACCERR +0x794cb. Unchanged x86 split also fails with allocator abort and
  restart loop. Force-stopped; no successful compatibility result or bypass.
- GL/Pixman matched nested controls both rendered/navigated Settings; Pixman
  alone not a proven fix. Forced-size workaround produced an exact Wayland
  maximized buffer/configure error and was reverted. Compositor trace overlays
  removed and original definition byte-matched. Global DPI override reverted.

## Current environment and verified rollback
- Distro Windroid, InstallRoot lab runtime\Windroid; custom binder kernel
  6.18.33.1-microsoft-standard-WSL2-windroid+, WSL3.0.3/WSLg1.0.79.
- GApps system20260927 and vendor20261022 are verified local official images;
  do not redownload. Latest official vendor feed still lists20261022.
- Lab guest fallback NESTED_WESTON=true, MULTI_WINDOWS=false; Android persistent
  multi_windows=false. Source defaults remain seamless false/true.
- Boot-wide HWUI Vulkan trial activated in SystemUI, Launcher and Settings but
  Windows remained stale/splash while Android rendered Settings. An early
  system_server HIDL/media-codec crash confounds startup; no causal claim.
- Rollback COMPLETE: restored waydroid.cfg.before-boot-vulkan, original guest
  config and offline-derived props; no HWUI override or temporary overlays.
  Installed session helper is original GL default with committed fixes.
- Rollback start22:01:47->22:03:48 on Nov6: ready, exit0 (121s).
- Nov7 08:27 Android IP and DNS pings2/2 each; 08:29 live ensure exit0, both
  states running. Overnight wall-clock gap includes host sleep; not continuous
  uptime/stress proof. No networking dropout reproduced in these samples.
- Retained root WSL PTY11413 still live Nov7. Reuse if available to limit new
  VMBus allocations, but verify session ID after reset. No listener installed.

## Active investigation, validation and uncommitted work
- Tray fix974d6c5: Stop/Install could announce success after failure; its APK
  path still interpolated into shell source. Fix now checks native exit codes,
  passes APK path as a literal argument, and catches action failures for error
  balloons; restart stops on failed stop. Source and CI regression test changed.
- Focused tray tests execute real lifecycle callbacks without creating Windows
  UI, mocking WSL. APK spaces/apostrophes, selected distro, path/ensure/install
  failures, stale success text on failure, stop/restart/status failures and
  successful restart pass in PowerShell7 and5.1. Existing CLI tests pass in both.
  Changed PowerShell parse/BOM and Git whitespace checks pass.
- Tray fix committed974d6c5 and staged in runtime/bin; original script backed up
  in graphics evidence (matching SHA256 verified).
  No live tray/file-picker validation claimed. Check actual diff after reset.
- Evidence: lab evidence/graphics-protocol-2026-11-06 (boot-vulkan-*, rollback,
  overnight-*-2026-11-07); lab evidence/2026-11-06-runtime; Nintendo report
  docs/NINTENDO-3.6.0.md and local evidence/nintendo-3.6.0. Raw APKs/binaries,
  tombstones/memory dumps and GApps images remain local-only.

## Blockers and limits
- Seamless graphics and intermittent framework/compositor crashes remain open.
- Fragmented-memory order7 VMBus ring failures can break new WSL commands while
  retained terminal works. WSL shutdown recovers; compaction80 did not fix it
  and was not persisted. No unverified kernel/socket-buffer patch applied.
- AppData custom-kernel lookup failure unresolved; public lab paths work.
- Nintendo root cause unresolved; currently installed ABI is x86. Do not repeat
  rapid restart loops without a new diagnostic hypothesis.
- Automatic approval review rejected the Inno compiler download/install command
  as 'blocked by policy'. Do not retry through another launcher. Wizard UI
  compilation remains pending. No question/approval request currently pending.

## Last successful operation and exact next action
Tray fix974d6c5 committed/staged with backup; PS7/5.1 checks pass. Lab-only
bindfs read/write control PASS; unmounted and removed empty Android target.
Six awake IP/DNS samples08:33:31->08:38:42 allpass (12 commands,2/2 each).
No sampler remains running; source fixtures retained only in lab evidence.
Installed HWC already contains focus-unlock and hotplug dimension guards:
BuildID6c430943c45f04be014a87a0715b8653; no rebuild/image change justified yet.
Passive Nintendo analysis: runtime/filebytes match atPC0x794cb; eight-byte data
read fromrax+rdx falls in---mapping inall12records, whilePCisinr-x. Missing raw
fault address limits confirmation; intentionality/cause stillunresolved. No
relaunch or app/protection changes. Reports/journal and mirrored lab docs updated.
Live HWC84/SurfaceFlinger118 snapshots exit0: Waylandpoll/EGLsemwait/SFLooperpoll;
no sampled focus-lock cycle. Expected nested route verified. Temporary Weston
--debug diagnostic restart instead exposed lifecycle race: old stop returned
before Weston exit; start reused disappearing compositor and timedout180s
without launching replacement (08:48:47->08:51:52). Three new isolated tests
fail old helper. New source waits bounded own-UID Weston exit on stop and
rechecks disappearing existing compositor while waiting for socket on start.
All13 Linux lifecycle tests pass18.565s; syntax/ShellCheck pass. Git Bash13-test run also passes41.834s with3 Linux-only skips.
Existing Windows Python: C:\Users\sdelo\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe
WINDROID_TEST_BASH=C:\Program Files\Git\bin\bash.exe; PATH python is only an
unusable Store alias. Do not install Python or repeat discovery.
LIFECYCLE FIX validated and ready to commit: rootfs/files/usr/local/bin/windroid-session
and rootfs/test-session.py. Three new tests fail old source; all13Linuxpass18.565s,
GitBashpass41.834s with3Linuxskips; syntax/ShellCheck pass. Temporary--debug
flag REMOVED; installed/source SHA25601afec178e057cc9eaeb286cf1267a679b562b939c95771f15787a4f8aeaccc6.
Actualnormalimmediatecycle: stop09:00:19->09:00:25(6s), oldWeston25619absent,
newPID29196, readiness09:01:53(88s), exit0. Diagnosticrunbeforethis renderedSettings
andlaterBattery; scenegraphbufferrelease/commitscontinue. No graphicsfixclaim.
Postfixednormalrestart Settings native Network page rendered; IP/DNS2/2 each,
controlscompleted09:02:39. No debugflag remains. This is one successfulcycle,
not a long-session/seamless proof. Current checkpoint commits the lifecyclefix
with source/tests/report validation; inspect actual Git log for commit ID.
Windows Settings shortcut exists and desktop sync completed0; ComputerUse's
installed-app inventory omitted it. ActualLNKactivation09:06 failedknownWSL
transport: order7vmbus/hvs allocation andUtilAcceptVsock110, no guestactivity.
Stopped only exact verified Windowswslg launcherPID4876; retainedPTYworks.
NEW TRAY SHORTCUT FIX: WSLg scans/deletes unreported links AND referencedicons
insideDistrofolder. OriginaltrayLNK/rooticonmissing, biniconretained. Source
installer creates `<DistroName> Tools` LNK withstablebinicon, repairs/migrates
oncompletedinstall, guardedlegacytargetremoval; uninstallerpreservesotherTools
files and validatesdistroname. Trayprefersbinicon. PS7/5.1shortcutfixturesand
existingtraycommandsPASS; changedparse/BOMpass. Actualall9completedinstaller
resumeexit0 repairedWindowsToolsLNK(correctCOMtarget/args/icon); stagedupdated
traywithbackup. Sourcefixreadytocommit; resyncsurvivalnotyetvalidated.
NEXT: commit coherent shortcutfix/docs, stop currentguestnormally via retained
rootPTY, then `wsl --shutdown` fromPowerShell7 to recovertransport. This ends
PTY11413. Open ONE newrootWSLterminal withhistorydisabled, startnormally, verify
newToolsLNK/binicon surviveWSLg resync and actualSettingsLNKactivation reaches
guest; record result. Do not reinstall/resetimages or changeaccountdata.
No quota/serviceautomation. Currentlabfallbacknestedtrue/multifalse, normalGL,
no temporarydebugflag/overlays. Sourcehelper0c6ff1a installed/hashverified.
