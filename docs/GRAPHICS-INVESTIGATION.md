# Lab graphics investigation

Work in progress, 2026-11-06. The contained Weston fallback works for a short
Settings control; seamless operation remains unresolved. Do not promote a
visible frame, readiness message or successful launch command to usability proof.

## Baseline and instrumentation

Surface Book3/i5-1035G7/8GB, WSL3.0.3/WSLg1.0.79, Android13 GApps20260927 and
vendor20261022. Android uses ANGLE over SwiftShader; nested Weston uses llvmpipe.
The physical desktop is3000x2000 at scale2. Direct Android calibration selected
3000x1904; nested Weston selected1280x768 at scale1.

Host `WAYLAND_DEBUG` is not automatically forwarded to Android's compositor.
The lab temporarily overlaid `system/etc/init/init.waydroid.rc`, replacing
only the compositor executable line with a shell wrapper. The wrapper executes
the same binary/arguments with `WAYLAND_DEBUG=client` and captures its output
to `/data/waydroid_tmp/windroid-hwc-protocol.txt`. Original service UID, groups,
capabilities and restart behavior remain in the definition. No protected app
was modified. [Wayland debugging documentation](https://wayland.freedesktop.org/extras.html)
documents this environment variable.

Original rc, Windroid config and Waydroid config are backed up under lab
`evidence/graphics-protocol-2026-11-06`. Trace and wrapper are local-only debug
artifacts. Remove the experiment overlay files with the container stopped,
restore the original config and properties, then validate normal startup.

## Findings so far

- Nested trace contains configure/ack exchanges and a1x1 background buffer with
  viewport destination1280x768. Settings launch returned WARM.
- Direct trace contains output scale2, configure1500x952 and a1x1 background
  buffer stretched by a viewport. That traffic is valid in itself; it does not
  prove a compositor defect. Historical WSLg logs also report surface/buffer
  dimension mismatches, but the symptom needs further correlation.
- Launching Settings with Android `am` alone did not expose its direct-mode
  window. Supported `waydroid app launch` also sets `waydroid.active_apps`, as
  confirmed in installed `tools/actions/app_manager.py`; use it for UI controls.
- A later native Settings window showed the full home screen, but navigation
  and movement were not established. Android screencap showed a Settings ANR
  dialog absent from the per-app Windows view. The captured ANR was20:46:17,
  after an earlier launch before readiness, so that process is a confounded
  control. Its main thread was runnable with scheduler wait recorded; no
  graphics deadlock or memory-exhaustion cause was established.
- `persist.waydroid.no_background_subsurface` is present in both upstream
  [compositor source](https://github.com/waydroid/android_hardware_waydroid/blob/lineage-20/hwcomposer/wayland-hwc.cpp)
  and the installed binary. A trial with true reached readiness near the180s
  limit but exposed no app window in the first supported-launch check. It is
  not a validated workaround. Reset it to false for the next control.

## Display-size control and rollback

The logical640x480 trial used existing `persist.waydroid.width` and `.height`;
runtime dimensions became1280x960 at scale2. It failed before a usable app
control, with this captured protocol error:

```text
xdg_surface buffer (640 x 480) does not match the configured maximized state (1500 x 952)
```

HWC aborted and SurfaceFlinger restarted with DEAD_OBJECT errors. The client
overrode dimensions selected by a maximized configure; it must reconcile that
state before committing a different size. This is a specific unsafe override
case, not proof of the same cause in earlier default-size failures. Do not
recommend forced dimensions as a workaround on this tested stack.

Rollback cleared width/height/no-background back to empty values (default
behavior), set multi_windows=false, restored `windroid.conf.original`, and
removed only the matching experiment-created rc and wrapper overlays. The
restored compositor definition byte-matched its original. Android account/app
data and verified images were retained. Untraced nested startup reached ready
in106s; visual control is being checked separately. Source defaults remain
seamless; the temporary lab fallback is not a project default.

## Session health follow-up

Windroid now supplements the log marker with a bounded live `waydroid app list`
query and requires returned package data. Upstream
[getAppsInfo implementation](https://github.com/waydroid/android_frameworks_waydroid/blob/lineage-20/services/java/id/waydro/server/WayDroidService.java)
queries PackageManager. A logged IPC error with exit0 is not accepted as
readiness. Probe time counts toward the wait deadline, and an existing session
waits for framework recovery without spawning another daemon. Ten isolated
Linux lifecycle tests pass; applicable Git Bash tests pass with two Linux-only
skips. The recovered real guest passed a live ensure probe in1.909s. This checks
framework responsiveness, not app ANRs or the Windows presentation path.

## Subsequent controls

A WSL shutdown restored presentation initially, but full-UI startup reproduced
a System UI ANR. Its main thread waited in `RenderProxy::setStopped`; a render
thread was runnable in `memmove` and ANGLE texture staging. This is a specific
backend lead, not proof of a deadlock. Raw target-only trace remains local.

The temporary `debug.hwui.renderer=skiavk` trial was verified with
`dumpsys gfxinfo`: both System UI and Settings used Skia Vulkan. Android rendered
Settings while the Windows view stayed black. The setting was cleared; it is
not a verified workaround. No renderer override was persisted.

Waydroid's `active_apps=Waydroid` selects full-desktop mode, while an app package
selects single-app mode even with multi_windows=false. The source app launcher
changes that property. `show-full-ui` additionally expands/collapses the
notification shade. Comparisons must distinguish those paths. A later control
set full-desktop mode and used Android `am` only to launch Settings after
readiness, avoiding the shade refresh.

Weston 13's supported `--renderer=pixman` was tested only in the installed lab
helper, with a backup. It reached readiness in 124 seconds. A Battery click
reached Android and produced a Battery screencap while an immediate Windows
capture still showed Network. A normal animated `weston-simple-shm` client
rendered inside the same desktop; Android updates also became visible. However,
updates later occurred without the animation, so repaint starvation is not an
established cause. The control client was stopped.

A bounded navigation sample without the control client showed Battery at
1,790 ms and Network at 5,355 ms after the next click. Thus this Pixman/full-UI
path can update and navigate, with latency. Earlier isolated stale snapshots
are not proof that every such frame is permanently frozen. An original-GL
control using the same full-UI/no-shade launch method is in progress before any
claim that Pixman alone improved reliability. Source renderer defaults remain
unchanged.

The live-framework timeout now escalates to SIGKILL after one additional second
if the query ignores termination. A stubborn 30-second mock distinguishes this
from an unbounded wait. Linux and Git Bash checks pass; the latter uses a wider
wall-time assertion to allow process startup under this host's Android load.
