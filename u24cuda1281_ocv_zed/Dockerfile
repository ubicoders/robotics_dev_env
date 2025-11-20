FROM ubicoders/ubuntu:u24_cuda12

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
ENV CONDA=/miniconda
ENV PATH=${CONDA}/bin:${PATH}

# Accept ToS for Anaconda channels (idempotent)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r


# Install OpenCV
ENV OCV_VERSION_PY=4.12.0.88
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
 && pip install numpy requests cython pyopengl opencv-python==${OCV_VERSION_PY} opencv-contrib-python==${OCV_VERSION_PY} \
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
COPY ./ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run
RUN /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run -- silent

WORKDIR /usr/local/zed

RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python get_python_api.py


WORKDIR /home/ubuntu


# delete the installers
#RUN rm /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run