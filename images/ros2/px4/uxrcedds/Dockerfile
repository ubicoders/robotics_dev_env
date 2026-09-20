# Versions come from .env via docker-compose build args.
ARG ROS_DISTRO
FROM ubicoders/ros2:${ROS_DISTRO}_px4
ARG UXRCE_DDS_AGENT_VERSION
ARG EMPY_VERSION
# The parent image runs as ubuntu; root steps first.
USER root
RUN apt update && apt upgrade -y

ENV UXRCE_DDS_AGENT_VERSION=${UXRCE_DDS_AGENT_VERSION}
COPY images/ros2/px4/uxrcedds/install_uxrce.bash /tmp/install_uxrce.bash
RUN cd /tmp && bash /tmp/install_uxrce.bash && rm /tmp/install_uxrce.bash

USER ubuntu
WORKDIR /home/ubuntu
# empy is pinned last, so it is not upgraded by the line above it.
RUN pip install --no-cache-dir -U pyros-genmsg setuptools && \
    pip install --no-cache-dir "empy==${EMPY_VERSION}"
