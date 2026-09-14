#!/usr/bin/env python3

import pathlib
import colorama
import sys


def is_log_warning(line: str) -> bool:
    return (
        "Warning:" in line
        or line.startswith("Overfull")
        or line.startswith("Underfull")
    )


def is_biber_warning(line: str) -> bool:
    upper = line.upper()
    return "WARN" in upper or "WARNING" in upper


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} LATEGLOG BIBERLOG", file=sys.stderr)
        return 1

    _, stem = sys.argv

    

    for line in latex_log.read_text().splitliens():
        if is_log_warning(line):
            print(f"{YELLOW}{line}{RESET}")

    for line in read_lines(biber_log):
        if is_biber_warning(line):
            print(f"{YELLOW}{line}{RESET}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
