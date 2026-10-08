FROM alpine

# GnuCOBOL 3.3-dev, branches/gnucobol-3.x at SVN r5729 (2026-10-06), the
# branch head when this was made. Vendored as a `git archive` of the OCamlPro
# GitHub mirror's commit 91d1bd5ac46f819b8bd003113bdb55f002620d77, which carries
# r5729's change and message verbatim -- pristine source, no generated files,
# fetched once rather than from SourceForge at build time.
#
# Built from the repository rather than a `make dist` tarball: dist wants the
# PDF manual, i.e. a TeX installation, only to package source we already have.
# So the tree is bootstrapped here, which is why autotools are in the image.
#
# Two build-environment workarounds, neither a change to GnuCOBOL's code:
#  -Wno-incompatible-pointer-types: libcob/mlio.c passes callbacks typed
#     `void (*)(void *, xmlError *)` where libxml2 >= 2.12 wants `const
#     xmlError *`, and GCC >= 14 makes that an error by default.
#  AWK=gawk: doc/cobcinfo.sh uses the regex `\$@{envvar:-?default@}`, which
#     BusyBox awk (Alpine's default) rejects; GNU awk accepts it.

WORKDIR /opt
COPY gnucobol-3.3-dev-r5729.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache g++ gcc libc-dev gettext gettext-dev make \
        autoconf automake libtool bison flex gawk texinfo help2man perl \
 && rm -rf /var/cache/apk/* \
 && mkdir gnucobol && tar xzf gnucobol-3.3-dev-r5729.tar.gz -C gnucobol \
 && rm gnucobol-3.3-dev-r5729.tar.gz \
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
      'GnuCOBOL 3.3-dev' \
      'source: svn://svn.code.sf.net/p/gnucobol/code/branches/gnucobol-3.x r5729 (2026-10-06)' \
      'git:    https://github.com/OCamlPro/gnucobol 91d1bd5ac46f819b8bd003113bdb55f002620d77' \
      'local patches: none' \
      > /usr/local/share/gnucobol/SOURCE \
 && cobc --version

LABEL org.opencontainers.image.title="gnucobol 3.3-dev builder" \
      org.opencontainers.image.version="3.3-dev r5729" \
      org.opencontainers.image.revision="91d1bd5ac46f819b8bd003113bdb55f002620d77" \
      org.opencontainers.image.source="https://github.com/OCamlPro/gnucobol/tree/gnucobol-3.x"
