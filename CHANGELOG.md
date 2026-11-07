# Windroid lab changelog (handoff, not yet committed to repository)

## 2026-11-06
- Created laptop bootstrap script for local inventory, development tools, Windroid clone, and journal directories.
- Prepared handoff documenting prior confirmed observations and unresolved defects.
- No installation or runtime validation occurred on the laptop in this preparation pass.

## 2026-11-06 — development audit and continuation checkpoint
- Audited the clean e85d7c6 checkout and Windows host; baseline evidence is in evidence/2026-11-06-baseline.
- Installed WSL 2.7.14 and enabled VirtualMachinePlatform without rebooting. Windows restart is required; no Windroid distro or Android runtime tested yet.
- Verified/extracted upstream v0.1.0 distribution ZIP against its published SHA-256; retained it under evidence/release-v0.1.0.
- Reproduced the default standalone versions.json download failure. The release bundles artifacts in Windroid.zip.
- Preserved the existing Sysnative fix in local commit ba4e275; wizard runtime validation remains pending.
- Added tracked AGENTS.md, SESSION_STATE.md and docs/CONTINUATION.md for recovery after app/context resets. Mirrored lab roadmap/changelog into the repository for Git history.
- Checked installed CLI help and official resume documentation. No supported automatic quota-reset trigger was verified; no polling, scheduled submissions, credit fallback or reset purchases configured.
- PowerShell parse, existing merge/revert tests, installer BOM and diff whitespace checks pass. Uncommitted installer draft remains incomplete and is NOT a validated GApps/session fix.

## 2026-11-06 — installer and firstboot regression fixes
- Implemented release ZIP discovery/cache verification and module VHDX hash checking; corrected WSL readiness checkpoint/error handling.
- Added installer configuration gate, firstboot flock and flavour-aware atomic success stamp, legacy stamp reprocessing and retry-safe GApps preseed parking. Packagers carry matching guest helpers; custom distro CLI/tray launchers retain selected names/paths.
- New artifact tests pass on PowerShell 7 and Windows PowerShell 5.1. Four isolated firstboot tests pass in Git Bash, with flock stubbed. PowerShell parse, shell syntax, existing config tests and whitespace checks pass. CI includes the new tests but has not run.
- Real WSL/Android behavior, Linux lock semantics, wizard execution, GApps download and app compatibility remain unvalidated. User authorized reboot; checkpoint saved before invoking Windows restart.

## 2026-11-06 — first reboot and WSL host prerequisite diagnosis
- Confirmed Windows reboot at 18:35:02 local; worktree clean at 3eb30d8 when resuming.
- WSL2 still unavailable. Elevated PowerShell 7 diagnostic found VMP Enabled but vmcompute service/executable absent; Windows hypervisor is present. WSL1 feature and full Hyper-V hypervisor feature disabled. Firmware-disabled conclusion is not justified by these results.
- Ran Microsoft's wsl --install --no-distribution elevated. DISM reported successful prerequisite enablement, exit 0, explicitly requiring another restart. No distro imported or Android runtime tested.
- Evidence: evidence/2026-11-06-baseline/post-reboot-host.txt and wsl-prerequisite-repair.txt. User approved the diagnostic UAC prompt; source/dependencies were not reinstalled.
- Saving checkpoint before second reboot. If vmcompute remains absent, inspect servicing/component health instead of repeating blind enable/reboot cycles.

## 2026-11-06 — VANILLA runtime baseline and property normalization
- Second prerequisite reboot resolved missing vmcompute. WSL delegated updater completed successfully to 3.0.3/WSLg 1.0.79 after its parent command was cancelled; documented the transition instead of treating it as a pinned 2.7 baseline.
- Added -SkipWslUpdate for explicit reproducible runs; minimum version check remains enforced.
- Custom kernel under AppData failed with WSL_E_CUSTOM_KERNEL_NOT_FOUND despite shell file access; identical public lab kernel/modules successfully imported Windroid. Retained probe files/config backup and recorded global config override.
- Real initialization reproduced DuplicateOptionError: Waydroid saved properties with spaces around =, old text matching added duplicate rendering keys. Replaced with atomic configparser normalization. Applied guest helper; full VANILLA firstboot/smoke/integration passed.
- Six fixture tests pass in WSL with real flock, including concurrent initialization and duplicate/spaced INI properties. Applicable Git Bash tests, PowerShell artifact tests (7/5.1), parse and shell syntax checks pass.
- Clean session start after WSL shutdown: 80s. Android routing and DNS pings pass. Settings WSLg window observed at splash; complete usability/window movement still pending.
- Warm restart exceeded readiness timeout and one WSL command returned WSAETIMEDOUT; WSL shutdown recovered it. First boot SystemUI NPE observed; root cause unproven. These remain open, along with GApps and Nintendo.
