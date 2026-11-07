# installer/ — the one-command user surface

```powershell
# vanilla:
powershell -ExecutionPolicy Bypass -File install.ps1
# with Google apps (image is fetched on YOUR machine — never redistributed):
powershell -ExecutionPolicy Bypass -File install.ps1 -Gapps
# uninstall (returns the machine to its prior state, stock kernel included):
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

Design constraints (plan Phase 2.1/2.6):

- **Idempotent + resumable**: stages are tracked in
  `%LOCALAPPDATA%\Windroid\state.json`; if the WSL install forces a reboot,
  rerunning the same command continues from where it stopped.
- **`.wslconfig` is merged, never clobbered** — Docker Desktop and other
  distros share it. Every key we set is recorded with its previous value,
  and `uninstall.ps1` reverts exactly those lines (unit-tested in
  `tests/test-wslconfig-merge.ps1`; a timestamped backup is also written).
  Keys we set: `[wsl2] kernel / kernelModules / memory` (default
  `min(8GB, 50% RAM)`), `[experimental] autoMemoryReclaim=gradual /
  sparseVhd=true`. We warn on `networkingMode=mirrored` but never change it
  (ADR-003).
- **Health check**: after first boot the installer runs the ddcash-style
  smoke test (session start → poll for `Session: RUNNING` + `Container:
  RUNNING` → stop) and reports PASS/FAIL.
- Target: ≤ 5 minutes on 100 Mbit excluding the one possible reboot —
  measured with `-Bench` (feeds docs/PERF.md).

`-ArtifactSource` accepts a local directory (Phase 1 testing on a clean VM)
or a release download base URL. Artifact names and checksums come from the
release's `versions.json` manifest.

Not yet built (backlog): winget manifest.

## Configuration ordering and release downloads

With no `-ArtifactSource`, use adjacent `artifacts/versions.json` when present;
otherwise download the upstream distribution ZIP, verify SHA256SUMS.txt, and
extract its artifacts. Published v0.1.0 has no standalone manifest asset.
Kernel, modules VHDX and rootfs hashes are all required and checked.

For a reproducible baseline, `-SkipWslUpdate` uses the installed WSL instead
of running `wsl --update`. The minimum WSL version is still checked; missing
WSL still goes through prerequisite installation. Default behavior updates WSL.

Guest firstboot waits for `/etc/windroid/.configured`. During configuration the
installer stops any legacy firstboot/container service, installs matching guest
helpers from `rootfs/files`, applies GApps/share settings, then writes the gate.
The explicit firstboot invocation serializes with systemd using flock and writes
the selected flavour to its success stamp only after initialization succeeds.
Legacy empty stamps are reprocessed; failed GApps downloads can be retried with
the same parked VANILLA preseed. Completed installations cannot silently switch
flavour by rerunning the installer; back up data and reinstall instead.

Both distribution formats include the guest helpers. When using an installer
from source, keep its repository layout. Direct rootfs imports must finish
configuration and create `/etc/windroid/.configured` before invoking firstboot;
they no longer initialize Android automatically before configuration.

Validation: `installer/tests/test-artifacts.ps1` tests release ZIP extraction,
cache reuse and corruption rejection. `python3 rootfs/test-firstboot.py` tests
configuration gating, legacy stamps and download retry behavior with isolated
fixtures. Git Bash stubs flock; actual Linux locking and Android runtime behavior
still require WSL validation.

## Tray shortcut ownership and repair

Windows tray shortcuts live under `Start Menu > <DistroName> Tools`, outside
WSLg's managed `<DistroName>` Android app folder. WSLg sync removes unreported
links and their referenced icons from its folder, which removed the original
tray shortcut in the lab. Installer reruns repair the tray link even when all
installation stages are complete, without reinitializing Android. Only a
matching legacy link is migrated; unrelated shortcuts/files are preserved.
`installer/tests/test-tray-shortcut.ps1` covers this behavior using isolated
files and a COM substitute; checks pass in PowerShell7 and5.1. Actual completed
installer resume also repaired the lab link; resync survival is checked separately.
