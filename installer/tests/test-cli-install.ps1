$ErrorActionPreference = 'Stop'
$apk = Join-Path ([IO.Path]::GetTempPath()) ("windroid-O'Brien-" + [guid]::NewGuid() + '.apk')
Set-Content -LiteralPath $apk -Value 'fixture'
$global:WindroidCliTestFailure = ''
$global:WindroidCliTestCalls = @()
function global:wsl {
    $global:WindroidCliTestCalls += ,@($args)
    $global:LASTEXITCODE = 0
    if ($args -contains 'wslpath') {
        if ($global:WindroidCliTestFailure -eq 'path') { $global:LASTEXITCODE = 2; return }
        return "/mnt/c/APK files/O'Brien.apk"
    }
    if ($args -contains 'bash' -and $global:WindroidCliTestFailure -eq 'ensure') { $global:LASTEXITCODE = 3 }
    if ($args -contains 'install' -and $global:WindroidCliTestFailure -eq 'install') { $global:LASTEXITCODE = 4 }
}
try {
    $cli = Join-Path $PSScriptRoot '..\..\scripts\windroid.ps1'
    & $cli install $apk -DistroName 'TestDistro'
    $installCall = $global:WindroidCliTestCalls | Where-Object { $_ -contains 'install' }
    if ($installCall[-1] -ne "/mnt/c/APK files/O'Brien.apk") { throw 'APK filename was not preserved as one argument' }
    if ($installCall -notcontains 'TestDistro') { throw 'Selected distro not used' }
    foreach ($failure in @('path', 'ensure', 'install')) {
        $global:WindroidCliTestFailure = $failure
        $global:WindroidCliTestCalls = @()
        $rejected = $false
        try { & $cli install $apk } catch { $rejected = $true }
        if (-not $rejected) { throw "CLI accepted $failure failure" }
        if ($failure -ne 'install' -and ($global:WindroidCliTestCalls | Where-Object { $_ -contains 'install' })) {
            throw "Installation ran after $failure failed"
        }
    }
    # Expected native failures above must not become the runner's exit status.
    $global:LASTEXITCODE = 0
    Write-Host 'ALL CLI INSTALL TESTS PASS'
} finally {
    Remove-Item -LiteralPath $apk -Force
    Remove-Item Function:\global:wsl
}
