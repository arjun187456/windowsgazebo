$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnvDir = Join-Path $RepoRoot 'windows-gazebo-env'
$SetupScript = Join-Path $RepoRoot 'scripts\setup-windows-gazebo.ps1'

$PixiExe = $null
if (Get-Command pixi -ErrorAction SilentlyContinue) {
    $PixiExe = 'pixi'
} else {
    $Candidate = Join-Path $env:USERPROFILE '.pixi\bin\pixi.exe'
    if (Test-Path $Candidate) {
        $PixiExe = $Candidate
    }
}

if (-not (Test-Path $EnvDir)) {
    if (-not (Test-Path $SetupScript)) {
        Write-Error "Windows Gazebo environment not found at: $EnvDir and setup script missing: $SetupScript"
        exit 1
    }

    Write-Host "Windows Gazebo environment missing; running setup for jazzy..."
    & $SetupScript -RosDistro jazzy

    if (-not (Test-Path $EnvDir)) {
        Write-Error "Setup completed but environment still missing at: $EnvDir"
        exit 1
    }
}

if (-not $PixiExe) {
    Write-Error 'pixi is not installed. Run .\scripts\setup-windows-gazebo.ps1 first.'
    exit 1
}

Push-Location $EnvDir
try {
    & $PixiExe run gz sim --verbose
}
finally {
    Pop-Location
}
