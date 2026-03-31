FROM alpine

WORKDIR /opt
COPY gnucobol-3.2.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache file gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
 && tar zxf gnucobol-3.2.tar.gz \
 && rm gnucobol-3.2.tar.gz \
 && sed -i '138i #include <libxml/parser.h>' gnucobol-3.2/libcob/common.c \
 && (cd gnucobol-3.2;./configure CFLAGS="-std=gnu17 -O2 -Wno-error -Wno-incompatible-pointer-types";make -j$(nproc);make install) \
 && rm -rf gnucobol-3.2 \
 && ldconfig / \
 && cobc --version
