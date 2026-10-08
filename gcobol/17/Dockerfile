# gcobol: GCC's COBOL front end, GCC 17 (a development snapshot) -- the
# second oracle for ~/slow-32/cobol's harness, superseding ../15.
#
# Why 17 and not 15: Simon Sobisch (2026-10-08) -- no release before GCC 17
# gets COBOL backports, and there were a great many fixes since 15, so a
# disagreement measured against 15 may simply be fixed. The "66
# disagreements" in slow-32's docs/oracles.md were measured against 15.
#
# Built by COBOLworx (Symas), who maintain the COBOL front end: build 4556,
# GCC 17.0.0 snapshot 2026-10-06 at GCC commit 7afc59. x86_64 ONLY -- there is
# no aarch64 package -- so this image is amd64-only: build it on an amd64
# builder, run it natively on an x86_64 host (kagura), or under emulation.
#
# The package lives in a rolling "current/" directory that keeps only the
# latest few builds, so this URL will eventually 404. The sha256 pins exactly
# what was tested; the image in ECR is the archive, not this URL.
#
# One image compiles and runs, as ../15 does: the programs need libgcobol at
# run time. `gcobol` is put on the PATH (the package names it gcobol-17) and
# /opt/gcobol's libraries registered, so the harness can use it unchanged.
FROM debian:13

ARG DEB=gcobol-17_17.0.0.20261006-7afc59-debian13-4556_x86_64.deb
ARG URL=https://cobolworx.com/downloads/packages/current/debian-13/${DEB}
ARG SHA256=8a43348e1699eea060a253da2dbba22b650199dbb93159d1f063d756f0fe1099

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && curl -fsSL --retry 3 -o /tmp/${DEB} "${URL}" \
 && echo "${SHA256}  /tmp/${DEB}" | sha256sum -c - \
 && apt-get install -y --no-install-recommends /tmp/${DEB} \
 && rm -f /tmp/${DEB} \
 && apt-get purge -y curl && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /opt/gcobol/bin/gcobol-17 /usr/local/bin/gcobol \
 && ln -s /opt/gcobol/bin/gcobc-17  /usr/local/bin/gcobc \
 && printf '/opt/gcobol/lib64\n/opt/gcobol/lib\n' > /etc/ld.so.conf.d/gcobol.conf \
 && ldconfig \
 && mkdir -p /usr/local/share/gcobol \
 && printf '%s\n' \
      'gcobol 17.0.0, COBOLworx build 4556' \
      'gcc snapshot 2026-10-06, gcc commit 7afc59' \
      "package: ${DEB}" \
      "sha256:  ${SHA256}" \
      > /usr/local/share/gcobol/SOURCE \
 && gcobol --version

LABEL org.opencontainers.image.title="gcobol 17 (GCC COBOL front end, COBOLworx build 4556)" \
      org.opencontainers.image.version="17.0.0.20261006-7afc59 build 4556" \
      org.opencontainers.image.source="https://cobolworx.com/downloads.php"

WORKDIR /work
