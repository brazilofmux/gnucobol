FROM debian:stable-slim

WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev -y \
 && apt-get install wget gcc gettext make -y \
 && rm -rf /var/lib/apt/lists/* \
 && wget 'https://sourceforge.net/projects/open-cobol/files/gnucobol/3.0/gnucobol-3.0-rc1.tar.gz/download' -O gnucobol-3.0-rc1.tar.gz \
 && tar zxf gnucobol-3.0-rc1.tar.gz \
 && rm gnucobol-3.0-rc1.tar.gz \
 && (cd gnucobol-3.0-rc1;./configure;make;make install) \
 && rm -rf gnucobol-3.0-rc1 \
 && ldconfig \
 && cobc --version
