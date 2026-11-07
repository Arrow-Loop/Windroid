$ErrorActionPreference = 'Stop'
# Load only command functions and the real lifecycle callbacks, without
# constructing NotifyIcon, running its timer, or contacting a live distro.
$tokens = $null; $errors = $null
$tray = Join-Path $PSScriptRoot '../../windows/tray/windroid-tray.ps1'
$ast = [System.Management.Automation.Language.Parser]::ParseFile($tray, [ref]$tokens, [ref]$errors)
if ($errors) { throw ($errors -join "`n") }
foreach ($name in @('Invoke-Guest', 'Install-TrayApk', 'Invoke-TrayAction')) {
    $definition = $ast.Find({ param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }, $true)
    if (-not $definition) { throw "Missing tray function: $name" }
    . ([scriptblock]::Create($definition.Extent.Text))
}
$handlers = @{}
foreach ($node in $ast.FindAll({ param($node)
    $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
    $node.Member.Value -eq 'Add' -and $node.Arguments.Count -eq 3 -and
    $node.Arguments[2] -is [System.Management.Automation.Language.ScriptBlockExpressionAst]
}, $true)) {
    $handlers[$node.Arguments[0].Value] = $node.Arguments[2].ScriptBlock.GetScriptBlock()
}
$DistroName = 'Tray Test Distro'
$icon = $null
$script:Failure = ''
$script:Calls = @()
$script:Tips = @()
function wsl {
    $script:Calls += ,@($args)
    $global:LASTEXITCODE = 0
    if ($args -contains 'wslpath') {
        if ($script:Failure -eq 'path') { $global:LASTEXITCODE = 2; return }
        if ($script:Failure -eq 'empty-path') { return }
        return "/mnt/c/APK files/O'Brien.apk"
    }
    foreach ($stage in @('ensure', 'stop', 'start', 'status')) {
        if ($script:Failure -eq $stage -and $args[-1] -match " $stage`$") {
            $global:LASTEXITCODE = 3
            # A stale success line must not override the process failure.
            return 'session ready'
        }
    }
    if ($args -contains 'install' -and $script:Failure -eq 'install') { $global:LASTEXITCODE = 4 }
}
function Show-Tip($icon, $title, $text, $kind = 'Info') {
    $script:Tips += [pscustomobject]@{ Text = $text; Kind = $kind }
}
function Assert-ErrorTip {
    if ($script:Tips[-1].Kind -ne 'Error') { throw 'Failed action did not display an error' }
    if ($script:Tips.Text -match 'Session (running|stopped|restarted)\.|Installation requested\.') {
        throw 'Failed action displayed a success notification'
    }
}
$apk = Join-Path ([IO.Path]::GetTempPath()) ("windroid-tray-O'Brien-" + [guid]::NewGuid() + '.apk')
try {
    Set-Content -LiteralPath $apk -Value 'fixture'
    Install-TrayApk $apk
    $install = @($script:Calls | Where-Object { $_ -contains 'install' })
    if ($install.Count -ne 1 -or $install[0][-1] -ne "/mnt/c/APK files/O'Brien.apk") {
        throw 'APK path was not passed as one literal native argument'
    }
    foreach ($call in $script:Calls) {
        if ($call -notcontains $DistroName) { throw 'Selected distro was lost' }
    }
    foreach ($stage in @('path', 'empty-path', 'ensure', 'install')) {
        $script:Failure = $stage; $script:Calls = @(); $script:Tips = @()
        Invoke-TrayAction { Install-TrayApk $apk } 'Installation requested.'
        Assert-ErrorTip
        if ($stage -ne 'install' -and ($script:Calls | Where-Object { $_ -contains 'install' })) {
            throw "Installation ran after $stage failed"
        }
    }
    foreach ($case in @(
        @('Start session', 'start'), @('Stop session', 'stop'),
        @('Restart session', 'stop'), @('Restart session', 'start'), @('Status', 'status')
    )) {
        $script:Failure = $case[1]; $script:Calls = @(); $script:Tips = @()
        & $handlers[$case[0]]
        Assert-ErrorTip
        if ($case[0] -eq 'Restart session' -and $case[1] -eq 'stop' -and
            ($script:Calls | Where-Object { $_[-1] -eq 'windroid-session start' })) {
            throw 'Restart continued after stop failed'
        }
    }
    $script:Failure = ''; $script:Calls = @(); $script:Tips = @()
    & $handlers['Restart session']
    if ($script:Tips[-1].Text -ne 'Session restarted.' -or $script:Calls.Count -ne 2) {
        throw 'Successful restart did not run stop/start and report completion'
    }
    Write-Host 'ALL TRAY COMMAND TESTS PASS'
} finally {
    Remove-Item -LiteralPath $apk -Force -ErrorAction SilentlyContinue
}
