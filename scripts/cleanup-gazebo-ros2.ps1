param(
    [switch]$IncludeBridge
)

$ErrorActionPreference = 'Stop'

# Stop Gazebo and Pixi-related local processes first.
Get-CimInstance Win32_Process | Where-Object {
    ($_.Name -in @('ruby.exe', 'pixi.exe', 'gz.exe', 'cmd.exe')) -and
    $_.CommandLine -and
    $_.CommandLine -match 'gazebo-windows|gz sim|windows-gazebo-env'
} | ForEach-Object {
    try {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop
        Write-Host "Stopped PID $($_.ProcessId): $($_.Name)"
    }
    catch {
        Write-Warning "Could not stop PID $($_.ProcessId): $($_.Exception.Message)"
    }
}

if ($IncludeBridge) {
    # Kill bridge-side ROS/Gazebo bridge processes in WSL.
    & wsl.exe -e bash -lc "pkill -f ros_gz_bridge/parameter_bridge || true; pkill -f 'ros2 run ros_gz_bridge parameter_bridge' || true"
    Write-Host 'Requested bridge shutdown in WSL.'
}

Write-Host 'Cleanup complete.'
