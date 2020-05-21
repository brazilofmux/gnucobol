FROM debian:stable-slim as genesis

WORKDIR /opt

RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget autoconf automake autopoint bison flex clang gettext help2man libtool m4 make texinfo texlive subversion -y \
 && svn export https://svn.code.sf.net/p/open-cobol/code/trunk open-cobol-code

WORKDIR /opt/open-cobol-code
RUN CC=clang autoreconf -I m4 \
 && CC=clang ./configure --with-indexed=db \
 && CC=clang po/update_linguas.sh \
 && CC=clang make \
 && CC=clang make dist

FROM debian:stable-slim

COPY --from=genesis /opt/open-cobol-code/gnucobol-4.0-early-dev.tar.gz /opt/gnucobol-4.0-early-dev.tar.gz
WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget clang gettext make -y \
 && tar zxf gnucobol-4.0-early-dev.tar.gz

WORKDIR /opt/gnucobol-4.0-early-dev
RUN CC=clang ./configure --with-indexed=db \
 && CC=clang make \
 && CC=clang make install \
 && ldconfig \
 && cobc --version
