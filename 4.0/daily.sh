if command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE=podman
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE=docker
else
    echo "Neither podman nor docker is installed." >&2
    exit 1
fi

for i in builder runtime hello
do
    (cd "$i"; "$CONTAINER_ENGINE" build -t "gnucobol:4.0-$i" .)
    if [ -n "${REP:-}" ]; then
        "$CONTAINER_ENGINE" tag "gnucobol:4.0-$i" "$REP/gnucobol:4.0-$i"
    fi
done
