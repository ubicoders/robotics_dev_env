FROM ubicoders/ros2:humble_cuda12_ocv

############################################################################
# ZED opencv Prep
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg libsm6 libxext6  -y
RUN apt install libjpeg-turbo8 libturbojpeg libusb-1.0-0 libusb-1.0-0-dev libopenblas-dev libarchive-dev libv4l-0 curl unzip zlib1g mesa-utils libpng-dev python3-dev python3-pip python3-setuptools libglew-dev freeglut3-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5opengl5 libqt5svg5 -y

## RUN pip3 uninstall numpy -y
RUN rm -rf /usr/local/lib/python3.10/dist-packages/numpy*
RUN pip3 install numpy==1.26.4 requests cython==3.0.11 PyOpenGL==3.1.1a1
############################################################################


# installing zed sdk
RUN apt install zstd -y
COPY ./ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run
RUN /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run -- silent
COPY ./ocv_pip.bash /home/ocv_pip.bash
RUN bash /home/ocv_pip.bash


# delete the installers
#ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run 
RUN rm /home/ZED_SDK_Ubuntu22_cuda12.1_v4.1.3.zstd.run
