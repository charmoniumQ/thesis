#!/usr/bin/env python3
import json
import os
import pathlib
import shutil
import subprocess
import typer

ROOT = pathlib.Path(__file__).parent
BUILD = ROOT / ".build"

STEM = "main"
PDF = BUILD / f"{STEM}.typ.pdf"
DEPS_OLD = BUILD / f"{STEM}.typ.deps.old.json"
DEPS_NEW = BUILD / f"{STEM}.typ.deps.new.json"


def run_shake() -> None:
    subprocess.run(["shake", PDF], cwd=ROOT, check=True)


def read_inputs(path: pathlib.Path) -> list[str]:
    return sorted(json.loads(path.read_bytes())["inputs"])


def initialize() -> None:
    BUILD.mkdir(exist_ok=True)
    if not DEPS_OLD.exists():
        DEPS_OLD.write_text(json.dumps({"inputs": [], "outputs": []}))


def main() -> int:
    initialize()

    run_shake()
    old_inputs = read_inputs(DEPS_OLD)
    new_inputs = read_inputs(DEPS_NEW)

    if new_inputs != old_inputs:
        shutil.copy2(os.path.join(ROOT, DEPS_NEW), os.path.join(ROOT, DEPS_OLD))

    introduced = set(new_inputs) - set(old_inputs)
    if introduced:
        run_shake()

    return 0


if __name__ == "__main__":
    typer.run(main)
