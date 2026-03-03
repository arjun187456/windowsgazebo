$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Launcher = Join-Path $RepoRoot 'scripts\launch-gazebo-windows.ps1'
$Desktop = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $Desktop 'Gazebo Sim (Windows).lnk'

if (-not (Test-Path $Launcher)) {
    Write-Error "Launcher script not found: $Launcher"
    exit 1
}

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = 'powershell.exe'
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$Launcher`""
$Shortcut.WorkingDirectory = $RepoRoot
$Shortcut.IconLocation = '%SystemRoot%\System32\shell32.dll,220'
$Shortcut.Description = 'Launch Gazebo Sim via Pixi environment'
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"
