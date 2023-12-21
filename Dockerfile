FROM alpine:3.9.2
RUN apk add --no-cache build-base nasm
COPY Makefile .
COPY server-linux.asm .
RUN make build-linux

FROM scratch
COPY --from=0 server server
ENTRYPOINT ["/server"]
