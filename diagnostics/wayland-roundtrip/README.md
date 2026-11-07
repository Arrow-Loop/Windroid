# Wayland queue ownership probe

Optional, standalone Linux client. It opens its own compositor connection and
never attaches to Android. Requires Python3 and installed libwayland-client.
Run as the graphical session user with its actual runtime/socket environment:

```bash
timeout 5 python3 diagnostics/wayland-roundtrip/probe.py shared
timeout 5 python3 diagnostics/wayland-roundtrip/probe.py private
```

Always use an external timeout: shared mode intentionally demonstrates two
threads dispatching one default queue and may hang. Private mode gives the
roundtrip thread its own queue while the other dispatches the default queue.
Each process attempts200 requests, prints progress and exits; the OS closes
its connection and background reader. No monitor or retry service is installed.

Wayland's [client API](https://wayland.freedesktop.org/docs/html/apb.html)
documents separate event queues for separate threads and requires dispatch on
the right queue/thread. This probe checks that ownership distinction, rather
than compositor rendering or Android compatibility.

## Lab observation, November7

With nested Weston, Ubuntu libwayland-client1.22.0-2.1build1:

| Mode | Three bounded trials |
|---|---|
| shared | timeout124, timeout124, pass200 |
| private | pass200, pass200, pass200 |

Meanwhile, the installed Android composer's main thread remained in a
`wl_display_roundtrip_queue` wait inside `window::create` in two samples over
four minutes apart, while its Wayland thread polled. Fresh clients through both
host and Android-mounted sockets completed. Mounted socket inode/dev matched;
namespace-aware socket inspection confirmed the composer peers with Weston.

The [upstream composer source](https://github.com/waydroid/android_hardware_waydroid/blob/lineage-20/hwcomposer/wayland-hwc.cpp)
calls default-queue roundtrips during window creation alongside a default-queue
dispatch thread. The probe supports investigating that pattern. It does not
prove the installed Android library has the same race or validate a composer
patch. No vendor binary, app protection, renderer or security setting changed.

## Android validation still required

Build guidance was reviewed against upstream HWC commit
`a575cfcc12ab79a122844218f2c6df5bd208cca0`. Its Android.bp links a static Wayland
client and platform/HIDL/generated Waydroid interfaces, so a normal Android SDK
app build cannot produce a replacement composer. The SDK used for the Canvas
control is not that platform build environment.

The lab has about81.3GB free disk and8GB physical RAM, with a3GB WSL cap.
The [current AOSP requirements](https://source.android.com/docs/setup/start/requirements)
describe400GB free disk and64GB RAM for a full current tree; those are not
measured minimum requirements for this older individual HAL. No full source sync
was started. Investigate a smaller native Android Wayland probe/matching-library
build before considering an entire platform build. No external build host,
remote CI workload or paid capacity has been requested or configured.

## Native Android probe

`android-probe.c` loads the unchanged installed composer library into its own
process and resolves exported Wayland functions. It never calls the HAL open
operation or a service API. `load` checks dependencies and symbol origin without
connecting; `shared`/`private` use a separate connection. A five-second alarm
bounds each process. Requests default200; an optional count accepts1..100000.

```bash
ANDROID_NDK_ROOT=/path/to/verified/android-ndk-r25c \
  bash diagnostics/wayland-roundtrip/build-android.sh /absolute/output/probe
```

Stage only that executable in an owned Android test directory. In the lab,
`LD_LIBRARY_PATH=/vendor/lib64:/apex/com.android.vndk.v33/lib64:/system/lib64`,
`XDG_RUNTIME_DIR=/run/xdg`, `WAYLAND_DISPLAY=wayland-0` were set only for each
test process. These paths were verified on this image; do not apply them to
other images without checking. Keep an external timeout as well.

NDK r25c archive SHA256
`769ee342ea75f80619d985c2da990c48b3d8eaf45f48783a2d48870d04b46108`, published
SHA1`53af80a1cce9144025b81c78c8cd556bff42bd0e` verified. The legacy toolchain is
pinned for this Android13 diagnostic. It is not a product dependency. Compilation
with `-Wall -Wextra -Werror` and builder syntax/ShellCheck pass.

On November7, load-only succeeded and symbol origin was the installed HWC.
Three200-request trials passed in each mode. Increasing to20000 requests
reproduced shared-queue stalls, while all three private-queue trials completed.
See local `android-queue-stress-results.txt` for exact outcomes. This tests the
actual linked library, but still does not prove a real composer fix. The running
composer remained unchanged and stalled during these isolated tests.

The20000-request shared trials all exited142 (the probe's five-second alarm),
before the next2000-request progress marker. Private trials all exited0. A
separate `preload` probe mode resolves the replacement through `RTLD_DEFAULT`
and reports its symbol origin, so a passing test cannot silently use the old
roundtrip implementation.

## Experimental per-call queue shim

`queue-shim.c` interposes only `wl_display_roundtrip`. Each call creates its own
sync queue, invokes the original queue-specific function and destroys that
queue while preserving errno. It resolves the already-loaded HAL via
`RTLD_NOLOAD`, because HAL modules can be local to the dynamic loader. It does
not open a HAL, change a display setting or modify the vendor binary.

`build-shim.sh` builds the optional shared library with the same verified NDK.
Activation is deliberately absent from the builder and installer. Native
`preload` stress trials with this library passed20000 requests in3/3, with the
reported roundtrip origin pointing to the shim. This validates isolated
interposition; a real composer lifecycle/visual/input test is still required.

The installed HAL has a `JUMP_SLOT` relocation for `wl_display_roundtrip`, making
a composer-only loader experiment possible. Any such experiment needs a backup
of its init definition, explicit rollback of owned overlay files, and a normal
container restart. Never apply LD_PRELOAD to all Android services or apps.
