#!/usr/bin/env bash
# Build cool-retro-term inside the Qt6 toolchain container, without installing
# Qt on the host. Produces an out-of-source build in ./build-docker and runs as
# the current user so artifacts are not left root-owned.
#
# Usage:
#   docker/build.sh            # build the image if needed, then compile
#   docker/build.sh --rebuild  # force a fresh image build first
set -euo pipefail

IMAGE=crt-build
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${1:-}" == "--rebuild" ]] || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    docker build -t "$IMAGE" -f "$REPO_ROOT/docker/Dockerfile" "$REPO_ROOT/docker"
fi

docker run --rm \
    -v "$REPO_ROOT":/src -w /src \
    --user "$(id -u):$(id -g)" \
    "$IMAGE" bash -c '
        set -e
        mkdir -p build-docker && cd build-docker
        qmake6 ../cool-retro-term.pro
        make -j"$(nproc)"
    '

echo "Build complete: $REPO_ROOT/build-docker/cool-retro-term"
