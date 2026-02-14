FROM ubicoders/ros2:jazzy_svo

RUN apt-get update && apt-get install -y libacl1-dev clang-14 libclang-14-dev llvm-14-dev pkg-config cmake build-essential curl vulkan-tools libvulkan1 libvulkan-dev vulkan-utility-libraries-dev spirv-tools

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# install zenoh-c
RUN git clone https://github.com/eclipse-zenoh/zenoh-c.git /tmp/zenoh-c
WORKDIR /tmp/zenoh-c
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/zenoh-c
RUN cmake --build build --config Release
RUN cmake --install build
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/zenoh-c/lib

# install zenoh c++
RUN git clone https://github.com/eclipse-zenoh/zenoh-cpp.git /tmp/zenoh-cpp
WORKDIR /tmp/zenoh-cpp
RUN cmake -B build -DZENOHCXX_ZENOHC=OFF -DZENOHCXX_ZENOHPICO=OFF -DCMAKE_PREFIX_PATH=/opt/zenoh-c
RUN cmake --build build --config Release
RUN cmake --install build

# install iceoryx 1 c++
RUN git clone https://github.com/eclipse-iceoryx/iceoryx.git /tmp/iceoryx
WORKDIR /tmp/iceoryx
RUN cmake -Bbuild -Hiceoryx_meta -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build -j $(nproc)
RUN cmake --install build

# install iceoryx 2 c++
RUN git clone https://github.com/ubicoders/iceoryx2 /tmp/iceoryx2
WORKDIR /tmp/iceoryx2
RUN git checkout ubicoders_0.7.0
RUN bash internal/scripts/install_dependencies_ubuntu.sh
RUN cmake -S . -B target/ffi/build -DBUILD_EXAMPLES=ON -DCMAKE_PREFIX_PATH="/usr/local/lib"
RUN cmake --build target/ffi/build -j $(nproc)
RUN cmake --install target/ffi/build

# install flatbuffers 23.5.26
RUN git clone https://github.com/google/flatbuffers.git /tmp/flatbuffers
WORKDIR /tmp/flatbuffers
RUN git checkout v23.5.26
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build -j $(nproc)
RUN cmake --install build

COPY ./ros2svo_vrobots/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

WORKDIR /home/ubuntu
COPY use_conda.bash /home/ubuntu/use_conda.bash
COPY use_system_python.bash /home/ubuntu/use_system_python.bash
RUN chmod +x /home/ubuntu/use_system_python.bash /home/ubuntu/use_system_python.bash
