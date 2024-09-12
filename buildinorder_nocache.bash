#!/bin/bash

# PX4 only U20 ===========================================
docker compose build ubicoders_u20_px4 --no-cache

# ROS1 ====================================================
docker compose build ubicoders_ros1_noetic --no-cache
docker compose build ubicoders_ros1_noetic_px4 --no-cache
docker compose build ubicoders_ros1_noetic_px4_mavros --no-cache

# ROS2 ====================================================
docker compose build ubicoders_ros2_humble --no-cache
docker compose build ubicoders_ros2_humble_px4 --no-cache
docker compose build ubicoders_ros2_humble_px4uxrcedds --no-cache

# CUDA based ROS2 ========================================
docker compose build ubicoders_ros2_humble_cuda12_ocv --no-cache
docker compose build ubicoders_ros2_humble_cuda12_ocv_zed --no-cache

# PUSH all
docker push ubicoders/px4:v1.14
docker push ubicoders/ros1:noetic
docker push ubicoders/ros1:noetic_px4
docker push ubicoders/ros1:noetic_px4_mavros
docker push ubicoders/ros2:humble
docker push ubicoders/ros2:humble_px4
docker push ubicoders/ros2:humble_px4_uxrcedds
docker push ubicoders/ros2:humble_cuda12_ocv
docker push ubicoders/ros2:humble_cuda12_ocv_zed