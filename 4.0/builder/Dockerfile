FROM alpine

WORKDIR /opt
COPY gnucobol-4.0-early-dev.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache wget g++ gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
# && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-trunk/artifacts/gnucobol-4.0.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-4.0.tar.gz \
 && tar zxf gnucobol-4.0-early-dev.tar.gz \
 && rm gnucobol-4.0-early-dev.tar.gz \
 && sed -i '2653c\            if (p && (memcmp (p+1, "bin", 3) == 0' gnucobol-4.0-early-dev/libcob/common.c \
 && sed -i '2654c\             || memcmp (p+1, "lib", 3) == 0)) {' gnucobol-4.0-early-dev/libcob/common.c \
 && (cd gnucobol-4.0-early-dev;./configure CFLAGS="-std=gnu17 -O2 -Wno-error -Wno-incompatible-pointer-types" --with-indexed=db --with-json=cjson;make -j$(nproc);make install) \
 && rm -rf gnucobol-4.0-early-dev \
 && ldconfig / \
 && cobc --version
