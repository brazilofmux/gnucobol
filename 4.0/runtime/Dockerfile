FROM alpine

COPY --from=gnucobol:4.0-builder /usr/local/lib/ /usr/local/lib/
COPY --from=gnucobol:4.0-builder /usr/local/bin/cobcrun /usr/local/bin/cobcrun

RUN apk add --update-cache db ncurses gmp libxml2 cjson-dev \
 && rm -rf /var/cache/apk/* \
 && ldconfig /
