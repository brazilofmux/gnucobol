FROM alpine:3.24.2

# GnuCOBOL 4.0-early-dev, from trunk at the SVN revision pinned in the ARGs
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
#
# ONE LOCAL PATCH to GnuCOBOL's code: libcob/common.c's exec-path detection
# does `p = strrchr (binpath, ...)` and then `memcmp (p+1, "bin", 3)` with no
# check that p is not NULL. Applied by matching the text, never a line number;
# the build fails unless each line is found exactly once. If upstream fixes it,
# the anchor vanishes and this build stops -- update.sh checks for that first.

ARG GNUCOBOL_VERSION=4.0-early-dev
ARG GNUCOBOL_SVN=svn://svn.code.sf.net/p/gnucobol/code/trunk
ARG GNUCOBOL_REV=5725
ARG GNUCOBOL_REV_DATE=2026-10-05
ARG GNUCOBOL_TARBALL=gnucobol-4.0-early-dev-r5725.tar.gz
ARG GNUCOBOL_SHA256=62cdaefa530f317a5c9c1a503b219f35d5cfcf42baae834d16462e9ce9ba4a20
ARG GNUCOBOL_ORIGIN="git archive of https://github.com/OCamlPro/gnucobol commit 72ab9a75187e059fda11386a99188e5491defd3a, which is r5725"

WORKDIR /opt
COPY ${GNUCOBOL_TARBALL} .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache g++ gcc libc-dev gettext gettext-dev make \
        autoconf automake libtool bison flex gawk texinfo help2man perl \
 && rm -rf /var/cache/apk/* \
 && echo "${GNUCOBOL_SHA256}  ${GNUCOBOL_TARBALL}" | sha256sum -c - \
 && mkdir gnucobol && tar xzf "${GNUCOBOL_TARBALL}" -C gnucobol \
 && rm "${GNUCOBOL_TARBALL}" \
 && f=gnucobol/libcob/common.c \
 && test "$(grep -c 'if (memcmp (p+1, "bin", 3) == 0$' $f)" = 1 \
 && test "$(grep -c '|| memcmp (p+1, "lib", 3) == 0) {$' $f)" = 1 \
 && sed -i 's/if (memcmp (p+1, "bin", 3) == 0$/if (p \&\& (memcmp (p+1, "bin", 3) == 0/' $f \
 && sed -i 's/|| memcmp (p+1, "lib", 3) == 0) {$/|| memcmp (p+1, "lib", 3) == 0)) {/' $f \
 && test "$(grep -c 'if (p && (memcmp (p+1, "bin", 3) == 0$' $f)" = 1 \
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
      "local patches: libcob/common.c NULL guard on p before memcmp (p+1, \"bin\"/\"lib\")" \
      > /usr/local/share/gnucobol/SOURCE \
 && cobc --version

LABEL org.opencontainers.image.title="gnucobol ${GNUCOBOL_VERSION} builder" \
      org.opencontainers.image.version="${GNUCOBOL_VERSION} r${GNUCOBOL_REV}" \
      org.opencontainers.image.source="${GNUCOBOL_SVN}"
