FROM ubicoders/ros2:humble
RUN apt update && apt upgrade -y

COPY download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash
COPY download_bridge_px4_ros.bash /home/ubuntu/
COPY install_uxrce.bash /home/ubuntu/install_uxrce.bash
COPY install_px4.bash /tmp/install_px4.bash
RUN bash /tmp/install_px4.bash

WORKDIR /home/ubuntu


