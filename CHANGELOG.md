# Windroid lab changelog

## 2026-11-07 — nested idle screen
- Disable the default five-minute idle timeout only on Windroid's embedded
  nested Weston display. It had hidden a still-drawing Android control behind
  black output and its own idle-lock overlay. Windows lock settings are unchanged.
- Delayed-socket regression now requires the option and fails without it.
  Linux13 lifecycle checks, applicable Git Bash checks, syntax/ShellCheck pass.
  Deployed helper after backup; normal restart/control launch returned0.
- Windows frame987 remained visible while paused for over331seconds without
  injected input. Native mouse/Space controls also passed. A separate System UI
  startup ANR required recovery; seamless/framework reliability remains open.

## 2026-11-07 — optional Android frame/input control
- Added a small permission-free Java Canvas diagnostic with frame/tap counters
  and a Space animation toggle, plus a local-only builder. It is separate from
  bundled apps and does not fetch tools or contact a service.
- Built with verified cached SDK33/R8 and JDK21; APK signatures verified.
  Windows rendered advancing frames and received mouse/Space input after a
  separate System UI startup ANR recovery. No seamless/Nintendo pass claimed.
- APKs, SDK binaries and local development signing keys remain outside Git.

## 2026-11-07 — asynchronous APK installation messages
- CLI and tray now say "Installation requested" after a successful Waydroid
  request, rather than claiming Android finished installing. The platform
  commits PackageInstaller sessions asynchronously; one lab request remained
  pending while a direct guest request completed 2.4 seconds after return.
- Own signed, permission-free diagnostic APK is valid and installed. Quoted
  spaces/apostrophes reach the guest correctly. No root install pipeline or
  package-verification setting was added; the pending request cause remains open.
- CLI/tray command checks pass on PowerShell7 and Windows PowerShell5.1;
  changed-script parse/BOM checks pass. Updated installed lab scripts after
  backup. Live tray file-picker/notifications remain unverified.

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

## 2026-11-06 — graphics isolation and CLI installation checks
- Captured composer Binder-pool abort matching Waydroid upstream commit 4aee4c8. Verified official vendor20261022 ZIP and tested vendor-only replacement with rollback retained during the experiment. The first updated run did not reproduce that abort; Windows still showed Settings splash while Android screencap showed full Settings UI.
- Weston logs showed 200% scaling and mismatched surface/buffer dimensions. Tested documented WESTON_RDP_HI_DPI_SCALING=false with backup/rollback; it did not yield a usable Windows app and SurfaceFlinger crashed in that run. Reverted override. No graphics fix is claimed.
- Saved baseline logs/state externally and successfully tested source uninstallation after checking exact removal targets. Started clean GApps installation in public lab runtime directory; GApps image selection was correct. Native download was slow, so downloaded the same official image via direct mirror, verified its OTA hash, and began local-only image preseeding for retry. GApps runtime validation is pending.
- CLI APK install now passes filenames as native arguments and rejects path-conversion, session-start and install failures. Mocked regression tests pass in PowerShell 7 and 5.1, including spaces/apostrophes and explicit selected distro.

## 2026-11-06 — lifecycle serialization and GApps readiness
- Added per-user lifecycle lock with detached-child descriptor closure, both-state health checks, readiness wait for existing starts, configurable 180s timeout and propagated container-stop failures. Five isolated tests pass with real Linux flock; applicable Git Bash tests pass. CI includes them.
- GApps stamp now confirms selected flavour after verified local-only image retry. First smoke readiness failed at 180s; later manual startup became ready and bundled apps installed. Installer smoketest/integrate still pending, so full GApps installation is not declared validated.
- Kernel diagnostics identified order-7 VMBus ring allocation failures preceding WSL vsock connection timeouts, matching upstream WSL #40795. Restart recovered channels; runtime-only compaction-proactiveness 80 is an experiment, not a persisted fix.
- User requested Play Store; native store window opened at splash. Started contained Weston fallback after per-app rendering failure and recovered WSL. User input detected in Weston; UI left under user control for sign-in/download. No credentials handled.
- User reports an APKMirror download; local matching Downloads file not found, full path requested. Nintendo identity/version/ABI/signature and crash reproduction pending.

## 2026-11-06 — nested compositor readiness and Nintendo reproduction
- Fixed nested Weston startup ordering: explicitly request wayland-1, wait for its Unix socket, and fail with diagnostics if the compositor exits. Real runtime previously attempted Waydroid before the socket appeared; updated helper reached readiness after recovery. This does not fix seamless graphics or System UI stability.
- Seven isolated Linux lifecycle tests pass, including delayed socket creation and early compositor failure; applicable Git Bash tests pass (two Linux-only skips). Bash syntax and Git whitespace checks pass. Test fixtures now stub process discovery/termination to avoid touching real Weston.
- Inspected supplied APKMirror Nintendo3.6.0/14330 bundle and signatures; unchanged x86_64 installation reproduces handoff SEGV_ACCERR at libpairipcore.so+0x794cb. Twelve records belong to one launch window. No bypass or Nintendo login performed.
- Installed unchanged signed x86 splits as an ABI control after recovering unrelated package/compositor failures. Longer observation shows rapid SIGABRT/restart loop, with libc page-signature mismatch and recursive signal-handler abort; target force-stopped. Short PID presence/no tombstone was not success. Root cause remains unresolved for both ABIs.
- Added docs/NINTENDO-3.6.0.md with hashes, environment, methods and limitations. APKs/native libraries/raw memory logs remain local in evidence/nintendo-3.6.0. Guest inspection-tool install also updated Mesa packages; transcript retained.
- Reused one persistent root WSL terminal after shutdown to avoid new VMBus channel allocation under fragmented memory. This investigation technique is not a persisted WSL fix. GApps smoke/integration and graphics/network reliability remain open.

## 2026-11-06 — resumed GApps smoke and integration
- Resumed the source installer with the same public InstallRoot, -Gapps -MemoryCapGB 3 -SkipWslUpdate -Bench and existing verified artifact directory. It skipped completed stages, accepted the already-ready session, verified both running states, stopped cleanly, and completed CLI/tray/Start Menu integration (exit0). state.json now records all stages complete. This is lifecycle/integration proof, not proof that Google login or app graphics work.
- Installed windroid.cmd status returned STOPPED after smoke; runtime bin files present. No Android data reset or reinstall occurred.
- Android IP1.1.1.1 and example.com DNS pings passed2/2 each after Nintendo restart-loop termination. Guest DNS resolution also passed; guest ping binary absent, so no guest ICMP result claimed. Evidence: gapps-network-after-nintendo.txt.
- Began separate post-smoke lifecycle start through retained root terminal and user1000 DBus environment. Record result before declaring restart reliability. Host available memory at this point was about807MiB/7778MiB; avoid increasing guest cap blindly.

## 2026-11-06 — post-smoke recovery validation
- Separate post-smoke start reached Android ready in83.361s; Settings visibly rendered inside contained Weston. Android IP and DNS pings again passed2/2; ConnectivityService reports validated Ethernet default network. No network defect reproduced in these two GApps observations; long-session dropout remains open.
- ShellCheck0.9.0 installed in guest; changed session helper passes shellcheck -S warning. Seven Linux lifecycle tests and applicable Git Bash tests already passed. No new kernel/sysctl or protected-app changes.
- Compared confirmed upstream kernel tags6.18.33.1 and6.18.54.1: channel.c has identical Git blob SHA162d6aeece7b3b6e4c321b07008efac49c253af4; inspected hv_sock ring-size selection is unchanged. A newer binder-kernel rebuild alone is not established as a fix for the captured ring allocation defect. Deferred that expensive experiment pending a specific patch hypothesis.

- Renderer follow-up: runtime ANGLE/pastel is Waydroid vendorSDK33+ substitution for the configured SwiftShader driver; verified against upstream init patch and SurfaceFlinger output. Documented in UPSTREAM-FACTS; no driver override applied. Ordinary contained Settings control remained rendered about10min with no matching fatal records in the bounded crash-buffer check.

## 2026-11-06 — Wayland protocol experiments and live readiness
- Captured compositor-only Wayland traces using a temporary local service wrapper/overlay, with originals backed up. Direct Settings exposed a full native frame after supported Waydroid launch, but input did not establish usability; Android screencap showed an ANR from an earlier premature launch. No seamless fix claimed.
- Tested source/binary-confirmed no_background_subsurface switch; no demonstrated improvement. Forced logical640x480 display failed with an exact maximized configure/buffer mismatch (1500x952 vs640x480), causing HWC/SurfaceFlinger restart loops. Recorded this specific unsafe override case without attributing prior default-size failures to it.
- Cleared experiment properties, restored nestedconfig, removed matching wrapper/rc overlays, verified original compositor definition byte-for-byte. Untraced startup reached readiness in106s. Framework probe succeeds; recovered Windows desktop currently appears black, so presentation recovery remains under investigation. Android user/account data retained.
- Session readiness now requires a bounded live PackageManager/platform app-list response as well as the ready log. Exit0 with an IPC error/empty result is rejected; recovery waits without duplicate daemon; probe time counts toward the deadline. Ten Linux tests pass, applicable Git Bash tests pass (two Linux-only skips), ShellCheck and Bash syntax pass. Healthy real ensure query passed in1.909s; installed helper in lab after backup.
- Detailed methods/limitations in docs/GRAPHICS-INVESTIGATION.md. Raw traces, target-only ANR and screenshots remain local under evidence/graphics-protocol-2026-11-06. No protected-app changes, global DPI changes, or quota automation.

## 2026-11-06 — controlled presentation and WOW64 checks
- Fresh WSL restart restored initial presentation but reproduced System UI ANR. Collected only target process trace: main waited in HWUI RenderProxy, render thread sampled in ANGLE texture staging. A verified runtime Skia Vulkan trial did not fix presentation and was cleared.
- GL and Pixman nested renderers both rendered/navigated Settings using a matched after-readiness full-desktop launch without the notification-shade refresh. An animated unprotected shm client worked; later navigation also worked after stopping it. No renderer-default change or repaint-causality claim. Timed Pixman Network update visible by5355ms; GL Battery panel appeared between4347ms and26679ms observations, so exact completion latency unknown.
- Existing windroid-app call from the working GL session did not reproduce black output. A clean seamless control is running to remove an earlier premature-launch ANR confound; graphics still open.
- Actual32bit Windows PowerShell probe reproduced redirected System32 wsl.exe missing, while Sysnative wsl.exe --status returned0 and hypervisor probe true. Core wizard detection logic verified on this host; compiled wizard UI remains untested. Compiler installation command was rejected by automatic approval review (blocked by policy); no alternative installation attempted.
- Live-health query now escalates if termination is ignored. Stubborn30s fixture passes on Linux and Git Bash with platform-appropriate startup overhead allowance. Original renderer/helper restored with committed readiness fixes; all temporary image overlays removed and property trials cleared.

## 2026-11-07 — tray failure handling and graphics rollback
- Tray commands now check native exit codes, display action failures, and stop restart when stopping fails. APK paths pass as literal native arguments, including spaces/apostrophes; failed conversion/readiness/install cannot announce success.
- New focused checks execute the real lifecycle callbacks with mocked WSL, without starting the tray UI. Tray and existing CLI checks pass in PowerShell7/Windows PowerShell5.1; changed-script parse/BOM and whitespace checks pass. CI includes tray checks. Live tray/file-picker behavior is not yet validated.
- Completed clean seamless and boot-wide HWUI Vulkan controls: the Windows splash/stale-frame defect persists despite verified Vulkan in all three UI processes. Early system-server HIDL/media-codec crash confounds startup; no causal claim. Restored original config/derived props and nested fallback; rollback startup exit0 in121s. No image/account/app reset.
- Nov7 Android IP/DNS pings2/2 and live framework ensure pass after overnight gap. Host sleep prevents continuous-uptime proof; networking dropout remains unconfirmed. Consolidated ROADMAP into current completed/open work to prevent repeated stale steps.
- Lab-only bindfs shared-storage read/write control passed; temporary mount and empty target directory removed, personal Downloads unchanged. Six awake IP/DNS samples across five minutes passed all12 ping commands. No persistent sampler installed.
- Passive analysis of the twelve existing Nintendo x86_64 records found matching runtime/file instruction bytes: an eight-byte read whose computed operand lies in a no-access mapping, while PC lies in an executable mapping. This narrows the fault mechanism without establishing its cause or intentional rejection; no relaunch or app modification.
- Read-only installed HWC symbol/disassembly inspection confirms the upstream focus-unlock and dimension-change hotplug guards are already present. No compositor rebuild, replacement or image change applied.

## 2026-11-07 — nested compositor restart completion
- Fixed another nested lifecycle race: stop now waits for the current user's Weston to exit and reports timeout while still attempting container shutdown. Start rechecks a disappearing existing compositor instead of waiting the whole socket deadline without launching a replacement.
- Three new regressions fail against the old helper. All13 Linux tests pass (18.565s); Git Bash passes with3 Linux-only skips (41.834s). Bash syntax/ShellCheck pass. Actual normal immediate cycle: stop6s, old compositor absent, replacement PID, readiness88s, exit0. Installed/source hashes match.
- Temporary local Weston diagnostic flag removed after scenegraph/protocol collection. The diagnostic run rendered Settings and later Battery, with buffer releases and continuing commits. This does not establish a permanent or seamless graphics fix. No image/app/account changes.
- Post-fix normal restart also rendered Settings in nested Weston and passed Android IP/DNS pings2/2 each. This is one successful cycle, not long-session or seamless proof.

## 2026-11-07 — Windows tray shortcut survival
- Moved the Windows tray shortcut into `<DistroName> Tools`, outside WSLg's managed Android app folder. Upstream WSLg sync scans all links and referenced icons there, then removes those absent from the Linux app list; the lab tray link and root icon were missing.
- Installer repairs/migrates its link even after completed integration, removing only a matching legacy target. Uninstall removes the owned Tools link and only an empty directory; unrelated Tools files remain. Uninstaller distro names use the installer's validation. Tray/shortcut prefer the retained bin icon.
- Isolated ownership/path/migration/repair/cleanup checks pass in PS7/5.1, as do existing tray command checks; changed-script parse/BOM checks pass. Actual all-stages-complete installer resume repaired the lab link without WSL/image stages. Resync survival still pending; live tray UI not claimed.
- Actual Windows Settings shortcut activation encountered the known order7 VMBus allocation/UtilAcceptVsock timeout, with no corresponding guest activity launch. Cancelled only exact verified launcherPID4876. Retained root terminal still works; WSL shutdown recovery planned after checkpoint.
- After clean WSL transport recovery, the actual Windows Settings shortcut started the user session and Android, then rendered Settings. New Tools tray link/bin icon survived WSLg app-folder resync unchanged. This validates shortcut transport/survival on a fresh session, not the unresolved fragmented-memory VMBus failure.
