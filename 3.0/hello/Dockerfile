FROM gnucobol:3.0-builder AS builder

WORKDIR /root
COPY test.cob .
RUN cobc -x test.cob

FROM gnucobol:3.0-runtime
COPY --from=builder /root/test .
CMD ["./test"]
