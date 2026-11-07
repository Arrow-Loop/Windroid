# Windroid lab roadmap (handoff, not yet committed to repository)

- [ ] Confirm laptop ownership, Windows edition, hardware, recovery image, and isolation.
- [ ] Bootstrap Git, development tools, repo, and evidence folder.
- [ ] Install Windroid from known release, with reproducible installation log.
- [ ] Reproduce WSL detection and validate pending `{sysnative}` branch fix.
- [ ] Diagnose local artifact source fallback and error messages.
- [ ] Reproduce GAPPS/VANILLA race and build idempotent fix.
- [ ] Fix launcher script invocation and execution policy UX.
- [ ] Isolate WSLg/LXC/Weston surface and window movement defects.
- [ ] Investigate Waydroid networking dropout.
- [ ] Investigate Nintendo native crash in `libpairipcore.so`; assess app support limitations without bypassing protections.
- [ ] Submit narrowly scoped validated PRs upstream and document test matrix.

## Audit checkpoint — 2026-11-06
- [x] Inspect hardware, Windows edition, virtualization, available disk and repository state. Ownership/isolation authorized by user; recovery image remains unverified.
- [x] Locate existing Git and repository; retain evidence folder and baseline results.
- [x] Read handoff and development docs; verify and extract official v0.1.0 ZIP.
- [x] Reproduce default artifact manifest Not Found; retain logs.
- [x] Install WSL and enable VirtualMachinePlatform (restart pending).
- [x] Establish tracked session checkpoint and resume instructions; verify CLI resume commands without starting another agent.
- [ ] Finish installer draft and matching guest gate/flavour-aware firstboot logic plus packaging; add regression tests, validate and commit coherent fix.
- [ ] Restart Windows, verify WSL2 VM startup, and establish actual Windroid runtime baseline.
- [ ] Validate Sysnative wizard fix on this machine (code already preserved as ba4e275).
- [ ] Reproduce/validate vanilla and GApps installs, recovery, networking and desktop window behavior.
- [ ] Obtain local Nintendo crash evidence without account sign-ins or protection bypass; diagnose exact x86_64 failure.
- [ ] Validate uninstall/coexistence and submit narrowly scoped PRs only after evidence supports them.

Earlier unchecked items remain open where this checkpoint records only partial completion. SESSION_STATE.md in source/Windroid is the authoritative next-action checkpoint.

## Implementation checkpoint — 2026-11-06
- [x] Complete installer/guest configuration protocol and packaging with isolated regression checks.
- [x] Validate artifact tests in PowerShell 7 and 5.1; firstboot fixtures in Git Bash.
- [ ] Reboot (authorized), validate Linux locking and perform actual vanilla/GApps install/runtime tests. Earlier runtime priorities remain open.


## Host prerequisite follow-up — 2026-11-06
- [x] Verify first reboot and diagnose VMP/service mismatch with elevated PowerShell 7.
- [ ] Complete reboot requested by official WSL prerequisite installation; if vmcompute remains absent, investigate Windows servicing before further feature changes.


## Runtime checkpoint — 2026-11-06
- [x] Complete WSL2 prerequisite startup and source VANILLA installation/smoke test.
- [x] Fix duplicate/spaced firstboot properties and test Linux concurrent initialization.
- [x] Verify Android IP routing and DNS on one clean session start.
- [ ] Diagnose AppData kernel load access, warm-start timeout/WSAETIMEDOUT, SystemUI crash and Settings rendering; repeat network tests.
- [ ] Validate clean GApps install, graphics and app compatibility; previous roadmap runtime tasks remain open.


## Follow-up checkpoint — 2026-11-06
- [x] Capture graphics compositor crashes and compare Android/Windows frames; reject and revert unsuccessful global HiDPI experiment.
- [x] Validate VANILLA uninstall and CLI APK path/error handling in PowerShell 7/5.1.
- [ ] Complete local-only GApps image retry and verify packages/rendering; seamless graphics remains unresolved.

