FROM alpine

WORKDIR /opt
RUN apk add --update-cache db-dev ncurses-dev gmp-dev wget gcc libc-dev gettext make \
 && rm -rf /var/cache/apk/* \
 && wget 'https://sourceforge.net/projects/open-cobol/files/gnucobol/3.0/gnucobol-3.0-rc1.tar.gz/download' -O gnucobol-3.0-rc1.tar.gz \
 && tar zxf gnucobol-3.0-rc1.tar.gz \
 && rm gnucobol-3.0-rc1.tar.gz \
 && (cd gnucobol-3.0-rc1;./configure;make -j12;make install) \
 && rm -rf gnucobol-3.0-rc1 \
 && ldconfig / \
 && cobc --version
