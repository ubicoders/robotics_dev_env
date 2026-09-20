# robotics_dev_env

Docker images for robotics development on Ubuntu 24.04: ROS 2 Jazzy, the PX4 toolchain, CUDA, OpenCV, and the ZED SDK. Images are published under `ubicoders/` on Docker Hub. Every image is fully baked: nothing has to be compiled after `docker run`.

## Images

| Image | Compose service | Folder | Built on |
|---|---|---|---|
| `ubicoders/px4:v1.17.0` | `px4` | `images/px4/` | `ubuntu:24.04` |
| `ubicoders/ros2:jazzy` | `ros2` | `images/ros2/base/` | `osrf/ros:jazzy-desktop-full-noble` |
| `ubicoders/ros2:jazzy_px4` | `ros2_px4` | `images/ros2/px4/` | `ubicoders/ros2:jazzy` |
| `ubicoders/ros2:jazzy_px4_uxrcedds` | `ros2_px4_uxrcedds` | `images/ros2/px4/uxrcedds/` | `ubicoders/ros2:jazzy_px4` |
| `ubicoders/ros2:jazzy_svo` | `ros2_svo` | `images/ros2/svo/` | `ubicoders/ros2:jazzy` |
| `ubicoders/ubuntu:u24_cuda12` | `cuda` | `images/cuda/base/` | `nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04` |
| `ubicoders/ubuntu:u24_cuda12_ocv_zed` | `cuda_ocv_zed` | `images/cuda/ocv_zed/` | `ubicoders/ubuntu:u24_cuda12` |
| `ubicoders/ros2:jazzy_cuda12` | `cuda_ros2` | `images/cuda/ros2/` | `ubicoders/ubuntu:u24_cuda12` |

The versions shown are the current values in `.env`.

## Layout

```
.env                      every pinned version, the single source of truth
docker-compose.yml        one service per image: build args, tag, run settings
build.bash                builds in dependency order, then pushes
common/                   files used by two or more images
images/
├── px4/
├── ros2/                 lineage from osrf/ros
│   ├── base/
│   ├── px4/
│   │   └── uxrcedds/
│   └── svo/
└── cuda/                 lineage from nvidia/cuda
    ├── base/
    ├── ocv_zed/
    └── ros2/
```

Nesting mirrors `FROM`: a child image sits inside the folder of the image it builds on, next to that image's `base/` or Dockerfile. A script used by a single image lives beside its Dockerfile; a file used by several images lives in `common/`.

## Use an image

```bash
docker compose run --rm ros2_px4
```

The compose services forward X11, mount `/dev`, and use host networking. The `cuda*` services also request the NVIDIA runtime and all GPUs.

## Build

```bash
./build.bash                          # build everything in order, then push
./build.bash --no-push                # build only
./build.bash --no-cache               # rebuild every layer
./build.bash --no-push ros2 ros2_px4  # a subset, still built parents first
```

Pushing starts only after every selected build has succeeded, so a child image is never published on a stale parent.

`cuda_ocv_zed` needs the ZED SDK installer named by `ZED_SDK_INSTALLER` in `.env`. Download it from Stereolabs and place it in `images/cuda/ocv_zed/`. It is ignored by git.

## Change a version

1. Edit the value in `.env`.
2. Run `./build.bash`.
3. Commit `.env` together with any Dockerfile change the new version required.

`ROS2_IMAGE_PLAN.md` records the design of the ROS 2 images, the reasons behind each decision, known caveats, and open items.
