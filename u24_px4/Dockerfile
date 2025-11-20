FROM ubuntu:24.04

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
COPY requirements.txt /tmp/requirements.txt
COPY install_px4.bash /tmp/install_px4.bash

RUN chmod +x /tmp/install_px4.bash && \
    /tmp/install_px4.bash && \
    rm /tmp/install_px4.bash


# ARM GCC toolchain path
ENV PATH=/opt/gcc-arm-none-eabi-9-2020-q2-update/bin:${PATH}

# --------------------
# Workspace & Scripts
# --------------------
WORKDIR /home/ubuntu
RUN mkdir -p /home/ubuntu

COPY download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash
COPY requirements.txt /tmp/requirements.txt

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
RUN pip uninstall -y empy
RUN pip install empy==3.3.4 jsonschema pyserial

# --------------------
# Python Dependencies via Miniconda Pip
# --------------------
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# --------------------
# Cleanup
# --------------------
RUN rm -rf /home/ubuntu/user || true

