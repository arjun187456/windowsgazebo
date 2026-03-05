$ErrorActionPreference = 'Stop'

$Distro = 'Ubuntu'
$DistroList = (& wsl.exe -l -q) | ForEach-Object { $_.Trim() } | Where-Object { $_ }

if ($DistroList -contains 'Ubuntu-24.04') {
    $Distro = 'Ubuntu-24.04'
} elseif ($DistroList -contains $Distro) {
    $Distro = 'Ubuntu'
} else {
    $UbuntuLike = $DistroList | Where-Object { $_ -like 'Ubuntu*' } | Select-Object -First 1
    if ($UbuntuLike) {
        $Distro = $UbuntuLike
    } elseif ($DistroList.Count -gt 0) {
        $Distro = $DistroList[0]
    }
}
$WslCommand = 'if [ -d ~/gazebo-windows ]; then cd ~/gazebo-windows; elif [ -d /mnt/c/Users/a113211/gazebo-windows ]; then cd /mnt/c/Users/a113211/gazebo-windows; else echo gazebo-windows_repo_not_found; exit 1; fi; export ROS_DISTRO=jazzy; export GZ_PARTITION=my_robot_sim; ./scripts/run-bridge.sh'

& wsl.exe -d $Distro -- bash -lc $WslCommand
if ($LASTEXITCODE -ne 0) {
	Write-Error "Failed to start ROS2 bridge in WSL distro '$Distro' (exit code: $LASTEXITCODE)."
	exit $LASTEXITCODE
}
