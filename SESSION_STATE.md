# Windroid session state

Updated: 2026-11-06 (America/New_York). Read this before continuing.

## Current objective

Investigate and fix installation, GApps initialization, session reliability,
networking, Windows integration and Nintendo Switch App startup, preserving
upstream compatibility. Persist progress through usage limits/restarts.

## Workspace and source

- Repository: `C:\Users\Public\Documents\Cody-Windroid-Lab\source\Windroid`
- Lab: `C:\Users\Public\Documents\Cody-Windroid-Lab`
- Branch: `codex/lab-reliability`; initial source `e85d7c6`.
- Origin: Arrow-Loop/Windroid; upstream releases: calm032019/Windroid.
- Handoff: lab `HANDOFF.md`; journal: lab `journals/ENGINEERING-JOURNAL.md`.
- Tracked ROADMAP.md and CHANGELOG.md contain the current lab status; lab copies
  are mirrored for the original handoff workflow. No push/PR performed.

## Completed work

- Read handoff, roadmap, changelog and repository technical docs. Handoff files
  were initially absent, then supplied in the lab; they have now been read.
- Captured baseline in lab `evidence/2026-11-06-baseline/`: Windows 11 Pro
  26200.9711, Surface Book 3, Intel i5-1035G7, about 8 GB RAM, ~104 GB free.
- Verified Git at `C:\Program Files\Git\cmd\git.exe`; version
  2.56.0.windows.4. Do not reinstall it. PowerShell 7.6.9 available.
- WSL 2.7.14.0 installed using elevated setup; VirtualMachinePlatform enabled
  with NoRestart. Installer explicitly reported RestartNeeded=True.
  WSLg 1.0.73.2; stock kernel 6.18.33.2-2. No distro imported yet.
- Downloaded official v0.1.0 ZIP and verified its published SHA-256:
  `72d63927d5da0a4465b50414c0cdcb5c9f948c957835c4ca9f3ef05bc1d364b8`.
  Extracted lab `evidence/release-v0.1.0/Windroid/artifacts`; reuse it.
- Reproduced default installer manifest HTTP Not Found with a disposable
  install state that skips preflight/WSL. Evidence: `artifact-source-probe.txt`.
  Release contains artifacts inside ZIP, not individual release assets.
- Cherry-picked user's existing Sysnative fix `585ddab` as `ba4e275`, retaining
  author credit. Runtime wizard validation still pending.
- Configured persistent continuation instructions/checkpoint and researched
  documented resume support; see docs/CONTINUATION.md.

## Active investigation

Installer/guest configuration changes are implemented with isolated regression
checks. Firstboot now waits for .configured, uses flock, reprocesses legacy empty
stamps, records flavour on success and retries failed GApps downloads without
moving the VANILLA preseed twice. Distribution packagers include guest helpers.
Artifact discovery extracts and verifies the release ZIP; all artifact hashes
are checked. WSL error/checkpoint handling and custom distro launchers improved.
These changes need real WSL/Android validation; no runtime fix is claimed yet.

## Last successful operation and validation

PowerShell parse checks pass. Release discovery/integrity regression tests pass
in PowerShell 7.6.9 and Windows PowerShell 5.1. Existing config merge/revert tests
pass. Four isolated firstboot tests pass under Git Bash; flock is stubbed there,
so Linux lock behavior is pending. Changed shell scripts pass bash -n, and
Git diff whitespace checks pass. Tests were added to CI but CI has not run.
No WSL distro imported yet. Windows boot time remains 2026-11-03 07:05 local.

## Outstanding blockers / unknowns

- First reboot confirmed: 2026-11-06 18:35:02 local. WSL2 remains unavailable; VirtualMachinePlatform reports Enabled but vmcompute service/executable are absent. Elevated official WSL prerequisite command completed and requests a second reboot.
- No Nintendo APK/tombstone on this laptop. Handoff reports x86_64 3.6.0,
  com.nintendo.znca, SIGSEGV/SEGV_ACCERR in libpairipcore.so at 0x794cb.
  Do not assume ARM translation, bypass protections, or use personal sign-ins.
- Graphics/window movement and networking dropouts have not been reproduced
  here. Recovery-image/BitLocker arrangements remain owner-managed/unverified.
- No official automatic quota-reset continuation mechanism verified; no
  polling, scheduler, paid-credit fallback, or reset purchase configured.

## Exact next action

Second prerequisite reboot is being requested after saving this checkpoint.
First reboot was verified at 2026-11-06 18:35:02 local. Source remains 3eb30d8.
Elevated PowerShell 7 diagnostic confirmed VirtualMachinePlatform Enabled,
Microsoft-Windows-Subsystem-Linux Disabled, Hyper-V-Hypervisor Disabled, and
vmcompute absent. HypervisorPresent=True, so do not assume firmware is disabled.
Ran official wsl --install --no-distribution elevated; DISM completed with exit 0
and explicitly requested restart. Logs: lab evidence/2026-11-06-baseline/
post-reboot-host.txt and wsl-prerequisite-repair.txt. No distro imported.

On resumption check actual boot time, Get-Service vmcompute,WslService,
wsl --status and wsl --list --verbose. If vmcompute is STILL absent, do NOT
repeat another blind feature-enable/reboot cycle. Inspect CBS servicing errors,
feature dependencies and component health before choosing a targeted repair.
Do not disable Windows security features to make virtualization work.

If WSL2 is operational, use PowerShell 7 from this repository:

```powershell
& .\installer\install.ps1 -ArtifactSource 'C:\Users\Public\Documents\Cody-Windroid-Lab\evidence\release-v0.1.0\Windroid\artifacts' -Bench
```

Capture output in a new lab evidence subdirectory; do not reuse the disposable
artifact-source-probe state. Verify binder, firstboot VANILLA stamp, session
start/stop, app windows and networking. Run firstboot tests in WSL with real
flock and concurrent initialization. Then validate GApps on a clean reinstall
with evidence retained; only one Waydroid installation may run at a time.
Continue session/network/graphics priorities and Nintendo exact-version crash
investigation without account sign-ins or protection bypass.

## Resume

Reopen this desktop chat and send: `Resume Windroid from SESSION_STATE.md.`
A fresh chat in this workspace can use the same instruction. For CLI use the
session picker with `codex resume` from this directory; select the correct
Windroid session rather than guessing a session ID or using global --all.
