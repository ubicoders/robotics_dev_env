#!/bin/bash
# Optional helper: clones the PX4 ROS 2 bridge packages into the workspace.
# Usage: download_bridge_px4_ros.bash [px4_msgs-ref]
# px4_msgs must match the PX4 firmware release. Default comes from .env (PX4_MSGS_VERSION),
# which is baked into the image as an environment variable.
PX4_MSGS_REF="${1:-${PX4_MSGS_VERSION:?pass a px4_msgs ref or set PX4_MSGS_VERSION}}"

cd /home/ubuntu/robot_ws/src/
git clone https://github.com/PX4/px4_msgs.git
cd px4_msgs
git checkout "${PX4_MSGS_REF}"

cd ..
# px4_ros_com has no per-release branch for 1.17, so main is used.
git clone https://github.com/PX4/px4_ros_com.git
