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

## Active investigation / uncommitted work

`installer/install.ps1` has an INCOMPLETE draft covering release ZIP discovery,
all three artifact hashes, WSL checkpoint/error handling, configure sequencing,
guest helper copying, persisted GApps choice, smoke-test failures and custom
distro launcher arguments. Do not treat this as an implemented/validated fix.

IMPORTANT: the draft currently copies unchanged guest helpers and writes a
`.configured` marker that they do not yet consume. The legacy firstboot script
still skips on an empty `.initialized` stamp; the GApps race is NOT fixed yet.
Complete the guest-side protocol and distribution packaging before running
the full patched installer. Add regression tests before committing this draft.
Only installer/install.ps1 was modified by the interrupted implementation.

## Last successful operation and validation

After interruption, inspected status/diff and verified all PowerShell files
parse, installer UTF-8 BOM is preserved, existing merge/revert tests pass,
and `git diff --check` passes. These are static/existing tests, not proof of
the draft's new behavior. CLI help confirms version 0.167.0-alpha.3.2 and
`codex resume` / `codex exec resume` support. No background Codex run launched.

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

Run `git status --short` and `git diff -- installer/install.ps1`, then read
`rootfs/files/usr/local/bin/windroid-firstboot` and its systemd unit. Complete
the GApps configuration gate, firstboot serialization and flavour-aware success
stamp/retry handling; package matching guest helpers in make-dist.ps1 and the
Inno setup file. Add isolated regression tests for release discovery/checksums
and the GApps race. Keep tests independent of a real Android install.

Then validate PowerShell 7 and 5.1, shell syntax and relevant behavioral tests;
commit the coherent installer/guest change only after checks pass. Obtain the
required Windows restart at a saved checkpoint, verify WSL status again, then
perform vanilla/GApps install and runtime tests from the verified local release.

## Resume

Reopen this desktop chat and send: `Resume Windroid from SESSION_STATE.md.`
A fresh chat in this workspace can use the same instruction. For CLI use the
session picker with `codex resume` from this directory; select the correct
Windroid session rather than guessing a session ID or using global --all.
