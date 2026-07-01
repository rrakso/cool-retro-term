#!/usr/bin/env bash
# Run the container-built cool-retro-term without installing Qt on the host,
# forwarding the display through WSLg (X11) and the GPU through /dev/dxg.
#
# Uses --network host so the --control-port server (bound to 127.0.0.1 inside
# the container) is reachable from host-side scripts on the same 127.0.0.1.
#
# Usage:
#   docker/run.sh [--control-port 9000] [extra cool-retro-term args...]
#   LIBGL_ALWAYS_SOFTWARE=1 docker/run.sh   # force software GL (llvmpipe)
set -euo pipefail

IMAGE=crt-build
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN=build-docker/cool-retro-term

if [[ ! -x "$REPO_ROOT/$BIN" ]]; then
    echo "Binary not found: $BIN (run docker/build.sh first)." >&2
    exit 1
fi

# Pass through a software-GL request if the caller set it.
SOFTWARE_GL_ENV=()
if [[ "${LIBGL_ALWAYS_SOFTWARE:-}" == "1" ]]; then
    SOFTWARE_GL_ENV=(-e LIBGL_ALWAYS_SOFTWARE=1)
fi

exec docker run --rm -i \
    --network host \
    --device /dev/dxg \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /usr/lib/wsl:/usr/lib/wsl \
    -v "$REPO_ROOT":/src -w /src \
    -e DISPLAY="${DISPLAY:-:0}" \
    -e QT_QPA_PLATFORM=xcb \
    -e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
    "${SOFTWARE_GL_ENV[@]}" \
    "$IMAGE" \
    "$BIN" "$@"
