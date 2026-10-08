FROM alpine

# GnuCOBOL 4.0-early-dev, trunk at SVN r5725 (2026-10-05), the trunk head when
# this was made. Vendored as a `git archive` of the OCamlPro GitHub mirror's
# commit 72ab9a75187e059fda11386a99188e5491defd3a (r5725, "Various WIN32
# fixes") -- pristine source, fetched once rather than from SourceForge at
# build time. ../../4.0 is the older oracle (r5627, packaged 2025-12-08) and
# is left as it is, so the tests that were measured against it still can be.
#
# Built from the repository rather than a `make dist` tarball (dist wants the
# PDF manual, i.e. TeX), so the tree is bootstrapped here.
#
# Build-environment workarounds, as for 3.3: -Wno-incompatible-pointer-types
# (libcob/mlio.c's libxml2 callbacks under GCC >= 14) and AWK=gawk
# (doc/cobcinfo.sh's regex, which BusyBox awk rejects).
#
# ONE LOCAL PATCH to GnuCOBOL's code, the same one ../../4.0 carries:
# libcob/common.c's exec-path detection does `p = strrchr (binpath, ...)` and
# then `memcmp (p+1, "bin", 3)` with no check that p is not NULL. Still present
# at r5725. Applied by matching the text, not a line number, and the build
# fails if either line is not found exactly once -- a moved line must not turn
# the guard into a silent no-op.

WORKDIR /opt
COPY gnucobol-4.0-early-dev-r5725.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache g++ gcc libc-dev gettext gettext-dev make \
        autoconf automake libtool bison flex gawk texinfo help2man perl \
 && rm -rf /var/cache/apk/* \
 && mkdir gnucobol && tar xzf gnucobol-4.0-early-dev-r5725.tar.gz -C gnucobol \
 && rm gnucobol-4.0-early-dev-r5725.tar.gz \
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
      'GnuCOBOL 4.0-early-dev' \
      'source: svn://svn.code.sf.net/p/gnucobol/code/trunk r5725 (2026-10-05)' \
      'git:    https://github.com/OCamlPro/gnucobol 72ab9a75187e059fda11386a99188e5491defd3a' \
      'local patches: libcob/common.c NULL guard on p before memcmp (p+1, "bin"/"lib")' \
      > /usr/local/share/gnucobol/SOURCE \
 && cobc --version

LABEL org.opencontainers.image.title="gnucobol 4.0-early-dev (trunk) builder" \
      org.opencontainers.image.version="4.0-early-dev r5725" \
      org.opencontainers.image.revision="72ab9a75187e059fda11386a99188e5491defd3a" \
      org.opencontainers.image.source="https://github.com/OCamlPro/gnucobol/tree/master"
