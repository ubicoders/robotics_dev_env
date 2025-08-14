FROM stereolabs/zed:4.0-gl-devel-cuda10.2-ubuntu18.04

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


# # --- Miniconda (non-interactive, robust) ---
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -p /home/miniconda -b
RUN /home/miniconda/bin/activate
ENV PATH="/home/miniconda/bin:${PATH}"
RUN conda init --all
RUN conda config --set auto_activate_base true

RUN rm -rf /home/ubuntu/user
WORKDIR /home/ubuntu

# ZED opencv prep for python and c++
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libjpeg-turbo8 libturbojpeg \
    libusb-1.0-0 libusb-1.0-0-dev libopenblas-dev libarchive-dev \
    libv4l-0 curl unzip zlib1g mesa-utils libpng-dev \
    python3-dev python3-pip python3-setuptools \
    libglew-dev freeglut3-dev \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5opengl5 libqt5svg5 \
    libavcodec-dev libavformat-dev libswscale-dev \
    build-essential cmake pkg-config \
    libgtk-3-dev libtbb-dev libeigen3-dev \
    libjpeg-dev libtiff-dev libwebp-dev libopenexr-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libdc1394-22-dev \
    liblapacke-dev \
    libcanberra-gtk-module libcanberra-gtk3-module \
    zstd \
 && rm -rf /var/lib/apt/lists/*

 
SHELL ["/bin/bash","-lc"]
ENV CONDA=/home/miniconda
ENV PATH=${CONDA}/bin:${PATH}

# Accept ToS for Anaconda channels (idempotent)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r


# Install OpenCV
ENV OCV_VERSION_PY=3.4.18.65
ENV OCV_VERSION_CPP=4.12.0


# OCV Python
## RUN conda create new environment
RUN conda create -n zed python=3.10
RUN conda init bash
RUN /bin/bash -c "conda init"
RUN echo "conda activate zed" >> ~/.bashrc
RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python -V \
 && pip install --upgrade pip \
 && pip install numpy==1.26.4 requests cython==3.0.11 pyopengl==3.1.1a1 requests opencv-python==${OCV_VERSION_PY} opencv-contrib-python==${OCV_VERSION_PY} \
 && conda install -c conda-forge libstdcxx-ng

# OCV C++
WORKDIR /home
RUN wget -O opencv-${OCV_VERSION_CPP}.zip https://github.com/opencv/opencv/archive/${OCV_VERSION_CPP}.zip \
 && unzip opencv-${OCV_VERSION_CPP}.zip \
 && rm opencv-${OCV_VERSION_CPP}.zip \
 && cd opencv-${OCV_VERSION_CPP} \
 && mkdir -p build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_JAVA=OFF -DWITH_OPENGL=ON \
 && make -j"$(nproc)" && make install

# installing zed sdk
# COPY ./ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run
# RUN /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run -- silent

WORKDIR /usr/local/zed

RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python get_python_api.py


WORKDIR /home/ubuntu