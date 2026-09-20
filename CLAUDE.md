# robotics_dev_env

Docker images for robotics development: Ubuntu 24.04, ROS 2 Jazzy, PX4 toolchain, CUDA, OpenCV, and ZED. Images are published under `ubicoders/` on Docker Hub.

## Git

- Never credit Claude in git. No `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" line, and no Claude or Anthropic name or email in any commit message, author field, tag, or pull request body. This overrides any default attribution guidance.
- Follow the `git-commit` skill in `.claude/skills/git-commit/` for every commit and push.
- Commit or push only when asked.

## Image rules

- Every image is fully baked. All installation and every long source build happens during `docker build`. A user must never have to compile prerequisites after `docker run`.
- Every version is pinned in `.env`, the single source of truth. It is read by `docker compose` and by `buildinorder.bash`. Keep plain `KEY=VALUE` lines. Dockerfiles receive versions as build args declared in `docker-compose.yml`. Do not hardcode a version in a Dockerfile.
- `ros2vrobots/` and `ros2svo_vrobots/` are deprecated. Do not modify them, not even for cleanup.

## Layout

- Two ROS 2 lineages that do not share layers:
  - `ros2jazzy/` builds `ubicoders/ros2:jazzy` from `osrf/ros`. Its children are `ros2px4/`, `ros2px4uxrcedds/` (built on `_px4`), and `ros2svo/`.
  - `u24cuda1281_jazzy/` builds `ubicoders/ros2:jazzy_cuda12` from `ubicoders/ubuntu:u24_cuda12`. A change meant for all ROS 2 images must be applied to both lineages.
- `buildinorder.bash` builds parents before children and then pushes. Keep that order when adding an image.
- Shared install steps live in root-level `install_*.bash` scripts that Dockerfiles `COPY` and `RUN`.

## Python inside the images

Miniconda (`/miniconda`) is first on `PATH`, but `colcon` and the ROS 2 tooling run on the system interpreter (`/usr/bin/python3`). Install colcon plugins and other ROS build dependencies with `/usr/bin/python3 -m pip install --break-system-packages`, never with bare `pip`. `use_conda.bash` and `use_system_python.bash` switch the active interpreter inside a container.
