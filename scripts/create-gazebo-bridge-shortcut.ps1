$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Launcher = Join-Path $RepoRoot 'scripts\launch-gazebo-and-bridge.ps1'
$Desktop = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $Desktop 'Gazebo + ROS2 Bridge.lnk'

if (-not (Test-Path $Launcher)) {
    Write-Error "Launcher script not found: $Launcher"
    exit 1
}

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$Launcher`""
$Shortcut.WorkingDirectory = $RepoRoot
$Shortcut.IconLocation = '%SystemRoot%\System32\shell32.dll,137'
$Shortcut.Description = 'Launch Gazebo on Windows and ROS2 bridge in WSL'
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"
