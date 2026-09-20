---
name: dockerfile-baseline
description: |
  Baseline every Dockerfile and compose service must meet: the container user is
  `ubuntu` with the host's UID and GID, the container stays alive for
  `docker exec` and VS Code attach (tty, stdin_open, privileged), and an image
  with Miniconda opens every new terminal with `(base)` already active, without
  `source ~/.bashrc`, and a ROS 2 image sources `/opt/ros/<distro>/setup.bash`
  in the `ubuntu` `.bashrc` so `ros2` works in every new terminal. Use whenever creating or editing a Dockerfile, adding a
  compose service, or adding an image. Keywords: Dockerfile, docker compose,
  new image, user, ubuntu, UID, GID, host user, permissions, root, sudo, tty,
  stdin_open, privileged, container exits, keep alive, attach, VS Code, dev
  container, miniconda, conda, base, bashrc, conda init, ROS 2, ros2, jazzy,
  setup.bash, source, /opt/ros, ros2 command not found
user-invocable: true
---

# Dockerfile baseline

Apply all five sections to every new Dockerfile. When editing an existing
Dockerfile that does not yet meet them, say so and ask before converting it.

## 1. User `ubuntu`, host UID and GID

The container runs as `ubuntu`, never as root, and its UID and GID equal those
of the host user who builds the image. Files written to bind mounts are then
owned by the host user.

Ubuntu 24.04 bases (`ubuntu`, `osrf/ros`, `nvidia/cuda`) already ship `ubuntu`
at 1000:1000, so the user is renumbered, not created. The `else` branch covers
bases without it.

```dockerfile
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN if id ubuntu >/dev/null 2>&1; then \
      groupmod -g ${HOST_GID} ubuntu && usermod -u ${HOST_UID} -g ${HOST_GID} ubuntu; \
    else \
      groupadd -g ${HOST_GID} ubuntu && \
      useradd -m -s /bin/bash -u ${HOST_UID} -g ${HOST_GID} ubuntu; \
    fi && \
    chown -R ubuntu:ubuntu /home/ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu
```

- Install `sudo` with the other apt packages, before this block.
- Do all root work (apt, `/opt`, `/usr/local`) first. Then set `USER ubuntu` and
  `WORKDIR /home/ubuntu` and do not switch back to root at the end of the file.
- A child image inherits `USER ubuntu`. For root steps use `USER root`, then
  restore `USER ubuntu`.
- Write shell setup to `/home/ubuntu/.bashrc`, never `/root/.bashrc`.
- Compose passes the IDs as build args:

  ```yaml
  args:
    HOST_UID: ${HOST_UID:-1000}
    HOST_GID: ${HOST_GID:-1000}
  ```

- Bash does not export `UID`, so compose cannot read it. The build entry point
  exports the values: `export HOST_UID=$(id -u) HOST_GID=$(id -g)`. Do not put
  them in `.env`, which is committed and holds versions only.
- A published image carries the IDs of the machine that built it (1000:1000 by
  default). A host with different IDs rebuilds locally.
- Mounts that target a home directory use `/home/ubuntu`, for example
  `$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw`.

## 2. Container stays alive

The container must keep running after start so that `docker exec` and VS Code
"Attach to Running Container" work.

- End the Dockerfile with `CMD ["/bin/bash"]`. Do not add an `ENTRYPOINT` or
  `CMD` that runs a task and exits.
- Every compose service merges the shared anchor, which already sets the
  defaults below. Do not repeat them per service, and do not remove them.

  ```yaml
  x-default-configuration: &default-configuration
    privileged: true
    stdin_open: true # docker run -i
    tty: true        # docker run -t
  ```

- Without compose, the equivalent is `docker run -it --privileged`.

## 3. Miniconda opens with `(base)`

Applies only to images that install Miniconda. A new terminal, including one
opened by VS Code in an attached container, must show `(base)` with no manual
`source ~/.bashrc`.

```dockerfile
ENV CONDA_DIR=/miniconda
ENV PATH=${CONDA_DIR}/bin:${PATH}
RUN mkdir -p ${CONDA_DIR} && chown ubuntu:ubuntu ${CONDA_DIR}

USER ubuntu
WORKDIR /home/ubuntu
ARG MINICONDA_INSTALLER
RUN curl -fsSL "https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}" -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda config --system --set changeps1 true && \
    conda init bash
```

- Run `conda init bash` as `ubuntu`, after `USER ubuntu`. Run as root, it writes
  `/root/.bashrc` and the `ubuntu` shell never activates conda.
- Install as `ubuntu` into a directory `ubuntu` owns (`-u` permits the existing
  directory). This avoids a recursive `chown` layer and lets `pip` and `conda
  install` work without sudo.
- Use `conda config --system` so the setting lands in `/miniconda/.condarc`
  rather than a per-user file.
- Never set `changeps1 false` or disable base auto-activation.
- To open in another environment, append `conda activate <env>` to
  `/home/ubuntu/.bashrc` after `conda init`.
- `MINICONDA_INSTALLER` is pinned in `.env`, per the image rules in `CLAUDE.md`.

## 4. ROS 2 images source the ROS environment

Applies only to images that contain ROS 2. A new terminal must have `ros2`,
`colcon`, and the ROS environment variables available with no manual `source`.

```dockerfile
USER ubuntu
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/ubuntu/.bashrc
```

- Use `${ROS_DISTRO}`, never a literal distro name. `osrf/ros` bases export it;
  on other bases declare `ARG ROS_DISTRO` and `ENV ROS_DISTRO=${ROS_DISTRO}`,
  with the value pinned in `.env`.
- Write to the `.bashrc` of the container user, `/home/ubuntu/.bashrc`, never
  `/root/.bashrc`.
- Do this once, in the lineage root (`images/ros2/base`, `images/cuda/ros2`).
  Children inherit the line and must not append it again.
- An image that builds an extra workspace or overlay appends its own
  `setup.bash` after the ROS line, for example
  `source /opt/ros2_rust/setup.bash`. Underlay first, overlays after.
- `.bashrc` is read by interactive shells only. A `RUN` step that needs ROS
  sources it explicitly: `RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build`.

## 5. Verify before reporting done

Build, then run:

```bash
docker run --rm -t <image> bash -ic 'id; echo "$CONDA_DEFAULT_ENV"; sudo -n true && echo sudo_ok; echo "$ROS_DISTRO"; command -v ros2'
```

Expected: `uid=<host uid>(ubuntu) gid=<host gid>(ubuntu)`, `base` (Miniconda
images only), `sudo_ok`, and the distro name with `/opt/ros/<distro>/bin/ros2`
(ROS 2 images only). Then `docker compose up -d <service>` and confirm
with `docker ps` that the container is still running.
