FROM ubicoders/ros2:humble
RUN apt update && apt upgrade -y

COPY download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash
COPY download_bridge_px4_ros.bash /home/ubuntu/
COPY install_px4.bash /tmp/install_px4.bash
RUN bash /tmp/install_px4.bash

RUN pip uninstall -y empy
RUN pip install empy==3.3.4

WORKDIR /home/ubuntu


# Set the environment variable by dynamically finding arm-none-eabi-gcc
# Dynamically find arm-none-eabi-gcc and set the PATH during build
RUN arm_gcc_path=$(find / -name arm-none-eabi-gcc | head -n 1) && \
    echo "export PATH=\$PATH:$(dirname $arm_gcc_path)" >> /etc/profile

# Set the environment variable permanently for future containers
ENV PATH=$PATH:/opt/gcc-arm-none-eabi-9-2020-q2-update/bin

# find / -name arm-none-eabi-gcc
# /opt/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc
# export PATH=$PATH:/path/to/arm-none-eabi-gcc