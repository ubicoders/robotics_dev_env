FROM ubicoders/ros1:noetic
RUN apt update && apt upgrade -y

#============================================================================
COPY ./download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash
COPY ./install_px4.bash /home/ubuntu/install_px4.bash
RUN bash install_px4.bash
RUN rm -r /home/ubuntu/install_px4.bash

