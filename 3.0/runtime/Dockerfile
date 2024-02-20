FROM alpine

COPY --from=gnucobol:3.0-builder /usr/local/lib/ /usr/local/lib/
COPY --from=gnucobol:3.0-builder /usr/local/bin/cobcrun /usr/local/bin/cobcrun

RUN apk add --update-cache db ncurses gmp \
 && rm -rf /var/cache/apk/* \
 && ldconfig /
