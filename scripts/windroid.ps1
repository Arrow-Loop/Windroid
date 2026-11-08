<#
.SYNOPSIS
  windroid CLI (plan Phase 2.4).
    windroid install <apk>   sideload an APK
    windroid start|stop|status
    windroid adb             print/run the adb connect line (docs: adb connect <IP>:5555)
    windroid shell           root shell into Android (waydroid shell)
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][ValidateSet("install", "start", "stop", "status", "adb", "shell", "help")]
    [string]$Command = "help",
    [Parameter(Position = 1)][string]$Arg,
    [string]$DistroName = "Windroid"
)
$ErrorActionPreference = "Stop"

function Invoke-Guest([string]$cmd, [string]$user = "windroid") {
    # The `bash -c` form is deliberate — prior art found direct-exec less
    # reliable for detached processes (docs/UPSTREAM-FACTS.md §6).
    wsl -d $DistroName -u $user -e bash -lc $cmd
    if ($LASTEXITCODE -ne 0) { throw "Guest command failed (exit $LASTEXITCODE): $cmd" }
}

switch ($Command) {
    "start"  { Invoke-Guest "windroid-session start" }
    "stop"   { Invoke-Guest "windroid-session stop" }
    "status" { Invoke-Guest "waydroid status" }
    "shell"  { wsl -d $DistroName -u root -e waydroid shell }
    "install" {
        if (-not $Arg) { Write-Error "usage: windroid install <path-to.apk>"; exit 2 }
        if (-not (Test-Path -LiteralPath $Arg -PathType Leaf)) { Write-Error "not found: $Arg"; exit 2 }
        $winPath = (Resolve-Path -LiteralPath $Arg).Path
        $wslPath = ((wsl -d $DistroName -e wslpath -a $winPath) -join '' -replace "`0", '').Trim()
        if ($LASTEXITCODE -ne 0 -or -not $wslPath) { throw 'Could not convert the APK path for WSL.' }
        Invoke-Guest 'windroid-session ensure'
        # Pass the filename as one native argument. Embedding it in bash
        # source breaks on ordinary apostrophes in filenames/directories.
        wsl -d $DistroName -u windroid -e waydroid app install $wslPath
        if ($LASTEXITCODE -ne 0) { throw "APK installation failed (exit $LASTEXITCODE)." }
        # Waydroid returns before Android's PackageInstaller commit finishes.
        Write-Host "Installation requested. Check Android for scan or confirmation prompts."
    }
    "adb" {
        # Official mechanism: adb connect <container IP>:5555
        # (docs.waydro.id/faq/using-adb-with-waydroid). waydroid status
        # prints "IP address:" when the session is RUNNING.
        Invoke-Guest "windroid-session ensure" | Out-Null
        $status = (Invoke-Guest "waydroid status") -join "`n"
        if ($status -match "IP address:\s*([\d.]+)") {
            $target = "$($Matches[1]):5555"
            Write-Host "adb connect $target"
            if (Get-Command adb -ErrorAction SilentlyContinue) { adb connect $target }
            else { Write-Host "(adb not found on PATH — install Android platform-tools and run the line above)" }
        } else {
            Write-Error "Could not read the container IP from 'waydroid status' — is the session RUNNING?"
        }
    }
    default {
        @"
windroid — Android subsystem for Windows

  windroid start | stop | status
  windroid install <apk>
  windroid adb        connect adb to the container (IP:5555)
  windroid shell      root shell into Android
"@ | Write-Host
    }
}
