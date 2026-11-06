$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot '..\install.ps1'), [ref]$tokens, [ref]$errors)
foreach ($name in @('Resolve-ArtifactSource', 'Assert-ArtifactHash')) {
    $fn = $ast.Find({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name}.GetNewClosure(), $true)
    $installerDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path.Replace("'", "''")
    Invoke-Expression ($fn.Extent.Text.Replace('$PSScriptRoot', "'$installerDir'"))
}
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('windroid-artifacts-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $testRoot | Out-Null
try {
    # The fixture exercises the real ZIP extraction and checksum code without
    # network, WSL, or a multi-gigabyte release download.
    $payload = Join-Path $testRoot 'payload\Windroid\artifacts'
    New-Item -ItemType Directory -Path $payload -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $payload 'versions.json') -Value '{}'
    $fixture = Join-Path $testRoot 'fixture.zip'
    Compress-Archive -Path (Join-Path $testRoot 'payload\Windroid') -DestinationPath $fixture
    $script:fixture = $fixture
    $script:digest = (Get-FileHash $fixture).Hash
    $script:badChecksum = $false
    $script:downloads = 0
    function Invoke-WebRequest {
        param($Uri, $OutFile, [switch]$UseBasicParsing)
        if ($Uri -like '*/SHA256SUMS.txt') {
            $sha = if ($script:badChecksum) { '0' * 64 } else { $script:digest }
            return [pscustomobject]@{Content = [Text.Encoding]::UTF8.GetBytes("$sha *Windroid.zip`n")}
        }
        $script:downloads++
        Copy-Item -LiteralPath $script:fixture -Destination $OutFile
    }
    if ((Resolve-ArtifactSource 'explicit-source' $testRoot) -ne 'explicit-source') { throw 'Explicit source changed' }
    $cache = Join-Path $testRoot 'cache'
    $resolved = Resolve-ArtifactSource '' $cache
    if (-not (Test-Path (Join-Path $resolved 'versions.json'))) { throw 'ZIP artifacts not resolved' }
    $null = Resolve-ArtifactSource '' $cache
    if ($script:downloads -ne 1) { throw 'Verified cached ZIP downloaded twice' }
    Assert-ArtifactHash $fixture $script:digest
    $rejected = $false
    try { Assert-ArtifactHash $fixture ('0' * 64) } catch { $rejected = $true }
    if (-not $rejected) { throw 'Corrupt artifact accepted' }
    $script:badChecksum = $true
    $rejected = $false
    try { $null = Resolve-ArtifactSource '' (Join-Path $testRoot 'bad-cache') } catch { $rejected = $true }
    if (-not $rejected) { throw 'Corrupt distribution accepted' }
    Write-Host 'ALL ARTIFACT TESTS PASS'
} finally {
    # Generated, absolute per-test directory only.
    Remove-Item -LiteralPath $testRoot -Recurse -Force
}
