FROM ubicoders/ubuntu:u24_cuda12
RUN apt-get update && apt-get upgrade -y

# --------------------
# Environment variables for ROS 2 Jazzy
ENV ROS_DISTRO=jazzy
ENV DEBIAN_FRONTEND=noninteractive
# Enable universe (recommended by ROS)
RUN add-apt-repository universe

# --------------------
# ROS 2 Jazzy setup
# --------------------
# Add ROS 2 repository using keyring (no apt-key)
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}}) main" > /etc/apt/sources.list.d/ros2.list \
    && apt-get update

# Install ROS 2 Jazzy desktop-full (same variant as osrf/ros:jazzy-desktop-full-noble)
RUN apt-get install -y \
    ros-jazzy-desktop-full \
    ros-dev-tools \
    python3-pip \
    python3-colcon-common-extensions \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Always source ROS 2 Jazzy in root bashrc (as requested)
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc

# --------------------
# ROS visualization / URDF helpers
# (desktop-full already brings many of these, but keeping explicit)
# --------------------
RUN apt-get update && apt-get install -y \
    ros-jazzy-robot-state-publisher \
    ros-jazzy-joint-state-publisher-gui \
    ros-jazzy-xacro \
    ros-jazzy-tf2-tools \
    ros-jazzy-rqt-tf-tree \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# Gazebo / GZ integration (ros-gz)
# desktop_full pulls in simulation + ros_gz_sim_demos; this
# keeps bridge/sim explicit to mirror your previous image.
# --------------------
RUN apt-get update && apt-get install -y \
    ros-jazzy-ros-gz \
    ros-jazzy-ros-gz-sim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# ros2_control core packages (control framework & controllers)
# --------------------
RUN apt-get update && apt-get install -y \
    ros-jazzy-ros2-control \
    ros-jazzy-ros2-controllers \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# rosdep
# --------------------
RUN apt-get update && apt-get install -y python3-rosdep \
    && rosdep init \
    && rosdep update \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# Default workspace
# --------------------
RUN mkdir -p /home/ubuntu/robot_ws/src
WORKDIR /home/ubuntu/


