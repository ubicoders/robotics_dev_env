FROM ubicoders/ros1:noetic_px4
RUN apt update && apt upgrade -y

#===========
RUN rosinstall_generator --rosdistro noetic mavlink | tee /tmp/mavros.rosinstall
RUN rosinstall_generator --upstream mavros | tee -a /tmp/mavros.rosinstall
COPY ./install_mavros.bash /home/ubuntu/install_mavros.bash
# RUN /home/ubuntu/install_mavros.bash
