pip3 install jsonschema

cd /home/ubuntu
git clone https://github.com/PX4/PX4-Autopilot --recursive
cd PX4-Autopilot
git checkout -f v1.14.3 # tag at release/1.14.3 branch
git submodule update --recursive
git submodule update --init --recursive

cd /home/ubuntu
git clone https://github.com/mavlink/mavlink.git --recursive
PYTHONPATH=/home/ubuntu/mavlink

