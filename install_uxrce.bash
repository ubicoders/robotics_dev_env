pip install --user -U empy pyros-genmsg setuptools

git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
cd Micro-XRCE-DDS-Agent
git checkout v2.4.1
mkdir build
cd build
cmake ..
make
make install
ldconfig /usr/local/lib/