# Versions come from .env via docker-compose build args.
ARG ROS_DISTRO
FROM ubicoders/ros2:${ROS_DISTRO}_px4
ARG UXRCE_DDS_AGENT_VERSION
ARG EMPY_VERSION
RUN apt update && apt upgrade -y

ENV UXRCE_DDS_AGENT_VERSION=${UXRCE_DDS_AGENT_VERSION}
COPY images/ros2/px4/uxrcedds/install_uxrce.bash /home/ubuntu/install_uxrce.bash
WORKDIR /home/ubuntu
RUN bash /home/ubuntu/install_uxrce.bash
RUN rm /home/ubuntu/install_uxrce.bash

RUN pip install --no-cache-dir "empy==${EMPY_VERSION}"
