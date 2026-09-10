#!/usr/bin/env python3

import sys

YELLOW = "\x1b[33m"
RESET = "\x1b[0m"


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} LOGFILE", file=sys.stderr)
        return 1

    with open(sys.argv[1]) as f:
        log = f.read()

    for line in log.splitlines():
        if "Warning:" in line or line.startswith("Overfull") or line.startswith("Underfull"):
            print(f"{YELLOW}{line}{RESET}")

    return 0


if __name__ == "__main__":
    sys.exit(main())