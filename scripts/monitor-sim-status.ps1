param(
    [int]$IntervalSec = 5,
    [string]$RosDistro = 'jazzy',
    [string]$GzPartition = 'my_robot_sim',
    [string]$LogFile,
    [switch]$AutoRestartBridge
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$BridgeLauncher = Join-Path $PSScriptRoot 'launch-wsl-bridge.ps1'
if (-not (Test-Path $BridgeLauncher)) {
    throw "Bridge launcher not found: $BridgeLauncher"
}

if ($LogFile) {
    $LogDir = Split-Path -Parent $LogFile
    if ($LogDir -and -not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir | Out-Null
    }
    if (-not (Test-Path $LogFile)) {
        "timestamp,gazebo_gui,gazebo_server,bridge_count,action" | Out-File -FilePath $LogFile -Encoding ascii
    }
}

$lastRestart = [DateTime]::MinValue

while ($true) {
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

    $rubyProcs = Get-Process -Name ruby -ErrorAction SilentlyContinue
    $gazeboGui = ($rubyProcs | Where-Object { $_.MainWindowTitle -like '*Gazebo Sim*' }).Count -gt 0

    $gazeboServer = (Get-CimInstance Win32_Process | Where-Object {
            ($_.Name -in @('ruby.exe', 'pixi.exe', 'cmd.exe', 'gz.exe')) -and
            $_.CommandLine -and
            $_.CommandLine -match 'gz sim -s'
        }).Count -gt 0

    $bridgeCountOutput = & wsl.exe -e bash -lc "ps -ef | grep -E 'ros_gz_bridge|parameter_bridge' | grep -v grep | wc -l"
    $bridgeCount = 0
    [void][int]::TryParse(($bridgeCountOutput | Select-Object -First 1).ToString().Trim(), [ref]$bridgeCount)

    $action = 'none'
    if ($AutoRestartBridge -and $bridgeCount -eq 0) {
        $secondsSinceRestart = ((Get-Date) - $lastRestart).TotalSeconds
        if ($secondsSinceRestart -ge 10) {
            $action = 'restart_bridge'
            Start-Process powershell.exe -ArgumentList @(
                '-NoExit',
                '-ExecutionPolicy',
                'Bypass',
                '-Command',
                "`$env:ROS_DISTRO='$RosDistro'; `$env:GZ_PARTITION='$GzPartition'; & '$BridgeLauncher'"
            )
            $lastRestart = Get-Date
        }
    }

    $status = [pscustomobject]@{
        timestamp    = $timestamp
        GazeboGui    = $gazeboGui
        GazeboServer = $gazeboServer
        BridgeProc   = $bridgeCount
        Action       = $action
    }

    $status | Format-Table -AutoSize

    if ($LogFile) {
        "$timestamp,$gazeboGui,$gazeboServer,$bridgeCount,$action" | Out-File -FilePath $LogFile -Append -Encoding ascii
    }

    Start-Sleep -Seconds $IntervalSec
}
