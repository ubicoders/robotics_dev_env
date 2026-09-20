#!/bin/bash
set -euo pipefail

# Agent version comes from .env (UXRCE_DDS_AGENT_VERSION), passed in by the Dockerfile.
: "${UXRCE_DDS_AGENT_VERSION:?UXRCE_DDS_AGENT_VERSION is not set}"

# empy is pinned by the Dockerfile (EMPY_VERSION), so it is not upgraded here.
pip install --user -U pyros-genmsg setuptools

git clone --depth 1 -b "${UXRCE_DDS_AGENT_VERSION}" https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
cd Micro-XRCE-DDS-Agent
mkdir build
cd build
cmake ..
make -j"$(nproc)"
make install
ldconfig /usr/local/lib/

cd ../..
rm -rf Micro-XRCE-DDS-Agent
