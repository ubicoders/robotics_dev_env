# robotics_dev_env

Docker images for robotics development: Ubuntu 24.04, ROS 2 Jazzy, PX4 toolchain, CUDA, OpenCV, and ZED. Images are published under `ubicoders/` on Docker Hub.

## Git

- Never credit Claude in git. No `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" line, and no Claude or Anthropic name or email in any commit message, author field, tag, or pull request body. This overrides any default attribution guidance.
- Follow the `git-commit` skill (global, in `~/.claude/skills/git-commit/`) for every commit and push.
- Commit or push only when asked.

## Image rules

- Every image is fully baked. All installation and every long source build happens during `docker build`. A user must never have to compile prerequisites after `docker run`.
- Every version is pinned in `.env`, the single source of truth, read by `docker compose`. Keep plain `KEY=VALUE` lines. Dockerfiles receive versions as build args declared in `docker-compose.yml`. Do not hardcode a version in a Dockerfile.
- Published image tags are a public interface. Folders, compose service names, and scripts may be reorganized; the `image:` values in `docker-compose.yml` may not change without being asked.
- Follow the `dockerfile-baseline` skill in `.claude/skills/dockerfile-baseline/` for every new Dockerfile and compose service: user `ubuntu` with the host UID, container stays alive, Miniconda opens with `(base)`.

## Layout

```
common/                   files used by two or more images
images/
  px4/                    ubicoders/px4:<PX4_TOOLCHAIN_VERSION>, from ubuntu
  ros2/                   lineage from osrf/ros
    base/                 ubicoders/ros2:jazzy
    px4/                  ubicoders/ros2:jazzy_px4
      uxrcedds/           ubicoders/ros2:jazzy_px4_uxrcedds
    svo/                  ubicoders/ros2:jazzy_svo
  cuda/                   lineage from nvidia/cuda
    base/                 ubicoders/ubuntu:u24_cuda12
    ocv_zed/              ubicoders/ubuntu:u24_cuda12_ocv_zed
    ros2/                 ubicoders/ros2:jazzy_cuda12
```

- Nesting mirrors `FROM`. Each lineage root holds `base/`; an image that builds on `base` is its sibling folder, and an image that builds on another child sits inside that child's folder (`px4/uxrcedds/`).
- The two ROS 2 lineages, `images/ros2/base` and `images/cuda/ros2`, do not share layers. A change meant for all ROS 2 images must be applied to both.
- A script or file used by one image lives beside that image's Dockerfile. One used by two or more images lives in `common/`. Do not add scripts to the repository root.
- Every build uses the repository root as context, so `COPY` sources are root-relative (`COPY common/requirements.txt ...`).
- ZED SDK installers are ignored by git and are kept in `images/cuda/ocv_zed/zed_sdk/`. Several may sit there; `ZED_SDK_INSTALLER` in `.env` selects the one the build uses.
- `build.bash` builds parents before children and then pushes, taking tags from `docker-compose.yml`. When adding an image, add its compose service and insert the service name in the `SERVICES` array after its parent.

## Python inside the images

Miniconda (`/miniconda`) is first on `PATH`, but `colcon` and the ROS 2 tooling run on the system interpreter (`/usr/bin/python3`). Install colcon plugins and other ROS build dependencies with `/usr/bin/python3 -m pip install --break-system-packages`, never with bare `pip`. `use_conda.bash` and `use_system_python.bash` switch the active interpreter inside a container.
