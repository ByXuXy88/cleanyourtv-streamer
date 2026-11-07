"""Prepare the exact upstream source tree used by this extension."""

import argparse
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parent
UPSTREAM = "https://github.com/Gathin23/cleanyourtv.git"
TAG = "v3.4.0"
BASE = "fc148d5a9707b30e8f49f489625947421740dc55"
PATCH = ROOT / "cleanyourtv-v3.4.0.patch"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, default=ROOT / "upstream")
    args = parser.parse_args()
    target = args.directory.resolve()
    if target.exists():
        parser.error(f"Choose a new directory. Already exists: {target}")
    subprocess.run(
        ["git", "clone", "--depth", "1", "--single-branch", "--branch", TAG, UPSTREAM, str(target)],
        check=True,
    )
    commit = subprocess.check_output(["git", "-C", str(target), "rev-parse", "HEAD"], text=True).strip()
    if commit != BASE:
        parser.error(f"Upstream commit changed. Expected {BASE}, got {commit}.")
    subprocess.run(["git", "-C", str(target), "apply", "--check", str(PATCH)], check=True)
    subprocess.run(["git", "-C", str(target), "apply", str(PATCH)], check=True)
    print(f"Source ready in {target / 'launcher'}")


if __name__ == "__main__":
    main()
