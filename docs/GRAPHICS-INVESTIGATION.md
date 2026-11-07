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
control using the same full-UI/no-shade launch method also rendered/navigated.
Its Battery page appeared between the 4,347 ms and 26,679 ms observations;
exact completion latency is unknown. The existing app launcher also rendered
from that working session. No renderer-only improvement is established, and
the installed helper was restored to the source GL default.

The live-framework timeout now escalates to SIGKILL after one additional second
if the query ignores termination. A stubborn 30-second mock distinguishes this
from an unbounded wait. Linux and Git Bash checks pass; the latter uses a wider
wall-time assertion to allow process startup under this host's Android load.

## Clean seamless and boot-wide Vulkan controls

A clean seamless start, with no premature app launch, exceeded 180 seconds;
the ready marker appeared about ten seconds later. The supported app launcher
then waited another 37 seconds for a live framework response. Windows still
showed a splash while Android rendered Settings behind a Trebuchet ANR. Its
main thread was sampled runnable in icon-cache initialization with substantial
scheduler wait. Earlier premature launch is therefore not the sole explanation;
this stack alone does not prove a graphics deadlock.

A distinct boot-wide Vulkan control applied `debug.hwui.renderer=skiavk` through
backed-up Waydroid properties and offline regeneration, before UI process forks.
System UI, Launcher and Settings all reported Skia Vulkan. Windows still showed
a stale splash/dim frame while Android screencap showed the full Settings page.
Startup again exceeded 180 seconds. The crash buffer also captured an early
system-server null dereference in `RefBase::incStrong` through the HIDL service
manager on an NDK MediaCodec thread, followed by DeadSystemExceptions and a
Launcher initialization NPE. This confounds startup and does not establish a
causal link to Vulkan. No renderer workaround is justified by these controls.

Rollback restored `waydroid.cfg.before-boot-vulkan`, the original nested lab
configuration and offline-derived properties. The HWUI override is absent;
multi_windows=false and source rendering defaults remain unchanged. No image
download or app/account reset occurred. Startup after rollback completed with
exit0 in 121 seconds on November 6. November 7 live-framework and IP/DNS controls
passed after an overnight gap, but host sleep prevents a continuous-uptime claim.
The official vendor feed was checked and still lists the installed 20261022
image as latest; the verified artifact was reused.

## Installed composer provenance — 2026-11-07

[Waydroid issue 2436](https://github.com/waydroid/waydroid/issues/2436) describes
a focus-lock cycle and excessive display hotplugs after the September vendor
image. The focus change merged in
[HWC PR87](https://github.com/waydroid/android_hardware_waydroid/pull/87) on
October18; the dimension-change guard merged as
[5af0c114](https://github.com/waydroid/android_hardware_waydroid/commit/5af0c114a19fc916de837ad553524cd2aade2719)
on October19. Both predate this lab's October22 vendor image.

Read-only inspection extracted the installed HWC's compressed mini debug
symbols into local evidence. Build ID is `6c430943c45f04be014a87a0715b8653`,
SHA256 `3dcfbc40b2944fd02d252b06c2eddbfcfd30b926f60d52a8d75ade245c68d1d8`.
Its `keyboard_handle_enter` unlocks the recursive mutex at `0x49bda` before the
task virtual call at `0x49bfc`. Its xdg configure path compares previous/current
width and height at `0x47cba`/`0x47cbf` and skips `do_hotplug` when unchanged.
These specific fixes are already reflected in the installed binary. Rebuilding
them alone is not a new test hypothesis; this does not exclude other lock or
surface-lifecycle defects. No binary was patched or replaced.

## Local Weston diagnostics and restart race

Bounded `debuggerd -b` snapshots of HWC and SurfaceFlinger in the black nested
session completed successfully. The sampled Wayland thread was polling, the
EGL worker was waiting for work, and SurfaceFlinger's main thread was in its
Looper. This sample did not show the focus-lock cycle; idle waits alone do not
prove the whole presentation path healthy. The expected nested socket binding
and a single Weston process were verified.

Enabling only Weston's documented local `--debug` interface required a restart
and exposed another lifecycle gap: stop returned while the old Weston was
exiting. Start could observe it once, skip launching a replacement, and wait
180 seconds for a socket that disappeared. The log retained the old compositor's
shutdown and no new startup. Three isolated regressions reproduce the old
helper's missing exit wait, false stop success and missing replacement.

The helper now waits within its configured budget for the current user's
nested compositor to exit, reports failure if it does not, and still attempts
container shutdown. Startup rechecks an existing compositor while waiting for
its socket, so disappearance can launch a replacement. Thirteen Linux tests
pass; Git Bash passes with three Linux-only skips. Syntax/ShellCheck pass.

The diagnostic start reached ready in93s. Before launching an app, Weston showed
its own desktop and the scene graph had only shell views. After supported
Settings launch, it recorded the1x1 parent plus1280x768 child, buffer releases
and continuing commits; Windows rendered Settings. Battery selection appeared
by3,970ms, with the full page observed later, so no exact navigation latency
is claimed. This control does not explain earlier intermittent black output.

The temporary flag was removed. A normal immediate cycle then stopped in6s,
left no Weston process, created a new PID and reached live readiness in88s
(09:00:25->09:01:53 on November7), exit0. Installed helper and source SHA256
match; no renderer, image or account change was retained. This is a lifecycle
fix, not a seamless graphics fix. Evidence remains in local
`evidence/integration-2026-11-07`.

## Nested idle screen and independent System UI ANR — November7

The first-party `diagnostics/android-control` workload drew advancing frames in
Android while the native nested view appeared black. Refreshing the Windows
window binding and activating it exposed Weston's own "Unlock your desktop"
overlay. This identifies an idle-screen cause in that observation, without
attributing all previous black frames or seamless failures to the same cause.

The [official Weston manual](https://manpages.ubuntu.com/manpages/noble/man1/weston.1.html)
documents a default300second idle timeout that can fade/lock the compositor;
`--idle-time=0` disables it. Windroid now passes this option only when launching
its embedded nested display. Source fallback defaults remain unchanged, and no
Windows lock/security setting or Android authentication setting was changed.
The delayed-socket regression requires this option and fails when it is removed.
All13 Linux lifecycle tests and applicable Git Bash checks pass, as do syntax
and ShellCheck. Installed/source helper hashes match after a backup.

Normal stop/start plus control launch returned0 at10:31:22. Windows displayed
advancing control frames, then accepted mouse events and Space. Paused frame987
was visibly confirmed. With no further injected input from10:36:03.476 through
the10:41:35 observation (over331seconds), Windows still displayed the same
paused frame987, without a black screen or Weston idle overlay. This is one
successful bounded idle control, not indefinite availability or seamless proof.

This boot also produced a System UI ANR at10:30:19 while executing
`com.android.systemui/.keyguard.KeyguardService`. Its main thread was Runnable
in `NotificationStackSizeCalculator` during startup, with about8.05seconds
scheduled execution and4.28seconds runnable wait in that trace. SurfaceFlinger
used344%CPU in the reported interval. The
[Lineage20 source](https://github.com/LineageOS/android_frameworks_base/blob/lineage-20.0/packages/SystemUI/src/com/android/systemui/statusbar/notification/stack/NotificationStackSizeCalculator.kt)
builds a sequence from the current child views; this sample alone establishes
neither an infinite loop nor a lock cycle. Do not patch notification/security
behavior or relax readiness deadlines based only on that stack.

The visible Wait action dismissed the ANR temporarily; it recurred. Close-app
recovery restarted System UI and recreated the control Activity, after which
the input observations above succeeded. System UI PID2966 was later sleeping
at0%CPU, control PID1774 and SurfaceFlinger104 remained present, and the bounded
VMBus error count was0. This is recovery evidence, not a framework fix.
