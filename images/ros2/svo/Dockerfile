# Versions come from .env via docker-compose build args.
ARG ROS_DISTRO
FROM ubicoders/ros2:${ROS_DISTRO}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# The parent image runs as ubuntu; root steps first.
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies for building VO third-party libraries
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libeigen3-dev \
        libspdlog-dev \
        libsuitesparse-dev \
        qtdeclarative5-dev \
        qt5-qmake \
        libqglviewer-dev-qt5 && \
    rm -rf /var/lib/apt/lists/*

ARG DEPS_DIR=/opt/src
RUN mkdir -p "${DEPS_DIR}"

# Install FBOW (bag of words)
RUN cd "${DEPS_DIR}" && \
    git clone --depth=1 https://github.com/rmsalinas/fbow.git && \
    cd fbow && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DFBOW_BUILD_EXAMPLES=OFF && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# Install Sophus
RUN cd "${DEPS_DIR}" && \
    git clone --depth=1 https://github.com/strasdat/Sophus.git && \
    cd Sophus && \
    mkdir -p build && cd build && \
    cmake .. -DSOPHUS_USE_BASIC_LOGGING=ON -DCMAKE_BUILD_TYPE=Release && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# Install g2o
RUN cd "${DEPS_DIR}" && \
    git clone --depth=1 https://github.com/RainerKuemmerle/g2o.git && \
    cd g2o && \
    mkdir -p build && cd build && \
    cmake .. -DG2O_USE_LOGGING=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

USER ubuntu
WORKDIR /home/ubuntu
COPY --chown=ubuntu:ubuntu common/use_conda.bash /home/ubuntu/use_conda.bash
COPY --chown=ubuntu:ubuntu common/use_system_python.bash /home/ubuntu/use_system_python.bash