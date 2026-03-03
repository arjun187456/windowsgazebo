# gazebo-windows

Run **Gazebo Sim natively on Windows** and **ROS 2 in WSL2**, connected through `ros_gz_bridge`.

## Architecture
- Windows 11: `gz sim` (native, via Pixi)
- WSL2 Ubuntu: ROS 2 nodes + `ros_gz_bridge`
- Shared transport partition: `GZ_PARTITION=my_robot_sim`

## Prerequisites
- Windows 11 + WSL2 (Ubuntu)
- ROS 2 already installed in WSL2 (`humble` or `jazzy`)
- VS Code + Remote-WSL (recommended)

## 1) Windows setup (PowerShell)
From repo root in Windows PowerShell:

```powershell
./scripts/setup-windows-gazebo.ps1 -RosDistro jazzy
```

For ROS 2 Humble, use:

```powershell
./scripts/setup-windows-gazebo.ps1 -RosDistro humble
```

Then launch Gazebo:

```powershell
cd .\windows-gazebo-env
pixi shell
gz sim --verbose
```

## 2) WSL setup (Ubuntu)
From repo root in WSL:

```bash
chmod +x scripts/*.sh
./scripts/setup-wsl-ros2.sh jazzy
```

For Humble:

```bash
./scripts/setup-wsl-ros2.sh humble
```

## 3) Run bridge from WSL
With Gazebo already running on Windows:

```bash
export ROS_DISTRO=jazzy
export GZ_PARTITION=my_robot_sim
./scripts/run-bridge.sh
```

## 4) Validate communication
In another WSL terminal:

```bash
source /opt/ros/$ROS_DISTRO/setup.bash
gz topic -l
ros2 topic list
```

Teleop test:

```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

## Optional launch file
A launch file is provided at `launch/bridge_only.launch.py`.

Run:

```bash
source /opt/ros/$ROS_DISTRO/setup.bash
ros2 launch launch/bridge_only.launch.py
```

> Note: This launch file starts only the bridge (not Gazebo), which matches the Windows-native Gazebo workflow.

## Troubleshooting
- If no topics appear, verify both sides use the same `GZ_PARTITION`.
- If discovery fails, allow Gazebo executables through Windows Firewall.
- Keep versions aligned:
  - ROS 2 Humble ↔ Gazebo Fortress (`gz-sim7`)
  - ROS 2 Jazzy ↔ Gazebo Harmonic (`gz-sim8`)
- If Copilot/WSL networking is flaky, MTU tuning may help:

```bash
sudo ip link set dev eth0 mtu 1492
```
