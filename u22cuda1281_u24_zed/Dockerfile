FROM ubicoders/ubuntu:u24_cuda12

# ZED opencv Prep
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg libsm6 libxext6 libjpeg-turbo8 libturbojpeg libusb-1.0-0 libusb-1.0-0-dev libopenblas-dev libarchive-dev libv4l-0 curl unzip zlib1g mesa-utils libpng-dev python3-dev python3-pip python3-setuptools libglew-dev freeglut3-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5opengl5 libqt5svg5 -y


SHELL ["/bin/bash","-lc"]
ENV CONDA=/home/miniconda
ENV PATH=${CONDA}/bin:${PATH}


# Accept ToS for Anaconda channels (idempotent)
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r


## RUN conda create new environment
RUN conda create -n zed python=3.10
RUN conda init bash
RUN /bin/bash -c "conda init"
RUN echo "conda activate zed" >> ~/.bashrc
RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python -V \
 && pip install --upgrade pip \
 && pip install numpy requests cython PyOpenGL opencv-python opencv-contrib-python

# installing zed sdk
RUN apt install zstd -y
COPY ./ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run
RUN /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run -- silent

WORKDIR /usr/local/zed

RUN . ${CONDA}/etc/profile.d/conda.sh \
 && conda activate zed \
 && python get_python_api.py

 WORKDIR /home/ubuntu


# delete the installers

#RUN rm /home/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.0.5.zstd.run
