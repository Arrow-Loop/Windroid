# Windroid session state

Updated 2026-11-06 (America/New_York), validation checkpoint about20:33 local.

## Objective and scope
Make Windroid reliable and investigate Nintendo Switch App startup. Work only in
this dedicated lab and Windroid repositories. Preserve upstream compatibility.
No quota polling, resets/credits, parallel agents or personal-account automation.

## Workspace and history
- Repo: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Journal: lab journals/ENGINEERING-JOURNAL.md. Read HANDOFF.md and dev guidance.
- Branch codex/lab-reliability; commits db3d92c Weston readiness; 4222460 Nintendo report/checkpoint.
- Earlier commits: ba4e275 Sysnative; 3eb30d8 installer/firstboot; 80a6332 INI
  normalization; 4a69a11 CLI APK argument/error handling. No push/PR performed.
- PowerShell runtime is already 7.6.9 (bundled Codex pwsh); standard Program
  Files PowerShell7 path is absent. Do not reinstall tools just for that path.

## Completed and verified
- WSL prerequisites resolved after two reboots; WSL3.0.3, WSLg1.0.79. Windows
  boot 2026-11-06 18:42:39 local. vmcompute available; custom binder kernel
  6.18.33.1-microsoft-standard-WSL2-windroid+.
- Official v0.1.0 ZIP verified under evidence/release-v0.1.0 (reuse).
- Source VANILLA initialization/smoke/integration passed; IP and DNS ping passed.
  Startup80-91s. Real duplicate INI properties fixed. VANILLA later uninstalled
  with evidence preserved; old AppData distro/root removed after path checks.
- Current GApps initialized using verified local-only official system20260927
  and vendor20261022. GAPPS stamp/Play Services presence verified. Initial smoke
  timed out180s; manual starts later became ready; bundled apps installed.
  Resumed source installer completed smoketest/integrate exit0; state records
  all stages. Smoke began already-ready and stopped cleanly. Separate start
  then reached ready in83.361s. Account/seamless-graphics usability unresolved.
- Updated composer matches upstream Binder-threadpool fix; seamless Windows
  app windows still splash/freeze while Android screencap shows UI. Global
  HiDPI experiment failed and was reverted. Nested fallback is temporary.
- User-supplied APKM identity/signatures inspected, unchanged x86_64 splits
  installed; Nintendo3.6.0/14330 crash reproduced: SIGSEGV/SEGV_ACCERR,
  libpairipcore.so+0x794cb. Twelve tombstones in ONE launch window, not12 trials.
  Root cause unresolved; no APK modification/protection bypass or account login.
- Official signed x86 splits successfully installed in package session2058170059
  with --abi x86 (replace, preserving data). Earlier failed ENOMEM session was
  abandoned. Current installed Nintendo ABI is x86, NOT x86_64.

## Environment and active investigation
- Distro Windroid; InstallRoot C:\Users\Public\Documents\Cody-Windroid-Lab\runtime\Windroid.
  Kernel/modules under public root; old AppData kernel lookup failure unresolved.
- Guest config NESTED_WESTON=true, MULTI_WINDOWS=false; runtime multi_windows=false.
  Source defaults remain false/true. Preserve GApps/Android user data; user may
  have signed into Google. Never inspect credentials or automate account UI.
- Kernel order7 vmbus_alloc_ring/hvs_probe failures precede WSL new-session
  WSAETIMEDOUT (upstream WSL#40795). Runtime compaction80 experiment did NOT
  prevent recurrence and was not persisted. WSL shutdown recovers channels.
- Established persistent root WSL PTY52561 after prior shutdown; reuse it rather
  than opening many WSL commands under fragmentation. It may expire on reset:
  never assume tool session IDs remain live. No listener/service was installed.
- Fresh source session start reached ready20:13:18. Session helper in guest has
  committed Weston socket wait fix (db3d92c): explicit wayland-1, actual readiness wait
  instead of fixed2sec, early child exit diagnostics. Real socket previously
  appeared after4sec, causing launch failure. Seven Linux lifecycle tests pass.
- x86 first launch20:13:56: pid3679 after4sec; no target x86 tombstone. Force-
  stopped after collection, relaunched20:14:59; later pid9399 top BootActivity.
  Longer check found SIGABRT/restart loop, NOT survival. PID20270 libc reports
  invalid pointer/page signature mismatch and recursive signal-handler abort.
  Target force-stopped20:17:06; pidof then empty. System UI ANR observed.

## Last successful operation and exact next action
Resumed actual installer smoke/integration exit0; installed CLI status STOPPED.
Separate post-smoke start reached ready83.361s. Android IP/DNS pings passed2/2
both before and after lifecycle restart. Settings rendered visibly in nested
Weston after restart; System UI ANR no longer visible in that check. Window
movement remains unproven (first automation drag blocked by other window, retry
returned screenshot without clear movement). No seamless graphics fix claimed.
ConnectivityService reports validated Ethernet; installed CLI reports both states
RUNNING on wayland-1. Exact Android fingerprint: waydroid/lineage_waydroid_x86_64/
waydroid_x86_64:13/TQ3A.230901.001/eng.aleast.20260927.143833:userdebug/test-keys.
Kernel-tag comparison found unchanged VMBus allocator; no blind rebuild done.
Read docs/WSL-SESSION-RELIABILITY.md before further transport experiments.
AOSP linker allocator source matches x86 diagnostic, but no installed symbol
match/caller/root cause established. Report updated with source/limits.
Ordinary Settings control stayed rendered about10min; bounded crash filter had
no matching fatal records and Nintendo pid absent. shared_memory mount/boot hook
verified. Runtime ANGLE+pastel over SwiftShader is intentional upstream vendor33
substitution, not a failed property override (see UPSTREAM-FACTS follow-up).
Next: inspect Waydroid hwcomposer source/environment setup for a supported way
to collect a bounded Wayland configure/ack/attach trace for one Settings launch.
Use that new evidence to compare the historical 1x1/2x surface-buffer mismatches;
preserve working contained fallback/config backups and Android data. Do not
repeat direct-mode/DPI tests without this specific diagnostic instrumentation. WSL fixes require a distinct
controlled upstream patch experiment, not repeating compaction/rebuild guesses.
## Validation, uncommitted work and blockers
- Completed code/tests committed db3d92c; Nintendo report checkpoint4222460.
  Current documentation checkpoint includes resumed GApps/network validation and
  WSL transport runbook committed bd6f90c. Current checkpoint adds verified
  modern software-renderer identity; check actual Git state for final status.
- Linux seven lifecycle tests and bash syntax pass. Git Bash applicable suite
  passed (two Linux-only tests skipped). Installed ShellCheck0.9.0; changed helper
  passes shellcheck -S warning (evidence/session-shellcheck.txt).
- Prior firstboot6 Linux tests, CLI/artifacts PS7/5.1 checks pass as documented.
- Blockers: seamless graphics, intermittent SurfaceFlinger DEAD_OBJECT abort,
  WSL fragmented-memory new-channel failures. Nintendo cause still unresolved.
- Evidence: lab evidence/2026-11-06-runtime and evidence/nintendo-3.6.0. Raw APKs,
  native binaries, tombstones/memory dumps and GApps images remain local-only.
  Bundle bb97fcb5123085bf3fe7793724bec516bb2b10a3e74358997d31c8ab6775cc95.
