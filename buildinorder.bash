#!/bin/bash
# Stop at the first failure so a child image is never built on, or pushed with, a stale parent.
set -euo pipefail

# Versions live in .env (also read automatically by docker compose).
cd "$(dirname "${BASH_SOURCE[0]}")"
source .env

# U24 PX4 ===========
docker compose build ubicoders_u24_px4

# ROS2 ====================================================
docker compose build ubicoders_ros2_jazzy
docker compose build ubicoders_ros2_jazzy_px4
docker compose build ubicoders_ros2_jazzy_px4uxrcedds
docker compose build ubicoders_ros2_jazzy_svo
# Deprecated, no longer built or pushed:
# docker compose build ubicoders_ros2_jazzy_vrobots
# docker compose build ubicoders_ros2_jazzy_svo_vrobots


# CUDA based ubuntu ========================================
docker compose build ubicoders_u24_cuda12
docker compose build ubicoders_u24_cuda12_ocv_zed

# CUDA based ROS2 ========================================
docker compose build ubicoders_u24_cuda12_jazzy


# PUSH all
docker push "ubicoders/px4:${PX4_TOOLCHAIN_VERSION}"

docker push "ubicoders/ros2:${ROS_DISTRO}"
docker push "ubicoders/ros2:${ROS_DISTRO}_px4"
docker push "ubicoders/ros2:${ROS_DISTRO}_px4_uxrcedds"
docker push "ubicoders/ros2:${ROS_DISTRO}_cuda12"
docker push "ubicoders/ros2:${ROS_DISTRO}_svo"
# Deprecated, no longer built or pushed:
# docker push "ubicoders/ros2:${ROS_DISTRO}_vrobots"
# docker push "ubicoders/ros2:${ROS_DISTRO}_svo_vrobots"

docker push ubicoders/ubuntu:u24_cuda12
docker push ubicoders/ubuntu:u24_cuda12_ocv_zed
