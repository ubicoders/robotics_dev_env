# syntax=docker/dockerfile:1
FROM ubicoders/ubuntu:u24_cuda12
# Versions come from .env via docker-compose build args.
ARG OPENCV_VERSION
ARG OPENCV_PYTHON_VERSION
ARG ZED_PYTHON_VERSION
ARG ZED_SDK_INSTALLER

# The parent image runs as ubuntu; root steps first.
USER root

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
    libdc1394-dev \
    liblapacke-dev \
    libcanberra-gtk-module libcanberra-gtk3-module \
    zstd \
 && rm -rf /var/lib/apt/lists/*


SHELL ["/bin/bash","-lc"]
# Install OpenCV
ENV OCV_VERSION_PY=${OPENCV_PYTHON_VERSION}
ENV OCV_VERSION_CPP=${OPENCV_VERSION}

# OCV C++
WORKDIR /home
RUN wget -O opencv-${OCV_VERSION_CPP}.zip https://github.com/opencv/opencv/archive/${OCV_VERSION_CPP}.zip \
 && unzip opencv-${OCV_VERSION_CPP}.zip \
 && rm opencv-${OCV_VERSION_CPP}.zip \
 && cd opencv-${OCV_VERSION_CPP} \
 && mkdir -p build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_JAVA=OFF -DWITH_OPENGL=ON \
 && make -j"$(nproc)" && make install \
 && cd /home && rm -rf opencv-${OCV_VERSION_CPP}

# installing zed sdk: ZED_SDK_INSTALLER (.env) selects one installer from zed_sdk/
# The installer is removed in the same layer so it does not stay in the image.
# It runs as root, so the SDK folder (models are written there at run time) and anything
# it touched in /miniconda are handed back to ubuntu. It also deletes /etc/sudoers.d/ubuntu,
# which is restored.
RUN --mount=type=bind,source=images/cuda/ocv_zed/zed_sdk/${ZED_SDK_INSTALLER},target=/tmp/zed_sdk.run \
    cp /tmp/zed_sdk.run /tmp/zed_install.run && chmod +x /tmp/zed_install.run && \
    /tmp/zed_install.run -- silent && rm -f /tmp/zed_install.run && \
    chown -R ubuntu:ubuntu /usr/local/zed && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && chmod 0440 /etc/sudoers.d/ubuntu && \
    find /miniconda -user root -exec chown -h ubuntu:ubuntu {} +

# --------------------
# Python side, as ubuntu (owner of /miniconda)
# --------------------
USER ubuntu
WORKDIR /home/ubuntu
ENV CONDA=/miniconda
ENV PATH=${CONDA}/bin:${PATH}

# Accept ToS for Anaconda channels (idempotent)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r




# OCV Python
## RUN conda create new environment
RUN conda create -n zed python=${ZED_PYTHON_VERSION}
RUN conda init bash
RUN /bin/bash -c "conda init"
RUN echo "conda activate zed" >> ~/.bashrc
RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python -V \
 && pip install --upgrade pip \
 && pip install numpy requests cython pyopengl opencv-python==${OCV_VERSION_PY} opencv-contrib-python==${OCV_VERSION_PY} \
 && conda install -c conda-forge libstdcxx-ng

# ZED Python API (pyzed) into the zed environment
RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && cd /tmp && python /usr/local/zed/get_python_api.py && rm -f /tmp/*.whl

CMD ["/bin/bash"]
