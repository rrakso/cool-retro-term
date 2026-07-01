# Build toolchain image for cool-retro-term (Qt6).
# Contains only the compiler + Qt6 dev packages; the source tree is expected to
# be bind-mounted at build time so rebuilds are fast and artifacts stay out of
# the repo. See docker/build.sh.
# Ubuntu 24.04 ships Qt 6.4, but the qmltermwidget submodule uses
# QRegularExpression::matchView (Qt 6.5+), so a newer base is required.
FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pkg-config \
        qt6-base-dev \
        qt6-base-dev-tools \
        qt6-declarative-dev \
        qt6-declarative-dev-tools \
        qt6-shadertools-dev \
        libqt6opengl6-dev \
        libgl1-mesa-dev \
        libglvnd-dev \
    && rm -rf /var/lib/apt/lists/*

# Runtime bits so the built binary can also be *run* from the container,
# forwarding the display via WSLg (X11); no Qt install needed on the host.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-dri \
        libglx-mesa0 \
        libqt6sql6-sqlite \
        qml6-module-qt5compat-graphicaleffects \
        libxcb-cursor0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-util1 \
        libxcb-xinerama0 \
        libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
