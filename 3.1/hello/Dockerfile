FROM gnucobol:3.1-builder AS builder

WORKDIR /root
COPY test.cob .
RUN cobc -x test.cob

FROM gnucobol:3.1-runtime
COPY --from=builder /root/test .
CMD ["./test"]
