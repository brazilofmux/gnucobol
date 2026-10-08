FROM alpine:3.24.2

# GnuCOBOL 3.3-dev, from branches/gnucobol-3.x at the SVN revision pinned in the ARGs
# below. ../../update.sh moves the pin: it exports a revision, vendors it as
# the tarball named here, and rewrites these ARG lines and the pinned tags in
# ../runtime and ../hello. Nothing else in this file names a revision.
#
# Built from the repository with bootstrap, not a `make dist` tarball: dist
# wants the PDF manual, i.e. a TeX installation, only to package source we
# already have.
#
# Build-environment workarounds, not changes to GnuCOBOL's code:
#  -Wno-incompatible-pointer-types: libcob/mlio.c's libxml2 error callbacks are
#     typed for the pre-2.12 API, which GCC >= 14 refuses by default.
#  AWK=gawk: doc/cobcinfo.sh's regex `\$@{envvar:-?default@}` is rejected by
#     BusyBox awk.

ARG GNUCOBOL_VERSION=3.3-dev
ARG GNUCOBOL_SVN=svn://svn.code.sf.net/p/gnucobol/code/branches/gnucobol-3.x
ARG GNUCOBOL_REV=5729
ARG GNUCOBOL_REV_DATE=2026-10-06
ARG GNUCOBOL_TARBALL=gnucobol-3.3-dev-r5729.tar.gz
ARG GNUCOBOL_SHA256=61570c0deabf741e73a17adbcb64d2d4e8c6fb6f5c4857de4e101cde6a343bce
ARG GNUCOBOL_ORIGIN="git archive of https://github.com/OCamlPro/gnucobol commit 91d1bd5ac46f819b8bd003113bdb55f002620d77, which is r5729"

WORKDIR /opt
COPY ${GNUCOBOL_TARBALL} .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache g++ gcc libc-dev gettext gettext-dev make \
        autoconf automake libtool bison flex gawk texinfo help2man perl \
 && rm -rf /var/cache/apk/* \
 && echo "${GNUCOBOL_SHA256}  ${GNUCOBOL_TARBALL}" | sha256sum -c - \
 && mkdir gnucobol && tar xzf "${GNUCOBOL_TARBALL}" -C gnucobol \
 && rm "${GNUCOBOL_TARBALL}" \
 && (cd gnucobol \
     && ./build_aux/bootstrap install \
     && ./configure CFLAGS="-std=gnu17 -O2 -Wno-error -Wno-incompatible-pointer-types" \
            --with-indexed=db --with-json=cjson \
     && make -j$(nproc) AWK=gawk \
     && make install AWK=gawk) \
 && rm -rf gnucobol \
 && ldconfig / \
 && mkdir -p /usr/local/share/gnucobol \
 && printf '%s\n' \
      "GnuCOBOL ${GNUCOBOL_VERSION}" \
      "source: ${GNUCOBOL_SVN} r${GNUCOBOL_REV} (${GNUCOBOL_REV_DATE})" \
      "from:   ${GNUCOBOL_ORIGIN}" \
      "sha256: ${GNUCOBOL_SHA256}" \
      "local patches: none" \
      > /usr/local/share/gnucobol/SOURCE \
 && cobc --version

LABEL org.opencontainers.image.title="gnucobol ${GNUCOBOL_VERSION} builder" \
      org.opencontainers.image.version="${GNUCOBOL_VERSION} r${GNUCOBOL_REV}" \
      org.opencontainers.image.source="${GNUCOBOL_SVN}"
