#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-jazzy}"
export GZ_PARTITION="${GZ_PARTITION:-my_robot_sim}"

set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u

echo "Using ROS_DISTRO=${ROS_DISTRO}"
echo "Using GZ_PARTITION=${GZ_PARTITION}"

echo "Starting ros_gz parameter bridge for /cmd_vel and /clock..."
exec ros2 run ros_gz_bridge parameter_bridge \
  /cmd_vel@geometry_msgs/msg/Twist@gz.msgs.Twist \
  /clock@rosgraph_msgs/msg/Clock@gz.msgs.Clock
