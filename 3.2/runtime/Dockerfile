FROM alpine:3.24.2

COPY --from=gnucobol:3.2.0-builder /usr/local/lib/ /usr/local/lib/
COPY --from=gnucobol:3.2.0-builder /usr/local/share/gnucobol/ /usr/local/share/gnucobol/
COPY --from=gnucobol:3.2.0-builder /usr/local/bin/cobcrun /usr/local/bin/cobcrun

RUN apk add --update-cache db ncurses gmp libxml2 cjson-dev libstdc++ libpanelw libintl \
 && rm -rf /var/cache/apk/* \
 && ldconfig /
