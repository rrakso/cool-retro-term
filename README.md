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
