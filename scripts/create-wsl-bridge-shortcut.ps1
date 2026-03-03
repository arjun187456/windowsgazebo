$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Launcher = Join-Path $RepoRoot 'scripts\launch-wsl-bridge.ps1'
$Desktop = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $Desktop 'ROS2 Bridge (WSL).lnk'

if (-not (Test-Path $Launcher)) {
    Write-Error "Launcher script not found: $Launcher"
    exit 1
}

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$Launcher`""
$Shortcut.WorkingDirectory = $RepoRoot
$Shortcut.IconLocation = '%SystemRoot%\System32\wsl.exe,0'
$Shortcut.Description = 'Launch ROS2 bridge in WSL'
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"
