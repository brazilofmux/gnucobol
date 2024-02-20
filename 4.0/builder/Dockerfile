FROM alpine

WORKDIR /opt
COPY gnucobol-4.0-early-dev.tar.gz .
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache wget gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
# && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-trunk/artifacts/gnucobol-4.0-early-dev.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-4.0-early-dev.tar.gz \
 && tar zxf gnucobol-4.0-early-dev.tar.gz \
 && rm gnucobol-4.0-early-dev.tar.gz \
 && (cd gnucobol-4.0-early-dev;./configure --with-indexed=db --with-json=cjson;make -j12;make install) \
 && rm -rf gnucobol-4.0-early-dev \
 && ldconfig / \
 && cobc --version
