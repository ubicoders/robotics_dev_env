
cd /home/ubuntu/catkin_ws/
wstool merge -t src /tmp/mavros.rosinstall
wstool update -t src -j4
cd /home/ubuntu/catkin_ws/
rosdep install --from-paths src --ignore-src -y
./src/mavros/mavros/scripts/install_geographiclib_datasets.sh
catkin build
source devel/setup.bash