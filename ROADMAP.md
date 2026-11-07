# Windroid lab roadmap

Updated 2026-11-07. SESSION_STATE.md records the exact next action. Historical
checkpoints remain in Git and the engineering journal; completed work below
must not be repeated just because an earlier journal entry was pending.

## Next priorities
- [ ] Validate live tray actions after committed974d6c5 (PS7/5.1 checks pass); staged with
  backup in lab runtime; live file-picker/notification-area behavior remains open.
- [ ] Isolate seamless WSLg presentation and framework/compositor instability.
  GL/Pixman nested controls can navigate; neither partial nor boot-wide HWUI
  Vulkan proved a fix. All temporary renderer/size/protocol overrides removed.
- [ ] Resolve WSL fragmented-memory VMBus/new-session failures with a specific
  upstream-backed hypothesis, bounded baseline and rollback.
- [ ] Continue networking across actual awake sessions and lifecycle cycles.
  IP/DNS controls pass, including Nov7 after overnight gap; sleep prevents a
  continuous-uptime claim. No dropout reproduced yet.
- [ ] Investigate Nintendo3.6.0 runtime cause using unmodified controls and
  preserved evidence. Both x86_64 and x86 fail. Passive x64 analysis identifies a data read into a
  no-access mapping; its cause remains unresolved. No bypass or compatibility claim.
- [ ] Finish Windows integration checks: live tray, app shortcuts, lab-only file
  sharing, clipboard/audio and window movement. Do not inspect account data.
- [ ] Compile/exercise wizard page when compiler installation is permitted;
  prior installation was rejected by automatic approval review. Core Sysnative
  detection is already verified in a real32bit process.
- [ ] Diagnose AppData kernel lookup; public lab kernel/modules path works.
- [ ] Confirm owner recovery-image availability before destructive recovery.
- [ ] Prepare narrowly scoped validated upstream contributions and test matrix;
  no push/PR performed yet. Broader hardware/coexistence coverage remains open.

## Completed and evidenced
- [x] Audit authorized dedicated Windows11Pro/i5/8GB host; existing Git/tools,
  handoff and upstream development documentation reviewed.
- [x] Establish tracked continuation/checkpoint and engineering journal. No
  supported automatic quota-reset trigger verified; no submission loop added.
- [x] Resolve WSL prerequisites/reboots; import and run binder-enabled distro.
- [x] Fix release artifact discovery/cache/integrity and firstboot GApps
  sequencing/configuration/locking/retry; real VANILLA and GApps outcomes tested.
- [x] Fix duplicate INI properties; six Linux firstboot fixtures pass, including
  real concurrent locking. Applicable Windows artifact/config checks pass.
- [x] Validate VANILLA uninstall and installed GApps CLI/Start Menu staging.
- [x] Fix CLI APK path/error propagation, with PowerShell7/5.1 checks.
- [x] Fix lifecycle locking, live framework readiness, probe termination and
  nested compositor socket race; thirteen Linux lifecycle tests and applicable
  Git Bash tests pass, plus syntax/ShellCheck.
- [x] Verify exact Nintendo artifact/signatures and reproduce both ABI failures;
  retain local-only evidence and stop the target restart loop.
- [x] Capture/revert graphics protocol, size, renderer and DPI experiments;
  preserve defaults and distinguish Windows presentation from Android rendering.
- [x] Verify core WOW64 Sysnative detection on this laptop.

Completion above applies only to the stated evidence. Installer smoke success
and framework readiness do not certify visual usability or account compatibility.

- [x] Lab-only bindfs namespace read/write control and six awake IP/DNS samples pass; app file-picker permissions and long-session reliability remain open.

- [x] Fix nested stop/restart exit race; three regressions and a real normal immediate restart pass. Temporary local diagnostic flag removed.


- [ ] Verify new Windows-owned tray shortcut survives WSLg resync; source fix and PS7/5.1 checks pass, actual completed-installer repair succeeded. WSL transport recovery pending before resync check.
