#!/bin/bash

# PX4 only U20 ===========================================
docker compose build ubicoders_u20_px4

# ROS1 ====================================================
docker compose build ubicoders_ros1_noetic
docker compose build ubicoders_ros1_noetic_px4
docker compose build ubicoders_ros1_noetic_px4_mavros

# ROS2 ====================================================
docker compose build ubicoders_ros2_humble
docker compose build ubicoders_ros2_humble_px4
docker compose build ubicoders_ros2_humble_px4uxrcedds

# CUDA based ROS2 ========================================
docker compose build ubicoders_ros2_humble_cuda12_ocv

# PUSH all
docker push ubicoders/px4:v1.14
docker push ubicoders/ros1:noetic
docker push ubicoders/ros1:noetic_px4
docker push ubicoders/ros1:noetic_px4_mavros
docker push ubicoders/ros2:humble
docker push ubicoders/ros2:humble_px4
docker push ubicoders/ros2:humble_px4_uxrcedds
docker push ubicoders/ros2:humble_cuda12_ocv
