# ROS 2 Image Plan

Design and status of the ROS 2 images in this repository. It records what each image contains, how versions and build order are controlled, what was decided and why, and what is still open. Rules that apply to every change live in `CLAUDE.md`; this document explains the ROS 2 family specifically.

Status date: 2026-09-20. All active images below were built and pushed to Docker Hub on 2026-09-19.

## Goals

1. One file, `.env`, decides every version. Changing a version is a one-line edit followed by a rebuild.
2. Images are fully baked: installation and long source builds happen during `docker build`, not after `docker run`.
3. A child image is never built on, or pushed with, a stale parent.
4. Rebuilds are repeatable: nothing important floats to "latest".

## Image family

There are two ROS 2 lineages. They share no layers, so a change meant for all ROS 2 images must be made in both.

### Lineage A: from the official ROS image

```
osrf/ros:${ROS_DISTRO}-desktop-full-${UBUNTU_CODENAME}
└── ubicoders/ros2:jazzy                 images/ros2/base/
    ├── ubicoders/ros2:jazzy_px4         images/ros2/px4/
    │   └── ubicoders/ros2:jazzy_px4_uxrcedds   images/ros2/px4/uxrcedds/
    └── ubicoders/ros2:jazzy_svo         images/ros2/svo/
```

| Image | Adds on top of its parent |
|---|---|
| `ros2:jazzy` | Build tools (apt), `rosdep update`, Miniconda pinned to Python 3.12, shared `requirements.txt`, pinned empy, `/home/ubuntu/robot_ws/src` workspace |
| `ros2:jazzy_px4` | PX4 toolchain from upstream `Tools/setup/ubuntu.sh` at `PX4_TOOLCHAIN_VERSION` (ARM GCC, Xtensa ESP32 compilers, Gazebo Harmonic, PX4 Python requirements), helper scripts `download_px4_autopilot.bash` and `download_bridge_px4_ros.bash` |
| `ros2:jazzy_px4_uxrcedds` | Micro XRCE-DDS Agent at `UXRCE_DDS_AGENT_VERSION`, built from source and installed to `/usr/local` |
| `ros2:jazzy_svo` | Visual odometry libraries built from source: FBOW, Sophus, g2o, plus Eigen, spdlog, SuiteSparse, Qt5, QGLViewer |

### Lineage B: from the CUDA base

```
nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu${UBUNTU_VERSION}
└── ubicoders/ubuntu:u24_cuda12          images/cuda/base/
    └── ubicoders/ros2:jazzy_cuda12      images/cuda/ros2/
```

`ros2:jazzy_cuda12` installs `ros-${ROS_DISTRO}-desktop-full` from the ROS apt repository, then ros-gz, ros2_control, the URDF and TF helpers, and rosdep. It mirrors what `osrf/ros` provides so that both lineages offer the same ROS 2 surface, with GPU support added.

### Removed

The `ros2:jazzy_vrobots` and `ros2:jazzy_svo_vrobots` images were deprecated and then removed from the repository on 2026-09-20, together with their compose services and the `.env` variables only they used (`RUST_TOOLCHAIN`, `FLATBUFFERS_VERSION`, `ICEORYX2_VERSION`). Their definitions are preserved in git tag `2026-Q1`. Their old tags are kept on Docker Hub on purpose and must not be deleted.

No active image contains iceoryx2 or zenoh. Rust is part of the ROS 2 base image, see "Rust support".

### Folder layout

Under `images/`, nesting mirrors `FROM`: each lineage root holds `base/`, and a child image sits inside the folder of the image it builds on. A file used by one image lives beside its Dockerfile (`images/ros2/px4/download_bridge_px4_ros.bash`, `images/ros2/px4/uxrcedds/install_uxrce.bash`). A file used by two or more images lives in `common/` (`requirements.txt`, `download_px4_autopilot.bash`, `use_conda.bash`, `use_system_python.bash`). Every build uses the repository root as context.

## Version control through `.env`

`docker compose` reads `.env` automatically and passes values to each Dockerfile as build args. `build.bash` pushes with `docker compose push`, so push tags come from the same source and are not repeated in the script. Dockerfile `ARG` lines deliberately have no default value, so `.env` stays the only source; `docker build --check` reports `InvalidDefaultArgInFrom` for this reason, and a bare `docker build` needs explicit `--build-arg` flags.

| Variable | Value | Used by (ROS 2 family) |
|---|---|---|
| `ROS_DISTRO` | `jazzy` | Base image of lineage A, apt package names in lineage B, every `ubicoders/ros2:*` tag and child `FROM` line |
| `UBUNTU_CODENAME` / `UBUNTU_VERSION` | `noble` / `24.04` | Base image names |
| `MINICONDA_INSTALLER` | `Miniconda3-py312_26.7.1-1-Linux-x86_64.sh` | `ros2:jazzy`, `ubuntu:u24_cuda12` |
| `EMPY_VERSION` | `3.3.4` | Final `pip install` in every image that builds ROS or PX4 messages |
| `PX4_TOOLCHAIN_VERSION` | `v1.17.0` | `ros2:jazzy_px4` |
| `PX4_MSGS_VERSION` | `release/1.17` | Baked into `ros2:jazzy_px4` as an environment variable for the bridge helper |
| `UXRCE_DDS_AGENT_VERSION` | `v3.0.2` | `ros2:jazzy_px4_uxrcedds` |
| `CUDA_VERSION` | `12.8.1` | Base of lineage B |

Service names in `docker-compose.yml` are distro-neutral (`ros2`, `ros2_px4`, `ros2_px4_uxrcedds`, `ros2_svo`, `cuda_ros2`). Container names still contain `jazzy`; they were kept so that existing `docker exec` commands continue to work.

## Build and push

`build.bash` builds parents before children, then pushes everything. It runs with `set -euo pipefail`, and all pushes come after the last build, so one failed build means nothing is pushed. `--no-cache` rebuilds every layer, `--no-push` skips the push, and naming services limits the run to them, still in dependency order.

ROS 2 service order: `ros2`, `ros2_px4`, `ros2_px4_uxrcedds`, `ros2_svo`, then (after `cuda`) `cuda_ros2`.

`depends_on` in `docker-compose.yml` orders container start only. It does not order image builds. A child `FROM ubicoders/ros2:jazzy` resolves to the local image when it exists and otherwise to the Docker Hub tag, so skipping the script risks building on an old parent.

## Decisions and their reasons

| Decision | Reason |
|---|---|
| PX4 toolchain comes from upstream `ubuntu.sh` fetched at a pinned tag | The previous `install_px4.bash` was a hand-copied snapshot of the same script at v1.16.0. Fetching removes the copy and makes a PX4 bump a one-line change. |
| No PX4 source in the image | Users clone their own PX4 repository or fork at any version. The image carries only the toolchain. |
| Miniconda pinned to Python 3.12 | `Miniconda3-latest` moved to Python 3.14, for which several wheels do not exist. Python 3.12 also matches the system interpreter of Ubuntu 24.04 and ROS 2 Jazzy. |
| empy pinned once, installed last | PX4 and ROS message generation break on empy 4. `install_uxrce.bash` no longer upgrades empy. |
| `px4_msgs` follows `release/1.17` | Message definitions must match the firmware release, or uORB and ROS 2 topics disagree. `px4_ros_com` has no 1.17 branch and follows `main`. |
| vrobots images removed rather than fixed | The `ubicoders/iceoryx2` fork is gone, and `ubicoders-vrobots-ipc` requires `iceoryx2==0.7.0`, which conflicts with any newer C++ build. |

## Python inside the images

Miniconda (`/miniconda`) is first on `PATH`, so a bare `python3` or `pip` means conda Python 3.12. `colcon` and the ROS 2 tooling run on the system interpreter, `/usr/bin/python3`. ROS build dependencies and colcon plugins must be installed with `/usr/bin/python3 -m pip install --break-system-packages`. `use_conda.bash` and `use_system_python.bash` switch the active interpreter inside a container.

In `ros2:jazzy_px4`, conda is already on `PATH` when `ubuntu.sh` runs, so the PX4 Python requirements land in conda. The Dockerfile then installs the upstream PX4 requirements and the shared `requirements.txt` into conda again, which is harmless but redundant.

## Known caveats

1. **Agent v3.0.2 and stock PX4 v1.17.0 do not interoperate.** The PX4 v1.17.0 client speaks the XRCE-DDS 2.x protocol. Agent 3.x needs firmware built with `UXRCE_DDS_CLIENT_USE_DDS_V3`, a Kconfig option that exists only on PX4 `main`. With stock v1.17.0 firmware or SITL, the agent starts and no ROS 2 topics appear. The PX4 documentation prescribes agent `v2.4.3` for Jazzy. Reverting is a one-line change in `.env` plus a rebuild of `ros2:jazzy_px4_uxrcedds`.
2. **The PX4 bridge is not fully baked.** `download_bridge_px4_ros.bash` clones `px4_msgs` and `px4_ros_com` at run time, and the user must then run `colcon build`. This conflicts with the fully-baked rule in `CLAUDE.md`.
3. **Compiling PX4 inside a container has not been verified.** The toolchain, compilers, and Python imports were checked. `make px4_sitl` and a NuttX target were not run.
4. **Floating inputs remain.** Every apt package, most of `requirements.txt`, the FBOW, Sophus, and g2o clones (`--depth=1` at the default branch), and `px4_ros_com` are unpinned. A rebuild next month can differ from today's.
5. **Image size.** `ros2:jazzy_px4` is about 16 GB and `ros2:jazzy_cuda12` about 27 GB. `ros2:jazzy_svo` keeps its source and build trees under `/opt/src`.

## Open items

| # | Item | Proposed action |
|---|---|---|
| 1 | Agent version | Decide between `v2.4.3` (works with stock v1.17.0) and `v3.0.2` (needs PX4 `main`). An alternative is to install both under separate prefixes and select at run time. |
| 2 | Bake the PX4 bridge | Clone `px4_msgs` at `PX4_MSGS_VERSION` and `px4_ros_com` during the `ros2:jazzy_px4` build and run `colcon build` with the system interpreter, so the workspace is ready after `docker run`. Pin `px4_ros_com` to a commit in `.env`. |
| 3 | Verify PX4 builds | In `ros2:jazzy_px4`, clone PX4 v1.17.0 and run `make px4_sitl` and `make px4_fmu-v6x_default`. |
| 4 | Pin the SVO libraries | Add `FBOW_VERSION`, `SOPHUS_VERSION`, and `G2O_VERSION` to `.env` and check out those refs instead of the default branch. |
| 5 | Reduce size | Delete source and build trees in the same `RUN` that installs them. Consider `--no-sim-tools` for `ubuntu.sh` in images that do not need Gazebo. |
| 6 | Deduplicate the apt block | The long build-tools apt list is repeated in `images/ros2/base/`, `images/ros2/px4/`, and `images/cuda/base/`. `images/ros2/px4/` inherits it from its parent and can drop most of it. |
| 7 | Remove deprecated images | Done in the repository on 2026-09-20. The old `jazzy_vrobots` and `jazzy_svo_vrobots` tags stay on Docker Hub on purpose, for existing users. Do not delete them. |
| 8 | Parallel builds | The PX4, lineage A, and lineage B chains are independent and can build in parallel lanes. Deferred: source builds already use every core, so the gain is mostly in download and apt time. |
| 9 | Service names | Done: compose services are distro-neutral. Container names still contain `jazzy`. |

## Rust support (rclrs and r2r)

Rust support lives inside the ROS 2 base images, not in separate images.

| Image | Status |
|---|---|
| `ros2:jazzy` (`images/ros2/base/`) | Built, tested, and pushed on 2026-09-20 |
| `ros2:jazzy_cuda12` (`images/cuda/ros2/`) | Built, tested, and pushed on 2026-09-20 |

`ros2:jazzy_px4`, `ros2:jazzy_px4_uxrcedds`, and `ros2:jazzy_svo` inherit Rust from `ros2:jazzy`.

- One script, `common/install_ros2_rust.bash`, run as user `ubuntu`.
- Rust toolchain in `/opt/rust`, on `PATH` for every shell, owned by `ubuntu`.
- rclrs overlay in `/opt/ros2_rust`, sourced from `/home/ubuntu/.bashrc`.
- `r2r` needs only the toolchain and `libclang`; it is a normal cargo dependency.
- The image build runs a smoke test for each library and fails if either breaks.

| `.env` key | Value | Note |
|---|---|---|
| `RUST_VERSION` | 1.98.1 | rclrs needs 1.85 or newer; Ubuntu apt has 1.75 |
| `ROS2_RUST_VERSION` | v0.7.0 | rclrs release |
| `ROSIDL_RUST_VERSION` | 0.4.12 | 0.5.0 changed the message scheme and breaks rclrs 0.7.0 |
| `ROSIDL_RUNTIME_RS_VERSION` | v0.6.1 | matches rclrs 0.7.0 |
| `R2R_VERSION` | 0.9.7 | |
| `CARGO_AMENT_BUILD_VERSION`, `COLCON_CARGO_VERSION`, `COLCON_ROS_CARGO_VERSION` | 0.1.11, 0.2.0, 0.2.0 | |

Every image runs as user `ubuntu` (see the `dockerfile-baseline` skill). The three lineage roots (`images/px4`, `images/ros2/base`, `images/cuda/base`) set the user up and install Miniconda as `ubuntu`. A child image uses `USER root` for its root steps and then returns to `USER ubuntu`.

## Changing a version

1. Edit the value in `.env`.
2. Run `./build.bash`. Cached layers above the changed step are reused; everything below rebuilds, including children.
3. If any build fails, nothing is pushed. Fix the cause and run the script again.
4. Commit `.env` together with any Dockerfile change that the new version required.
