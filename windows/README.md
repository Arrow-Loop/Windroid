# windows/ — Windows integration layer

`tray/windroid-tray.ps1` — stage 1 tray app per ADR-005: PowerShell +
NotifyIcon + balloon tips, no GUI framework until this has run for two
weeks in real use. Started from Start Menu > Windroid Tools > Windroid Tray
(shortcut created by the installer).

For a custom distro name, the folder is `<DistroName> Tools`. WSLg owns the
separate Android app folder and deletes links absent from its Linux app list
at sync end, including icons referenced by those links. The Windows tray must
stay outside that folder. Rerunning the installer repairs/migrates its shortcut
even if the integration stage is already complete. Migration removes only a
legacy link targeting the same installation; uninstall preserves unrelated
files in the Tools folder. The staged `bin/windroid.ico` is preferred so a
legacy WSLg cleanup cannot remove the tray's icon source.

Menu: Status · Start/Stop/Restart session · Install APK… (file picker →
`waydroid app install`) · Android Settings (`com.android.settings`) ·
Open logs · Check for updates (GitHub latest release vs the local
manifest) · Exit. Double-click = ensure session running.

Session and installation failures display an error balloon. Restart stops if
the stop command fails; it does not start another session or announce success.
APK filenames are passed as native arguments so spaces and apostrophes survive
the Windows-to-WSL conversion. `installer/tests/test-tray-commands.ps1` checks
these command paths and the real lifecycle callbacks without starting the UI.
The focused checks pass on PowerShell 7 and Windows PowerShell 5.1; they do not
establish live file-picker, notification-area, or Android rendering behavior.

The tray reports "Installation requested" after Waydroid accepts an install
request. Android commits asynchronously, and an accepted request can remain
pending; verify completion in Android before launching or reporting success.

A November7 lab-only sharing control used the installed bindfs options and
shared root propagation to expose a fresh test directory under Android shared
storage. Windows-to-Android reads and Android-to-Windows writes matched the
fixtures. The temporary mount and empty Android directory were removed;
personal Downloads was not inspected or remounted. This checks the namespace
transport, not app file-picker permissions. Evidence remains in lab
`evidence/integration-2026-11-07/file-share-result.json`.

Stage 2 (Tauri or WinUI 3) is backlog; requirements to carry over live in
the WSA behaviour reference (docs/UPSTREAM-FACTS.md §8): per-app Start Menu
entries, a settings surface with app list + shutdown + GPU/network toggles,
shared-folder file handling.
