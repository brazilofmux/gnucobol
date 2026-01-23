# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker containerization wrapper for GnuCOBOL (GNU COBOL compiler). It maintains build and deployment configurations for multiple GnuCOBOL versions (3.0, 3.1, 3.2, 4.0) as Docker containers, with actual GnuCOBOL source distributed as tarballs.

## Repository Structure

```
gnucobol/
├── 3.0/, 3.1/, 3.2/, 4.0/  # Version-specific directories
│   ├── builder/             # Docker build env with Dockerfile and tarball
│   ├── hello/               # Test program container
│   ├── runtime/             # Runtime container
│   └── daily.sh             # Version build script
├── csv/                      # CSV utilities for COBOL (C + COBOL)
├── dates/                    # Date utilities for COBOL (C + COBOL)
└── daily.sh                  # Main build orchestration script
```

## Build Commands

### Docker Images

Build all containers for a version (uses podman):
```bash
cd 4.0 && ./daily.sh
```

This builds three images: `gnucobol:4.0-builder`, `gnucobol:4.0-runtime`, `gnucobol:4.0-hello`

Build individual container:
```bash
cd 4.0/builder && podman build -t gnucobol:4.0-builder .
```

### Utility Libraries

Build CSV utilities:
```bash
cd csv && make
```

Build date utilities:
```bash
cd dates && make
```

Clean build artifacts:
```bash
make clean      # Remove .o files
make realclean  # Remove .o and .so files
```

## COBOL Compilation Commands

Compile COBOL to executable:
```bash
cobc -x program.cob
```

Compile COBOL to shared library:
```bash
cobc -b -O3 -o OUTPUT $(OBJECTS)
```

Compile COBOL source to object file (free format):
```bash
cobc -free -O3 -c source.cbl -o source.o
```

## GnuCOBOL 4.0 Bug Fix

The Dockerfiles are pinned to `alpine:3.20` for stability.

The builder Dockerfile includes a patch for a NULL pointer dereference bug in `libcob/common.c` (function `cob_setup_env`). At line 2652, `strrchr()` can return NULL if the path has no slash character, but line 2653 dereferences `p+1` without checking for NULL. The sed commands add the missing NULL check:

```c
// Before (buggy):
p = strrchr (binpath, SLASH_CHAR);
if (memcmp (p+1, "bin", 3) == 0
 || memcmp (p+1, "lib", 3) == 0) {

// After (fixed):
p = strrchr (binpath, SLASH_CHAR);
if (p && (memcmp (p+1, "bin", 3) == 0
 || memcmp (p+1, "lib", 3) == 0)) {
```

## Architecture

### Docker Container Hierarchy

1. **builder** - Full GnuCOBOL 4.0 build environment on Alpine
   - Contains gcc, make, all development headers
   - Builds and installs GnuCOBOL from tarball
   - Configure: `--with-indexed=db --with-json=cjson`

2. **runtime** - Minimal runtime environment
   - Copies only `/usr/local/lib/` and `cobcrun` from builder
   - Runtime dependencies: db, ncurses, gmp, libxml2, cjson, libstdc++

3. **hello** - Multi-stage test container
   - Uses builder to compile test.cob
   - Uses runtime for final image

### GnuCOBOL Compilation Model

GnuCOBOL uses source-to-source translation: COBOL → C → native binary via the system C compiler.

### Utility Libraries

Both `csv/` and `dates/` produce shared COBOL libraries (.so) from mixed C and COBOL sources. Pattern rules:
- `.cbl` files compiled with `cobc -free -O3 -c`
- `.c` files compiled with `gcc -std=c11 -O3 -fPIC -c`
