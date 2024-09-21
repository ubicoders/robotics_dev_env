pip3 install jsonschema

cd /home/ubuntu
git clone https://github.com/PX4/PX4-Autopilot --recursive
cd PX4-Autopilot
git checkout -f v1.14.2 # tag at release/1.14.2 branch
git submodule update --recursive
git submodule update --init --recursive

cd /home/ubuntu
git clone https://github.com/mavlink/mavlink.git --recursive
PYTHONPATH=/home/ubuntu/mavlink

# find / -name arm-none-eabi-gcc
# /opt/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc
# export PATH=$PATH:/path/to/arm-none-eabi-gcc