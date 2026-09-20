#!/bin/bash
# Installs Rust plus both ROS 2 Rust client libraries: rclrs (ros2_rust) and r2r.
# Versions come from .env, passed in by the Dockerfile as build args.
# Runs as the ubuntu user; root steps go through sudo.
set -euo pipefail

: "${ROS_DISTRO:?}" "${RUST_VERSION:?}" "${ROS2_RUST_VERSION:?}" "${R2R_VERSION:?}"
: "${CARGO_AMENT_BUILD_VERSION:?}" "${COLCON_CARGO_VERSION:?}" "${COLCON_ROS_CARGO_VERSION:?}"
: "${ROSIDL_RUST_VERSION:?}" "${ROSIDL_RUNTIME_RS_VERSION:?}"
: "${RUSTUP_HOME:?}" "${CARGO_HOME:?}"

WS=/opt/ros2_rust_ws
INSTALL=/opt/ros2_rust

sudo apt-get update
sudo apt-get install -y --no-install-recommends libclang-dev python3-pip python3-vcstool
sudo rm -rf /var/lib/apt/lists/*

# Everything Rust lives under /opt, owned by ubuntu so cargo and rustup work without sudo.
sudo install -d -o "$(id -un)" -g "$(id -gn)" /opt/rust "${WS}" "${INSTALL}"

# Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --no-modify-path --profile default --default-toolchain "${RUST_VERSION}"
rustup component add rust-src rust-analyzer
cargo install --locked cargo-ament-build --version "${CARGO_AMENT_BUILD_VERSION}"

# colcon plugins, for the system interpreter and for conda (both provide a colcon)
sudo /usr/bin/python3 -m pip install --break-system-packages --no-cache-dir \
    "colcon-cargo==${COLCON_CARGO_VERSION}" "colcon-ros-cargo==${COLCON_ROS_CARGO_VERSION}"
if [ -x /miniconda/bin/pip ]; then
    /miniconda/bin/pip install --no-cache-dir \
        "colcon-cargo==${COLCON_CARGO_VERSION}" "colcon-ros-cargo==${COLCON_ROS_CARGO_VERSION}"
fi

# rclrs overlay: rclrs plus the ROS interface packages rebuilt with the Rust generator
mkdir -p "${WS}/src"
cd "${WS}"
git clone --depth 1 -b "${ROS2_RUST_VERSION}" https://github.com/ros2-rust/ros2_rust.git src/ros2_rust
vcs import src < "src/ros2_rust/ros2_rust_${ROS_DISTRO}.repos"
# The repos file tracks main for these two; pin them to releases that match rclrs.
git -C src/ros2-rust/rosidl_rust checkout -q "${ROSIDL_RUST_VERSION}"
git -C src/ros2-rust/rosidl_runtime_rs checkout -q "${ROSIDL_RUNTIME_RS_VERSION}"
# The upstream examples are not part of the overlay.
rm -rf src/ros2-rust/examples

# Build on the system interpreter, not conda.
export PATH="/usr/bin:${PATH}"
set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u
/usr/bin/python3 -m colcon build --install-base "${INSTALL}" \
    --cmake-args -DPython3_EXECUTABLE=/usr/bin/python3 -DBUILD_TESTING=OFF

# Smoke tests, built with the rclrs overlay sourced as it will be for users.
set +u
source "${INSTALL}/setup.bash"
set -u

# rclrs: a new ament_cargo package in a new workspace
SMOKE_WS=/tmp/rclrs_smoke_ws
mkdir -p "${SMOKE_WS}/src/rclrs_smoke/src"
cd "${SMOKE_WS}/src/rclrs_smoke"
cat > Cargo.toml <<'TOML'
[package]
name = "rclrs_smoke"
version = "0.1.0"
edition = "2021"

[dependencies]
rclrs = "0.7"
std_msgs = "*"
TOML
cat > package.xml <<'XML'
<?xml version="1.0"?>
<package format="3">
  <name>rclrs_smoke</name>
  <version>0.1.0</version>
  <description>Build-time check that rclrs works</description>
  <maintainer email="info@ubicoders.com">ubicoders</maintainer>
  <license>Apache-2.0</license>
  <depend>rclrs</depend>
  <depend>std_msgs</depend>
  <export><build_type>ament_cargo</build_type></export>
</package>
XML
cat > src/main.rs <<'RS'
use rclrs::*;

fn main() -> Result<(), RclrsError> {
    let context = Context::default_from_env()?;
    let executor = context.create_basic_executor();
    let node = executor.create_node("rclrs_smoke")?;
    let publisher = node.create_publisher::<std_msgs::msg::String>("rclrs_smoke")?;
    publisher.publish(&std_msgs::msg::String { data: "hello".to_string() })?;
    println!("rclrs_smoke_ok");
    Ok(())
}
RS
cd "${SMOKE_WS}"
/usr/bin/python3 -m colcon build --packages-select rclrs_smoke
./install/rclrs_smoke/lib/rclrs_smoke/rclrs_smoke

# r2r: a plain cargo project
SMOKE=/tmp/r2r_smoke
cargo new --bin "${SMOKE}"
cd "${SMOKE}"
cargo add "r2r@=${R2R_VERSION}"
cat > src/main.rs <<'RS'
use r2r::QosProfile;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let ctx = r2r::Context::create()?;
    let mut node = r2r::Node::create(ctx, "r2r_smoke", "")?;
    let publisher =
        node.create_publisher::<r2r::std_msgs::msg::String>("/r2r_smoke", QosProfile::default())?;
    for i in 0..5 {
        publisher.publish(&r2r::std_msgs::msg::String { data: format!("hello {i}") })?;
        node.spin_once(std::time::Duration::from_millis(100));
    }
    println!("r2r_smoke_ok");
    Ok(())
}
RS
cargo build
./target/debug/r2r_smoke

# Keep the install tree and the cargo registry; drop sources and build output.
cd /
sudo rm -rf "${WS}" "${SMOKE}" "${SMOKE_WS}"
