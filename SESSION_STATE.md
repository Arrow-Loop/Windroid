# Windroid session state

Updated 2026-11-08 13:15 America/New_York. Read before changing files.

## Objective and authorization
Make Windroid reliable and investigate Nintendo Switch App startup. Continue
without routine approval; tools/WSL/runtime tests/reboots authorized. Preserve
Android data/upstream compatibility. No protection bypass, unrelated accounts,
quota polling/retry submissions/credit purchases/API fallback or second agent.

## Workspace and references
- Repository: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Handoff: lab HANDOFF.md. Journal: lab journals/ENGINEERING-JOURNAL.md.
- Read AGENTS.md, ROADMAP.md, CHANGELOG.md, docs/CONTINUATION.md, README.md and
  docs/PLAN.md; inspect branch/status/log/diff and actual processes before work.
- Branch codex/lab-reliability tracks origin/codex/lab-reliability in
  Arrow-Loop/Windroid. Periodic checkpoint pushes authorized; no PR/merge/force.
- Git C:\Program Files\Git\cmd\git.exe. Command-local automation identity only.
- Current tools use bundled PowerShell7.6.9; use Join-Path $PSHOME pwsh.exe.
  C:\Program Files\PowerShell\7\pwsh.exe absent. WindowsPowerShell5.1 is a test
  target; process-only ExecutionPolicy Bypass used, no global policy changes.
- Python C:\Users\sdelo\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe.
  PATH python Store alias is nonworking. Git Bash C:\Program Files\Git\bin\bash.exe.

## Completed work
- Installer artifact discovery/cache/integrity, Sysnative detection, GApps
  flavour/order/config/locking/retry and duplicate INI properties fixed.
  Real VANILLA install/smoke/network/uninstall and resumed GApps controls pass.
- CLI literal APK paths/failure propagation and tray failure notifications fixed;
  PS7/5.1 fixtures pass. Asynchronous install completion remains open.
- Session serialization/live framework/socket readiness/probe termination fixed;
  nested compositor idle blanking and stop/restart socket/exit races fixed.
  Linux firstboot6/lifecycle13 pass; actual immediate restart/input/network pass.
- Windows-owned Tools tray shortcut/bin icon survive WSLg resync; actual installer
  repair and cold/warm Windows Settings shortcut launch/render pass.
- Lab-only bindfs read/write and repeated awake IP/DNS controls pass. No continuous
  uptime/network reliability claim; clipboard/audio/live tray UI remain open.
- Passive Nintendo report docs/NINTENDO-3.6.0.md: unchanged x64/x86 both fail.
  Twelve existing x64 samples agree on libpairipcore+0x794cb eight-byte data read
  into no-access mapping, PC executable. Cause unresolved; no bypass/new launch.
- Isolated baseline/queue/pointer/modal composer builds compile/strict-link/load.
  Shared queue native stress fails3/3; private3/3 passes. Real baseline and queue
  candidate nested frame/input short controls pass, neither causal/perf proof.
- Direct queue-only trial failed180s live readiness and focus input. Android ANR
  dialogs were invisible in native app window. One verified SystemUI recovery
  did not fix subsequent own-control FocusEvent ANR. No direct resize proof.
- Narrow raw-ANR routing prototype790... passed nested+multi startup83s, normal
  frame/input, raw dialog presentation, auto-dismiss windows2->1, and native
  Android Close app: PID3389 killed12:57:59, user request after error, windows0.
  Normal launcher relaunch0/PID3526/faultoff/tap662,323/frame648 pass.
  Wait/native titlebar close/scaling/multiple dialogs/direct WSLg unvalidated.
- Own permission-free diagnostic optional explicit10..90s one-shot fault built,
  signed/updated with original signer. Default30s, normal/recreation disabled,
  invalid bounds disable. APK SHA256 ea76d3eff271cffe88c9c8ae7f6e35a298a6668c5a6f9cda7d766759091a9fcb.
  Intentional ANRs kept separate from spontaneous failures. No other app changed.

## Actual environment and last successful operation
- WSL3.0.3/WSLg1.0.79, binder6.18.33.1-windroid+, retained official GApps images.
  Original .wslconfig SHA256 C86527AFE90712FC8B7C6CC8655A5C3F40A90A57D80F21801AE58F58C40D0879;
  eight CPUs, memory3GB/reclaimgradual; no DPI/size/Vulkan override.
- Modal trial ended. Runtime persist.waydroid.multi_windows=false set0; normal
  stop0; restore-scoped-fallback-modal-local.sh0. Config backups byte-match:
  NESTED_WESTON=true/MULTI_WINDOWS=false. Owned modal HWC overlay removed only
  after790... hash verified. Original images unchanged; fallback start0 at13:02:24 (112s).
- Prior scoped lab RC/shim restored (not pristine production):
  /var/lib/waydroid/overlay/system/etc/init/init.waydroid.rc
  SHA256762eece58f962bd9a0dc0efcc1a9ee0b591f94a2bd769d721e6ce0eb61398ab2
  /var/lib/waydroid/overlay/vendor/lib64/libwindroid_queue.so
  SHA256c80b386d7425c4f31f3ca8f264d9028254f6657000c9d87bfa4d2c7f93150578.
  Original active HWC verified3dcfbc40b2944fd02d252b06c2eddbfcfd30b926f60d52a8d75ade245c68d1d8.
- Retained root WSL PTY68395 idle after start0/original HWC/scoped map/runtime false verified. HISTFILE=/dev/null. Root vars repo, j=Nov8
  evidence, i=Nov7 evidence, b=/opt/windroid-lab-tools/hwc-native-build,
  c=lab tools/hwc-native-build. Refresh LXC initpid after restart.
- Guest Android data /home/windroid/.local/share/waydroid/data. Do not dump unrelated
  app/account contents. Nintendo unchanged/force-stopped. Own fault was off before stop.

## Publication and validation
- User manually completed GCM browser sign-in; no credentials inspected/logged.
  Push37 commits through cde4cff succeeded; subsequent594f749/f640b37 pushed.
  Remote9ff44628d82b811372551dd6194c7a745979b1c7 verified; modal checkpoint pushed.
- CI first failed timeout regression on ubuntu-latest26. Kept strict test/deadline,
  pinned shipped Noble24.04 and print timeout version. Hosted firstboot6/lifecycle13
  pass. Later CLI assertions passed but expected LASTEXITCODE4 leaked into wrapper;
  f640b37 clears status only after success. PS7/5.1 CLI/tray wrapper exit0/BOM pass.
- Hosted runs42507669546 and42508236932 all green; latest modal checkpoint: https://github.com/Arrow-Loop/Windroid/actions/runs/42507669546
  Not a Windows runtime/complete graphics certification.
- PROGRESS.md is the public status; push coherent milestones roughly30–60min of
  active work and before substantial handoff. No APK/SDK/keys/rawprivate logs.

## Blockers and incomplete scope
Intermittent SystemUI ANRs, seamless presentation/focus/resize, ignored first
pointer-enter coordinates, WSL VMBus order7/channel allocation, Nintendo crash,
asynchronous APK installation completion and remaining Windows integration.
Inno compiler install previously rejected by automatic approval review; do not
retry via another launcher. Compiled wizard UI untested. No supported automatic
allowance-reset continuation verified/configured; checkpoint does not run Codex.

## Uncommitted work and exact next action
Modal/fixture checkpoint9ff4462 committed/pushed/CI green. Last runtime fallback
start0 in112s, original HWC/scoped map/runtimefalse verified; own normal launch0,
native frame926/tap662,368/faultoff. Further documentation checkpoint pending.

## Latest resolved observation: installation confirmation
User reported seeing an app scan prompt (possibly Play Protect), clicked Scan,
then Install. Do not treat this helpful intervention as an error. Agent had not
observed the actual prompt, so exact provider/text remains user-reported.
At13:14:25 verified own org.windroid.lab.control lastUpdateTime13:11:54 and
session1002420193 mDestroyed=true/mFinalStatus=1/Session installed/mSessionApplied=true.
Windows request at13:08:34 therefore completed after user interaction, not while
initial CLI returned. No install retry, root-PM substitute, data clear or verifier
setting change was needed. Staged APK had matched the verified source hash.
Evidence: Nov8 component-control/own-install-request-sessions.after-user-approval.txt.
The previous pending-session trace is historical; do not resume debugging it as stuck.
User interaction plausibly explains this wait but scan-provider/internal cause was
not instrumented. Original Nov7 pending session cause remains unconfirmed.

## Exact next action
1. Update/push this confirmation checkpoint. Latest earlier remote278f6ba; clean
   runtime remains original HWC+scoped lab shim/nestedfallback/runtime multi=false.
2. Inspect installer/CLI/tray documentation for accurate guidance that Android may
   require an on-screen scan/confirmation after Installation requested. Do not
   promise completion, suppress verification or approve security prompts blindly.
   For a future owned install, actively capture the actual dialog before deciding
   whether its buttons may be automated under computer-use rules. User handles
   any security/privacy consent action requiring their decision.
3. Continue remaining roadmap: live tray/integration and direct graphics/focus.
   Modal candidate remains separate from product until further direct/native-close/
   scaling tests pass. Nintendo unchanged, no need for new target launches.

Screen inspection is on demand during active work, not continuous monitoring.
Save context and actual outcomes; no polling/submission service or quota fallback.
