"""Build production HTML without modifying Typsite's owned raw outputs.

Run from the project root: python3 scripts/build.py [--typsite /path/to/typsite]
Preview/watch raw HTML with Typsite directly; serve publish/ for lazy-embed testing.
"""
import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def build(project: Path, typsite: str):
    project = project.resolve()
    cache = project / ".cache"
    output = project / "publish"
    # These paths are generated-only. Never follow a replacement directory link.
    for directory in (cache, output):
        if directory.is_symlink():
            raise ValueError(f"Refusing symlinked build directory: {directory}")
    cache.mkdir(exist_ok=True)
    subprocess.run([
        typsite, "compile", "--packages", "packages",
        "--cache", ".cache/typsite", "--output", ".cache/site",
    ], cwd=project, check=True)
    # Postprocessing is destructive. Work on a fresh copy, never the ownership-
    # journaled output. Replacing the deployment tree also drops obsolete fragments.
    with tempfile.TemporaryDirectory(prefix="deploy-", dir=cache) as temporary:
        staging = Path(temporary) / "site"
        shutil.copytree(cache / "site", staging, ignore=shutil.ignore_patterns(
            ".typsite.lock", ".typsite-outputs.json",
        ))
        for script in ("cache-bust.py", "lazy-embeds.py"):
            subprocess.run([
                sys.executable, str(project / ".github/scripts" / script), str(staging),
            ], cwd=project, check=True)
        backup = Path(temporary) / "previous"
        if output.exists():
            output.rename(backup)
        try:
            staging.rename(output)
        except OSError:
            if backup.exists():
                backup.rename(output)
            raise
    print(f"Production site ready: {output}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typsite", default="typsite")
    args = parser.parse_args()
    # Resolve relative executable paths before invoking any subprocesses.
    binary = str(Path(args.typsite).absolute()) if "/" in args.typsite else args.typsite
    build(Path.cwd(), binary)


if __name__ == "__main__":
    main()
