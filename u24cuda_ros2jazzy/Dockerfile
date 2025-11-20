FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
RUN apt-get update && apt-get upgrade -y
RUN echo "alias python=python3" >> /root/.bashrc
# --------------------
# Locale / base setup
# --------------------
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone
# --------------------
# Install locales
# --------------------
RUN apt-get update && apt-get install -y \
    locales \
    lsb-release \
    gnupg2 \
    curl \
    software-properties-common \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# --------------------
# System packages
# --------------------
RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
  apt-utils \
  autoconf \
  automake \
  bison \
  bzip2 \
  build-essential \
  ca-certificates \
  ccache \
  cmake \
  cppcheck \
  curl \
  dmidecode \
  dirmngr \
  doxygen \
  file \
  flex \
  g++ \
  genromfs \
  gcc \
  gdb \
  git \
  gnupg2 \
  gosu \
  gperf \
  lcov \
  libncurses-dev \
  libcunit1-dev \
  libfreetype6-dev \
  libgtest-dev \
  libpng-dev \
  libssl-dev \
  libasio-dev \
  libtinyxml2-dev \
  libtool \
  lsb-release \
  net-tools \
  make \
  nano \
  ninja-build \
  openjdk-8-jdk \
  openjdk-8-jre \
  openssh-client \
  picocom \
  minicom \
  screen \
  pkg-config \
  python3-dev \
  python3-pip \
  python3-tk \
  rsync \
  software-properties-common \
  shellcheck \
  tzdata \
  tree \
  uncrustify \
  unzip \
  valgrind \
  vim-common \
  wget \
  xsltproc \
  zip \
  && apt-get -y autoremove \
  && apt-get clean autoclean \
  && rm -rf /var/lib/apt/lists/*


# --------------------
# Miniconda (non-interactive)
# --------------------
ENV CONDA_DIR=/miniconda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

RUN conda --version && \
    conda config --set always_yes yes --set changeps1 no && \
    conda clean -afy || true

RUN conda config --set changeps1 True
RUN /miniconda/bin/conda init bash

# --------------------
# Python Dependencies via Miniconda Pip
# --------------------
COPY requirements.txt /tmp/requirements.txt
RUN pip uninstall empy -y
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
rm /tmp/requirements.txt

# --------------------
# Shell / env tweaks
# --------------------
RUN mkdir -p /home/ubuntu/robot_ws/src
RUN rm -rf /home/ubuntu/user

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


