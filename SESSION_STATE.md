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

- Windows restart required before WSL2 runtime tests. No reboot issued.
- No Nintendo APK/tombstone on this laptop. Handoff reports x86_64 3.6.0,
  com.nintendo.znca, SIGSEGV/SEGV_ACCERR in libpairipcore.so at 0x794cb.
  Do not assume ARM translation, bypass protections, or use personal sign-ins.
- Graphics/window movement and networking dropouts have not been reproduced
  here. Recovery-image/BitLocker arrangements remain owner-managed/unverified.
- No official automatic quota-reset continuation mechanism verified; no
  polling, scheduler, paid-credit fallback, or reset purchase configured.

## Exact next action

User explicitly authorized reboot on 2026-11-06. Source and documentation are
being committed before invoking shutdown.exe /r /t 30 (without forced app close).
On resumption, first inspect Git status/log and Windows LastBootUpTime; do not
assume the scheduled restart completed. Run wsl --status and wsl --list --verbose.
If WSL2 is operational, use PowerShell 7 in this repository to run:

```powershell
& .\installer\install.ps1 -ArtifactSource 'C:\Users\Public\Documents\Cody-Windroid-Lab\evidence\release-v0.1.0\Windroid\artifacts' -Bench
```

Capture output in a new lab evidence subdirectory; do not reuse the disposable
artifact-source-probe state as an actual installation. Verify binder, firstboot
stamp VANILLA, session start/stop, app window and networking. Run firstboot tests
inside WSL with real flock, then test concurrent initialization. Validate GApps
via a clean reinstall after preserving test evidence; do not register two active
Waydroid stacks simultaneously. Continue session/network/graphics priorities,
and investigate Nintendo only with local exact-version app/crash evidence.

If startup fails, retain exit codes/logs and diagnose before making more changes.
Do not redownload the verified release or reinstall Git/WSL unnecessarily.

## Resume

Reopen this desktop chat and send: `Resume Windroid from SESSION_STATE.md.`
A fresh chat in this workspace can use the same instruction. For CLI use the
session picker with `codex resume` from this directory; select the correct
Windroid session rather than guessing a session ID or using global --all.
