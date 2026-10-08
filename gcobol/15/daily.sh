#!/bin/sh
# builds gcobol:15 (compile and run in one image)
if command -v podman >/dev/null 2>&1; then E=podman; elif command -v docker >/dev/null 2>&1; then E=docker; else echo "no podman or docker" >&2; exit 1; fi
cd "$(dirname "$0")" && "$E" build -t gcobol:15 .
