FROM alpine

WORKDIR /opt
COPY gnucobol-4.0.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache wget g++ gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
# && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-trunk/artifacts/gnucobol-4.0.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-4.0.tar.gz \
 && tar zxf gnucobol-4.0.tar.gz \
 && rm gnucobol-4.0.tar.gz \
 && sed -i 's/if (memcmp (p+1, "bin", 3) == 0/if (p \&\& (memcmp (p+1, "bin", 3) == 0/' gnucobol-4.0/libcob/common.c \
 && sed -i 's/ || memcmp (p+1, "lib", 3) == 0) {/ || memcmp (p+1, "lib", 3) == 0)) {/' gnucobol-4.0/libcob/common.c \
 && (cd gnucobol-4.0;./configure --with-indexed=db --with-json=cjson;make -j12;make install) \
 && rm -rf gnucobol-4.0 \
 && ldconfig / \
 && cobc --version
