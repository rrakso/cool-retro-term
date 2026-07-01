# cool-retro-term

|> Default Amber|C:\ IBM DOS|$ Default Green|
|---|---|---|
|![Default Amber Cool Retro Term](https://user-images.githubusercontent.com/121322/32070717-16708784-ba42-11e7-8572-a8fcc10d7f7d.gif)|![IBM DOS](https://user-images.githubusercontent.com/121322/32070716-16567e5c-ba42-11e7-9e64-ba96dfe9b64d.gif)|![Default Green Cool Retro Term](https://user-images.githubusercontent.com/121322/32070715-163a1c94-ba42-11e7-80bb-41fbf10fc634.gif)|

## Description
cool-retro-term is a terminal emulator which mimics the look and feel of the old cathode tube screens.
It has been designed to be eye-candy, customizable, and reasonably lightweight.

It uses the QML port of qtermwidget (Konsole): https://github.com/Swordfish90/qmltermwidget.

This terminal emulator works under Linux and macOS and requires Qt6.

Settings such as colors, fonts, and effects can be accessed via context menu.

## Realtime control (scripting)

cool-retro-term can expose a small TCP control server to tweak render
parameters live from an external script. It is **disabled by default** and
**binds to `127.0.0.1` only**. Enable it with a port:

```text
cool-retro-term --control-port 9000
```

The protocol is newline-terminated plain text (values normalized `0.0` to `1.0`):

```text
set <param> <value>    # apply live, e.g. set burnIn 0.6
get <param>            # returns the current value
list                   # lists controllable parameters
save                   # persist the current live state to the profile
reload                 # reload the saved profile, discarding live changes
```

Controllable parameters include: `contrast`, `brightness`, `ambientLight`,
`opacity`, `staticNoise`, `screenCurvature`, `glowingLine`, `burnIn`, `bloom`,
`chromaColor`, `saturationColor`, `jitter`, `horizontalSync`, `flickering`,
`rgbShift`, `frameGloss`, `frameSize`, `screenRadius`, `margin`.

`set` changes apply instantly but are lost on restart; run `save` to persist
the current state to the profile, exactly like the settings menu does. A
ready-to-use Python client (standard library only) lives in
[`scripts/crt_control.py`](scripts/crt_control.py):

```bash
python3 scripts/crt_control.py set burnIn 0.6
python3 scripts/crt_control.py save
python3 scripts/crt_control.py list
```

## Screenshots
![Image](<https://i.imgur.com/TNumkDn.png>)
![Image](<https://i.imgur.com/hfjWOM4.png>)
![Image](<https://i.imgur.com/GYRDPzJ.jpg>)

## Install

If you want to get a hold of the latest version, just go to the Releases page and grab the latest AppImage (Linux) or dmg (macOS).

Alternatively, most distributions such as Ubuntu, Fedora or Arch already package cool-retro-term in their official repositories.

## Building

Check out the wiki and follow the instructions on how to build it on [Linux](https://github.com/Swordfish90/cool-retro-term/wiki/Build-Instructions-(Linux)) and [macOS](https://github.com/Swordfish90/cool-retro-term/wiki/Build-Instructions-(macOS)).

Note that the current `qmltermwidget` submodule requires **Qt 6.5+**
(it uses `QRegularExpression::matchView`). Distros that still ship Qt 6.4,
namely Ubuntu 24.04, Debian 12 "Bookworm", and the Bookworm-based Raspberry Pi
OS, will fail to build with a `matchView` error. Use Qt 6.5 or newer.

### Building in Docker (no host Qt install)

To compile without installing Qt on the host, use the provided toolchain image:

```bash
docker/build.sh          # builds the Qt6 image on first run, then compiles
```

The result lands in `build-docker/cool-retro-term`. The image is based on
Ubuntu 25.04 (Qt 6.8). See [`docker/Dockerfile`](docker/Dockerfile).

The container-built binary links against the container's Qt, so it will not run
directly on a host without Qt. On **WSL2 (WSLg)** you can run it straight from
the container; the display and GPU are forwarded automatically:

```bash
docker/run.sh --control-port 9000
```

`docker/run.sh` uses `--network host`, so the control server is reachable from
host-side scripts at `127.0.0.1:9000`. Set `LIBGL_ALWAYS_SOFTWARE=1` to fall
back to software rendering if GPU passthrough misbehaves.

### Running on a Raspberry Pi (native, no Docker)

For a Pi, build natively; Docker is unnecessary overhead there. The catch is
the Qt version: **Raspberry Pi OS Bookworm ships Qt 6.4.2, which is too old**
(same `matchView` failure). Use the **Trixie-based Raspberry Pi OS (Debian 13,
2025), which ships Qt 6.8.2**, on a 64-bit (arm64) image:

```bash
sudo apt update
sudo apt install git build-essential qmake6 qt6-base-dev qt6-base-dev-tools \
    qt6-declarative-dev qt6-declarative-dev-tools qt6-shader-baker \
    qml6-module-qt5compat-graphicaleffects libqt6sql6-sqlite

git clone --recursive <your-fork-url>
cd cool-retro-term
mkdir build && cd build && qmake6 .. && make -j"$(nproc)"
./app/cool-retro-term --control-port 9000
```

Notes:

- On Debian the shader baker `qsb` comes from the `qt6-shader-baker` package
  (installed to `/usr/lib/qt6/bin/qsb`, which qmake's `QT_HOST_BINS` resolves
  to), not from `qt6-shadertools`.
- `qml6-module-qt5compat-graphicaleffects` and `libqt6sql6-sqlite` are the two
  runtime pieces most easily missed: without the first the UI fails to load
  (`module "Qt5Compat.GraphicalEffects" is not installed`), without the second
  settings can't be saved (`QSQLITE driver not loaded`).
- The distro/snap-store `cool-retro-term` is upstream's Qt5 build (v1.1.1), so
  it will **not** contain this fork's control server, so build from source.
