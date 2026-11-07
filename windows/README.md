# windows/ — Windows integration layer

`tray/windroid-tray.ps1` — stage 1 tray app per ADR-005: PowerShell +
NotifyIcon + balloon tips, no GUI framework until this has run for two
weeks in real use. Started from Start Menu > Windroid > Windroid Tray
(shortcut created by the installer).

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

Stage 2 (Tauri or WinUI 3) is backlog; requirements to carry over live in
the WSA behaviour reference (docs/UPSTREAM-FACTS.md §8): per-app Start Menu
entries, a settings surface with app list + shutdown + GPU/network toggles,
shared-folder file handling.
