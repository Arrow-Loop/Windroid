<#
.SYNOPSIS
  Windroid installer — one command, idempotent, resumable across the
  WSL-install reboot (plan Phase 2.1).

.DESCRIPTION
  Stages (tracked in state.json; rerun after a reboot continues where it
  left off):
    1 preflight      Windows 11, virtualization, disk, WSL/distro detection
    2 wsl            install/update WSL if needed (may require reboot)
    3 artifacts      fetch kernel + rootfs per the version manifest
    4 wslconfig      MERGE our keys into %USERPROFILE%\.wslconfig (never clobber)
    5 import         wsl --import of the Windroid distro
    6 configure      guest config: -Gapps flag, Windows Downloads share path
    7 firstboot      waydroid init from preseeded images (binder kernel active)
    8 smoketest      start session, wait for RUNNING, stop — PASS/FAIL
    9 integrate      Start Menu shortcuts, tray, windroid CLI on PATH

.PARAMETER Gapps
  Build the GApps flavour user-side (never redistributed — ADR-004).
.PARAMETER ArtifactSource
  Directory or base URL holding the release artifacts + versions.json
  manifest. Default: the project's GitHub latest release.
.PARAMETER DistroName
  WSL distro name to register (default: windroid).

.NOTES
  All Linux-side values come from docs/UPSTREAM-FACTS.md; .wslconfig keys
  are the documented ones ([wsl2] kernel/kernelModules/memory,
  [experimental] autoMemoryReclaim/sparseVhd).
#>
[CmdletBinding()]
param(
    [switch]$Gapps,
    [string]$ArtifactSource,
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')][string]$DistroName = "Windroid",
    [string]$InstallRoot = "$env:LOCALAPPDATA\Windroid",
    [ValidateRange(2, 64)][int]$MemoryCapGB = 0,   # 0 = auto: min(8GB, 50% RAM)
    [switch]$SkipWslUpdate,  # reproducible testing with the installed WSL; minimum version still enforced
    [switch]$Bench
)
$ErrorActionPreference = "Stop"
$script:StartTime = Get-Date

$StateFile  = Join-Path $InstallRoot "state.json"
$KernelDir  = Join-Path $InstallRoot "kernel"
$DistroDir  = Join-Path $InstallRoot "distro"
$BinDir     = Join-Path $InstallRoot "bin"
$LogFile    = Join-Path $InstallRoot "install.log"
$WslConfig  = Join-Path $env:USERPROFILE ".wslconfig"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan; Add-Content $LogFile "$(Get-Date -Format o) $msg" }
function Fail($msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; Add-Content $LogFile "$(Get-Date -Format o) FAIL: $msg"; exit 1 }

function Get-State {
    if (Test-Path $StateFile) { Get-Content $StateFile -Raw | ConvertFrom-Json }
    else { [pscustomobject]@{ done = @(); wslconfigChanges = @(); wslgconfigChanges = @() } }
}
function Save-State($state) { $state | ConvertTo-Json -Depth 5 | Set-Content $StateFile }
function Test-Done($state, $stage) { $state.done -contains $stage }
function Mark-Done([ref]$state, $stage) {
    if (-not (Test-Done $state.Value $stage)) { $state.Value.done += $stage }
    Save-State $state.Value
}

function Resolve-ArtifactSource([string]$source, [string]$cacheDir) {
    if ($source) { return $source }
    $bundled = Join-Path $PSScriptRoot '..\artifacts'
    if (Test-Path -LiteralPath (Join-Path $bundled 'versions.json')) { return $bundled }

    # v0.1.0 publishes a distribution ZIP, not individual kernel/rootfs files
    # or versions.json. Verify that ZIP before extracting its artifacts.
    New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
    $base = 'https://github.com/calm032019/Windroid/releases/latest/download'
    $sums = Invoke-WebRequest -UseBasicParsing -Uri "$base/SHA256SUMS.txt"
    $sumText = if ($sums.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($sums.Content) } else { [string]$sums.Content }
    $match = [regex]::Match($sumText, '(?im)^([a-f0-9]{64})\s+\*?Windroid\.zip\s*$')
    if (-not $match.Success) { throw 'Release checksums do not contain Windroid.zip. Use -ArtifactSource with an extracted release artifacts directory.' }
    $expected = $match.Groups[1].Value
    $zip = Join-Path $cacheDir 'Windroid.zip'
    if (-not (Test-Path -LiteralPath $zip) -or (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne $expected) {
        $partial = "$zip.partial"
        Invoke-WebRequest -UseBasicParsing -Uri "$base/Windroid.zip" -OutFile $partial
        if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $expected) { throw 'Release ZIP SHA-256 mismatch; nothing was imported.' }
        Move-Item -LiteralPath $partial -Destination $zip -Force
    }
    $expanded = Join-Path $cacheDir 'expanded'
    Expand-Archive -LiteralPath $zip -DestinationPath $expanded -Force
    $artifacts = Join-Path $expanded 'Windroid\artifacts'
    if (-not (Test-Path -LiteralPath (Join-Path $artifacts 'versions.json'))) { throw 'Release ZIP has no Windroid/artifacts/versions.json.' }
    return $artifacts
}

function Assert-ArtifactHash([string]$path, [string]$sha) {
    if ($sha -notmatch '^[a-fA-F0-9]{64}$') { throw "Missing or invalid SHA-256 for $path" }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $sha) { throw "SHA-256 mismatch for $path" }
}

New-Item -ItemType Directory -Force -Path $InstallRoot, $KernelDir, $DistroDir, $BinDir | Out-Null
$state = Get-State
if ($state.PSObject.Properties.Name -contains 'gapps') {
    if ($Gapps -and -not $state.gapps) { Fail 'This installation was configured as VANILLA. Back up Android data and reinstall with -Gapps; changing image flavour on a resumed install is not supported.' }
    $Gapps = [bool]$state.gapps
}

# ---------------------------------------------------------------- 1 preflight
if (-not (Test-Done $state "preflight")) {
    Write-Step "Preflight"
    $os = Get-CimInstance Win32_OperatingSystem
    if ([int]$os.BuildNumber -lt 22000) { Fail "Windows 11 (build >= 22000) required; found build $($os.BuildNumber). Windows 10 is out of scope (docs/known-limits.md)." }

    $cs = Get-CimInstance Win32_ComputerSystem
    if (-not $cs.HypervisorPresent) {
        $vfw = (Get-CimInstance Win32_Processor).VirtualizationFirmwareEnabled
        if (-not $vfw) { Fail "Virtualization is disabled. Enable VT-x/AMD-V in firmware, then rerun." }
    }

    $sysDrive = Get-PSDrive -Name $env:SystemDrive.TrimEnd(':')
    if ($sysDrive.Free -lt 15GB) { Fail "Need >= 15 GB free on $env:SystemDrive (found $([math]::Round($sysDrive.Free/1GB,1)) GB)." }

    # Advise BEFORE touching anything: enabling WSL forces a Windows restart
    # (the setup wizard shows this on its system-check page; this covers the
    # console/INSTALL.cmd path).
    $wslEnabled = $false
    try { wsl --status *> $null; $wslEnabled = ($LASTEXITCODE -eq 0) } catch { }
    if (-not $wslEnabled) {
        Write-Host ""
        Write-Host "NOTE: WSL is not enabled on this PC yet. Setup will enable it now," -ForegroundColor Yellow
        Write-Host "but Windows will REQUIRE A RESTART partway through. After restarting," -ForegroundColor Yellow
        Write-Host "run this installer again - it resumes exactly where it left off." -ForegroundColor Yellow
        Write-Host "Press Ctrl+C within 10 seconds if you'd rather not continue." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }

    # Existing distro with our name = previous/partial install; import stage handles it.
    # Mirrored networking conflicts with Waydroid's dnsmasq (ADR-003) — warn, don't touch.
    if ((Test-Path $WslConfig) -and (Select-String -Path $WslConfig -Pattern '^\s*networkingMode\s*=\s*mirrored' -Quiet)) {
        Write-Warning "Your .wslconfig sets networkingMode=mirrored — Waydroid's dnsmasq will conflict (docs/UPSTREAM-FACTS.md §6). NAT is the supported mode; the documented workaround is [experimental] ignoredPorts=53,67,68. Not changing your config."
    }
    Mark-Done ([ref]$state) "preflight"
}

# ---------------------------------------------------------------------- 2 wsl
if (-not (Test-Done $state "wsl")) {
    Write-Step "WSL install/update"
    $wslOk = $false
    try { wsl --status | Out-Null; $wslOk = ($LASTEXITCODE -eq 0) } catch { }
    if (-not $wslOk) {
        wsl --install --no-distribution
        if ($LASTEXITCODE -notin @(0, 3010)) { Fail "wsl --install failed (code $LASTEXITCODE). First-time WSL setup may require an elevated terminal." }
        # Do not checkpoint WSL as ready before the required reboot. Reruns
        # must recheck it instead of skipping straight to import.
        Write-Host ""
        Write-Host "A REBOOT is likely required to finish enabling WSL." -ForegroundColor Yellow
        Write-Host "After rebooting, rerun this same command — it resumes automatically." -ForegroundColor Yellow
        exit 0
    }
    if (-not $SkipWslUpdate) {
        wsl --update | Out-Null
        if ($LASTEXITCODE -ne 0) { Fail "wsl --update failed (code $LASTEXITCODE); the WSL stage will retry on rerun." }
    }
    # .wsl-file features and current fixes need a reasonably fresh WSL (>= 2.4.4).
    # wsl.exe output is UTF-16; strip the interleaved NULs before parsing.
    $verLine = ((wsl --version) -replace "`0", "") | Select-String -Pattern 'WSL[^\d]*([\d.]+)' | Select-Object -First 1
    $ver = if ($verLine) { $verLine.Matches.Groups[1].Value } else { $null }
    Add-Content $LogFile "WSL version: $ver"
    if (-not $ver) { Fail "Could not determine the WSL version. Run 'wsl --version' and 'wsl --update', then rerun." }
    if ([version]$ver -lt [version]"2.4.4") { Fail "WSL $ver is too old (need >= 2.4.4). Run 'wsl --update' and rerun." }
    Mark-Done ([ref]$state) "wsl"
}

# ---------------------------------------------------------------- 3 artifacts
if (-not (Test-Done $state "artifacts")) {
    try { $ArtifactSource = Resolve-ArtifactSource $ArtifactSource (Join-Path $InstallRoot 'release-cache') }
    catch { Fail "Cannot obtain release artifacts: $($_.Exception.Message) Use -ArtifactSource <extracted Windroid\artifacts>." }
    Write-Step "Fetching artifacts from $ArtifactSource"
    function Get-Artifact($name, $dest) {
        if (-not $name -or $name -match '[/\\]' -or $name -in @('.', '..')) { throw "Invalid artifact filename: $name" }
        # Test-Path on an https:// string throws DriveNotFoundException —
        # branch on the source shape, not on path existence.
        if ($ArtifactSource -match '^https?://') {
            try { Invoke-WebRequest -UseBasicParsing -Uri "$ArtifactSource/$name" -OutFile $dest }
            catch { throw "Cannot fetch $name from $ArtifactSource. Releases may bundle artifacts inside Windroid.zip; extract it and pass -ArtifactSource <Windroid\artifacts>. $($_.Exception.Message)" }
        } else {
            Copy-Item (Join-Path $ArtifactSource $name) $dest -Force
        }
    }
    Get-Artifact "versions.json" (Join-Path $InstallRoot "manifest.json")
    $manifest = Get-Content (Join-Path $InstallRoot "manifest.json") -Raw | ConvertFrom-Json

    $kernelName  = $manifest.kernel.artifact
    $modulesName = $manifest.kernel.modules_artifact
    if (-not $modulesName) { $modulesName = $kernelName -replace '^bzImage-', 'modules-' -replace '$', '.vhdx' }
    $rootfsName  = $manifest.rootfs.flavours.vanilla.artifact
    Get-Artifact $kernelName  (Join-Path $KernelDir "bzImage")
    Get-Artifact $modulesName (Join-Path $KernelDir "modules.vhdx")
    Get-Artifact $rootfsName  (Join-Path $DistroDir "rootfs.tar.gz")

    # Checksums per manifest — refuse to proceed on mismatch.
    foreach ($pair in @(
        @{ path = (Join-Path $KernelDir "bzImage");        sha = $manifest.kernel.sha256 },
        @{ path = (Join-Path $KernelDir "modules.vhdx");   sha = $manifest.kernel.modules_sha256 },
        @{ path = (Join-Path $DistroDir "rootfs.tar.gz");  sha = $manifest.rootfs.flavours.vanilla.sha256 })) {
        Assert-ArtifactHash $pair.path $pair.sha
    }
    Mark-Done ([ref]$state) "artifacts"
}

# ---------------------------------------------------------------- 4 wslconfig
if (-not (Test-Done $state "wslconfig")) {
    Write-Step "Merging .wslconfig (backup + surgical key edits only)"
    if ($MemoryCapGB -eq 0) {
        $ramGB = [math]::Floor((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        $MemoryCapGB = [math]::Min(8, [math]::Max(2, [math]::Floor($ramGB / 2)))
    }
    # .wslconfig wants escaped backslashes (kernel=C:\\path). In .NET regex
    # substitution a backslash is LITERAL ($ is the only special char), so
    # the replacement is '\\' — '\\\\' writes quadruple backslashes
    # (zip-test finding; WSL tolerated it, but stay spec-conformant).
    $kernelPath  = (Join-Path $KernelDir "bzImage")  -replace '\\', '\\'
    $modulesPath = (Join-Path $KernelDir "modules.vhdx") -replace '\\', '\\'

    if (Test-Path $WslConfig) {
        Copy-Item $WslConfig "$WslConfig.windroid-backup-$(Get-Date -Format yyyyMMddHHmmss)"
    }
    # Minimal ini merge: set key in section if present, else append; record
    # previous values so uninstall.ps1 can revert exactly our changes.
    $lines = if (Test-Path $WslConfig) { @(Get-Content $WslConfig) } else { @() }
    $changes = @()
    function Set-IniKey([string[]]$lines, $section, $key, $value) {
        $out = New-Object System.Collections.Generic.List[string]
        $inSection = $false; $set = $false; $sectionSeen = $false
        foreach ($line in $lines) {
            if ($line -match '^\s*\[(.+)\]\s*$') {
                if ($inSection -and -not $set) { $out.Add("$key=$value"); $set = $true }
                $inSection = ($Matches[1] -eq $section)
                if ($inSection) { $sectionSeen = $true }
                $out.Add($line); continue
            }
            if ($inSection -and $line -match "^\s*$([regex]::Escape($key))\s*=") {
                $script:prevValue = ($line -split '=', 2)[1].Trim()
                $out.Add("$key=$value"); $set = $true; continue
            }
            $out.Add($line)
        }
        if (-not $sectionSeen) { $out.Add("[$section]"); $out.Add("$key=$value"); $set = $true }
        elseif (-not $set) { $out.Add("$key=$value") }
        return ,$out.ToArray()
    }
    # No sparseVhd: WSL 2.7.x disabled sparse VHD support ("due to potential
    # data corruption") and warns on every start if set (zip-test finding).
    foreach ($kv in @(
        @{ s = "wsl2";         k = "kernel";           v = $kernelPath },
        @{ s = "wsl2";         k = "kernelModules";    v = $modulesPath },
        @{ s = "wsl2";         k = "memory";           v = "${MemoryCapGB}GB" },
        @{ s = "experimental"; k = "autoMemoryReclaim"; v = "gradual" })) {
        $script:prevValue = $null
        $lines = Set-IniKey $lines $kv.s $kv.k $kv.v
        $changes += [pscustomobject]@{ section = $kv.s; key = $kv.k; value = $kv.v; previous = $script:prevValue }
    }
    Set-Content -Path $WslConfig -Value $lines
    $state.wslconfigChanges = $changes

    # .wslgconfig: make WSLg badge GUI apps with the Windroid logo instead
    # of Tux, and use it as the fallback window icon. The paths resolve via
    # /mnt/wslg/distro (the per-instance user-distro mount), so they only
    # exist inside the Windroid distro's WSLg — other distros keep Tux.
    $WslgConfig = Join-Path $env:USERPROFILE ".wslgconfig"
    if (Test-Path $WslgConfig) {
        Copy-Item $WslgConfig "$WslgConfig.windroid-backup-$(Get-Date -Format yyyyMMddHHmmss)"
    }
    $glines = if (Test-Path $WslgConfig) { @(Get-Content $WslgConfig) } else { @() }
    $gchanges = @()
    foreach ($kv in @(
        @{ s = "system-distro-env"; k = "WSL2_DEFAULT_APP_ICON";         v = "/mnt/wslg/distro/usr/lib/windroid/windroid-256.png" },
        @{ s = "system-distro-env"; k = "WSL2_DEFAULT_APP_OVERLAY_ICON"; v = "/mnt/wslg/distro/usr/lib/windroid/windroid-256.png" })) {
        $script:prevValue = $null
        $glines = Set-IniKey $glines $kv.s $kv.k $kv.v
        $gchanges += [pscustomobject]@{ section = $kv.s; key = $kv.k; value = $kv.v; previous = $script:prevValue }
    }
    Set-Content -Path $WslgConfig -Value $glines
    if (-not ($state.PSObject.Properties.Name -contains 'wslgconfigChanges')) {
        $state | Add-Member -NotePropertyName wslgconfigChanges -NotePropertyValue @()
    }
    $state.wslgconfigChanges = $gchanges
    Save-State $state
    wsl --shutdown
    Mark-Done ([ref]$state) "wslconfig"
}

# ------------------------------------------------------------------- 5 import
if (-not (Test-Done $state "import")) {
    Write-Step "Importing distro '$DistroName'"
    $existing = (wsl --list --quiet) -replace "`0", "" | Where-Object { $_ -eq $DistroName }
    if ($existing) {
        Write-Warning "Distro '$DistroName' already registered — reusing it. (Run uninstall.ps1 first for a clean reinstall.)"
    } else {
        wsl --import $DistroName (Join-Path $DistroDir "vm") (Join-Path $DistroDir "rootfs.tar.gz")
        if ($LASTEXITCODE -ne 0) { Fail "wsl --import failed (code $LASTEXITCODE)" }
    }
    Mark-Done ([ref]$state) "import"
}

# ---------------------------------------------------------------- 6 configure
if (-not (Test-Done $state "configure")) {
    Write-Step "Configuring guest ($(if ($Gapps) { 'GAPPS' } else { 'vanilla' }))"
    # Verify the custom kernel actually took (binder present) before firstboot.
    wsl -d $DistroName -u root -e bash -c "zgrep -q '^CONFIG_ANDROID_BINDER_IPC=y' /proc/config.gz"
    if ($LASTEXITCODE -ne 0) { Fail "Custom kernel not active in WSL (binder missing). Check [wsl2] kernel= in $WslConfig, run 'wsl --shutdown', retry." }

    # Older rootfs releases started firstboot as soon as this first WSL
    # command booted systemd, before -Gapps was applied. Quiesce that worker
    # before configuring anything; then install the matching guest fixes.
    wsl -d $DistroName -u root -e systemctl stop windroid-firstboot.service waydroid-container.service
    if ($LASTEXITCODE -ne 0) { Fail 'Could not stop firstboot/container before guest configuration.' }
    $guestFiles = Join-Path $PSScriptRoot '..\rootfs\files'
    if (Test-Path -LiteralPath $guestFiles) {
        $guestSource = ((wsl -d $DistroName -u root -e wslpath -a $guestFiles) -join '' -replace "`0", '').Trim()
        if ($LASTEXITCODE -ne 0 -or -not $guestSource) { Fail 'Cannot resolve the bundled guest files in WSL.' }
        foreach ($file in @(
            @{ path = 'usr/local/bin/windroid-firstboot'; mode = '0755' },
            @{ path = 'usr/local/bin/windroid-session'; mode = '0755' },
            @{ path = 'usr/local/sbin/windroid-prep'; mode = '0755' },
            @{ path = 'etc/systemd/system/windroid-firstboot.service'; mode = '0644' })) {
            wsl -d $DistroName -u root -e install -D -m $file.mode "$guestSource/$($file.path)" "/$($file.path)"
            if ($LASTEXITCODE -ne 0) { Fail "Cannot install guest helper $($file.path)." }
        }
        wsl -d $DistroName -u root -e systemctl daemon-reload
        if ($LASTEXITCODE -ne 0) { Fail 'Cannot reload guest service definitions.' }
    } elseif ($Gapps) {
        Fail 'GApps setup requires the matching rootfs/files guest helpers beside this installer. Use the complete distribution or repository checkout.'
    }

    if ($Gapps) {
        wsl -d $DistroName -u root -e bash -c "sed -i 's/^GAPPS=false/GAPPS=true/' /etc/windroid/windroid.conf"
        if ($LASTEXITCODE -ne 0) { Fail 'Could not select GAPPS in the guest configuration.' }
    }
    # Windows -> Android Downloads sharing (plan Phase 2.5): pass the WSL
    # view of the user's Downloads folder into the guest. NOT via sed with
    # an interpolated value: PowerShell's native-argv quoting mangles
    # embedded \" and truncates the expression (zip-test finding, twice).
    # Base64 through WSLENV needs zero quote characters end to end; the
    # guest reads /etc/windroid/downloads-path as raw text.
    $downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    $wslDownloads = ((wsl -d $DistroName -e wslpath -a "$downloads") -join '' -replace "`0", "").Trim()
    if ($LASTEXITCODE -ne 0) { Fail 'Could not resolve Windows Downloads in the guest.' }
    if ($wslDownloads) {
        $env:WINDROID_DL_B64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($wslDownloads))
        $oldWslEnv = $env:WSLENV
        $env:WSLENV = "WINDROID_DL_B64" + $(if ($oldWslEnv) { ":" + $oldWslEnv } else { "" })
        try {
            wsl -d $DistroName -u root -e bash -c 'echo $WINDROID_DL_B64 | base64 -d > /etc/windroid/downloads-path'
            if ($LASTEXITCODE -ne 0) { Fail 'Could not configure the Windows Downloads share.' }
        } finally {
            $env:WSLENV = $oldWslEnv
            Remove-Item Env:WINDROID_DL_B64 -ErrorAction SilentlyContinue
        }
    }
    wsl -d $DistroName -u root -e touch /etc/windroid/.configured
    if ($LASTEXITCODE -ne 0) { Fail 'Could not mark guest configuration complete.' }
    $state | Add-Member -NotePropertyName gapps -NotePropertyValue ([bool]$Gapps) -Force
    Mark-Done ([ref]$state) "configure"
}

# ---------------------------------------------------------------- 7 firstboot
if (-not (Test-Done $state "firstboot")) {
    Write-Step "First boot (waydroid init$(if ($Gapps) { ' -s GAPPS — downloads the GApps image now' } else { ' from preseeded images' }))"
    wsl -d $DistroName -u root -e /usr/local/bin/windroid-firstboot
    if ($LASTEXITCODE -ne 0) { Fail "firstboot failed — see /var/log/windroid-firstboot.log inside the distro" }
    Mark-Done ([ref]$state) "firstboot"
}

# ---------------------------------------------------------------- 8 smoketest
if (-not (Test-Done $state "smoketest")) {
    Write-Step "Smoke test: session up -> RUNNING -> down (ddcash-style)"
    wsl -d $DistroName -u windroid -e bash -lc "windroid-session start"
    $startCode = $LASTEXITCODE
    $ok = $false
    for ($i = 0; $startCode -eq 0 -and $i -lt 40; $i++) {
        $status = (wsl -d $DistroName -u windroid -e bash -lc "waydroid status 2>/dev/null") -join "`n"
        if ($LASTEXITCODE -eq 0 -and $status -match "Session:\s*RUNNING" -and $status -match "Container:\s*RUNNING") { $ok = $true; break }
        Start-Sleep -Seconds 3
    }
    wsl -d $DistroName -u windroid -e bash -lc "windroid-session stop" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail 'Smoke test could not stop the session cleanly.' }
    if (-not $ok) { Fail "smoke test: session never reached RUNNING (see ~/.local/state/windroid/session.log in the distro)" }
    Write-Host "Smoke test: PASS" -ForegroundColor Green
    Mark-Done ([ref]$state) "smoketest"
}

# ---------------------------------------------------------------- 9 integrate
if (-not (Test-Done $state "integrate")) {
    Write-Step "Windows integration (CLI + tray + Start Menu)"
    foreach ($f in @("windroid.ps1", "bench.ps1")) {
        $src = Join-Path $PSScriptRoot "..\scripts\$f"
        if (Test-Path $src) { Copy-Item $src $BinDir -Force }
    }
    $traySrc = Join-Path $PSScriptRoot "..\windows\tray\windroid-tray.ps1"
    if (Test-Path $traySrc) { Copy-Item $traySrc $BinDir -Force }

    # Only wire up what was actually copied — a release download without the
    # repo checkout must not get a dead shim/shortcut.
    if (Test-Path (Join-Path $BinDir "windroid.ps1")) {
        # windroid.cmd shim so `windroid` works from any shell once on PATH.
        Set-Content -Path (Join-Path $BinDir "windroid.cmd") -Value "@powershell -NoProfile -ExecutionPolicy Bypass -File `"$BinDir\windroid.ps1`" -DistroName `"$DistroName`" %*"
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$BinDir*") {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$BinDir", "User")
        }
    } else {
        Write-Warning "scripts\windroid.ps1 not found next to the installer — the 'windroid' CLI was not installed."
    }

    # Windroid logo: used by the tray and the Start Menu shortcut. WSLg's
    # per-app shortcuts land in the same Programs\<DistroName> folder, so
    # everything Android lives under one "Windroid" Start Menu group.
    $icoSrc = Join-Path $PSScriptRoot "..\assets\windroid.ico"
    if (Test-Path $icoSrc) {
        Copy-Item $icoSrc (Join-Path $InstallRoot "windroid.ico") -Force
        Copy-Item $icoSrc (Join-Path $BinDir "windroid.ico") -Force   # tray badge fallback
    }

    if (Test-Path (Join-Path $BinDir "windroid-tray.ps1")) {
        $programs = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\$DistroName"
        New-Item -ItemType Directory -Force -Path $programs | Out-Null
        $shell = New-Object -ComObject WScript.Shell
        $lnk = $shell.CreateShortcut((Join-Path $programs "Windroid Tray.lnk"))
        $lnk.TargetPath = "powershell.exe"
        $lnk.Arguments  = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$BinDir\windroid-tray.ps1`" -DistroName `"$DistroName`" -InstallRoot `"$InstallRoot`""
        if (Test-Path (Join-Path $InstallRoot "windroid.ico")) { $lnk.IconLocation = "$(Join-Path $InstallRoot "windroid.ico"),0" }
        $lnk.Save()
    } else {
        Write-Warning "windows\tray\windroid-tray.ps1 not found next to the installer — tray shortcut not created."
    }
    Mark-Done ([ref]$state) "integrate"
}

$elapsed = (Get-Date) - $script:StartTime
Write-Host ""
Write-Host "Windroid installed. ($([math]::Round($elapsed.TotalMinutes,1)) min$(if ($Bench) { ' — recorded for PERF.md' }))" -ForegroundColor Green
Write-Host "  Start:      windroid start     (or the Windroid Tray in the Start Menu)"
Write-Host "  Install app: windroid install <apk>"
Write-Host "  Android apps appear under Start Menu > Windroid ($DistroName) as you install them."
if ($Bench) { Add-Content (Join-Path $InstallRoot "bench-install.txt") "$(Get-Date -Format o) install_seconds=$([int]$elapsed.TotalSeconds) gapps=$Gapps" }
