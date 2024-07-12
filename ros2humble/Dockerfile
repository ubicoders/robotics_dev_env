FROM osrf/ros:humble-desktop-full-jammy

RUN apt update && apt upgrade -y

# System packages 
RUN apt-get -y --quiet --no-install-recommends install \
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
  make \
  nano \
  net-tools \
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

#==== Python packages ==========================
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

# install required python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt
RUN rosdep update


RUN pip uninstall em
RUN pip install empy==3.3.4
RUN apt update && apt upgrade -y
RUN apt-get install python3-tk -y

#===============================================

# ============ ROS2 packages
# install Fast-RTPS dependencies
RUN apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev

# install Cyclone DDS dependencies
RUN apt install --no-install-recommends -y \
  libcunit1-dev

# ====================================================

# default workspace
RUN mkdir -p /home/ubuntu/robot_ws/src


## zsh
COPY .p10k.zsh /root/.p10k.zsh
COPY installzsh.bash /root/installzsh.bash
RUN bash /root/installzsh.bash


# setup some  environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc
RUN echo "alias python=python3" >> /root/.bashrc
