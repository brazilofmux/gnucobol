FROM alpine

WORKDIR /opt
COPY gnucobol-3.0-rc1.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev file gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
 && tar zxf gnucobol-3.0-rc1.tar.gz \
 && rm gnucobol-3.0-rc1.tar.gz \
 && (cd gnucobol-3.0-rc1;./configure CFLAGS="-std=gnu17 -O2 -Wno-error -Wno-incompatible-pointer-types";make -j$(nproc);make install) \
 && rm -rf gnucobol-3.0-rc1 \
 && ldconfig / \
 && cobc --version
