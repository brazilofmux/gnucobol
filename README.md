# gnucobol

Docker/Podman build recipes for [GnuCOBOL](https://gnucobol.sourceforge.io/),
packaged as minimal Alpine-based container images. Separate versioned
directories exist for GnuCOBOL **3.0**, **3.1**, **3.2**, and **4.0**.

Each version produces three images:

| Image | Purpose |
| --- | --- |
| `gnucobol:<ver>-builder` | Full build toolchain (gcc, make, headers). Use to compile `.cob` sources with `cobc`. |
| `gnucobol:<ver>-runtime` | Minimal runtime. Contains `libcob`, `cobcrun`, and the libraries needed to execute programs built by the builder image. |
| `gnucobol:<ver>-hello`   | Multi-stage sample that compiles `test.cob` in the builder and runs it on the runtime. |

## Building the images

Either `podman` or `docker` works. From the repo root, build all images for
one version:

```sh
cd 4.0 && ./daily.sh
```

That script builds `builder`, `runtime`, and `hello` in order (each depends
on the previous). The top-level `daily.sh` drives the same for every
supported version.

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

- The 4.0 builder carries a small `sed` patch for a NULL-pointer bug in
  `libcob/common.c` (`cob_setup_env`); see `CLAUDE.md` for details.
- GnuCOBOL 4.0 is tracked from upstream development snapshots and the
  tarball in `4.0/builder/` is updated periodically.
- Released under the MIT License (see `LICENSE`).
