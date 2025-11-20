#!/bin/bash

# U24 PX4 ===========
docker compose build ubicoders_u24_px4

# ROS2 ====================================================
docker compose build ubicoders_ros2_jazzy
docker compose build ubicoders_ros2_jazzy_px4
docker compose build ubicoders_ros2_jazzy_px4uxrcedds

# CUDA based ubuntu ========================================
docker compose build ubicoders_u24_cuda12
docker compose build ubicoders_u24_cuda12_ocv_zed

# CUDA based ROS2 ========================================
docker compose build ubicoders_u24_cuda12_jazzy


# PUSH all
docker push ubicoders/px4:v1.16

docker push ubicoders/ros2:jazzy
docker push ubicoders/ros2:jazzy_px4
docker push ubicoders/ros2:jazzy_px4_uxrcedds
docker push ubicoders/ros2:jazzy_cuda12

docker push ubicoders/ubuntu:u24_cuda12
docker push ubicoders/ubuntu:u24_cuda12_ocv_zed


