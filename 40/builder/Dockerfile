FROM debian:stable-slim

WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget gcc gettext make -y \
 && rm -rf /var/lib/apt/lists/* \
 && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-trunk/artifacts/gnucobol-4.0-early-dev.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-4.0-early-dev.tar.gz \
 && tar zxf gnucobol-4.0-early-dev.tar.gz \
 && rm gnucobol-4.0-early-dev.tar.gz

WORKDIR /opt/gnucobol-4.0-early-dev
RUN ./configure --with-indexed=db \
 && make \
 && make install \
 && ldconfig \
 && cobc --version
