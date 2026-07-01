#!/usr/bin/env python3
"""Realtime control client for cool-retro-term.

Start the terminal with a control port, e.g.:

    cool-retro-term --control-port 9000

Then drive render parameters live over a plain TCP line protocol (no external
dependencies, just the standard library). Values are normalized 0.0..1.0.

Protocol:
    set <param> <value>   set a parameter live (clamped to 0.0..1.0)
    get <param>           read a parameter's current value
    list                  list controllable parameters
    save                  persist the current live state to the profile
    reload                reload the saved profile, discarding live changes

Live "set" changes are lost on restart; run "save" to persist them.

Examples:
    python3 crt_control.py set burnIn 0.6
    python3 crt_control.py save
    python3 crt_control.py list

    # Or as a library, for animations:
    from crt_control import CRTControl
    import math, time
    with CRTControl(port=9000) as crt:
        t = 0.0
        while True:
            crt.set("burnIn", 0.5 + 0.5 * math.sin(t))
            t += 0.1
            time.sleep(0.03)
"""

import argparse
import socket
import sys


class CRTControl:
    def __init__(self, host="127.0.0.1", port=9000, timeout=2.0):
        self._sock = socket.create_connection((host, port), timeout=timeout)
        self._file = self._sock.makefile("r", encoding="utf-8")

    def _command(self, line):
        self._sock.sendall((line + "\n").encode("utf-8"))
        return self._file.readline().strip()

    def set(self, param, value):
        return self._command(f"set {param} {value}")

    def get(self, param):
        return self._command(f"get {param}")

    def list(self):
        return self._command("list")

    def save(self):
        return self._command("save")

    def reload(self):
        return self._command("reload")

    def close(self):
        self._file.close()
        self._sock.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=9000)
    parser.add_argument(
        "command", choices=["set", "get", "list", "save", "reload"]
    )
    parser.add_argument("param", nargs="?")
    parser.add_argument("value", nargs="?")
    args = parser.parse_args(argv)

    with CRTControl(host=args.host, port=args.port) as crt:
        if args.command == "list":
            print(crt.list())
        elif args.command == "save":
            print(crt.save())
        elif args.command == "reload":
            print(crt.reload())
        elif args.command == "get":
            if not args.param:
                parser.error("get requires a parameter name")
            print(crt.get(args.param))
        elif args.command == "set":
            if not args.param or args.value is None:
                parser.error("set requires a parameter name and a value")
            print(crt.set(args.param, args.value))
    return 0


if __name__ == "__main__":
    sys.exit(main())
