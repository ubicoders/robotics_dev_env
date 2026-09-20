#!/bin/bash
# Builds the images in dependency order, then pushes them.
#
# Usage: ./build.bash [--no-cache] [--no-push] [service ...]
#   --no-cache   rebuild every layer
#   --no-push    build only
#   service ...  limit the run to these compose services (default: all)
#
# Image tags and versions are not repeated here: docker compose takes them from
# docker-compose.yml and .env, for the build and for the push.

# Stop at the first failure so a child image is never built on, or pushed with, a stale parent.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Images that run as the ubuntu user take the host IDs. Bash does not export UID.
export HOST_UID="$(id -u)" HOST_GID="$(id -g)"

# Parents before children. Add a new image after its parent.
SERVICES=(
    px4

    ros2
    ros2_px4
    ros2_px4_uxrcedds
    ros2_svo

    cuda
    cuda_ocv_zed
    cuda_ros2
)

build_args=()
push=true
requested=()

for arg in "$@"; do
    case "${arg}" in
        --no-cache) build_args+=(--no-cache) ;;
        --no-push)  push=false ;;
        -h|--help)  sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)         echo "Unknown option: ${arg}" >&2; exit 2 ;;
        *)          requested+=("${arg}") ;;
    esac
done

# A requested subset is still walked in SERVICES order, whatever order it was given in.
selected=()
if [ "${#requested[@]}" -eq 0 ]; then
    selected=("${SERVICES[@]}")
else
    for name in "${requested[@]}"; do
        if [[ ! " ${SERVICES[*]} " =~ " ${name} " ]]; then
            echo "Unknown service: ${name}. Known services: ${SERVICES[*]}" >&2
            exit 2
        fi
    done
    for service in "${SERVICES[@]}"; do
        if [[ " ${requested[*]} " =~ " ${service} " ]]; then
            selected+=("${service}")
        fi
    done
fi

for service in "${selected[@]}"; do
    docker compose build "${build_args[@]}" "${service}"
done

# Push only after every build succeeded.
if [ "${push}" = true ]; then
    for service in "${selected[@]}"; do
        docker compose push "${service}"
    done
fi
