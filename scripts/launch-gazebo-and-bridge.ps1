$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$GazeboLauncher = Join-Path $RepoRoot 'scripts\launch-gazebo-windows.ps1'
$BridgeLauncher = Join-Path $RepoRoot 'scripts\launch-wsl-bridge.ps1'

if (-not (Test-Path $GazeboLauncher)) {
    Write-Error "Missing file: $GazeboLauncher"
    exit 1
}

if (-not (Test-Path $BridgeLauncher)) {
    Write-Error "Missing file: $BridgeLauncher"
    exit 1
}

Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $GazeboLauncher)
Start-Sleep -Seconds 4
Start-Process powershell.exe -ArgumentList @('-ExecutionPolicy', 'Bypass', '-File', $BridgeLauncher)
