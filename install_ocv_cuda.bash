#!/bin/bash
# remove the old version of OpenCV

echo "Removing OpenCV files from /usr/local/bin..."
sudo rm -rf /usr/local/bin/opencv*

echo "Removing OpenCV libraries from /usr/local/lib..."
sudo rm -rf /usr/local/lib/libopencv*

echo "Removing OpenCV CMake package from /usr/local/cmake..."
sudo rm -rf /usr/local/cmake/opencv4

echo "Removing OpenCV headers from /usr/local/include..."
sudo rm -rf /usr/local/include/opencv4

echo "Removing OpenCV headers from /usr/include..."
sudo rm -rf /usr/include/opencv4

echo "Removing OpenCV shared files from /usr/local/share..."
sudo rm -rf /usr/local/share/opencv4

echo "Removing any additional OpenCV files from /etc..."
sudo rm -rf /etc/opencv*
sudo rm -rf /usr/local/etc/opencv*

echo "Updating the shared library cache..."
sudo ldconfig

echo "Cleaning up CMake cache..."
rm -rf ~/.cmake

echo "OpenCV has been completely removed from your system."

sudo apt-get update
sudo apt-get install -y build-essential cmake git pkg-config libgtk2.0-dev libgtk-3-dev \
    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libatlas-base-dev gfortran python3-dev


# Download OpenCV 4.10.0 source code
wget https://github.com/opencv/opencv/archive/4.10.0.zip -O /tmp/opencv_src.zip

# Navigate to the home directory and unzip the source code
cd /home
unzip /tmp/opencv_src.zip
rm /tmp/opencv_src.zip

# Download OpenCV 4.10.0 contrib modules
wget https://github.com/opencv/opencv_contrib/archive/4.10.0.zip -O /tmp/opencv_contrib.zip
unzip /tmp/opencv_contrib.zip -d /home/
rm /tmp/opencv_contrib.zip


# Create a build directory and navigate into it
cd /home/opencv-4.10.0
mkdir build
cd build

# Configure the build with CMake, enabling CUDA support
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/home/opencv_contrib-4.10.0/modules \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_opencv_python3=ON \
    -D WITH_CUDA=ON \
    -D CUDA_ARCH_BIN=6.1 \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D WITH_GTK=ON \
    -D WITH_OPENGL=ON \
    -D WITH_QT=ON \
    -D PYTHON3_EXECUTABLE=$(which python3) \
    -D PYTHON3_INCLUDE_DIR=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['include'])") \
    -D PYTHON3_LIBRARY=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['platlib'])") \
    ..

# Compile OpenCV
make -j$(nproc)

# Install OpenCV
make install

# Update the shared library cache
ldconfig
