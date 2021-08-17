FROM debian:stable-slim

WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget gcc gettext make -y \
 && rm -rf /var/lib/apt/lists/* \
 && wget 'https://sourceforge.net/projects/gnucobol/files/gnucobol/3.1/gnucobol-3.1.2.tar.gz/download' -O gnucobol-3.1.2.tar.gz \
 && tar zxf gnucobol-3.1.2.tar.gz \
 && rm gnucobol-3.1.2.tar.gz \
 && (cd gnucobol-3.1.2;./configure;make -j12;make install) \
 && rm -rf gnucobol-3.1.2 \
 && ldconfig \
 && cobc --version
