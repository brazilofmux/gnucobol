# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Container build recipes for GnuCOBOL, and for gcobol (GCC's COBOL front end), on Alpine. The GnuCOBOL images serve as **oracles** for `~/slow-32`'s COBOL compiler, and are published to Docker Hub as `hurriedreformist/gnucobol`. The fleet in `~/builder` builds them (`jobs/gnucobol.sh`, `jobs/gcobol.sh`); this repository holds what they build from.

## Repository Structure

```
gnucobol/
├── 3.1/   GNU release 3.1.2             -> gnucobol:3.1.2-*      and gnucobol:3.1-*
├── 3.2/   GNU release 3.2               -> gnucobol:3.2.0-*      and gnucobol:3.2-*
├── 3.3/   branches/gnucobol-3.x r5729   -> gnucobol:3.3-r5729-*  and gnucobol:3.3-*
├── 4.0/   trunk r5725                   -> gnucobol:4.0-r5725-*  and gnucobol:4.0-*
│   ├── builder/   Dockerfile + the vendored source tarball
│   ├── runtime/   libcob, cobcrun, and the runtime libraries
│   └── hello/     test.cob, compiled in builder and run on runtime
├── gcobol/15, gcobol/17   gcobol oracles (17 is amd64-only; see its Dockerfile)
├── daily.sh   local build of any line, as the fleet job does it
└── update.sh  moves a development line's pin (3.3, 4.0) -- see below
```

The directory name is the line's **moving** tag. Each line's **pinned** tag is written in its `runtime/Dockerfile` (`COPY --from=gnucobol:<pinned>-builder`) and `hello/Dockerfile`; `daily.sh` and the fleet job both read it from there. A pinned tag names exactly one build -- a GNU release padded to three components, or a development line's SVN revision -- and the fleet job never rebuilds a pin that is already in ECR. To move a line forward, change its pin.

## Provenance

Every builder records what it was built from in `/usr/local/share/gnucobol/SOURCE` and in OCI labels.

- **3.1, 3.2**: the GNU release tarballs, byte-identical to ftp.gnu.org's and signed by Simon Sobisch (key B9459D0CA8A740B323235CDF13E96B53C005604E, in the GNU keyring; verified 2026-10-08). Each Dockerfile checks the tarball's sha256.
- **3.3, 4.0**: a `git archive` of the OCamlPro GitHub mirror's commit for the pinned SVN revision (r5729 = 91d1bd5ac4, r5725 = 72ab9a7518, matched against `svn log`). Pristine source, built with bootstrap, because `make dist` requires a TeX installation for the PDF manual.

## Changes made to GnuCOBOL's source

Only one changes behaviour, and only on 4.0 (trunk): `libcob/common.c`'s exec-path detection does `p = strrchr (binpath, ...)` and then `memcmp (p+1, "bin", 3)` with no check that `p` is not NULL. Still present at r5725. Fixed by making it `if (p && (memcmp (p+1, "bin", 3) == 0 ... ))`. 3.x has no such code.

The rest are build fixes for today's toolchain, not behaviour:

- `#include <libxml/parser.h>` (3.1, 3.2): libxml2 >= 2.12 stopped pulling it in through its other headers.
- `-Wno-incompatible-pointer-types` (all): `libcob/mlio.c`'s libxml2 error callbacks are typed for the pre-2.12 API, which GCC >= 14 refuses by default.
- `AWK=gawk` (3.3, 4.0): `doc/cobcinfo.sh`'s regex `\$@{envvar:-?default@}` is rejected by BusyBox awk.

**Every patch matches text, never a line number, and the build fails unless its anchor is found exactly once.** The earlier Dockerfiles patched by line number; 3.1's copied 3.2's line 138, which in 3.1.2 is outside the libxml block. A moved line must stop the build, not turn a fix into a silent no-op.

## Build Commands

```bash
./daily.sh            # all four lines, locally (podman or docker)
./daily.sh 4.0        # one line
podman run --rm gnucobol:4.0-hello      # Hello, World!
```

Every image is `FROM alpine:3.24.2` -- pinned to the version the published images were built on, so a rebuild is the same build.

## Moving a pin: update.sh

`./update.sh --check` compares each development line's pin with its branch and changes nothing. `./update.sh 4.0` (or `./update.sh 3.3 5731`) moves that line: it `svn export`s the revision (normalised to the branch's last change at or before it), checks `configure.ac` declares the line's version, checks the NULL-guard anchors when the builder carries that patch, gives every file the revision's commit time (as `git archive` does; mixed svn-export mtimes make the build regenerate `po/` and fail a gettext version check), tars it, and rewrites the builder's ARG lines and the pinned tags in `runtime/` and `hello/`. The result is staged, not committed; build it with `./daily.sh <line>` before committing. It refuses 3.1 and 3.2 (GNU releases) and a line with uncommitted changes.

Not every revision builds: branches/gnucobol-3.x r5724 calls libxml2 2.14's `xmlCtxtGetOptions` behind a `>= 2.12` guard, fixed in r5726.

## GnuCOBOL Compilation Model

GnuCOBOL translates COBOL to C and compiles that with the system C compiler, which is why the builder image carries gcc.
