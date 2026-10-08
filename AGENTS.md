# Repository Guidelines

## Project Structure & Module Organization
This repository wraps multiple GnuCOBOL releases as container builds.

- `3.1/`, `3.2/`, `3.3/`, `4.0/`: one container stack per GnuCOBOL line, each with `builder/`, `runtime/`, `hello/`. The directory name is the line's tag; its pinned tag is in `runtime/Dockerfile`.
- `*/builder/Dockerfile`: builds the compiler image from the packaged source tarball.
- `*/runtime/Dockerfile`: trims the runtime dependencies for compiled COBOL programs.
- `*/hello/test.cob`: minimal smoke-test program used by the hello image.
- `daily.sh`: builds any line locally, the way the fleet job in `~/builder` does. `update.sh` is superseded (see `CLAUDE.md`).

## Build, Test, and Development Commands

- `./daily.sh 4.0`: build `gnucobol:4.0-builder`, `-runtime` and `-hello` (and the pinned `4.0-r5725-*`); `./daily.sh` alone builds every line.
- `cd 4.0/builder && podman build -t gnucobol:4.0-builder .`: rebuild one image while iterating on a Dockerfile.
- `cd 4.0/hello && podman build -t gnucobol:4.0-hello .`: rebuild the smoke-test image after editing `test.cob`.
- `cd 4.0/runtime && podman build -t gnucobol:4.0-runtime .`: validate runtime-layer changes in isolation.

## Coding Style & Naming Conventions
Follow the style already in the tree.

- Use 4-space indentation in shell scripts and keep loops/simple command sequences compact.
- Preserve the existing split between `builder`, `runtime`, and `hello` under each version directory.
- Keep COBOL examples minimal and readable; the current `test.cob` files use classic uppercase COBOL formatting.
- Prefer small, targeted edits and keep version-specific changes isolated to the matching directory.

## Testing Guidelines
There is no separate test framework in this repository; validation is build-based.

- Rebuild the affected line with `./daily.sh <line>` after changing its Dockerfiles.
- Rebuild the specific `hello` image if you change a sample program or compiler flags.
- Treat a clean `podman build` and a working hello image as the minimum acceptance bar.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects such as `Fix build again` and `Add update.sh`.

- Keep commit titles brief, specific, and action-oriented.
- In pull requests, describe the affected version or library, list the commands you ran, and note any tarball or patch updates.
- Include container output or error snippets when changing build infrastructure; screenshots are unnecessary for this repository.
