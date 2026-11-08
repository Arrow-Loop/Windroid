# Windroid lab progress

Updated November8,2026 (America/New_York).

**Installation and lifecycle fixes are implemented and tested. Seamless Windows
use and Nintendo compatibility are still unresolved.** Experimental graphics
patches are clearly separated from validated installer/session changes.

| Area | Completed and validated | Still open |
|---|---|---|
| Installation/GApps | Artifact discovery/cache/integrity, first-boot ordering/locking/retry, VANILLA install/uninstall and resumed GApps smoke/integration | Broader hardware matrix; compiled wizard UI |
| Session lifecycle | Serialization, live readiness, nested socket/exit races and idle blanking fixes;13 Linux lifecycle checks plus real cycles | Intermittent SystemUI ANRs and WSL channel allocation failures |
| Windows integration | Literal APK paths/error reporting, tray failure handling, Windows-owned shortcut survival; PS7/5.1 checks and actual shortcut launch | Live tray UI, clipboard/audio, seamless movement/resize |
| Networking | Repeated Android IP/DNS checks pass, including after current rollback | Long-session dropout has not been reproduced or ruled out |
| Graphics | Native queue race reproduced; private-queue controls pass; rebuilt baseline/source queue candidate render and accept input in nested tests | Direct startup/input failures, focus ANR, hidden system dialogs; source candidates not shipped |
| Nintendo Switch App3.6.0 | Verified unchanged artifacts; reproduced both x86_64/x86 failures; passive crash analysis recorded | Root cause and compatibility fix; no protection bypass |

## Latest concrete work

- Built isolated Android composer components using verified NDK/VNDK inputs,
  avoiding a full Android checkout. Strict compile/link and isolated load pass.
- Compared unchanged baseline and queue-only source candidate as actual services.
  Both pass short nested frame/input controls; this does not prove a permanent fix.
- Direct trial failed live readiness and focus handling. Android ANR dialogs
  intercepted input but were omitted from the Windows app window.
- Added an explicit, default-off one-shot fault to the permission-free lab app.
  It reproducibly exposes an ANR raw layer; normal input and recovery pass.
- Prepared a narrowly scoped raw-ANR routing prototype. Compile/link/load pass;
  multi-window runtime testing is next. Dialog placement/close behavior remain
  unvalidated. The temporary source binary trial was rolled back.

## Current checkpoint

The modal trial is paused for user-requested GitHub sign-in/publication. The
container is stopped; original HWC and the earlier scoped lab shim are retained.
The new modal prototype is not installed. Android app/account data is preserved.

Continue from [SESSION_STATE.md](SESSION_STATE.md). Read the full
[CHANGELOG.md](CHANGELOG.md), open [ROADMAP.md](ROADMAP.md),
[graphics build/results](diagnostics/wayland-roundtrip/NATIVE-BUILD.md) and
[Nintendo report](docs/NINTENDO-3.6.0.md) for evidence and limitations.

Completed checkpoints will be pushed at meaningful milestones, approximately
30–60minutes of active work, and before substantial session handoffs. This
requires an active session; no quota-reset polling/submission automation exists.
