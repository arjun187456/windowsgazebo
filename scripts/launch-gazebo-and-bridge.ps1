param(
    [string]$RosDistro = 'jazzy',
    [string]$GzPartition = 'my_robot_sim',
    [string]$WorldPath,
    [switch]$ForceRestart
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnvDir = Join-Path $RepoRoot 'windows-gazebo-env'
$BridgeLauncher = Join-Path $RepoRoot 'scripts\launch-wsl-bridge.ps1'

$DefaultWorldPath = Join-Path (Split-Path -Parent $RepoRoot) 'pick-and-place-ros2-gazebo\worlds\pick_place.sdf'
if (-not $WorldPath) {
    $WorldPath = $DefaultWorldPath
}

if (-not (Test-Path $EnvDir)) {
    Write-Error "Gazebo Pixi env not found: $EnvDir"
    exit 1
}

if (-not (Test-Path $BridgeLauncher)) {
    Write-Error "Missing file: $BridgeLauncher"
    exit 1
}

if (-not (Test-Path $WorldPath)) {
    Write-Error "World file not found: $WorldPath"
    exit 1
}

$PixiExe = $null
if (Get-Command pixi -ErrorAction SilentlyContinue) {
    $PixiExe = 'pixi'
}
else {
    $PixiCandidate = Join-Path $env:USERPROFILE '.pixi\bin\pixi.exe'
    if (Test-Path $PixiCandidate) {
        $PixiExe = $PixiCandidate
    }
}

if (-not $PixiExe) {
    Write-Error 'pixi not found. Install pixi first.'
    exit 1
}

if ($ForceRestart) {
    Get-Process -Name ruby, pixi -ErrorAction SilentlyContinue | Stop-Process -Force
    & wsl.exe -e bash -lc "pkill -f ros_gz_bridge/parameter_bridge || true"
}

$GazeboServerCmd = @(
    "`$env:GZ_PARTITION='$GzPartition'",
    "`$env:GZ_IP='127.0.0.1'",
    "Set-Location '$EnvDir'",
    "& '$PixiExe' run gz sim -s '$WorldPath'"
) -join '; '

$GazeboGuiCmd = @(
    "`$env:GZ_PARTITION='$GzPartition'",
    "`$env:GZ_IP='127.0.0.1'",
    "Set-Location '$EnvDir'",
    "& '$PixiExe' run gz sim -g"
) -join '; '

$BridgeCmd = @(
    "`$env:ROS_DISTRO='$RosDistro'",
    "`$env:GZ_PARTITION='$GzPartition'",
    "& '$BridgeLauncher'"
) -join '; '

Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $GazeboServerCmd)
Start-Sleep -Seconds 3
Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $GazeboGuiCmd)
Start-Sleep -Seconds 2
Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $BridgeCmd)

Write-Host "Started Gazebo server + GUI + ROS2 bridge"
Write-Host "World: $WorldPath"
Write-Host "Partition: $GzPartition"
