# Windroid session state

Updated 2026-11-06 (America/New_York).

## Objective and scope
Make Windroid reliable and investigate Nintendo Switch App startup. Work only in
this dedicated lab and Windroid repositories. Preserve upstream compatibility.
No quota polling, resets/credits, parallel agent or personal-account automation.

## Workspace and history
- Repo: C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid
- Lab: C:\Users\Public\Documents\Cody-Windroid-Lab
- Branch: codex/lab-reliability. Read Git status/diff/log on every resume.
- Commits: ba4e275 Sysnative; 3eb30d8 configure/firstboot protocol; 80a6332
  structured INI normalization; 4a69a11 CLI APK path/error handling.
- Read lab HANDOFF.md and journals/ENGINEERING-JOURNAL.md plus roadmap/changelog.
- No push or PR performed. Source rootfs images have not been rebuilt.

## Completed and verified
- Windows boot 2026-11-06 18:42:39 local; WSL prerequisites now working.
- Current WSL 3.0.3, WSLg 1.0.79. Earlier update completed via delegated MSI even
  after its parent command was cancelled; do not assume WSL 2.7.14 remains.
- Original v0.1.0 ZIP verified/extracted in evidence/release-v0.1.0; reuse it.
- VANILLA installed from source + old release artifacts; binder kernel active,
  smoke test passed, bundled apps/integration created. DuplicateOptionError on
  retry fixed using configparser. Routing + DNS pings passed. Starts took 80–91s.
- Captured composer Binder-threadpool abort matching upstream 4aee4c8. Tested
  official vendor20261022 with verified ZIP hash; no immediate repeat of this
  abort, but Windows stayed at splash while Android screencap showed full UI.
- Disabled WSLg HiDPI in an isolated test: unsuccessful, SurfaceFlinger crash.
  Reverted config; original per-app defaults remain in source.
- Preserved VANILLA evidence/state, checked exact deletion paths, successfully
  ran source uninstaller. Old AppData install/distro and its internal vendor
  backup are gone; original artifacts and external evidence are retained.
- Clean GApps installation uses PUBLIC InstallRoot (see below). Initial native
  mirror download was slow; cancelled that exact init process, fetched the same
  official system ZIP via direct SourceForge mirror, verified OTA hash, and
  locally preseeded GAPPS system + official vendor20261022. Images are local-only.
- GApps firstboot success stamp is GAPPS. Installer smoke test initially failed
  readiness at 180s. A subsequent manual start reached readiness and installed
  bundled apps. Installer still has smoketest/integrate stages pending.
- Google Play Store package launched and its native window was observed at
  splash. User requested Store access; per-app rendering remained broken.

## Current environment / active user handoff
- Distro Windroid; InstallRoot:
  C:\Users\Public\Documents\Cody-Windroid-Lab\runtime\Windroid
  Kernel/modules under this root; no AppData kernel path now. Original AppData
  kernel lookup failed despite shell access; public path works (cause unresolved).
- Guest /etc/windroid/windroid.conf currently NESTED_WESTON=true,
  MULTI_WINDOWS=false for the temporary contained-desktop fallback. Source
  defaults remain false/true respectively. Android runtime multi_windows was
  set false after fallback startup. Nested Weston start returned session ready.
- Launched WAYLAND_DISPLAY=wayland-1 waydroid show-full-ui and Play Store.
  Native window: Weston Compositor - wayland0 (Windroid), last handle1181240.
  Always rediscover handles. Computer Use detected USER INPUT when trying to
  foreground it, so stopped UI automation and left control to the user.
- Do not inspect/automate Google sign-in or capture credentials. Once user signs
  in, do not reset/uninstall/delete Android user data without explicit approval.
- User says original Nintendo APK/tombstone are not in lab (app came from Play).
  User now downloaded a supposed Nintendo app from APKMirror; matching filename
  not found in local Downloads. Asked for its FULL PATH, reply pending.
  Inspect package/version/architecture/signing data before installation. Do not
  claim it is the original x86_64 3.6.0 until verified. No protection bypasses.

## Key reliability findings
- WSL new-session timeouts correlate with order-7 allocation failures in
  vmbus_alloc_ring/hvs_probe and UtilAcceptVsock110. Matches WSL issue40795.
  A WSL shutdown recovered the guest; no Windows reboot needed.
- Runtime-only compaction_proactiveness changed 20 -> 80 after last recovery;
  one-shot compact_memory ran. No persistent kernel/sysctl change or production
  fix claimed. Evidence fallback-recovery.txt and vsock-memory-diagnostics.txt.
- A stopped container and RUNNING session were insufficient health signals;
  lifecycle helper now serializes start/stop, waits readiness without duplicate
  spawn, checks both states, closes locks in detached children, propagates stop
  failure, and supports SESSION_READY_TIMEOUT (default180, 1..600).
- Five isolated lifecycle tests pass on Linux (real flock) and applicable tests
  pass on Git Bash (concurrency skipped). Six firstboot tests pass on Linux.
  Artifact and CLI tests pass in PowerShell7 and5.1; parse/syntax/diff checks pass.
  Real GApps stability/graphics are still unresolved; do not claim otherwise.

## Last successful operation / exact next action
Contained fallback startup returned ready; Play Store launch command returned0.
User input detected in Weston; leave account UI to user. Wait for APKMirror path
or user download confirmation while finishing independent code/doc work. Do not
restart Android while the user is signing in/downloading.
Then inspect only the supplied app artifact or target package metadata, verify
identity/version/ABI/signature, and reproduce Nintendo startup with scoped logs.
For runtime testing, preserve current GApps installation and user data. Finish
installer health/integration stages only after status/readiness verified and
without resetting configuration/account state. Investigate permanent seamless
rendering and WSL memory-fragmentation fixes separately from temporary fallback.

## Evidence and validation pending
All logs/images/manifests under lab evidence/2026-11-06-runtime, including
android-settings.png, composer-crash-full.txt, vendor-update.txt, DPI experiment
logs, vanilla-uninstall.txt, gapps-install.txt, gapps-retry-local-images.txt,
gapps-local-images.txt, lifecycle diagnostics and fallback recovery log.
GApps image ZIPs under gapps-local-only are NEVER to be committed or published.
No Nintendo crash reproduced on this laptop yet. Original handoff: x86_64 3.6.0,
com.nintendo.znca, SIGSEGV/SEGV_ACCERR libpairipcore.so PC0x794cb.