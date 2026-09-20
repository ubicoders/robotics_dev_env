#!/bin/bash
# Optional helper: clones upstream PX4-Autopilot into /home/ubuntu.
# Usage: download_px4_autopilot.bash [git-ref]
# Default ref is the tag the image toolchain was installed from (PX4_TOOLCHAIN_VERSION).
# The image ships no PX4 source, so cloning your own fork or version works the same way.
PX4_REF="${1:-${PX4_TOOLCHAIN_VERSION:?pass a git ref or set PX4_TOOLCHAIN_VERSION}}"

pip3 install jsonschema

cd /home/ubuntu
git clone https://github.com/PX4/PX4-Autopilot --recursive
cd PX4-Autopilot
git checkout -f "${PX4_REF}"
git submodule update --recursive
git submodule update --init --recursive

cd /home/ubuntu
git clone https://github.com/mavlink/mavlink.git --recursive
PYTHONPATH=/home/ubuntu/mavlink
