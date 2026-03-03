$ErrorActionPreference = 'Stop'

$Distro = 'Ubuntu'
$DistroList = (& wsl.exe -l -q) | ForEach-Object { $_.Trim() } | Where-Object { $_ }
if ($DistroList -notcontains $Distro) {
	$DefaultLine = (& wsl.exe -l -v | Select-String '\*').Line
	if ($DefaultLine) {
		$parts = ($DefaultLine -replace '^\s*\*\s*', '') -split '\s{2,}'
		if ($parts.Length -gt 0 -and $parts[0]) {
			$Distro = $parts[0].Trim()
		}
	} elseif ($DistroList.Count -gt 0) {
		$Distro = $DistroList[0]
	}
}
$WslCommand = 'if [ -d ~/gazebo-windows ]; then cd ~/gazebo-windows; elif [ -d /mnt/c/Users/a113211/gazebo-windows ]; then cd /mnt/c/Users/a113211/gazebo-windows; else echo "gazebo-windows repo not found"; exit 1; fi; export ROS_DISTRO=jazzy GZ_PARTITION=my_robot_sim; ./scripts/run-bridge.sh'

$Command = "wsl.exe -d $Distro -- bash -lc `"$WslCommand`""
Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $Command)
