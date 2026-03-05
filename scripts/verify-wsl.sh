#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-jazzy}"
set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u

echo "ROS distro: ${ROS_DISTRO}"
echo "GZ_PARTITION: ${GZ_PARTITION:-<not-set>}"

echo "Checking required binaries..."
command -v ros2 >/dev/null && echo "- ros2: OK"
command -v gz >/dev/null && echo "- gz: OK"

echo "Checking ros_gz_bridge package..."
if ros2 pkg prefix ros_gz_bridge >/dev/null 2>&1; then
	echo "- ros_gz_bridge: OK"
else
	echo "- ros_gz_bridge: NOT FOUND"
	exit 1
fi

echo "Listing first 20 Gazebo topics (if Gazebo is running on Windows and discoverable):"
gz topic -l | head -n 20 || true

echo "Verification complete."
