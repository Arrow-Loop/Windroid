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
