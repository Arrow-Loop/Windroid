# Windroid lab roadmap

- [ ] Confirm laptop ownership, Windows edition, hardware, recovery image, and isolation.
- [x] Bootstrap Git, development tools, repo, and evidence folder.
- [x] Install Windroid from verified release artifacts and source helpers; retain installation logs.
- [ ] Reproduce WSL detection and validate pending `{sysnative}` branch fix.
- [x] Diagnose and fix release artifact discovery/cache/hash validation.
- [x] Implement and test configuration gate/flavour-aware initialization; verify local VANILLA and GApps outcomes.
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


## Lifecycle and GApps checkpoint — 2026-11-06
- [x] Add and test lifecycle serialization, readiness waiting and stop-error propagation.
- [x] Verify GApps selection/success stamp after local verified-image retry; manual startup reaches ready.
- [x] Capture VMBus allocation failure / WSL vsock timeout mechanism.
- [ ] Complete GApps smoke/integration and permanent graphics/memory fixes.
- [ ] Await supplied APKMirror path/user Store download, verify artifact, reproduce scoped Nintendo crash. Preserve account data after manual sign-in.


## Nintendo and nested compositor checkpoint — 2026-11-06
- [x] Verify supplied artifact identity/signatures and reproduce original x86_64 Nintendo startup fault locally.
- [x] Complete unchanged signed x86 ABI control; it also fails (allocator abort/restart loop). Force-stop target; preserve data/evidence.
- [x] Fix nested compositor socket readiness race; seven Linux lifecycle tests and applicable Git Bash checks pass; real recovered startup reaches ready.
- [ ] Diagnose Nintendo runtime fault using upstream allocator/runtime evidence and unmodified controls; no protection bypass or successful compatibility claim.
- [ ] Resolve System UI ANR/seamless rendering and WSL fragmented-memory channel failures; complete GApps smoke/integration and repeated networking validation.
These entries supersede stale pending-artifact/reboot steps above; historical checkpoints are retained.

## GApps installer completion — 2026-11-06
- [x] Complete actual resumed GApps smoke/integration stages, exit0; installed CLI status verified. Smoke began with an already-ready session and stopped cleanly.
- [x] Verify Android IP/DNS connectivity after Nintendo failure (two replies each).
- [ ] Validate separate post-smoke restart and ordinary-app rendering; installer completion does not close graphics, account usability, repeated networking or long-session reliability.

## Live framework and graphics trace checkpoint — 2026-11-06
- [x] Capture bounded compositor protocol with backed-up, reversible instrumentation; remove it after tests.
- [x] Reject stale ready markers when live framework/package queries fail; test recovery and bounded wait behavior, verify healthy real probe.
- [x] Identify forced-size maximized-state protocol error; revert unsupported workaround and retain evidence.
- [ ] Recover/validate contained presentation after rollback (framework ready, current Windows view black), then isolate default-size seamless geometry/input/ANR behavior. Readiness is not graphics proof.
- [ ] Continue wizard Sysnative runtime check, long-session networking/WSL transport, and Nintendo cause investigation after runtime stabilization.
