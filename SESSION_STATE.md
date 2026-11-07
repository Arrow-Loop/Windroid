# Windroid session state

Updated: 2026-11-06 (America/New_York).

## Objective
Make Windroid reliable: installation/GApps, sessions, networking, Windows
integration, graphics and Nintendo Switch App compatibility. Continue autonomously
while active; preserve evidence and upstream compatibility.

## Workspace
- Repository: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Branch codex/lab-reliability; origin Arrow-Loop/Windroid.
- Read lab HANDOFF.md and journals/ENGINEERING-JOURNAL.md before resuming.
- Historical commits: ba4e275 Sysnative fix, 3eb30d8 installer/guest protocol,
  afad1d0 prerequisite diagnosis. No push/PR yet.

## Completed work / last successful operations
- Both prerequisite reboots completed. Last boot: 2026-11-06 18:42:39 local.
  vmcompute now exists; WSL2 works. No more prerequisite reboots needed.
- WSL update originally stalled on an invisible consent prompt. Its delegated
  MSI finished successfully despite cancellation of its parent wsl command.
  Current WSL 3.0.3, WSLg 1.0.79; do NOT assume earlier 2.7.14 baseline remains.
- Official v0.1.0 ZIP already downloaded, hash verified and extracted in lab
  evidence/release-v0.1.0/Windroid/artifacts. Do not redownload.
- Installed distro Windroid at %LOCALAPPDATA%\Windroid\distro\vm using those
  artifacts and source installer. All state.json stages complete; smoke PASS,
  bundled apps installed, CLI and Start Menu integration created.
- Kernel AppData path returned WSL_E_CUSTOM_KERNEL_NOT_FOUND despite file being
  present/readable by the shell. Public-directory probe WORKED. Current global
  .wslconfig points kernel and modules into lab evidence/2026-11-06-runtime/
  kernel-access-probe. Original config is saved there as wslconfig-before.txt.
  Do not delete these kernel files. Installation state still records the old
  value paths; reconcile metadata before relocating files/uninstall testing.
- Active kernel: 6.18.33.1-microsoft-standard-WSL2-windroid+; binder works.
  firstboot stamp /var/lib/windroid/.initialized contains VANILLA.
- Runtime found duplicate rendering properties after Waydroid rewrote INI keys
  with spaces. Replaced sed/grep property insertion with atomic configparser
  normalization, including explicit multi_windows=false support. Applied helper
  to guest; retry passed firstboot and full installer smoke test.
- Six isolated firstboot tests PASS inside real WSL, including concurrent flock
  serialization and spaced/duplicate property normalization. Five applicable
  tests PASS on Git Bash (concurrency test Linux only). Artifact tests PASS on
  PowerShell 7 and 5.1; parse/bash syntax/diff checks pass.
- One clean post-WSL-shutdown session start succeeded in 80 seconds. Both session
  and container RUNNING, IP 192.168.240.112. Android ping 1.1.1.1 and example.com
  PASS (routing and DNS), evidence saved. Settings app launched into its own
  WSLg window; first screenshot showed its splash only, inspect again.

## Active investigation and risks
- Session warm restart exceeded 90s and an overlapping WSL diagnostic returned
  WSAETIMEDOUT. WSL shutdown recovered guest (systemd running). Root cause not
  established; host free RAM was ~660 MB. Do not claim stable sessions yet.
- Initial Android SystemUI KeyguardService/AppOpsControllerImpl NPE observed in
  crash buffer during first boot. Later sys.boot_completed=1; transient vs ongoing
  failure not determined. Preserve logs before changing images.
- GApps, move/resize/clipboard/audio, uninstall/coexistence and Nintendo untested.
  Nintendo exact APK/tombstone absent here; handoff: x86_64 3.6.0 com.nintendo.znca,
  SIGSEGV/SEGV_ACCERR libpairipcore.so PC 0x794cb. No account sign-ins or bypasses.
- No quota polling/automatic reset/credit fallback configured; no parallel agent.

## Uncommitted work
Structured firstboot property normalization, six-test regression suite, installer
-SkipWslUpdate switch (still enforces minimum version), README and this checkpoint.
Commit coherent changes with actual results before a substantial session ends.

## Exact next action
Inspect Settings window again (Computer Use sky target returned msrdc.exe window
1836442, title Settings (Windroid); rediscover fresh handles after resets).
Capture Android runtime/crash logs and confirm app reaches usable settings UI.
Save validation and commit the firstboot normalization + skip-update changes.
Continue warm start/stop reliability and graphics/network checks. Then stop the
single Waydroid stack and validate GApps via clean reinstall, preserving baseline
logs and fixing install metadata/kernel access path deliberately. Never run two
Waydroid stacks concurrently. Do not claim the Nintendo crash fixed without logs.

## Evidence / resume
Lab evidence/2026-11-06-runtime contains installation transcripts, kernel access
probe/config backup, cold-guest-baseline.txt, cold-session-start.txt,
cold-running-status.txt, android-ip-connectivity.txt, android-dns-connectivity.txt.
Read AGENTS.md, this file, ROADMAP.md, CHANGELOG.md, docs/CONTINUATION.md and Git
status/diff on resume. Reopen this chat and say Resume Windroid.