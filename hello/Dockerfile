FROM gnucobol:builder AS builder

WORKDIR /root
COPY test.cob .
RUN cobc -x test.cob

FROM gnucobol:runtime
COPY --from=builder /root/test .
CMD ["./test"]
