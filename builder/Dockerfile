FROM debian:stable-slim as genesis

WORKDIR /opt

RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget autoconf automake autopoint bison flex gcc gettext help2man libtool m4 make texinfo texlive subversion -y \
 && svn export https://svn.code.sf.net/p/open-cobol/code/trunk open-cobol-code

WORKDIR /opt/open-cobol-code
RUN autoreconf -I m4 \
 && ./configure --with-indexed=db \
 && po/update_linguas.sh \
 && make \
 && make dist

FROM debian:stable-slim

COPY --from=genesis /opt/open-cobol-code/gnucobol-4.0-early-dev.tar.gz /opt/gnucobol-4.0-early-dev.tar.gz
WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget gcc gettext make -y \
 && tar zxf gnucobol-4.0-early-dev.tar.gz

WORKDIR /opt/gnucobol-4.0-early-dev
RUN ./configure --with-indexed=db \
 && make \
 && make install \
 && ldconfig \
 && cobc --version
