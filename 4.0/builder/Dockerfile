FROM debian:stable-slim

WORKDIR /opt
COPY gnucobol.patch .
RUN apt-get update -y \
 && apt-get install libdb-dev libncurses5-dev libgmp-dev libxml2-dev libcjson-dev -y \
 && apt-get install wget gcc gettext make patch makepatch -y \
 && rm -rf /var/lib/apt/lists/* \
 && wget 'https://ci.appveyor.com/api/projects/GitMensch/gnucobol-trunk/artifacts/gnucobol-4.0-early-dev.tar.gz?job=Image:%20Ubuntu1804' -O gnucobol-4.0-early-dev.tar.gz \
 && tar zxf gnucobol-4.0-early-dev.tar.gz \
 && rm gnucobol-4.0-early-dev.tar.gz \
 && (cd gnucobol-4.0-early-dev;patch -p1 < /opt/gnucobol-2.patch;./configure --with-indexed=db --with-json=cjson;make -j12;make install) \
 && rm -rf gnucobol-4.0-early-dev \
 && rm /opt/gnucobol.patch \
 && ldconfig \
 && cobc --version
