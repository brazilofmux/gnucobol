FROM alpine

WORKDIR /opt
RUN apk add --update-cache db-dev ncurses-dev gmp-dev libxml2-dev cjson-dev \
 && apk add --update-cache wget gcc libc-dev gettext make \
 && rm -rf /var/cache/apt/* \
 && wget 'https://sourceforge.net/projects/gnucobol/files/gnucobol/3.2/gnucobol-3.2.tar.gz/download' -O gnucobol-3.2.tar.gz \
 && tar zxf gnucobol-3.2.tar.gz \
 && rm gnucobol-3.2.tar.gz \
 && (cd gnucobol-3.2;./configure;make -j12;make install) \
 && rm -rf gnucobol-3.2 \
 && ldconfig / \
 && cobc --version
