FROM debian:stable-slim

WORKDIR /opt
COPY gnucobol-4.0-early-dev.tar.gz .
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget clang gettext make -y \
 && tar zxf gnucobol-4.0-early-dev.tar.gz

WORKDIR gnucobol-4.0-early-dev
RUN CC=clang ./configure --with-indexed=db \
 && CC=clang make \
 && CC=clang make install \
 && ldconfig \
 && cobc --version
