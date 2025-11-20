#!/bin/bash

# ROS2 ====================================================
docker compose build ubicoders_ros2_jazzy
docker compose build ubicoders_ros2_jazzy_px4
docker compose build ubicoders_ros2_jazzy_px4uxrcedds

# CUDA based ubuntu ========================================
docker compose build ubicoders_u24_cuda12
docker compose build ubicoders_u24_cuda12_zed

# CUDA based ROS2 ========================================
docker compose build ubicoders_ros2_humble_cuda12_ocv
docker compose build ubicoders_ros2_humble_cuda12_ocv_zed


# PUSH all
docker push ubicoders/ros2:jazzy
docker push ubicoders/ros2:jazzy_px4
docker push ubicoders/ros2:jazzy_px4_uxrcedds
docker push ubicoders/ros2:jazzy_cuda12_ocv
docker push ubicoders/ros2:jazzy_cuda12_ocv_zed
docker push ubicoders/ubuntu:u24_cuda12
docker push ubicoders/ubuntu:u24_cuda12_zed

