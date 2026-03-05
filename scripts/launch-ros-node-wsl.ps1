param(
    [Parameter(Mandatory = $true)]
    [string]$Package,

    [Parameter(Mandatory = $true)]
    [string]$Executable,

    [string]$Arguments = '',
    [string]$RosDistro = 'jazzy',
    [string]$GzPartition = 'my_robot_sim',
    [string]$Distro,
    [switch]$NoNewWindow
)

$ErrorActionPreference = 'Stop'

if (-not $Distro) {
    $DistroList = (& wsl.exe -l -q) | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    if ($DistroList -contains 'Ubuntu-24.04') {
        $Distro = 'Ubuntu-24.04'
    }
    elseif ($DistroList -contains 'Ubuntu') {
        $Distro = 'Ubuntu'
    }
    elseif ($DistroList.Count -gt 0) {
        $Distro = $DistroList[0]
    }
    else {
        throw 'No WSL distro found.'
    }
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WslRepoPath = '/mnt/c/Users/a113211/gazebo-windows'
$NodeCmd = "source /opt/ros/$RosDistro/setup.bash; export ROS_DISTRO=$RosDistro; export GZ_PARTITION=$GzPartition; if [ -d ~/gazebo-windows ]; then cd ~/gazebo-windows; elif [ -d $WslRepoPath ]; then cd $WslRepoPath; fi; ros2 run $Package $Executable $Arguments"

if ($NoNewWindow) {
    & wsl.exe -d $Distro -- bash -lc $NodeCmd
    exit $LASTEXITCODE
}

$PsCommand = "wsl.exe -d $Distro -- bash -lc `"$NodeCmd`""
Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $PsCommand)
Write-Host "Started ROS node: ros2 run $Package $Executable $Arguments"
