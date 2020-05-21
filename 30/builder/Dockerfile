FROM debian:stable-slim

WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev -y \
 && apt-get install wget gcc gettext make -y \
 && wget 'https://sourceforge.net/projects/open-cobol/files/gnucobol/3.0/gnucobol-3.0-rc1.tar.gz/download' -O gnucobol-3.0-rc1.tar.gz \
 && tar zxf gnucobol-3.0-rc1.tar.gz

WORKDIR /opt/gnucobol-3.0-rc1
RUN ./configure \
 && make \
 && make install \
 && ldconfig \
 && cobc --version
