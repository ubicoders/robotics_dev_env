FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

############################################################################
# ZED opencv Prep
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg libsm6 libxext6  -y
RUN apt install libjpeg-turbo8 libturbojpeg libusb-1.0-0 libusb-1.0-0-dev libopenblas-dev libarchive-dev libv4l-0 curl unzip zlib1g mesa-utils libpng-dev python3-dev python3-pip python3-setuptools libglew-dev freeglut3-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5opengl5 libqt5svg5 -y

## RUN pip3 uninstall numpy -y
RUN rm -rf /usr/local/lib/python3.10/dist-packages/numpy*
RUN pip3 install numpy==1.26.4 requests cython==3.0.11 PyOpenGL==3.1.1a1
############################################################################
# Installing ROS2 Humble
# Set environment variables for ROS 2 Humble
ENV ROS_DISTRO humble

# Update and install necessary dependencies
RUN apt-get update && apt-get install -y \
    locales \
    lsb-release \
    gnupg2 \
    curl \
    software-properties-common \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - \
    && sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && apt-get update

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && echo "UTC" > /etc/timezone

# Install ROS 2 Humble desktop full
RUN apt-get install -y ros-humble-desktop-full \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Source ROS 2 setup script
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

# Install additional tools (optional)
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

############################################################################
# System packages
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
# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest

# install Cyclone DDS dependencies
RUN apt install --no-install-recommends -y libcunit1-dev

# install required python packages
RUN pip uninstall em
COPY ./requirements.txt /home/ubuntu/requirements.txt
RUN pip install -r /home/ubuntu/requirements.txt
RUN pip3 install -r /home/ubuntu/requirements.txt
RUN rm -r /home/ubuntu/requirements.txt

# setup ROS environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
RUN echo "alias python=python3" >> /root/.bashrc

RUN apt update
RUN apt install ros-humble-gazebo-ros-pkgs -y
RUN pip install setuptools==58.2.0
# default workspace
RUN mkdir -p /home/ubuntu/robot_ws/src
WORKDIR /home/ubuntu/

# installing opencv with cuda support
RUN apt-get install build-essential libcanberra-gtk-module libcanberra-gtk3-module cmake libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev -y
RUN pip uninstall opencv-python opencv-contrib-python -y
COPY ./install_ocv_cuda.bash /home/install_ocv_cuda.bash
RUN bash /home/install_ocv_cuda.bash


# installing zed sdk
RUN apt install zstd -y
COPY ./ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run
RUN /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run -- silent
COPY ./ocv_pip.bash /home/ocv_pip.bash
RUN bash /home/ocv_pip.bash

# ros hubmle additional packages
RUN apt install ros-humble-*msgs -y
RUN pip install -U rosdep
RUN rosdep init
RUN rosdep update
RUN pip install setuptools==58.2.0

# delete the installers
#ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run  install_ocv_cuda.bash  ocv_pip.bash  opencv-4.10.0  opencv_contrib-4.10.0
RUN rm /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run
RUN rm /home/install_ocv_cuda.bash
RUN rm /home/ocv_pip.bash
RUN rm -r /home/opencv-4.10.0
RUN rm -r /home/opencv_contrib-4.10.0