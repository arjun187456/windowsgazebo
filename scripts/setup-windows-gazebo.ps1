param(
    [ValidateSet('humble','jazzy')]
    [string]$RosDistro = 'jazzy'
)

$ErrorActionPreference = 'Stop'

if ($RosDistro -eq 'humble') {
    $GzPkg = 'gz-sim7'
} else {
    $GzPkg = 'gz-sim8'
}

$PixiExe = $null
if (Get-Command pixi -ErrorAction SilentlyContinue) {
    $PixiExe = 'pixi'
} else {
    $Candidate = Join-Path $env:USERPROFILE '.pixi\bin\pixi.exe'
    if (Test-Path $Candidate) {
        $PixiExe = $Candidate
    }
}

Write-Host "Installing Pixi if missing..."
if (-not $PixiExe) {
    iwr -useb https://pixi.sh/install.ps1 | iex
    $Candidate = Join-Path $env:USERPROFILE '.pixi\bin\pixi.exe'
    if (Test-Path $Candidate) {
        $PixiExe = $Candidate
    } else {
        Write-Host 'Restart PowerShell and re-run this script.'
        exit 0
    }
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WinEnv = Join-Path $RepoRoot 'windows-gazebo-env'

if (-not (Test-Path $WinEnv)) {
    New-Item -ItemType Directory -Path $WinEnv | Out-Null
}

Push-Location $WinEnv
if (-not (Test-Path (Join-Path $WinEnv 'pixi.toml'))) {
    & $PixiExe init
}

& $PixiExe add $GzPkg

Write-Host "Setting user-level GZ_PARTITION=my_robot_sim"
[Environment]::SetEnvironmentVariable('GZ_PARTITION', 'my_robot_sim', 'User')

Write-Host "Done. Launch Gazebo with:"
Write-Host "  cd $WinEnv"
Write-Host "  pixi shell"
Write-Host "  gz sim --verbose"
Pop-Location
