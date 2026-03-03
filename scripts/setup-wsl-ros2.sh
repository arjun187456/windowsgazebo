#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${1:-jazzy}"

if [[ "${ROS_DISTRO}" != "humble" && "${ROS_DISTRO}" != "jazzy" ]]; then
  echo "Usage: $0 [humble|jazzy]"
  exit 1
fi

echo "[1/4] Updating apt metadata"
sudo apt update

echo "[2/4] Installing ros_gz bridge meta package"
sudo apt install -y "ros-${ROS_DISTRO}-ros-gz" "ros-${ROS_DISTRO}-teleop-twist-keyboard"

echo "[3/4] Configuring GZ_PARTITION in ~/.bashrc"
if ! grep -q "export GZ_PARTITION=my_robot_sim" ~/.bashrc; then
  echo "export GZ_PARTITION=my_robot_sim" >> ~/.bashrc
fi

echo "[4/4] Sourcing ROS setup and validating"
set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u
if ros2 pkg prefix ros_gz_bridge >/dev/null 2>&1; then
  echo "ros_gz_bridge detected"
else
  echo "ros_gz_bridge not found; check installation"
  exit 1
fi

echo "WSL setup complete for ROS ${ROS_DISTRO}. Open a new shell or run: source ~/.bashrc"
