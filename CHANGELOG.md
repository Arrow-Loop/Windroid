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
