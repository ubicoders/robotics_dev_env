#!/bin/bash

# Variables
OPENCV_VERSION="4.10.0"
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
SITE_PACKAGES_DIR="/usr/local/lib/python${PYTHON_VERSION}/dist-packages"
CV2_DIR="${SITE_PACKAGES_DIR}/cv2"

# Check if cv2 directory exists
if [ ! -d "$CV2_DIR" ]; then
  echo "cv2 directory not found in $CV2_DIR. Ensure OpenCV is installed."
  exit 1
fi

# Step 1: Create a .pth file for opencv-python
echo "Creating opencv-python.pth file..."
echo "$CV2_DIR" | sudo tee ${SITE_PACKAGES_DIR}/opencv-python.pth

# Step 2: Create a .dist-info directory and METADATA file for opencv-python
echo "Creating opencv_python-${OPENCV_VERSION}.dist-info directory and METADATA file..."
sudo mkdir -p ${SITE_PACKAGES_DIR}/opencv_python-${OPENCV_VERSION}.dist-info

sudo tee ${SITE_PACKAGES_DIR}/opencv_python-${OPENCV_VERSION}.dist-info/METADATA <<EOF
Metadata-Version: 2.1
Name: opencv-python
Version: ${OPENCV_VERSION}
Summary: OpenCV Python bindings
Home-page: https://opencv.org/
Author: OpenCV Team
License: MIT
Platform: any
EOF

# Step 3: Create a .dist-info directory and METADATA file for opencv-contrib-python (optional)
echo "Creating opencv_contrib_python-${OPENCV_VERSION}.dist-info directory and METADATA file..."
sudo mkdir -p ${SITE_PACKAGES_DIR}/opencv_contrib_python-${OPENCV_VERSION}.dist-info

sudo tee ${SITE_PACKAGES_DIR}/opencv_contrib_python-${OPENCV_VERSION}.dist-info/METADATA <<EOF
Metadata-Version: 2.1
Name: opencv-contrib-python
Version: ${OPENCV_VERSION}
Summary: OpenCV Python bindings with contrib modules
Home-page: https://opencv.org/
Author: OpenCV Team
License: MIT
Platform: any
EOF

# Final check
echo "Checking if pip recognizes the installed packages..."
pip list | grep opencv

echo "Script completed. OpenCV should now be recognized by pip."
