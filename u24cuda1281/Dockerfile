FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=UTC
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone

# Base deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    software-properties-common \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    curl \
    wget \
    git \
    gnupg \
    # C/C++ & utils
    g++ \
    gcc \
    gdb \
    ccache \
    cppcheck \
    lcov \
    file \
    autoconf \
    automake \
    bison \
    flex \
    libtool \
    # libs
    libncurses-dev \
    libcunit1-dev \
    libfreetype6-dev \
    libgtest-dev \
    libpng-dev \
    libssl-dev \
    libasio-dev \
    libtinyxml2-dev \
    # X/GL runtime
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    # net & misc
    net-tools \
    openssh-client \
    picocom \
    minicom \
    screen \
    nano \
    dmidecode \
    dirmngr \
    doxygen \
    lsb-release \
    # Python from Ubuntu
    python3 \
    python3-pip \
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

# If you actually need Java, pick a supported version:
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-17-jdk-headless && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
# new shell (or)
RUN exec bash -l


# Requirements
WORKDIR /home/



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
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# --------------------
# Cleanup
# --------------------
RUN rm -rf /home/ubuntu/user || true

