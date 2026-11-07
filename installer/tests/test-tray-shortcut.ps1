$ErrorActionPreference = 'Stop'
foreach ($pair in @(@('install.ps1', 'Install-WindroidTrayShortcut'), @('uninstall.ps1', 'Remove-WindroidTrayShortcut'))) {
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot "../$($pair[0])"), [ref]$tokens, [ref]$errors)
    if ($errors) { throw ($errors -join "`n") }
    $name = $pair[1]
    $fn = $ast.Find({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }, $true)
    if (-not $fn) { throw "Missing function: $name" }
    . ([scriptblock]::Create($fn.Extent.Text))
}
# Persist mock link metadata in the fixture; no COM, WSL or real Start Menu.
$script:Shell = [pscustomobject]@{}
$script:Shell | Add-Member ScriptMethod CreateShortcut {
    param($path)
    $link = [pscustomobject]@{ FilePath = $path; TargetPath = ''; Arguments = ''; IconLocation = '' }
    if (Test-Path -LiteralPath $path) {
        $old = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $link.TargetPath = $old.TargetPath; $link.Arguments = $old.Arguments; $link.IconLocation = $old.IconLocation
    }
    $link | Add-Member ScriptMethod Save {
        $this | Select-Object TargetPath, Arguments, IconLocation | ConvertTo-Json |
            Set-Content -LiteralPath $this.FilePath
    }
    $link
}
function New-Object { param([string]$ComObject)
    if ($ComObject -ne 'WScript.Shell') { throw "Unexpected COM request: $ComObject" }
    $script:Shell
}
$temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$testRoot = Join-Path $temp ('windroid-shortcut-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $testRoot | Out-Null
try {
    $root = Join-Path $testRoot "O'Brien install"
    $bin = Join-Path $root 'bin'
    $programs = Join-Path $testRoot 'Programs'
    $managed = Join-Path $programs 'TestDistro'
    $tools = Join-Path $programs 'TestDistro Tools'
    New-Item -ItemType Directory -Path $bin, $managed -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $bin 'windroid-tray.ps1') 'fixture'
    Set-Content -LiteralPath (Join-Path $bin 'windroid.ico') 'fixture icon'
    $legacy = Join-Path $managed 'Windroid Tray.lnk'
    $old = $script:Shell.CreateShortcut($legacy)
    $old.TargetPath = 'powershell.exe'
    $old.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$(Join-Path $bin 'windroid-tray.ps1')`" -DistroName `"TestDistro`" -InstallRoot `"$root`""
    $old.Save()
    Install-WindroidTrayShortcut $root 'TestDistro' $programs
    $shortcut = Join-Path $tools 'Windroid Tray.lnk'
    if (-not (Test-Path -LiteralPath $shortcut) -or (Test-Path -LiteralPath $legacy)) {
        throw 'Owned tray link was not migrated out of the WSLg-managed folder'
    }
    $link = $script:Shell.CreateShortcut($shortcut)
    if ($link.Arguments -ne $old.Arguments -or $link.TargetPath -ne 'powershell.exe') {
        throw 'Shortcut lost the selected distro or quoted installation path'
    }
    if ($link.IconLocation -ne "$(Join-Path $bin 'windroid.ico'),0") { throw 'Stable staged icon not selected' }
    # Repair is independent of the completed integration stage.
    Remove-Item -LiteralPath $shortcut
    Install-WindroidTrayShortcut $root 'TestDistro' $programs
    if (-not (Test-Path -LiteralPath $shortcut)) { throw 'Missing shortcut was not repaired' }
    $old.Arguments = 'unrelated custom shortcut'; $old.Save()
    Install-WindroidTrayShortcut $root 'TestDistro' $programs
    if (-not (Test-Path -LiteralPath $legacy)) { throw 'Unrelated legacy shortcut was removed' }
    $other = Join-Path $tools 'User notes.txt'
    Set-Content -LiteralPath $other 'preserve'
    Remove-WindroidTrayShortcut 'TestDistro' $programs
    if ((Test-Path -LiteralPath $shortcut) -or -not (Test-Path -LiteralPath $other)) {
        throw 'Uninstall removed unrelated Tools files or left the owned link'
    }
    Remove-Item -LiteralPath $other
    Remove-WindroidTrayShortcut 'TestDistro' $programs
    if (Test-Path -LiteralPath $tools) { throw 'Empty Tools directory was not removed' }
    Install-WindroidTrayShortcut (Join-Path $testRoot 'missing') 'AbsentDistro' $programs
    if (Test-Path -LiteralPath (Join-Path $programs 'AbsentDistro Tools')) { throw 'Dead tray shortcut created' }
    Write-Host 'ALL TRAY SHORTCUT TESTS PASS'
} finally {
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if ([IO.Path]::GetDirectoryName($resolved) -ne $temp.TrimEnd([IO.Path]::DirectorySeparatorChar) -or
        [IO.Path]::GetFileName($resolved) -notlike 'windroid-shortcut-*') { throw 'Unsafe fixture cleanup target' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
