FROM osrf/ros:noetic-desktop-full-focal

RUN apt update && apt upgrade -y
RUN apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y
RUN rosdep update

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

RUN apt update && apt upgrade -y
RUN apt-get install python3-catkin-tools python3-rosinstall-generator -y
RUN mkdir -p /home/ubuntu/catkin_ws/src
WORKDIR /home/ubuntu/catkin_ws/
RUN catkin init
RUN wstool init src
RUN wstool init

WORKDIR /home/ubuntu

## zsh
COPY .p10k.zsh /root/.p10k.zsh
COPY installzsh.bash /root/installzsh.bash
RUN bash /root/installzsh.bash

# add base env for ros
RUN echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash >> /root/.bashrc"

#=====
COPY requirements.txt /home/ubuntu/requirements.txt
RUN pip install -r /home/ubuntu/requirements.txt
RUN pip3 install -r /home/ubuntu/requirements.txt
RUN rm -r /home/ubuntu/requirements.txt

RUN apt-get install python3-tk -y
RUN echo "alias python=python3" >> /root/.bashrc

