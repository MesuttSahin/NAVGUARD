[CmdletBinding()]
param(
    [switch]$DeleteAfterPull
)

$ErrorActionPreference = 'Stop'
$packageName = 'io.github.mesuttsahin.navguard'
$remoteDirectory = "/storage/emulated/0/Android/data/$packageName/files/navguard_ai"
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$destination = Join-Path $repositoryRoot 'data\private_ai\raw'
$expectedRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'data\private_ai'))
$resolvedDestination = [System.IO.Path]::GetFullPath($destination)

if (-not $resolvedDestination.StartsWith($expectedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to write outside data\private_ai.'
}

$adb = Get-Command adb -ErrorAction Stop
$deviceLines = @(& $adb.Source devices) | Where-Object { $_ -match "\tdevice$" }
if ($deviceLines.Count -ne 1) {
    throw "Expected exactly one authorized adb device; found $($deviceLines.Count)."
}

Write-Host 'Device found: YES'

$findCommand = "find '$remoteDirectory' -maxdepth 1 -type f -name 'navguard_ai_session_*.csv' -print"
$remoteFiles = @(& $adb.Source shell $findCommand) |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -like "$remoteDirectory/navguard_ai_session_*.csv" }

Write-Host "Files found: $($remoteFiles.Count)"
if ($remoteFiles.Count -eq 0) {
    Write-Host "Files pulled: 0"
    Write-Host "Destination: $resolvedDestination"
    exit 0
}

New-Item -ItemType Directory -Path $resolvedDestination -Force | Out-Null
$pulled = 0
foreach ($remoteFile in $remoteFiles) {
    $fileName = [System.IO.Path]::GetFileName($remoteFile)
    if ($fileName -notmatch '^navguard_ai_session_[0-9a-fA-F-]+_(stationary|straight_walk|turning|unstable_motion)\.csv$') {
        throw "Unexpected remote AI dataset filename: $fileName"
    }
    $localFile = Join-Path $resolvedDestination $fileName
    & $adb.Source pull $remoteFile $localFile | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $localFile -PathType Leaf)) {
        throw "adb pull failed for $fileName"
    }
    $pulled++
    if ($DeleteAfterPull) {
        & $adb.Source shell rm -- $remoteFile | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Pulled $fileName but could not delete its phone copy."
        }
    }
}

Write-Host "Files pulled: $pulled"
Write-Host "Destination: $resolvedDestination"
Write-Host "Phone copies deleted: $($DeleteAfterPull.IsPresent)"
