FROM alpine:3.24.2

# GnuCOBOL 3.1.2, the GNU release. gnucobol-3.1.2.tar.gz is byte-identical to
# https://ftp.gnu.org/gnu/gnucobol/gnucobol-3.1.2.tar.gz, whose signature
# verifies as "Good signature from simonsobisch@gnu.org" (key
# B9459D0CA8A740B323235CDF13E96B53C005604E, in the GNU keyring) -- checked
# 2026-10-08. The sha256 below ties this build to exactly that file.
#
# One build fix, not a change to GnuCOBOL's behaviour: libxml2 >= 2.12 no longer
# pulls <libxml/parser.h> in through its other headers, so libcob's common.c and
# mlio.c lose the declarations they use. The include is added right after
# `#include <libxml/xmlwriter.h>`, inside the WITH_XML2 block, in each file that
# lacks it, and the build fails unless that anchor is found exactly once. The
# earlier Dockerfile inserted it at line 138 of common.c by number -- copied from
# 3.2's, where 138 is inside the libxml block; in 3.1.2 it is a blank line after
# "coblocal.h", outside any guard.
#
# -Wno-incompatible-pointer-types: libcob/mlio.c's libxml2 error callbacks are
# typed for the pre-2.12 API, which GCC >= 14 refuses by default.
#
# configure, make and make install are chained with && -- the earlier `;` let a
# failed configure or make through so long as make install succeeded.

WORKDIR /opt
COPY gnucobol-3.1.2.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache file gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
 && echo "f38c60b38a9e404bcba709b61b46f2bafa146b5f3dd90a94b2a70f5cea2f6297  gnucobol-3.1.2.tar.gz" | sha256sum -c - \
 && tar zxf gnucobol-3.1.2.tar.gz \
 && rm gnucobol-3.1.2.tar.gz \
 && for f in gnucobol-3.1.2/libcob/common.c gnucobol-3.1.2/libcob/mlio.c; do \
      grep -q '^#include <libxml/parser.h>$' "$f" && continue; \
      test "$(grep -c '^#include <libxml/xmlwriter.h>$' "$f")" = 1 || { echo "anchor not unique in $f"; exit 1; }; \
      sed -i '/^#include <libxml\/xmlwriter.h>$/a #include <libxml/parser.h>' "$f"; \
      test "$(grep -c '^#include <libxml/parser.h>$' "$f")" = 1 || { echo "parser.h not added once in $f"; exit 1; }; \
    done \
 && (cd gnucobol-3.1.2 \
     && ./configure CFLAGS="-std=gnu17 -O2 -Wno-error -Wno-incompatible-pointer-types" \
     && make -j$(nproc) \
     && make install) \
 && rm -rf gnucobol-3.1.2 \
 && ldconfig / \
 && mkdir -p /usr/local/share/gnucobol \
 && printf '%s\n' \
      'GnuCOBOL 3.1.2' \
      'source: https://ftp.gnu.org/gnu/gnucobol/gnucobol-3.1.2.tar.gz (the GNU release)' \
      'sha256: f38c60b38a9e404bcba709b61b46f2bafa146b5f3dd90a94b2a70f5cea2f6297' \
      'signed: simonsobisch@gnu.org, key B9459D0CA8A740B323235CDF13E96B53C005604E' \
      'local patches: none (build fix only: #include <libxml/parser.h> for libxml2 >= 2.12)' \
      > /usr/local/share/gnucobol/SOURCE \
 && cobc --version

LABEL org.opencontainers.image.title="gnucobol 3.1.2 builder" \
      org.opencontainers.image.version="3.1.2" \
      org.opencontainers.image.source="https://ftp.gnu.org/gnu/gnucobol/gnucobol-3.1.2.tar.gz"
