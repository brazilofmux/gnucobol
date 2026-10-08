# gnucobol

Docker/Podman build recipes for [GnuCOBOL](https://gnucobol.sourceforge.io/),
packaged as minimal Alpine-based container images, published as
`hurriedreformist/gnucobol` on Docker Hub. Four lines:

| Directory | GnuCOBOL | Tags |
| --- | --- | --- |
| `3.1/` | release 3.1.2 | `3.1-*`, pinned `3.1.2-*` |
| `3.2/` | release 3.2 | `3.2-*`, pinned `3.2.0-*` |
| `3.3/` | 3.3-dev, branches/gnucobol-3.x r5729 | `3.3-*`, pinned `3.3-r5729-*` |
| `4.0/` | 4.0-early-dev, trunk r5725 | `4.0-*`, pinned `4.0-r5725-*` |

The short tag follows its line; the pinned tag never changes what it names.

Each version produces three images:

| Image | Purpose |
| --- | --- |
| `gnucobol:<ver>-builder` | Full build toolchain (gcc, make, headers). Use to compile `.cob` sources with `cobc`. |
| `gnucobol:<ver>-runtime` | Minimal runtime. Contains `libcob`, `cobcrun`, and the libraries needed to execute programs built by the builder image. |
| `gnucobol:<ver>-hello`   | Multi-stage sample that compiles `test.cob` in the builder and runs it on the runtime. |

## Building the images

Either `podman` or `docker` works. From the repo root:

```sh
./daily.sh          # every line
./daily.sh 4.0      # one line
```

It builds `builder`, `runtime`, and `hello` in order (each depends on the
previous), under both the line's tag and its pinned tag. The published images
are built by the fleet in `~/builder`; this is for building locally.

To build a single image directly:

```sh
cd 4.0/builder && podman build -t gnucobol:4.0-builder .
```

## Running the sample

After building:

```sh
podman run --rm gnucobol:4.0-hello
# Hello, World!
```

## Compiling your own COBOL program

Mount a directory containing your sources into the builder, compile, then
run the resulting binary on the runtime image.

```sh
# Compile program.cob to an executable named `program`
podman run --rm -v "$PWD":/src -w /src gnucobol:4.0-builder \
    cobc -x program.cob

# Execute it on the minimal runtime
podman run --rm -v "$PWD":/src -w /src gnucobol:4.0-runtime ./program
```

For a module (callable from `cobcrun`) instead of a standalone executable:

```sh
podman run --rm -v "$PWD":/src -w /src gnucobol:4.0-builder \
    cobc -m program.cob
podman run --rm -v "$PWD":/src -w /src gnucobol:4.0-runtime \
    cobcrun program
```

### Packaging your program as an image

Mirror the pattern in `4.0/hello/Dockerfile`:

```dockerfile
FROM gnucobol:4.0-builder AS builder
WORKDIR /src
COPY program.cob .
RUN cobc -x program.cob

FROM gnucobol:4.0-runtime
COPY --from=builder /src/program .
CMD ["./program"]
```

## Notes

- The 4.0 builder fixes a NULL-pointer dereference in `libcob/common.c`,
  still present in trunk; the other builders carry only build fixes for
  today's toolchain. `CLAUDE.md` lists them all.
- Each image records exactly what it was built from in
  `/usr/local/share/gnucobol/SOURCE`.
- Released under the MIT License (see `LICENSE`).
