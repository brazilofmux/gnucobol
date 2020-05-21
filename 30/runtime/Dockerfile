FROM debian:stable-slim

COPY --from=gnucobol:3.0-builder /usr/local/lib/ /usr/local/lib/
COPY --from=gnucobol:3.0-builder /usr/local/bin/cobcrun /usr/local/bin/cobcrun

RUN apt-get update -y \
 && apt-get install libdb5.3 libncurses5 libgmp10 -y \
 && ldconfig
