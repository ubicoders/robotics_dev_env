# ZED SDK installers

Put ZED SDK `.run` installers from https://www.stereolabs.com/developers/release in this folder. They are ignored by git (`*.run`), so each machine that builds the image needs its own copy.

Several installers may sit here side by side. `ZED_SDK_INSTALLER` in the repository `.env` names the one that `images/cuda/ocv_zed/Dockerfile` copies into the image.

The file name encodes the Ubuntu, CUDA, and TensorRT versions the installer was built for. It must match the base image `ubicoders/ubuntu:u24_cuda12` (Ubuntu 24.04, CUDA 12.8): an Ubuntu 22 installer, for example, cannot be used with it.
