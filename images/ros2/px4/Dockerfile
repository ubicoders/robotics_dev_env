# Versions come from .env via docker-compose build args.
ARG ROS_DISTRO
FROM ubicoders/ros2:${ROS_DISTRO}
ARG PX4_TOOLCHAIN_VERSION
ARG PX4_MSGS_VERSION
ARG EMPY_VERSION
# The parent image runs as ubuntu; root steps first.
USER root
RUN apt update && apt upgrade -y

# --------------------
# Base Configuration
# --------------------
ENV DEBIAN_FRONTEND=noninteractive

# --------------------
# System Packages
# --------------------
RUN apt-get update && \
    apt-get -y --quiet --no-install-recommends install \
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
      sudo \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --------------------
# PX4 Dependencies & Toolchain
# --------------------
# Upstream setup script and its requirements.txt, fetched at the pinned PX4 tag.
# Only the toolchain is installed: the PX4 source is not kept in the image.
ENV PX4_TOOLCHAIN_VERSION=${PX4_TOOLCHAIN_VERSION}
ENV PX4_MSGS_VERSION=${PX4_MSGS_VERSION}
ENV RUNS_IN_DOCKER=true
RUN mkdir -p /opt/px4_toolchain && cd /opt/px4_toolchain && \
    for f in ubuntu.sh requirements.txt; do \
      curl -fsSL "https://raw.githubusercontent.com/PX4/PX4-Autopilot/${PX4_TOOLCHAIN_VERSION}/Tools/setup/${f}" -o "${f}" || exit 1; \
    done && \
    bash ubuntu.sh && \
    rm -f /opt/px4_toolchain/*.tar.xz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Xtensa (ESP32) compilers installed by ubuntu.sh
ENV PATH=/opt/xtensa-esp-elf/bin:${PATH}

# --------------------
# Workspace & Scripts
# --------------------
USER ubuntu
WORKDIR /home/ubuntu

COPY --chown=ubuntu:ubuntu common/download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash
COPY --chown=ubuntu:ubuntu images/ros2/px4/download_bridge_px4_ros.bash /home/ubuntu/download_bridge_px4_ros.bash
COPY --chown=ubuntu:ubuntu common/requirements.txt /tmp/requirements.txt

# --------------------
# Python Dependencies via Miniconda Pip
# --------------------
RUN pip install --no-cache-dir -r /opt/px4_toolchain/requirements.txt -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt
RUN pip install --no-cache-dir "empy==${EMPY_VERSION}"
