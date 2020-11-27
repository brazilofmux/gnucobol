FROM debian:stable-slim

WORKDIR /opt
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget gcc gettext make -y \
 && rm -rf /var/lib/apt/lists/* \
 && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-3-x/artifacts/gnucobol-3.1-1-dev.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-3.1-dev.tar.gz \
 && tar zxf gnucobol-3.1-dev.tar.gz \
 && rm gnucobol-3.1-dev.tar.gz \
 && (cd gnucobol-3.1-dev;./configure;make -j12;make install) \
 && rm -rf gnucobol-3.1-dev \
 && ldconfig \
 && cobc --version
