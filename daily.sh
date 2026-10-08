#!/bin/bash
# Build GnuCOBOL images locally, the way ~/builder's jobs/gnucobol.sh does on
# the fleet: builder -> runtime -> hello, tagged under the line's PINNED tag
# (read from <line>/runtime/Dockerfile) and its MOVING tag (the directory name).
#
#   ./daily.sh              all lines: 3.1 3.2 3.3 4.0
#   ./daily.sh 4.0          one line
#   REP=<registry> ./daily.sh 3.3   also tag each image for that registry
#
# The fleet build is the one that publishes; this is for iterating locally.
set -euo pipefail

if command -v podman >/dev/null 2>&1; then E=podman
elif command -v docker >/dev/null 2>&1; then E=docker
else echo "Neither podman nor docker is installed." >&2; exit 1; fi

cd "$(dirname "$0")"
[ $# -gt 0 ] || set -- 3.1 3.2 3.3 4.0

for line in "$@"; do
    [ -f "$line/runtime/Dockerfile" ] || { echo "no such line: $line" >&2; exit 1; }
    pin=$(grep -oE 'gnucobol:[^ ]+-builder' "$line/runtime/Dockerfile" | head -1 | sed -E 's/^gnucobol:(.+)-builder$/\1/')
    case "$pin" in
        "$line"?*) ;;
        *) echo "$line pins '$pin', which is not a more specific $line" >&2; exit 1 ;;
    esac
    echo "=== $line: gnucobol:$pin-* and gnucobol:$line-* ==="
    for v in builder runtime hello; do
        (cd "$line/$v" && "$E" build -t "gnucobol:$pin-$v" .)
        "$E" tag "gnucobol:$pin-$v" "gnucobol:$line-$v"
        if [ -n "${REP:-}" ]; then
            "$E" tag "gnucobol:$pin-$v" "$REP/gnucobol:$pin-$v"
            "$E" tag "gnucobol:$pin-$v" "$REP/gnucobol:$line-$v"
        fi
    done
    "$E" run --rm "gnucobol:$pin-hello"
done
