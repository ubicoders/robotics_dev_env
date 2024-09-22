FROM ubicoders/ros2:humble_px4
RUN apt update && apt upgrade -y

COPY install_uxrce.bash /home/ubuntu/install_uxrce.bash
WORKDIR /home/ubuntu
RUN bash /home/ubuntu/install_uxrce.bash
RUN rm /home/ubuntu/install_uxrce.bash

RUN pip uninstall -y empy
RUN pip install empy==3.3.4